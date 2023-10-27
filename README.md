# Minecraft(Purpur) server via Docker
Данный контейнер позволяет вам запустить minecraft на ядре Purpur версии 1.20.1 или любой иной версии ядра, которой вы захотите, если она будет в репозитрии Purpur. Данное решение разработанно для построение на его основе сервера с конфигурацией >=12 ГБ ОЗУ и 8 ядер/16 потоков.

# Что надо для запуска

## 1. [Docker](https://docs.docker.com/engine/install/):
### Операционная система:
- Linux: Docker поддерживает большинство распространенных дистрибутивов Linux, таких как Ubuntu, Debian, CentOS и другие.
- Windows: Docker поддерживает Windows 10 Pro, Enterprise или Education (64-бит) с включенной подсистемой Windows для Linux (WSL 2).
- macOS: Docker поддерживает macOS 10.13 и выше с установленным Docker Desktop.

### Процессор:
64-битный процессор с виртуализацией включенной в BIOS/UEFI.

### Память (RAM):
Рекомендуется не менее 12 ГБ оперативной памяти.
Для минимального запуска/тестирования рекомендуется 1 ГБ оперативной памяти.

### Хранилище:
Свободное место на диске для установки Docker и контейнеров.
Рекомендуется не менее 12 гб дискового пространства.

### Интернет-соединение:
Для загрузки образов контейнеров и других ресурсов.

## 2. [Docker Compose](https://docs.docker.com/compose/install/) (по желанию):
- Установленный Docker: Docker Compose требует установленного Docker на хост-системе.
- Python: Docker Compose написан на языке Python, поэтому требуется наличие Python на вашей системе.

- Интернет-соединение: Для загрузки конфигураций и ресурсов, Docker Compose также требует интернет-соединения.

## Как использовать

