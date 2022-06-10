#!/sbin/openrc-run

name="container-carpet-server"
description="Containerized fabric carpet minecraft server."

pidfolder="/run/containers/carpet_server/"
pidfile="/run/containers/carpet_server/${RC_SVCNAME}.pid"
cidfile="/run/containers/carpet_server/${RC_SVCNAME}.ctr-id"

volume_path="/home/minecraft/server/" # change to appropriate path
version="1.19.0"

command="/usr/bin/podman"
command_args="start"
stop_args="stop --cidfile ${cidfile}"

command_user="minecraft" # change to host user

depend() {
	want net
	after net.online
}

check_and_repair() {
    if [ ! -d ${pidfolder} ]; then
        mkdir --parents ${pidfolder}
    fi
    chown ${command_user}: ${pidfolder}
    
    if [ ! -f ${cidfile} ]; then
        repair
    else
        procs=$(runuser ${command_user} --command="/usr/bin/podman ps -aq --filter id=$(cat ${cidfile})")

        if [ ! "${procs}" ]; then 
            repair
        fi
    fi
}

repair() {
    if [ -f ${cidfile} ]; then
        rm ${cidfile}
    fi
    if [ -f ${pidfile} ]; then
        rm ${pidfile}
    fi
    run_command="/usr/bin/podman container run \
          --conmon-pidfile ${pidfile} \
          --cidfile ${cidfile} \
          --cgroups=no-conmon \
          --replace \
          --restart always \
          --detach \
          --tty \
          --interactive \
          --volume ${volume_path}:/server/:U,Z \
          --publish 25565:25565 \
          --name carpet-server \
          container_carpet_server:${version}"

    runuser ${command_user} --command="${run_command}"
}

start_pre() {
    # check for container existance
    # restart if not.
    check_and_repair
}

start() {
    ebegin "Starting container-carpet-server"

    runuser ${command_user} --command="${command} ${command_args} $(cat ${cidfile})"

    eend $?
}

stop() {
    ebegin "Stopping container-carpet-server"

    echo "stop" | socat EXEC:"podman attach b12175f68aaf27e1a530b6b8b760c25919d1290c807aabb10dc41a011c4d57e0",pty STDIN

    sleep 5

    procs=$(runuser ${command_user} --command="/usr/bin/podman ps -aq --filter id=$(cat ${cidfile})")

    if [ "${procs}" ]; then
        runuser ${command_user} --command="${command} ${stop_args}"
    fi

    eend $?
}
