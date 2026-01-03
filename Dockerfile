# Specify Playwright MCP as base image
FROM mcr.microsoft.com/playwright/mcp:latest


# Set default environment variables
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NOVNC_PORT=6901 \
    VNC_RESOLUTION=1280x720 \
    PLAYWRIGHT_VIEWPORT_SIZE=1024,720

# Switch to root user for package installation
USER root

# Install required packages
RUN apt-get update && apt-get install -y  \
    xvfb \
    fluxbox \
    xterm \
    git \
    tigervnc-standalone-server \
    tigervnc-common \
    websockify \
    ca-certificates \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create directory for X server and templates
RUN mkdir -p /tmp/.X11-unix /templates && \
    chmod 1777 /tmp/.X11-unix

# Clone noVNC from GitHub
RUN git clone https://github.com/novnc/noVNC.git /usr/local/novnc
RUN ln -s /usr/local/novnc/vnc.html /usr/local/novnc/index.html

# Copy wrapper and startup scripts into container
COPY --chown=node:node src/chrome-wrapper.sh src/startup.sh src/xstartup src/templates/config.json /usr/local/bin/
RUN chmod +x /usr/local/bin/chrome-wrapper.sh /usr/local/bin/startup.sh /usr/local/bin/xstartup

# Switch back to default user
USER node

# Expose ports
EXPOSE 6901 8831

# Command to execute when container starts
ENTRYPOINT ["/usr/local/bin/startup.sh"]
