# ---------------------------
# UBX Lightweight Desktop + noVNC for Railway
# ---------------------------
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV USER=user
ENV HOME=/home/$USER
ENV VNC_PASSWORD=1234
ENV PORT=6080

# ---------------------------
# Install desktop, KDE apps, browsers, utilities
# ---------------------------
RUN apt-get update && apt-get install -y \
    firefox \
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
    x11vnc -storepasswd $VNC_PASSWORD $HOME/.vnc/passwd

# ---------------------------
# Setup noVNC
# ---------------------------
RUN ln -s /usr/share/novnc/vnc.html $HOME/index.html

# ---------------------------
# Start script
# ---------------------------
RUN printf '#!/bin/bash\n\
export DISPLAY=:1\n\
export USER=user\n\
export HOME=/home/user\n\
\n\
# Start virtual display\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
\n\
# Start XFCE desktop (can launch Plasma apps)\n\
startxfce4 &\n\
\n\
# Start x11vnc with password\n\
x11vnc -display :1 -forever -usepw -rfbport 5901 &\n\
\n\
# Start websockify for noVNC\n\
websockify --web=/usr/share/novnc/ 0.0.0.0:${PORT:-6080} localhost:5901\n' > /start.sh

RUN chmod +x /start.sh

# ---------------------------
# Expose port for Railway
# ---------------------------
EXPOSE 6080

# ---------------------------
# Run the container
# ---------------------------
CMD ["/start.sh"]
