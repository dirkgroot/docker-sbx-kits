# syntax=docker/dockerfile:1
# The shell template carries the platform floor and already ships Node 24
# (Pi needs >= 22.19), so the build only pins Pi itself — plus the two
# runtime dependencies Pi fetches or warns about itself (fd, tmux keys) —
# so the provide cannot claim a version the image does not run.
FROM dhi.io/sbx-templates:shell-docker
ARG PI_VERSION
USER root
# tmux backs the pi-launch wrapper below; fd is a Pi runtime dependency it
# would otherwise download itself. The template's Debian mirrors are http,
# which some egress setups refuse — use https.
RUN sed -i 's|^URIs: http://deb.debian.org|URIs: https://deb.debian.org|' /etc/apt/sources.list.d/debian.sources \
 && apt-get update \
 && apt-get install -y --no-install-recommends tmux fd-find \
 && rm -rf /var/lib/apt/lists/*
# HOME=/root keeps npm's side effects out of the agent's home; --cache
# points at a build-local dir because the template ships a /root/.npm the
# agent user owns.
RUN export HOME=/root \
 && npm install -g --ignore-scripts --no-fund --no-audit --cache /tmp/npm-cache \
      "@earendil-works/pi-coding-agent@${PI_VERSION}" \
 && rm -rf /tmp/npm-cache /root/.npm /root/.cache /root/.config /root/.local \
 && ln -s /usr/bin/fdfind /usr/local/share/npm-global/bin/fd \
 && printf 'set -g extended-keys on\nset -g extended-keys-format csi-u\n# tmux drops OSC 52 from pane apps under its "external" default — "on" stores\n# it AND forwards it to the outer terminal: the only clipboard path for pi.\nset -g set-clipboard on\n' > /home/agent/.tmux.conf \
 && chown agent:agent /home/agent/.tmux.conf \
 && pi --version | grep -qx "${PI_VERSION}" \
 && ! find /home/agent -uid 0 | grep -q .
# The TUI's half-block logo (▀/█) needs a UTF-8 locale; POSIX makes tmux draw
# every block as an underscore. C.UTF-8 ships with glibc — no locales setup.
# The container has no Wayland/X display, so Pi's clipboard must go through
# OSC 52 (tmux forwards it, Ghostty applies it; clipboard-write defaults to
# allow). Without this Pi tries wl-copy first and reports the Wayland error.
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 PI_CLIPBOARD_OSC52=1
COPY <<'EOF' /usr/local/bin/pi-launch
#!/bin/sh
# tmux only with a terminal attached (headless runs need stdout); -A
# reattach ignores the argv tail by design: attach to the live agent.
[ -t 0 ] && command -v tmux >/dev/null 2>&1 \
  && exec tmux new-session -A -s pi pi "$@"
exec pi "$@"
EOF
RUN chmod 755 /usr/local/bin/pi-launch
USER agent
WORKDIR /home/agent/workspace
ENTRYPOINT ["/usr/local/bin/pi-launch"]
