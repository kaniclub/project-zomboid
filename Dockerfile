FROM debian:buster-slim

# Stop apt-get asking to get Dialog frontend
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

# LinuxGSM_ variables
ENV LGSM_VERSION="latest" \
    LGSM_GAMESERVER="" \
    LGSM_GAMESERVER_UPDATE="true" \
    LGSM_GAMESERVER_START="false" \
    LGSM_GAMESERVER_RENAME="" \
    LGSM_COMMON_CONFIG="" \
    LGSM_COMMON_CONFIG_FILE="" \
    LGSM_SERVER_CONFIG="" \
    LGSM_SERVER_CONFIG_FILE="" \
    # Steam ports
    STEAM_PORT_1=8766  \
    STEAM_PORT_2=8767 \
    # RCON
    RCON_PORT=27015 \
    RCON_PASSWORD="rcon-password" \
    # Server informations
    SERVER_NAME="pzserver" \
    SERVER_PASSWORD="" \
    SERVER_BRANCH="" \
    SERVER_BETA_PASSWORD="" \
    # Admin DB Password (required for the first launch)
    ADMIN_PASSWORD="pzserver-password" \
    # Server port
    SERVER_PORT=16261 \
    # Game UDP port to allow player to contact the server (by default : 24 players)
    PLAYER_PORTS=16262-16285

# Fix for JRE installation
RUN mkdir -p /usr/share/man/man1/

# Switch to root to use apt-get
USER root

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        bc \
        binutils \
        bsdmainutils \
        bzip2 \
        ca-certificates \
        curl \
        default-jre \
        file \
        gzip \
        iproute2 \
        jq \
        lib32gcc1 \
        lib32stdc++6 \
        libsdl2-2.0-0:i386 \
        locales \
        mailutils \
        netcat \
        nodejs \
        postfix \
        procps \
        python \
        tar \
        tmux \
        util-linux \
        unzip \
        rng-tools \
        xz-utils \
        wget && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        nodejs && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

RUN npm set progress=false && \
    npm config set depth 0 && \
    npm install --no-audit --global gamedig && \
    npm cache clean --force

# Set the locale
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8" \
    TimeZone=Asia/Tokyo

# Add the steam user
RUN adduser \
    --disabled-login \
    --disabled-password \
    --shell /bin/bash \
    --gecos "" \
    linuxgsm && \
    usermod -G tty linuxgsm

COPY ./scripts/*.sh /
RUN chmod +x /*.sh

# Create server directories and link to access them
RUN [ -d /home/linuxgsm/Zomboid ] || mkdir -p /home/linuxgsm/Zomboid && \
    chown linuxgsm:linuxgsm /home/linuxgsm/Zomboid && \
    ln -s /home/linuxgsm/Zomboid /server-data && \
    [ -d /home/linuxgsm/serverfiles ] || mkdir -p /home/linuxgsm/serverfiles && \
    chown linuxgsm:linuxgsm /home/linuxgsm/serverfiles && \
    ln -s /home/linuxgsm/serverfiles /server-files
# Switch to the user steam
USER linuxgsm
WORKDIR /home/linuxgsm

# Make server port available to host : (10 slots)
EXPOSE ${STEAM_PORT_1}/udp ${STEAM_PORT_2}/udp ${SERVER_PORT}/udp ${PLAYER_PORTS} ${RCON_PORT}

# Persistant folder
VOLUME ["/server-data", "/server-files"]


ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=60s --timeout=30s --start-period=300s --retries=3 CMD [ "/lgsm_healthcheck.sh" ]