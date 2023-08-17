FROM openjdk:17-slim AS build

ARG TARGETARCH

ENV PURPURSPIGOT_CI_URL=https://api.purpurmc.org/v2/purpur/1.20.1/latest/download
ENV RCON_URL=https://github.com/itzg/rcon-cli/releases/download/1.6.2/rcon-cli_1.6.2_linux_${TARGETARCH}.tar.gz

WORKDIR /opt/minecraft

# Download purpurclip
ADD ${PURPURSPIGOT_CI_URL} purpur.jar

# Install and run rcon
ADD ${RCON_URL} /tmp/rcon-cli.tgz
RUN tar -x -C /usr/local/bin -f /tmp/rcon-cli.tgz rcon-cli && \
  rm /tmp/rcon-cli.tgz

FROM openjdk:17-slim AS runtime

# Working directory
WORKDIR /data

# Obtain runable jar from build stage
COPY --from=build /opt/minecraft/purpur.jar /opt/minecraft/purpur.jar
COPY --from=build /usr/local/bin/rcon-cli /usr/local/bin/rcon-cli

# Volumes for the external data (Server, World, Config...)
VOLUME "/data"

# Expose minecraft port
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Set memory size
ARG memory_size=1G
ENV MEMORYSIZE=$memory_size

#Set Puferfish Flags or other that is frist then -jar
ARG overade_flags="--add-modules=jdk.incubator.vector"
ENV OVERADEFLAGS=$overade_flags

# Set Java Flags
ARG java_flags="-Dterminal.jline=false -Dterminal.ansi=true -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dcom.mojang.eula.agree=true"
ENV JAVAFLAGS=$java_flags

WORKDIR /data

# Entrypoint with java optimisations
ENTRYPOINT /usr/local/openjdk-17/bin/java $OVERADEFLAGS -jar -Xms$MEMORYSIZE -Xmx$MEMORYSIZE $JAVAFLAGS /opt/minecraft/purpur.jar --nojline nogui
