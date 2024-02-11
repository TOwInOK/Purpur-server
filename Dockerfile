#Running environment
FROM eclipse-temurin:19-jre-alpine
ARG TARGETARCH

# Download and copy the gosu binary for arm64
RUN set -eux; \
    apk add --no-cache curl libstdc++ jq && \
    curl -sL https://github.com/tianon/gosu/releases/download/1.17/gosu-amd64 -o /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

#Download minecraft
LABEL Minecraft PurpurMC server

#default value
ARG version=1.20.4
ENV VERSION=${version}

WORKDIR /opt/minecraft
COPY ./getminecraft.sh /
RUN chmod +x /getminecraft.sh
RUN /getminecraft.sh

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
    rm -rf /tmp/rcon-cli /tmp/rcon-cli.tgz && \
    apk del curl

# Volumes for the external data (Server, World, Config...)
VOLUME "/data"

# Main Port
EXPOSE 25565/tcp

# Memory size
ARG memory_size=1G
ENV MEMORYSIZE=${memory_size}

# Pufferfish flag
ARG puffer_flags="--add-modules=jdk.incubator.vector"
ARG PUFFER_FLAGS=${puffer_flags}

# ZGC by default
ARG java_flags="-Djava.awt.headless=true -Dterminal.jline=false -Dterminal.ansi=true -XX:+UseZGC -XX:MaxGCPauseMillis=16 -XX:ActiveProcessorCount=8 -XX:+UseNUMA -XX:+AlwaysPreTouch -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:InitiatingHeapOccupancyPercent=20 -Dcom.mojang.eula.agree=true"
ENV JAVAFLAGS=${java_flags}

# Set Additional Flags
ARG add_flags='--nojline -C ./config/commands.yml -S ./config/spigot.yml -b ./config/bukkit.yml -c ./config/server.properties --pufferfish-settings ./config/pufferfish.yml --purpur-settings ./config/purpur.yml --paper-settings-directory ./config/paper/  -d "yyyy-MM-dd HH:mm:ss" --world-dir ./worlds/'
ENV ADD_FLAGS=${add_flags}


WORKDIR /data

COPY /docker-entrypoint.sh /opt/minecraft
RUN chmod +x /opt/minecraft/docker-entrypoint.sh

# Entrypoint
ENTRYPOINT ["/opt/minecraft/docker-entrypoint.sh"]
