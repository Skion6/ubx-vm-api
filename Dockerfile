# ---------------------------
# UBX Desktop + noVNC for Railway
# ---------------------------
# Use a pre-built image that already includes LXDE desktop, VNC server,
# noVNC, Firefox, Chromium, and development tools. This avoids installing
# hundreds of packages at build time and prevents build timeouts.
FROM dorowu/ubuntu-desktop-lxde-vnc:latest

ENV VNC_PASSWORD=1234
ENV RESOLUTION=1280x720

# Patch the base image's nginx config to listen on all interfaces (0.0.0.0:80)
# instead of the default localhost-only binding (127.0.0.1:80).
# We only change the listen address — the rest of the base image's proven
# noVNC proxy configuration is left intact so supervisor can manage nginx normally.
RUN find /etc/nginx -name "*.conf" -o -name "default" | \
    xargs sed -i 's/listen 127\.0\.0\.1:80/listen 0.0.0.0:80/g'

# Validate the final nginx configuration at build time so a bad config
# fails the build rather than silently serving 502s at runtime.
RUN nginx -t

# Expose the noVNC web port
EXPOSE 80
