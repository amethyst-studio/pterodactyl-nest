#!/bin/bash

echo "[Pterodactyl:install.sh] Node.js Universal :: STEP_INSTALL"
echo ": MKDIR /mnt/server/" && mkdir -p /mnt/server/ > /dev/null
echo ": ENTDIR /mnt/server/" && cd /mnt/server/ > /dev/null || exit

if [ "${UPDATE}" == "false" ] || [ "${UPDATE}" == "0" ]; then
  echo ""
  echo "WARN: Update via Git -> Disabled by user startup configuration."
  echo "  + You are required to manually upload your project, excluding node_modules, unless enabled."
  echo "  + If you would like to enable this feature, please update your startup settings and reinstall your server."
  echo ""
  echo ": EXIT [0] / The installation has been successfully completed."
  exit 0
fi

if [[ ${GIT_REMOTE} != *.git ]]; then
  GIT_REMOTE=${GIT_REMOTE}.git
fi

if [ -z "${GIT_USERNAME}" ] && [ -z "${GIT_ACCESS_TOKEN}" ]; then
  echo "ERR: Update via Git -> Detected invalid user startup configuration."
  echo "  + You must specify both a valid username and access token to use this feature."
  echo ""
  echo ": EXIT [1] / The installation has failed. Please review the console for more information."
  echo ": EXIT [1] / Navigate to 'Settings' and select 'Reinstall Server' once resolved."
  exit 1
else
  GIT_REMOTE=https://${GIT_USERNAME}:${GIT_ACCESS_TOKEN}@$(echo -e "${GIT_REMOTE}" | cut -d/ -f3-)
fi

if [ "$(ls -A /mnt/server)" ]; then
  echo ": CHKDIR /mnt/server/ EXISTS"
  if [ -d .git ]; then
    echo ": CHKDIR /mnt/server/.git/ EXISTS"
    if [ -f .git/config ]; then
      echo -e ": CHKFILE /mnt/server/.git/config"
      ORIGIN=$(git config --get remote.origin.url)
    else
      echo "ERR: Update via Git -> Detected invalid '/mnt/server/.git/config'."
      echo "  + The origin of the .git directory does not match the configured Git Remote URL."
      echo ""
      echo ": EXIT [1] / The installation has failed. Please review the console for more information."
      echo ": EXIT [1] / Navigate to 'Settings' and select 'Reinstall Server' once resolved."
      exit 1
    fi
  fi

  if [ "${ORIGIN}" == "${GIT_REMOTE}" ]; then
    echo ": COMMAND -> git fetch --all"
    git fetch --all > /dev/null
    if [ -f package-lock.json ]; then
      echo ": COMMAND -> rm -f package-lock.json"
      rm -f package-lock.json > /dev/null
    fi
    echo ": COMMAND -> git reset --hard"
    git reset --hard > /dev/null
    echo ": COMMAND -> git pull"
    git pull > /dev/null
  fi
else
  echo ": CHKDIR /mnt/server/ NOT-EXISTS"
  if [ -z "${GIT_BRANCH}" ]; then
    git config --global user.email "ptero@mxsrv.amethyst.live" > /dev/null
    git config --global user.name "Pterodactyl Panel Automation" > /dev/null
    echo -e ": COMMAND -> git clone \"${GIT_REMOTE}\" ."
    git clone "${GIT_REMOTE}" .
  else
    git config --global user.email "ptero@mxsrv.amethyst.live" > /dev/null
    git config --global user.name "Pterodactyl Panel Automation" > /dev/null
    echo -e ": COMMAND -> git clone --single-branch --branch \"${GIT_BRANCH}\" \"${GIT_ADDRESS}\" ."
    git clone --single-branch --branch "${GIT_BRANCH}" "${GIT_ADDRESS}" .
  fi
fi
echo ": EXIT [0] / The installation has been successfully completed."
exit 0
