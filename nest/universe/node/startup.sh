#!/bin/bash

# Fetch the latest source code.
if [[ -d .git ]] && [[ ${UPDATE} == '1' ]]; then
  echo "Updating the remote sources from the remote Git repository."
  echo "$ git config --global pull.rebase true" && git config --global pull.rebase true
  echo "$ git fetch --all" && git fetch --all
  echo "$ git reset --hard" && git reset --hard
  echo "$ git pull" && git pull
  echo "$ git ls-files --error-unmatch package-lock.json || rm -f ./package-lock.json"
  git ls-files --error-unmatch package-lock.json || rm -f package-lock.json
fi

# Build the extra binaries used to install certain packages.
if [[ ${INSTALL_CORE} == '1' ]]; then
  echo "Installing core packages as requested by the environment."
  echo "$ npm install --no-save node-gyp" && npm install --no-save node-gyp > /dev/null 2>&1
  echo "$ npm install --no-save @mapbox/node-pre-gyp" && npm install --no-save @mapbox/node-pre-gyp > /dev/null 2>&1
fi

# Install additional packages used by the main npm install process.
if [[ ${INSTALL_ADDITIONAL} != "" ]]; then
  echo "Installing additional packages as requested by the environment."
  echo "$ npm install --no-save ${INSTALL_ADDITIONAL}" && npm install --no-save "${INSTALL_ADDITIONAL}" > /dev/null 2>&1
fi

# Install the latest application software based on the lock file if it is tracked.
echo "Installing the production dependencies from the 'package.json' provided by the user."
echo "$ npm install --only=production" && npm install --only=production > /dev/null 2>&1

# Launch the application via the specified mode.
if [[ ${AUTOMATIC_RESTART} == '1' ]]; then
  echo "Launching the application in fast-restart mode."
  npx --yes --package=forever -c forever --minUptime=500 --spinSleepTime=1000 -c 'node --max-old-space-size={{SERVER_MEMORY}} {{SCRIPT}}'
else
  echo "Launching the application in full-restart mode."
  node --max-old-space-size='{{SERVER_MEMORY}}' '{{SCRIPT}}'
fi
