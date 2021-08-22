#!/bin/bash

echo "Configuring Pterodactyl Node.js Application..."

apt update &&
  apt install -y git curl jq file unzip make gcc g++ python python-dev libtool

mkdir -p /mnt/server/
cd /mnt/server/

if [ "${UPDATE}" == "false" ] || [ "${UPDATE}" == "0" ]; then
  echo -e "We will assume you are aware what you are doing and will deploy all required files manually."
  echo -e "If you wish to enable git auto updating, please reinstall the server with Update via Git enabled."
  exit 0
fi

if [[ ${GIT_REMOTE} != *.git ]]; then
  GIT_REMOTE=${GIT_REMOTE}.git
fi

if [ -z "${GIT_USERNAME}" ] && [ -z "${GIT_ACCESS_TOKEN}" ]; then
  echo "Git username and password are required to update via Git."
  exit 1
else
  GIT_REMOTE=https://${GIT_USERNAME}:${GIT_ACCESS_TOKEN}@$(echo -e ${GIT_REMOTE} | cut -d\/ -f3-)
fi

if [ $(ls -A /mnt/server) ]; then
  echo "This directory '/mnt/server' already exists. Validating status."
  if [ -d .git ]; then
    echo "Directory '/mnt/server' is compatible with updater."
    if [ -f .git/config ]; then
      echo -e "Directory has '.git/config'"
      ORIGIN=$(git config --get remote.origin.url)
    else
      echo -e "Directory does not have '.git/config'"
      echo -e "Exiting to prevent accidental damage. Please validate the clone or reinstall your server."
      exit 1
    fi
  fi

  if [ "${ORIGIN}" == "${GIT_REMOTE}" ]; then
    echo "Git origin is correct. Pulling latest changes."
    git pull
  fi
else
  echo "Directory '/mnt/server' does not exist. Cloning latest version of remote application."
  if [ -z "${GIT_BRANCH}" ]; then
    echo -e "Cloning default branch."
    git clone ${GIT_REMOTE} .
  else
    echo -e "Cloning ${GIT_BRANCH} branch."
    git clone --single-branch --branch ${GIT_BRANCH} ${GIT_ADDRESS} .
  fi
fi

if [ -f /mnt/server/package.json ]; then
  /usr/local/bin/npm install --production
else
  echo "Application does not have a package.json file. Skipping installation."
  exit 0
fi

echo -e "Installation has been successfully completed. Please validate the application and begin using your service."
exit 0
