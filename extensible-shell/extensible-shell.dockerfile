FROM dhi.io/sbx-templates:shell-docker

RUN sudo apt-get update && \
    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends vim && \
    sudo rm -rf /var/lib/apt/lists/*

RUN printf '#!/usr/bin/env bash\nbash -l\n' > /home/agent/entrypoint.sh && \
    chmod 0700 /home/agent/entrypoint.sh

ENTRYPOINT ["/home/agent/entrypoint.sh"]
