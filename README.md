# ContainerCarpetServer
Containerized Servers for Technical Minecraft

## Introduction

This project aims to provide a system for running a Fabric Minecraft 
server(with Carpet!) inside of a Podman(or Docker) container for improved 
security.

The project is developed for and tested with Podman, but Docker likely works 
near identically. OpenRC currently the only supported init system, but 
it should not be too hard to write a service script for SystemD. Feel free to 
submit a PR if you write a script for SystemD to use with this project.

This branch aims to support the latest version of Minecraft, but it should not 
be hard to make this work with older versions as well. Feel free to submit a 
PR to support other versions.

Current Minecraft Version: 1.19.0

## Installation

### Prerequisites

* Linux
* Podman
* OpenRC

### System Setup

1. Create a new user.
For example: 
<br/>`useradd -m -G <GROUPS> -s /bin/bash <USERNAME>`<br/>
Include group `wheel` to allow temporary root access.

2. Login as the new user.

3. Create a directory to store server persistent server files in. For example: 
</br>`mkdir ~/server/`</br>

### Installation

1. While logged in as a non-root user, pull the Container Image from DockerHub. 
<br/>`podman pull docker.io/thecydonian/container_carpet_server:1.19.0`<br/>

2. Run the Container with the following command. Replace `<VOLUME PATH>` with 
the absolute path to your persistent server files directory 
(e.g. `/home/minecraft/server/`).
```
podman container run \
          --tty \
          --interactive \
          --volume <VOLUME PATH>:/server/:U,Z \
          --publish 25565:25565/tcp \
          container_carpet_server:1.19.0
```

3. After populating your volume directory by installing Fabric, Carpet, and 
Lithium, the container should fail since you have not agreed to the EULA yet. 
Run `podman unshare nvim <VOLUME PATH>/eula.txt` or replace nvim with your 
preferred editor. Once the file is open, replace `eula=false` with `eula=true`. 
Note: Since the volume directory is now owned by a non-root user inside the 
container, to modify contained files, any command must follow `podman unshare` 
to run it in the correct namespace.

4. Run `podman start -l` to restart the container. It should now run properly, 
and you should be able to connect to the server on the host system's IP address 
on port 25565.

### OpenRC Setup

To automate starting and stopping the server, we can use OpenRC. Setup is simple.

1. Clone this repository: 
<br/>`git clone https://github.com/theCydonian/ContainerCarpetServer.git`</br>

2. Enter the repository: `cd ContainerCarpetServer/`

3. Modify the init script where necessary. Set the `volume_path` variable to 
the absolute path to your volume directory and set the `command_user` 
variable to be your user. You can edit the file with:
<br/>`vi openrc/container-carpet-server`</br>

4. Copy init script to `/etc/init.d/` as root. This can be accomplished by 
running: 
<br/>`sudo cp openrc/container-carpet-server /etc/init.d/`

5. Start the service.
<br/>`sudo rc-service container-carpet-server start`<br/>

6. Set this service to start on boot.
<br/>`sudo rc-update add container-carpet-server default`<br/>

## Backups

Keeping server backups is usually a good idea in case anything goes wrong. We 
are going to use cronie to perform daily backups.

For example, to `/etc/crontab`, simply add the following line:

```
  00 00 *  *  *  /home/minecraft/backup.sh
```

At midnight every day this script the backup script will run as root.

Change the user to the user you run the container under, and change the script 
location to where you store the backup script. You can also change the 
frequency of backups. The <i><a href="#UL">Useful Links</a></i> section of this 
README has information on how to use the `/etc/crontab` file.

Here is an example `backup.sh`:

```
#!/bin/bash
date=$(date +"%Y%m%d%H%M%S%3N")
tar -czf /path/to/backup/dir/${date}.tar.gz \
--directory=/path/to/volume/dir/ .
```

## Useful Tips

1. When configuring your server, run commands under `podman unshare` 
for the correct permissions.
2. You can attach to your running server container with `podman attach -l`.
3. You can detach from a running container with `ctrl+p` then `ctrl+q`.

## <span id="UL">Useful Links</span>

* [About Podman](https://docs.podman.io/en/latest/index.html)
* [Using OpenRC](https://wiki.gentoo.org/wiki/OpenRC)
* [Using cronie](https://docs.rockylinux.org/guides/automation/cronie/)
* [Using Carpet Mod](https://youtu.be/Lt-ooRGpLz4)
* [Server configuration](https://minecraft.fandom.com/wiki/Server.properties)

## Projects Used
* [Fabric](https://fabricmc.net/)
* [Carpet Mod](https://github.com/gnembon/fabric-carpet)
* [Lithium](https://github.com/CaffeineMC/lithium-fabric)
