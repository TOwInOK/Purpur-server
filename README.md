# Minecraft Purpur Server Docker Image

This Docker image allows you to run a Minecraft Purpur server in a Docker container.

## Build

To build the Docker image, you can use the following command:

```bash
version: "3"

services:
  minecraft:
    image: "towinok/purpur-server:latest"
    restart: always
    container_name: "purpur"
    environment:
      MEMORYSIZE: "12G"
#ZGC by default :)
      JAVAFLAGS: >
        -Djava.awt.headless=true
        -Dterminal.jline=false
        -Dterminal.ansi=true
        -XX:+UseZGC
        -XX:ConcGCThreads=8
        -XX:MaxGCPauseMillis=20
        -XX:ActiveProcessorCount=8
        -XX:+UseNUMA
        -XX:+AlwaysPreTouch
        -XX:+UseStringDeduplication
        -XX:+ParallelRefProcEnabled
        -XX:+PerfDisableSharedMem
        -XX:InitiatingHeapOccupancyPercent=20
        -Dcom.mojang.eula.agree=true

    #if you need
    cpus: 8.0
    #if you need
    #MEMORYSIZE*1.20
    mem_limit: 14746M
    volumes:
      - "/path/to/purpur_data:/data:rw"
    ports:
      - "25565:25565/tcp"
    stdin_open: true
    tty: true
    depends_on:
      - purpur_db
      - purpur_adminer
    #if you use db
    healthcheck:
      test: ["CMD-SHELL", "nc -z -v -w5 purpur_db 3306"]
      interval: 30s
      timeout: 10s
      retries: 5

# Define purpur_db and purpur_adminer services here
```
## if you don'y like ZGC
```bash
# AIKAR G1
      JAVAFLAGS: >
         -Dterminal.jline=false
         -Dterminal.ansi=true
         -XX:+UseG1GC
         -XX:+ParallelRefProcEnabled
         -XX:MaxGCPauseMillis=170
         -XX:+UnlockExperimentalVMOptions
         -XX:+DisableExplicitGC
         -XX:+AlwaysPreTouch
         -XX:G1HeapWastePercent=5
         -XX:G1MixedGCCountTarget=4
         -XX:G1MixedGCLiveThresholdPercent=90
         -XX:G1RSetUpdatingPauseTimePercent=5
         -XX:SurvivorRatio=32
         -XX:+PerfDisableSharedMem
         -XX:MaxTenuringThreshold=1
         -XX:G1NewSizePercent=50
         -XX:G1MaxNewSizePercent=50
         -XX:G1HeapRegionSize=32M
         -XX:G1ReservePercent=15
         -XX:InitiatingHeapOccupancyPercent=20 # Задаем процент начальной занятости кучи
         -Dusing.aikars.flags=https://mcflags.emc.gs
         -Daikars.new.flags=true
         -Dcom.mojang.eula.agree=true # Соглашаемся с лицензией Mojang
```


## Example db with adminer
```bash
db:
    container_name: "purpur_db"
    image: "lscr.io/linuxserver/mariadb:latest"
    restart: always
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=""
      - MYSQL_ROOT_PASSWORD=myrootpassword
      - MYSQL_USER=mydbuser
      - MYSQL_PASSWORD=mydbpassword
    volumes:
      - "/path/to/db_data:/config"
    ports:
      - "3306:3306"
    cpus: 1.0
    mem_limit: 1844M
      
  adminer:
    container_name: "purpur_adminer"
    image: "adminer"
    restart: always
    ports:
      - "25555:8080"
    cpus: 0.5
    mem_limit: 820M
    depends_on:
      - db
```


