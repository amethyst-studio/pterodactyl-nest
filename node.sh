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

echo -e "${GIT_REMOTE}"
