FROM dhi.io/sbx-templates:shell-docker

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends vim && \
    rm -rf /var/lib/apt/lists/*

RUN printf '#!/usr/bin/env bash\nbash -l\n' > /home/agent/entrypoint.sh && \
    chmod 0700 /home/agent/entrypoint.sh

ENTRYPOINT ["/home/agent/entrypoint.sh"]
