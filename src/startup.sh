#!/bin/bash

# Copy default config if it doesn't exist
if [ ! -f /config/config.json ]; then
    echo "Config not found in /config, copying default"
    mkdir -p /config
    cp /usr/local/bin/config.json /config/config.json
    echo "Default config copied to /config/config.json"
fi

# Terminate background processes when the script exits
trap 'kill -TERM $PID_VNC $PID_NOVNC; wait; exit' TERM INT

# Start vncserver
if [ -n "${VNC_PASSWORD}" ]; then
  # Create VNC password file
  mkdir -p ~/.vnc
  echo "${VNC_PASSWORD}" | vncpasswd -f > ~/.vnc/passwd
  chmod 600 ~/.vnc/passwd
  EXTRA_OPTS=""
else
  EXTRA_OPTS="-SecurityTypes None -I-KNOW-THIS-IS-INSECURE"
fi

vncserver ${DISPLAY} ${EXTRA_OPTS} \
  -fg \
  -localhost no \
  -geometry ${VNC_RESOLUTION} \
  -xstartup /usr/local/bin/xstartup &
PID_VNC=$!

# Wait for VNC server to open TCP port
echo "Waiting for VNC server to start on port ${VNC_PORT}..."
timeout=15
start_time=$(date +%s)
while ! nc -z localhost ${VNC_PORT}; do
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    if [ ${elapsed_time} -ge ${timeout} ]; then
        echo "Timeout: VNC server did not start within ${timeout} seconds."
        exit 1
    fi
    sleep 0.2
done
echo "VNC server started successfully."

# Start noVNC (websockify)
websockify --web /usr/local/novnc/ ${NOVNC_PORT} localhost:${VNC_PORT} &
PID_NOVNC=$!

echo "----------------------------------------------------"
echo "  VNC/noVNC server started (Passwordless)."
echo "  Connect to:"
echo "    - Web Browser (noVNC): http://localhost:${NOVNC_PORT}/"
echo "----------------------------------------------------"
echo "Starting Playwright MCP application with full options..."

# Start Playwright MCP with full options
exec node /app/cli.js \
    --config /config/config.json \
    --viewport-size "${PLAYWRIGHT_VIEWPORT_SIZE}" \
    --no-sandbox

# Wait for main process vncserver to exit
wait $PID_VNC
