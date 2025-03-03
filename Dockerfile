FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    apt-transport-https \
    gnupg && \
    rm -rf /var/lib/apt/lists/*

# Download and install the specific version of kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.30.6/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install jq
RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

