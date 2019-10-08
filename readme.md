RLCraft Minecraft Server (in a docker container)
================================================

Recommended Usage
-----------------

If you want to keep your server arround it is advised that you additionally mount the /server/world and /server/backup folders into a volume.

1. Create the volume  
`docker volume create rlcraft-data-vol`

2. Start the container  
`docker run -p --mount source=rlcraft-data-vol,target=/server -e EULA=TRUE -p 25565:25565 othrayte/rlcraft-server`
