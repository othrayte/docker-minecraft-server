#! /bin/bash

# Defaults
DEFAULT_JVM_XMX=1G
DEFAULT_JVM_XMS=1G
MODPACK_ZIP_ROOT=/

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
if [ ! -f eula.txt ]; then
    if [ "$EULA" != "" ]; then
        echo "# Generated via Docker on $(date)" > eula.txt
        echo "eula=$EULA" >> eula.txt
    else
        echo 'ERROR: The minecraft EULA must be accepted before the server can be started.\n'
        echo "By setting the enviroment variable EULA to TRUE you are indicating your agreement to the EULA at https://account.mojang.com/documents/minecraft_eula."
        exit 1
    fi
fi

if [ ! -f "dms_server.jar" ]; then
    # Get Forge
    if [ ! -z "$FORGE_URL" ]; then
        echo " **********************"
        echo " *  INSTALLING FORGE  *"
        echo " **********************"
        wget "$FORGE_URL" -O forge-installer.jar
        java -jar forge-installer.jar --installServer
        rm forge-installer.jar
        ln -s forge-*-universal.jar dms_server.jar
    fi
    
    # Get Minecraft (vanilla)
    if [ ! -z "$MINECRAFT_SERVER_URL" ]; then
        echo " *******************************"
        echo " *  INSTALLING VANILLA SERVER  *"
        echo " *******************************"
        wget "$MINECRAFT_SERVER_URL" -O minecraft_server.jar
        ln -s minecraft_server.jar dms_server.jar
    fi
fi

# Get Modpack
if [ ! -z "$MODPACK_URL" ] && [ ! -d "mods" ]; then
    echo " ************************"
    echo " *  INSTALLING Modpack  *"
    echo " ************************"
    wget "$MODPACK_URL" -O modpack.zip
    unzip modpack.zip -d ziptmp
    mv ziptmp/$MODPACK_ZIP_ROOT/* .
    rm -rf ziptmp modpack.zip
fi

# Get additional mods
if [ ! -z "$ADDITIONAL_MODS" ]; then
    echo " *****************"
    echo " *  ADDING Mods  *"
    echo " *****************"
    for mod in $ADDITIONAL_MODS; do
        wget $mod --no-clobber -P ./mods
    done
fi

echo " ************************"
echo " *  STARTING Minecraft  *"
echo " ************************"
java -Xmx${JVM_XMX:-$DEFAULT_JVM_XMX} -Xms${JVM_XMS:-$DEFAULT_JVM_XMS} -jar dms_server.jar nogui
