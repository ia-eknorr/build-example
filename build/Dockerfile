ARG IGNITION_VERSION="8.1.44"
FROM inductiveautomation/ignition:${IGNITION_VERSION:-latest}

USER root

# Set environment variables
ENV ACCEPT_IGNITION_EULA="Y"
ENV IGNITION_EDITION="standard"

# Install any additional packages here
RUN apt-get update && apt-get install -y cowsay figlet && rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/games/cowsay /usr/bin/cowsay && ln -s /usr/games/cowthink /usr/bin/cowthink

# Copy in the entrypoint shim and scripts
COPY --chmod=0755 ./scripts/*.sh /usr/local/bin/
COPY --chmod=0755 ./entrypoint-shim.sh /usr/local/bin/

# Set entrypoint-shim.sh as the entrypoint
ENTRYPOINT [ "entrypoint-shim.sh" ]