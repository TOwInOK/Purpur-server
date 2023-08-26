FROM eclipse-temurin:19-jre AS build
RUN apt-get update && \
    apt-get install -y curl jq gosu && \
    rm -rf /var/lib/apt/lists/*

LABEL Minecraft PurpurMC server

ARG version=1.20.1

WORKDIR /opt/minecraft
COPY ./getminecraft.sh /
RUN chmod +x /getminecraft.sh
RUN /getminecraft.sh $version

#Running environment
FROM eclipse-temurin:19-jre AS runtime
ARG TARGETARCH
# Install gosu
RUN set -eux; \
 apt-get update && \
 apt-get install -y gosu && \
 rm -rf /var/lib/apt/lists/* && \
 gosu nobody true

# Working directory
WORKDIR /data
COPY --from=build /opt/minecraft/purpur.jar /opt/minecraft/purpur.jar

#Rcon install
ARG TARGETARCH
ARG RCON_CLI_VER=1.6.0
ADD https://github.com/itzg/rcon-cli/releases/download/${RCON_CLI_VER}/rcon-cli_${RCON_CLI_VER}_linux_${TARGETARCH}.tar.gz /tmp/rcon-cli.tgz
RUN mkdir -p /tmp/rcon-cli && \
    tar -x -C /tmp/rcon-cli -f /tmp/rcon-cli.tgz && \
    mv /tmp/rcon-cli/rcon-cli /usr/local/bin/ && \
    rm -rf /tmp/rcon-cli /tmp/rcon-cli.tgz

# Volumes for the external data (Server, World, Config...)
VOLUME "/data"

# Main Port
EXPOSE 25565/tcp

# Memory size
ARG memory_size=1G
ENV MEMORYSIZE=${memory_size}

# Pufferfish flag
ARG puffer_flags="--add-modules=jdk.incubator.vector"
ENV PUFFERFISHFLAGS=${puffer_flags}

# Override flags if you are have it.
ARG override_flags=""
ENV OVERRIDEFLAGS=${override_flags}

# Default Aikar's flags
ARG java_flags="-Dterminal.jline=false -Dterminal.ansi=true -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dcom.mojang.eula.agree=true"
ENV JAVAFLAGS=${java_flags}

# Set Spigot Flags
ARG spigot_flags=""
ENV SPIGOT_FLAGS=${spigot_flags}

# Set PaperMC Flags
ARG paper_flags="--nojline"
ENV PAPER_FLAGS=${paper_flags}

# Set Purpur Flags
ARG purpur_flags=""
ENV PURPUR_FLAGS=${purpur_flags}

WORKDIR /data

COPY /docker-entrypoint.sh /opt/minecraft
RUN chmod +x /opt/minecraft/docker-entrypoint.sh

# Entrypoint
ENTRYPOINT ["/opt/minecraft/docker-entrypoint.sh"]
