FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NOVNC_PORT=6080

# Install system + desktop + browser
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    x11vnc xvfb \
    wget curl git \
    python3 python3-pip \
    chromium-browser \
    novnc websockify \
    && apt-get clean

# Create user
RUN useradd -m user
WORKDIR /home/user

# Set VNC password
RUN mkdir ~/.vnc && \
    x11vnc -storepasswd 1234 ~/.vnc/passwd

# noVNC setup
RUN ln -s /usr/share/novnc/vnc.html /home/user/index.html

# Start script
RUN echo '#!/bin/bash\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
startxfce4 &\n\
x11vnc -display :1 -forever -usepw -rfbport 5901 &\n\
websockify --web=/usr/share/novnc/ 6080 localhost:5901\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 6080

CMD ["/start.sh"]
