FROM debian:bullseye-slim
#FROM debian:latest
#FROM python:3.9-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        wget \
        tar \
        jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Jellyfin's FFmpeg
#RUN curl -fsSL https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | gpg --dearmor -o /usr/share/keyrings/jellyfin-archive-keyring.gpg && \
#    echo "deb [signed-by=/usr/share/keyrings/jellyfin-archive-keyring.gpg] https://repo.jellyfin.org/debian bullseye main" | tee /etc/apt/sources.list.d/jellyfin.list && \
#    apt-get update && \
#    apt-get install -y --no-install-recommends jellyfin-ffmpeg6 && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*

WORKDIR /app/

RUN mkdir /downloads

# Download and install latest version
#RUN LATEST_VERSION=$(curl -s https://api.github.com/repos/5rahim/seanime/releases/latest | jq -r .tag_name) && \
#    VERSION_NO_V=$(echo ${LATEST_VERSION} | sed 's/v//') && \
#    echo "Latest version: ${LATEST_VERSION}" && \
#    echo "Version without v: ${VERSION_NO_V}" && \
#    wget "https://github.com/5rahim/seanime/releases/download/${LATEST_VERSION}/seanime-${VERSION_NO_V}_Linux_x86_64.tar.gz" && \
#    tar -xzf "seanime-${VERSION_NO_V}_Linux_x86_64.tar.gz" && \
#    rm "seanime-${VERSION_NO_V}_Linux_x86_64.tar.gz" && \
#    chmod +x seanime

# Install Seanime
RUN wget "https://github.com/5rahim/seanime/releases/download/v2.5.2/seanime-2.5.2_Linux_x86_64.tar.gz" && \
    tar -xzf "seanime-2.5.2_Linux_x86_64.tar.gz" && \
    rm "seanime-2.5.2_Linux_x86_64.tar.gz" && \
    chmod +x seanime

#ENV PATH="/usr/lib/jellyfin-ffmpeg/:$PATH"

EXPOSE 80 443 43211 43213 43214 8080 6881 6881/udp 10000

COPY . .

RUN pwd

#ARG TAILSCALE_VERSION
#ENV TAILSCALE_VERSION=$TAILSCALE_VERSION

#RUN apt-get -qq update \
#  && apt-get -qq install --upgrade -y --no-install-recommends \
#    apt-transport-https \
#    ca-certificates \
#    netcat-openbsd \
#    wget \
#    dnsutils \
#  > /dev/null \
#  && apt-get -qq clean \
#  && rm -rf \
#    /var/lib/apt/lists/* \
#    /tmp/* \
#    /var/tmp/* \
#  && :

#RUN echo "+search +short" > /root/.digrc
#COPY run-tailscale.sh /app/

#COPY install-tailscale.sh /tmp
#RUN /tmp/install-tailscale.sh && rm -r /tmp/*

# Install Python, pip, and necessary build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Python3 and pip3 as the default Python and pip commands
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip

#COPY ./app/requirements.txt /app/app/
RUN pip install --no-cache-dir -r /app/app/requirements.txt

RUN wget https://pkgs.tailscale.com/stable/$(wget -q -O- https://pkgs.tailscale.com/stable/ | grep 'amd64.tgz' | cut -d '"' -f 2) && \
    tar xzf tailscale* --strip-components=1
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

RUN chmod +x /app/app/start.sh

# Start Seanime
CMD ["bash", "-c", "/app/app/start.sh & ./seanime --datadir /app/config/Seanime"]
