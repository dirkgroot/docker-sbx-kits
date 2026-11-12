FROM dhi.io/sbx-templates:shell-docker
ARG PI_VERSION
USER root

RUN sed -i 's|^URIs: http://deb.debian.org|URIs: https://deb.debian.org|' /etc/apt/sources.list.d/debian.sources \
 && apt-get update \
 && apt-get install -y --no-install-recommends tmux fd-find \
 && rm -rf /var/lib/apt/lists/*

RUN export HOME=/root \
 && npm install -g --ignore-scripts --no-fund --no-audit --cache /tmp/npm-cache \
      "@earendil-works/pi-coding-agent@${PI_VERSION}" \
 && rm -rf /tmp/npm-cache /root/.npm /root/.cache /root/.config /root/.local \
 && ln -s /usr/bin/fdfind /usr/local/share/npm-global/bin/fd \
 && printf 'set -g extended-keys on\nset -g extended-keys-format csi-u\n# tmux drops OSC 52 from pane apps under its "external" default — "on" stores\n# it AND forwards it to the outer terminal: the only clipboard path for pi.\nset -g set-clipboard on\n' > /home/agent/.tmux.conf \
 && chown agent:agent /home/agent/.tmux.conf \
 && pi --version | grep -qx "${PI_VERSION}" \
 && ! find /home/agent -uid 0 | grep -q .

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 PI_CLIPBOARD_OSC52=1
COPY <<'EOF' /usr/local/bin/pi-launch
#!/bin/sh
[ -t 0 ] && command -v tmux >/dev/null 2>&1 \
  && exec tmux new-session -A -s pi pi "$@"
exec pi "$@"
EOF

RUN chmod 755 /usr/local/bin/pi-launch

USER agent
WORKDIR /home/agent/workspace
ENTRYPOINT ["/usr/local/bin/pi-launch"]
