Barebones Modded Minecraft Server (in a docker container)
=========================================================

Minimal Example
---------------
`docker run -e EULA=TRUE -e MODPACK=rlcraft/1.12.2-beta-2.7.0 -p othrayte/minecraft-server`

Recommended Usage
-----------------

If you want to keep your server around it is advised that you additionally mount at least the /server/world and /server/backup folders into a volume.

1. Create the volume  
`docker volume create minecraft-server-vol`

2. Start the container
`docker run --mount source=minecraft-server-vol,target=/server -e EULA=TRUE -e MODPACK=rlcraft/1.12.2-beta-2.7.0 -p 25565:25565 othrayte/minecraft-server`
