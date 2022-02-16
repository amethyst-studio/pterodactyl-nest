#!/bin/bash

# Define the exit function.
success()
          {
  echo
  echo 'The application has completed installation successfully. Please review the transaction log for any issue then start the service.'
  exit 0
}

# Define the error function.
error()
        {
  echo
  echo 'The installation process failed due to an error. The reference code and error message are attached below.'
  echo
  echo "Reference Code: ${1}"
  echo "${2}"
  echo
  echo 'Please correct the above mentioned issues, or reach out to support.'
  echo 'Want to try again? Navigate to "Settings" and select "Reinstall Server" to attempt the install process once more.'
  exit 254
}

# Print the initial header.
echo '[amethyst-studio/pterodactyl-nest] Preparing to install the Node.js-configured environment.'
echo '  Copyright (c) 2021 Samuel Voeller on behalf of Amethyst [Live] Studio.'
echo '  Find the source at https://github.com/amethyst-studio/pterodactyl-nest'

# Check if the updater is to be used. This will rapid-terminate the installation for self-service mode.
if [[ ${UPDATE} == 'false' ]] || [[ ${UPDATE} == '0' ]]; then
  echo 'Skipping the git-based operations due to the updater variable being set to "false" or "0".'
  success
fi

# Prepare the installation environment.
echo
echo '$ mkdir /mnt/server/' && mkdir -p /mnt/server
echo '$ cd /mnt/server/' && cd /mnt/server || exit 254

# Ensure the remote is correctly formatted.
if [[ ${GIT_REMOTE} != *.git ]]; then
  GIT_REMOTE="${GIT_REMOTE}.git"
fi

# Ensure the environment variables are defined.
if [[ -z ${GIT_REMOTE} ]] || [[ -z ${GIT_USERNAME} ]] || [[ -z ${GIT_ACCESS_TOKEN} ]]; then
  error \
    'ERR_ENV_VARIABLE_MISSING' \
    'Ensure that the GIT_REMOTE, GIT_USERNAME, and GIT_ACCESS_TOKEN environment variables are set under the "Startup" view. These are all required for automatic updates.'
else
  GIT_REMOTE="https://${GIT_USERNAME}:${GIT_ACCESS_TOKEN}@$(echo -e "${GIT_REMOTE}" | cut -d/ -f3-)"
fi

# Detect if the .git directory is available to update vs using a fresh clone.
LS_MNT_SERVER=$(ls -A .)
if [[ -n ${LS_MNT_SERVER} ]]; then
  echo 'Detected files within '/mnt/server' and is now attempting to use the existing project.'
  if [[ -d .git ]]; then
    echo 'Locating the persistent origin of the current project...'
    if [[ -f .git/config ]]; then
      ORIGIN=$(git config --get remote.origin.url)
      echo 'Remote is '"${ORIGIN}"''
    else
      error \
        'GIT_CONFIG_MISSING_OR_CORRUPT' \
        'Please test the '.git' folder integrity. It potentially is missing files or corrupted in some form.'
    fi
  fi
fi

# Set the global git configuration.
echo
echo '$ git config --global user.email report@amethyst.live' && git config --global user.email 'report@amethyst.live'
echo '$ git config --global user.name Amethyst Pterodactyl.io' && git config --global user.name 'Amethyst Pterodactyl.io'
echo "$ git config --global pull.rebase true" && git config --global pull.rebase true

# Determine the installation method.
if [[ ${ORIGIN} != '' ]]; then
  # Force the project to sync with the origin being available.
  echo
  echo '$ git remote set-url origin GIT_REMOTE' && git remote set-url origin "${GIT_REMOTE}" > /dev/null 2>&1
  echo '$ git fetch --all' && git fetch --all
  echo '$ git reset --hard' && git reset --hard
  echo '$ git pull' && git pull
  success
else
  # Attempt to clone with GIT_REMOTE.
  echo
  echo "$ git clone ${GIT_REMOTE} . --single-branch" && git clone "${GIT_REMOTE}" . --single-branch
  success
fi
