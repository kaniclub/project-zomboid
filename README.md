# Project Zomboid server - Docker image

Docker version of the Project Zomboid steam server.

## 使い方

### 始める前に

サーバーを実行する２つのディレクトリを作成してください。

- `server-data`: 再起動のたびに構成を保持する場合は必須
- `server-files`: (オプション) アプリケーションのすべてのファイルが含まれています

ディレクトリの権限を調整してください

```bash
chown 1000:1000 server-data
chown 1000:1000 server-files
```


#### Docker command

```bash
docker run -d --name project-zomboid \
              -e SERVER_NAME="pzserver" \
              -e ADMIN_PASSWORD="pzserver-password" \
              -v $(pwd)/server-data:/server-data \
              -v $(pwd)/server-files:/server-files \
              -p 8766:8766/udp \
              -p 8767:8767/udp \
              -p 16261:16261/udp \
              -p 16262-16285:16262-16285 \
              -p 27015:27015 
```

#### Docker Compose

```yaml
version: "3.7"

services:
  project-zomboid:
    image: kaniclub/project-zomboid:latest
    restart: unless-stopped
    environment:
      SERVER_NAME: "pzserver"
      ADMIN_PASSWORD: "pzserver-password"
    ports:
      - "8766:8766/udp"
      - "8767:8767/udp"
      - "16261:16261/udp"
      - "16262-16285:16262-16285"
      - "27015:27015"
    volumes:
      - ./server-data:/server-data
      - ./server-files:/server-files
```

ファイルを作成後コマンドを実行 `docker-compose up`.

### Host networking

#### Docker command

```bash
docker run -d --name project-zomboid \
              --network=host \
              -e SERVER_NAME="pzserver" \
              -e ADMIN_PASSWORD="pzserver-password" \
              -v $(pwd)/server-data:/server-data \
              -v $(pwd)/server-files:/server-files 
```

#### Docker Compose

```yaml
version: "3.7"

services:
  project-zomboid:
    image: kaniclub/project-zomboid:latest
    restart: unless-stopped
    environment:
      SERVER_NAME: "pzserver"
      ADMIN_PASSWORD: "pzserver-password"
    network_mode: host
    volumes:
      - ./server-data:/server-data
      - ./server-files:/server-files
```

ファイルを作成後コマンドを実行 `docker-compose up`.

#### Specifying IP address

In this network mode, you could specify the IP address of the host instead of letting the program do it automatically.

In the command line, add the parameter `-e LGSM_SERVER_CONFIG='ip="xx.xx.xx.xx"'`.

In the docker compose file, add this environment variable:

```yaml
LGSM_SERVER_CONFIG: |
  ip="xx.xx.xx.xx"
```

### After starting

初めて実行したときに、設定ファイルが作成されます。 `/server-data/Server/$SERVER_NAME.ini`
設定変更後、サーバーを再起動します。

### その他設定

## Variables

- **STEAM_PORT_1** Steam port 1 (default: 8766)
- **STEAM_PORT_2** Steam port 2 (default: 8767)
- **RCON_PORT** RCON port (default: 27015)
- **RCON_PASSWORD** RCON password
- **SERVER_NAME** Name of your server (for db & ini file). **Warning:** don't use special characters or spaces.
- **SERVER_PASSWORD** Password of your server used to connect to it
- **SERVER_PUBLIC_NAME** Public name of your server
- **SERVER_BRANCH** Name of the beta branch
- **SERVER_BETA_PASSWORD** Password for the beta branch
- **ADMIN_PASSWORD** Admin password on your server
- **SERVER_PORT** Game server port
- **PLAYER_PORTS** Game ports to allow player to contact the server (by default : 16262-16272 to allow 10 players)
- **TimeZone**
- **PUID**
- **PGID**


**SERVER_BRANCH**, **SERVER_BETA_PASSWORD** and **ADMIN_PASSWORD** are not used if these values are set by **LGSM_COMMON_CONFIG**, **LGSM_COMMON_CONFIG_FILE**, **LGSM_SERVER_CONFIG** or **LGSM_SERVER_CONFIG_FILE**. These 4 variables from [cyrale/linuxgsm](https://github.com/cyrale/linuxgsm#variables) can override default settings from LinuxGSM\_: [\_default.cfg](https://github.com/GameServerManagers/LinuxGSM/blob/master/lgsm/config-default/config-lgsm/pzserver/_default.cfg).

## Volumes

- **/server-data** Data directory of the server. Contains db, config files...
- **/server-files** Application dir of the server.

## Expose

- **8766** Steam port 1 (udp)
- **8767** Steam port 2 (udp)
- **27015** RCON
- **16261** Game server (udp)
- **16262-16XXX** Clients slots

You need to bind X ports for client connection. (Example: If you have 10 slots, you need to put `-p 16262-16285:16262-16285`, if you have 100 slots, you need to put `-p 16262-16362:16262-16362`).
