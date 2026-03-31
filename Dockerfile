# ---------------------------
# UBX Desktop + noVNC for Railway
# ---------------------------
# Use a pre-built image that already includes LXDE desktop, VNC server,
# noVNC, Firefox, Chromium, and development tools. This avoids installing
# hundreds of packages at build time and prevents build timeouts.
FROM dorowu/ubuntu-desktop-lxde-vnc:latest

ENV VNC_PASSWORD=1234
ENV RESOLUTION=1280x720

# Expose the noVNC web port
EXPOSE 80
