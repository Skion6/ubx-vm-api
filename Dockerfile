# ---------------------------
# UBX Desktop + noVNC for Railway
# ---------------------------
# Use a pre-built image that already includes LXDE desktop, VNC server,
# noVNC, Firefox, Chromium, and development tools. This avoids installing
# hundreds of packages at build time and prevents build timeouts.
FROM dorowu/ubuntu-desktop-lxde-vnc:latest

ENV VNC_PASSWORD=1234
ENV RESOLUTION=1280x720

# Override nginx config so it listens on all interfaces (0.0.0.0:80)
# instead of the default localhost-only binding in the base image.
COPY nginx.conf /etc/nginx/sites-available/default

# Ensure sites-enabled points exclusively to our custom config.
# The base image may have a stale symlink or a different target, so we
# clear the directory and recreate the symlink from scratch.
RUN rm -f /etc/nginx/sites-enabled/* && \
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Also patch any remaining 127.0.0.1 listen directives in the nginx config
# tree to ensure nothing else re-binds to localhost only.
RUN sed -i 's/listen\s\+127\.0\.0\.1:80/listen 0.0.0.0:80/g' \
        /etc/nginx/sites-available/default \
        /etc/nginx/nginx.conf 2>/dev/null || true

# Validate the final nginx configuration at build time so a bad config
# fails the build rather than silently serving 502s at runtime.
RUN nginx -t

# Expose the noVNC web port
EXPOSE 80