- Установить [Docker](https://docs.docker.com/engine/install/)
- Установить [Docker Compose](https://docs.docker.com/compose/install/) (по желанию)

- Простой запуск через docker для версии minecraft 1.20.1
  ```yml
  docker run -d \
    --name purpur \
    --restart always \
    -v /path/to/purpur_data:/data:rw \
    -p 25565:25565/tcp \
    --interactive \
    --tty \
    towinok/purpurmain:latest
  ```
    - ```/path/to/purpur_data``` Заменить на локальный путь к папке хранения данных на хосте.
    - ```VERSION: "1.20.1"``` Заменить ```1.20.1``` на интересующую вас версию.

- Простой запуск через docker-compose для версии minecraft 1.20.1
  ```yml
  version: "3"
  
  services:
    minecraft:
      image: "towinok/purpur-server:latest"
      restart: always
      container_name: "purpur"
      environment:
        VERSION: "1.20.1"
      volumes:
        - "/path/to/purpur_data:/data:rw"
      ports:
        - "25565:25565/tcp"
      stdin_open: true
      tty: true
  ```
    - ```docker-compose up``` Для запуска файла.
    - ```/path/to/purpur_data``` Заменить на локальный путь к папке хранения данных на хосте.
    - ```VERSION: "1.20.1"``` Заменить ```1.20.1``` на интересующуюинтересующую вас версию.
## Доступные Environments
- ```VERSION``` Версия Minecraft/PurpurMC сервера.
  - Default ARG: ```1.20.1```
- ```MEMORYSIZE``` Размер выделенной памяти для Java процесса Minecraft сервера.
  - Default ARG: ```1G```
- ```PUFFER_FLAGS``` Стандартный флаг который используется по умолчанию, не требует написания и повторного использования.
  - Default ARG ```--add-modules=jdk.incubator.vector```. При желании можно поставить ```""``` в значение и он работать перестанет, тогда Pufferfish не будет работать как надо.
- ```JAVAFLAGS``` Дополнительные флаги Java, используемые для настройки Java виртуальной машины.
  - Default ARG для 8 ядер 16 потоков и >=12G GB ОЗУ:
    ```yml
    -Djava.awt.headless=true -Dterminal.jline=false -Dterminal.ansi=true -XX:+UseZGC -XX:MaxGCPauseMillis=16 -XX:ActiveProcessorCount=8 -XX:+UseNUMA -XX:+AlwaysPreTouch -XX:+UseStringDeduplication -XX:+ParallelRefProcEnabled XX:+PerfDisableSharedMem -XX:InitiatingHeapOccupancyPercent=20 -Dcom.mojang.eula.agree=true
    ```
  - ПРЕДУПРЕЖДЕНИЕ! Если у вас меньше 12 гб, то прошу использовать флаги от [Aikar](https://flags.sh)
- ```ADD_FLAGS``` Дополнительные флаги и параметры для запуска Minecraft/PurpurMC сервера.
  - Dedault ARG
      ```yml
     --nojline -C ./config/commands.yml -S ./config/spigot.yml -b ./config/bukkit.yml -c ./config/server.properties --pufferfish-settings ./config/pufferfish.yml --purpur-settings ./config/purpur.yml --paper-settings-directory ./config/paper/  -d "yyyy-MM-dd HH:mm:ss" --world-dir ./worlds/
    ```
    - ```--world-dir ./worlds/'``` Папка с мирами по умолчанию.
    - ```--paper-settings-directory ./config/paper/``` ./config => paper/ => конфигураций Paper
    - ```--purpur-settings ./config/purpur.yml``` ./config => конфигураций Purpur
    - ```./config/pufferfish.yml --purpur-settings ``` ./config => конфигураций Pufferfish
    - ```-C ./config/commands.yml``` ./config => конфигурационный файл для создания алиасов команд (не рекомендуется к настройке).
    - ```-S ./config/spigot.yml``` ./config => Конфигурация Spigot
    - ```-b ./config/bukkit.yml``` ./config => Конфигурация Bukkit

## Выполнение
Если всё выполнилось правильно то появится отчёт об исполнении
```bash
"------------------------------------------------------------------"
"Purpur version: ${PURPUR_VERSION}-${LATEST_BUILD}"
"------------------------------------------------------------------"

"Purpur server downloaded successfully."
```
  - ```{PURPUR_VERSION}``` Версия Minecraft которую вы указали.
  - ```{LATEST_BUILD}``` Последняя версия Purpur для данной версии майнкрафт на момент запроса.
Если при скачивании не совпадут хэш-суммы ```"Purpur server downloaded with error"```, то файл будет скачиваться до тех пор пока не будет совпадения ключей.
Стоит отметить, что если версия не валидна, то и ошибка так же будет связанна с ключом, так как по факту нету файла удовлетворяющим требованию.

В случае если контейнер умрёт с флагом ```--restart always``` или ``` restart: always``` , то контейнер перезапустится автоматически.

## Подключение к контейнеру
```bash
docker exec -it CONTAINER_ID /bin/sh
```
```bash
docker-compose exec SERVICE_NAME /bin/sh
```
Для получения ID и NAME
```bash
docker ps
```
### Прикладной материал
- Основные команды для пользования Docker [[EN](https://docs.docker.com/engine/reference/commandline/cli/)]
- Базовое использование Docker-compose [[EN](https://docs.docker.com/compose/reference/)]
- Сравнение и полезная информация о флагах для minecraft [[EN](https://github.com/brucethemoose/Minecraft-Performance-Flags-Benchmarks)]
- Почему Aikar's флаг хороши [[EN](https://docs.papermc.io/paper/aikars-flags)]
- Кратко об ZGC [[EN](https://github.com/1ByteBit/ZGC-For-Minecraft)]
- OpenJDK wiki ZGC [[EN](https://wiki.openjdk.org/display/zgc/Main)]
# Что в разработке?
- Алиасы для docker
- Выбор из ядер для скачивания
  - Vanila
  - Paper
  - Purpur
    
