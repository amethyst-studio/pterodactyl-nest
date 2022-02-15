#!/bin/bash
cd /home/container || exit

# trunk-ignore(shellcheck/SC2312)
INTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')
INTERNAL_PORT="{{server.build.default.port}}"
NODE_VERSION=$(node --version)
export INTERNAL_IP

# Detail localized information.
echo
echo '=== Local Configuration ==='
echo "Node.js Version: ${NODE_VERSION}"
echo "Mapped IP: ${INTERNAL_IP}"
echo "Mapped Port: ${INTERNAL_PORT}"
echo '=-=-=-=-=-=-=-=-=-=-=-=-=-='
echo
echo

# Initialize the application.
MODIFIED_STARTUP=$(echo -e "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo "$ ${MODIFIED_STARTUP}"
eval "${MODIFIED_STARTUP}"
