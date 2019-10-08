#! /bin/bash

# Defaults
DEFAULT_JVM_XMX=1G
DEFAULT_JVM_XMS=1G

if [ ! -z "$MIGRATE" ]
then
	echo " **********************"
	echo " *  MIGRATING SERVER  *"
	echo " **********************"
    if [ -d "world" ]; then
        echo "Error: Migration requested but target already contains a world!"
        exit 1
    fi
    cp -R "$MIGRATE/world" ./world
    cp "$MIGRATE/eula.txt" "$MIGRATE/server.properties" "$MIGRATE/whitelist.json" "$MIGRATE/banned-ips.json" "$MIGRATE/banned-players.json" "$MIGRATE/ops.json" ./
fi

if [ ! -z "$MODPACK" ]
then
    CONFIG_URL=https://raw.githubusercontent.com/othrayte/docker-minecraft-server/master/modpacks/$MODPACK.config
fi

if [ ! -z "$CONFIG_URL" ]
then
    CONFIG=$(curl -s $CONFIG_URL)
    echo -e "Using the following configuration:\n$CONFIG\n\n"
    eval "$CONFIG"
fi

if [ -z "$MODPACK_URL" ] &&  [ ! -z "${CURSEFORGE_PROJECTID}" ] && [ ! -z "${CURSEFORGE_FILEID}" ]
then
    MODPACK_URL=$(curl https://addons-ecs.forgesvc.net/api/v2/addon/${CURSEFORGE_PROJECTID}/file/${CURSEFORGE_FILEID}/download-url)
fi

if [ -z "$FORGE_URL" ] &&  [ ! -z "${MINECRAFT_VER}" ] && [ ! -z "${FORGE_VER}" ]
then
    FORGE_URL=https://files.minecraftforge.net/maven/net/minecraftforge/forge/${MINECRAFT_VER}-${FORGE_VER}/forge-${MINECRAFT_VER}-${FORGE_VER}-installer.jar
fi

# Check EULA
if [ ! -e eula.txt ]; then
    if [ "$EULA" != "" ]; then
        echo "# Generated via Docker on $(date)" > eula.txt
        echo "eula=$EULA" >> eula.txt
    else
        echo 'ERROR: The minecraft EULA must be accepted before the server can be started.\n'
        echo "By setting the enviroment variable EULA to TRUE you are indicating your agreement to the EULA at https://account.mojang.com/documents/minecraft_eula."
        exit 1
    fi
fi

# Get Forge
if [ ! -z "$FORGE_URL" ] && [ ! -f "forge-server.jar" ]; then
	echo " **********************"
	echo " *  INSTALLING FORGE  *"
	echo " **********************"
    wget "$FORGE_URL" -O forge-installer.jar
    java -jar forge-installer.jar --installServer
    rm forge-installer.jar
    mv forge-*-universal.jar forge-server.jar
fi

# Get Modpack
if [ ! -z "$MODPACK_URL" ] && [ ! -d "mods" ]; then
	echo " ************************"
	echo " *  INSTALLING Modpack  *"
	echo " ************************"
	wget "$MODPACK_URL" -O modpack.zip
	unzip modpack.zip -d ziptmp
	mv ziptmp/*/* .
	rm -rf ziptmp modpack.zip
fi

echo " ************************"
echo " *  STARTING Minecraft  *"
echo " ************************"
java -Xmx${JVM_XMX:-$DEFAULT_JVM_XMX} -Xms${JVM_XMS:-$DEFAULT_JVM_XMS} -jar forge-server.jar nogui
