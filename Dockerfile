FROM ubuntu:16.04

# File Author / Maintainer
MAINTAINER Cornell IT Cloud DevOps Team <cloud-devops@cornell.edu>

# Name of the private key in keys directory.
ENV DEPLOY_KEY_PRIVATE=example_deploy_rsa

# Install ssh and git clients
RUN \
  apt-get update && \
  apt-get install -y ssh git-core && \
  rm -rf /var/lib/apt/lists/*

# Get the private key into the Docker image.
COPY keys/ /keys

# Since we always touch the "version" file before each build,
# adding "version" to the image will cause Docker to throw away
# cached layers.
ADD version /tmp/version

# Prepare for using ssh with github.com.
RUN \
  mkdir -p /root/.ssh/ && \
  cp /keys/$DEPLOY_KEY_PRIVATE /root/.ssh/id_rsa && \
  chmod 400 /root/.ssh/id_rsa && \
  touch /root/.ssh/known_hosts && \
  ssh-keyscan github.com >> /root/.ssh/known_hosts

# Do git access here.
WORKDIR /tmp
RUN \
  git clone git@github.com:CU-CloudCollab/docker-github-target.git

# Cleanup so that ssh keys are not stored in the Docker image.
RUN \
  rm -rf /root/.ssh && \
  rm -rf /keys
