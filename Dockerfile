FROM docker:18.06.0-ce AS docker-source

FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies (git, ssh, etc.)
RUN apt-get update && apt-get install -y \
    git \
    openssh-client \
    sudo \
    tar \
    gzip \
    ca-certificates \
    locales \
    curl \
    gcc \
    python-dev \
    python-setuptools \
    apt-transport-https \
    lsb-release \
    gnupg \
 && rm -rf /var/lib/apt/lists/*

# Install Docker
COPY --from=docker-source /usr/local/bin/docker /usr/local/bin/docker

# Install Docker
# RUN set -ex \
#  && export DOCKER_VERSION=$(curl --silent --fail --retry 3 https://download.docker.com/linux/static/stable/x86_64/ | grep -o -e 'docker-[.0-9]*-ce\.tgz' | sort -r | head -n 1) \
#  && DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/${DOCKER_VERSION}" \
#  && echo Docker URL: $DOCKER_URL \
#  && curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
#  && ls -lha /tmp/docker.tgz \
#  && tar -xz -C /tmp -f /tmp/docker.tgz \
#  && mv /tmp/docker/* /usr/bin \
#  && rm -rf /tmp/docker /tmp/docker.tgz \
#  && which docker \
#  && (docker version || true)

# Install docker-compose
RUN COMPOSE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/docker-compose-latest" \
 && curl --silent --show-error --location --fail --retry 3 --output /usr/bin/docker-compose $COMPOSE_URL \
 && chmod +x /usr/bin/docker-compose \
 && docker-compose version

# Install gcloud
ENV CLOUD_SDK_VERSION 212.0.0
RUN easy_install -U pip \
 && pip install -U crcmod \
 && export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
 && echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && apt-get update \
 && apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-python=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-python-extras=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-java=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-app-engine-go=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-datalab=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-datastore-emulator=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-pubsub-emulator=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-bigtable-emulator=${CLOUD_SDK_VERSION}-0 \
        google-cloud-sdk-cbt=${CLOUD_SDK_VERSION}-0 \
        kubectl \
 && rm -rf /var/lib/apt/lists/* \
 && gcloud config set core/disable_usage_reporting true \
 && gcloud config set component_manager/disable_update_check true \
 && gcloud config set metrics/environment github_docker_image \
 && gcloud --version \
 && docker --version && kubectl version --client

CMD ["/bin/sh"]
