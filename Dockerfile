# ---------------------------
# UBX Desktop + noVNC for Railway
# ---------------------------
# Use a pre-built image that already includes LXDE desktop, VNC server,
# noVNC, Firefox, Chromium, and development tools. This avoids installing
# hundreds of packages at build time and prevents build timeouts.
FROM dorowu/ubuntu-desktop-lxde-vnc:latest

ENV VNC_PASSWORD=1234
ENV RESOLUTION=1280x720

# Write our complete, standalone nginx.conf directly to the main config
# file, bypassing the base image's sites-available/sites-enabled setup
# entirely. This prevents supervisor from restarting nginx with a stale
# or conflicting config fragment.
COPY nginx.conf /etc/nginx/nginx.conf

# Disable the sites-enabled directory so the base image's default server
# block (which binds to 127.0.0.1:80) can never be loaded alongside ours.
RUN rm -rf /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-enabled

# Validate the final nginx configuration at build time so a bad config
# fails the build rather than silently serving 502s at runtime.
RUN nginx -t

# Expose the noVNC web port
EXPOSE 80
