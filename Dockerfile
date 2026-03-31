# ---------------------------
# Railway-friendly lightweight VM
# ---------------------------
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NOVNC_PORT=6080
ENV USER=user
ENV HOME=/home/$USER
ENV PORT=6080

# ---------------------------
# Install desktop + utilities + browsers
# ---------------------------
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    plasma-desktop plasma-workspace \
    dolphin \
    konsole \
    kwrite \
    kwin-addons kwin-x11 \
    kde-config-gtk-style \
    kdialog \
    kfind \
    khotkeys \
    kio-extras \
    knewstuff-dialog \
    qml-module-qt-labs-platform \
    systemsettings \
    gwenview \
    firefox \
    chromium-browser \
    x11vnc xvfb \
    novnc websockify \
    jq wget curl git \
    python3 python3-pip \
    && apt-get clean

# ---------------------------
# Create user
# ---------------------------
RUN useradd -m $USER
WORKDIR $HOME

# ---------------------------
# Set VNC password
# ---------------------------
RUN mkdir -p $HOME/.vnc && \
    x11vnc -storepasswd 1234 $HOME/.vnc/passwd

# ---------------------------
# Setup noVNC
# ---------------------------
RUN ln -s /usr/share/novnc/vnc.html $HOME/index.html

# ---------------------------
# Start script
# ---------------------------
RUN echo '#!/bin/bash
export DISPLAY=:1
export USER=user
export HOME=/home/user

# Start virtual display
Xvfb :1 -screen 0 1280x720x24 &

# Start XFCE desktop (or Plasma if you prefer)
startxfce4 &

# Start x11vnc with password
x11vnc -display :1 -forever -usepw -rfbport 5901 &

# Start websockify for noVNC, Railway-friendly port
websockify --web=/usr/share/novnc/ 0.0.0.0:${PORT:-6080} localhost:5901
' > /start.sh

RUN chmod +x /start.sh

# ---------------------------
# Expose port for Railway
# ---------------------------
EXPOSE 6080

# ---------------------------
# Start the container
# ---------------------------
CMD ["/start.sh"]
