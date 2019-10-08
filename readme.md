Barebones Modded Minecraft Server (in a docker container)
=========================================================

Recommended Usage
-----------------

If you want to keep your server around it is advised that you additionally mount at least the /server/world and /server/backup folders into a volume.

1. Create the volume  
`docker volume create minecraft-server-vol`

2. Start the container  
`docker run -p --mount source=minecraft-server-vol,target=/server -e EULA=TRUE -p 25565:25565 othrayte/minecraft-server`
