#!/bin/sh

set -e

fabric_url="https://meta.fabricmc.net/v2/versions/loader/1.19.2/0.14.9/0.11.0/server/jar"
fabric_jar="fabric-server-mc.1.19.2-loader.0.14.9-launcher.0.11.0.jar" 

carpet_url="https://github.com/gnembon/fabric-carpet/releases/download/1.4.83/fabric-carpet-1.19.1-1.4.83+v220727.jar"

lithium_url="https://github.com/CaffeineMC/lithium-fabric/releases/download/mc1.19.2-0.8.3/lithium-fabric-mc1.19.2-0.8.3.jar"

# Server Installation
if [ -z "$(ls -A /server/)" ]; then
  cd /server/
  curl -OJ $fabric_url

  mkdir /server/mods/
  cd /server/mods/
  curl -LOJ $carpet_url 
  curl -LOJ $lithium_url

  cd /server/
  java -Xmx2G -jar $fabric_jar nogui
fi

# Server Execution
cd /server/
if [ -f /server/startup.sh ]; then
  /server/startup.sh
else
  exec java -Xmx2G -jar $fabric_jar nogui
fi
