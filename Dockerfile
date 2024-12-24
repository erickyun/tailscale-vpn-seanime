FROM debian:bullseye-slim
#FROM debian:latest

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
RUN curl -fsSL https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | gpg --dearmor -o /usr/share/keyrings/jellyfin-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/jellyfin-archive-keyring.gpg] https://repo.jellyfin.org/debian bullseye main" | tee /etc/apt/sources.list.d/jellyfin.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends jellyfin-ffmpeg6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
RUN wget "https://github.com/5rahim/seanime/releases/download/v2.5.1/seanime-2.5.1_Linux_x86_64.tar.gz" && \
    tar -xzf "seanime-2.5.1_Linux_x86_64.tar.gz" && \
    rm "seanime-2.5.1_Linux_x86_64.tar.gz" && \
    chmod +x seanime

ENV PATH="/usr/lib/jellyfin-ffmpeg/:$PATH"

EXPOSE 80 443 43211 43213 43214 8080 6881 6881/udp 10000

COPY . .

RUN pwd

ARG TAILSCALE_VERSION
ENV TAILSCALE_VERSION=$TAILSCALE_VERSION

RUN apt-get -qq update \
  && apt-get -qq install --upgrade -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    netcat-openbsd \
    wget \
    dnsutils \
  > /dev/null \
  && apt-get -qq clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
  && :

RUN echo "+search +short" > /root/.digrc
COPY run-tailscale.sh /app/

COPY install-tailscale.sh /tmp
RUN /tmp/install-tailscale.sh && rm -r /tmp/*

# Start Seanime
CMD ["bash", "-c", "/app/run-tailscale.sh & ./seanime --datadir /app/config/Seanime"]
