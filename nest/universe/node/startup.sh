if [ -d .git ] && [ "${UPDATE}" == "1" ]; then
  git config --global pull.rebase true
  git fetch --all > /dev/null
  if [ -f package-lock.json ]; then
    rm -f package-lock.json > /dev/null
  fi
  git reset --hard > /dev/null
  git pull
fi

echo "Install: node-gyp"
npm install node-gyp > /dev/null

echo "Install: package.json"
npm install

echo -e "Launch: ${SCRIPT}"
if [ "${RESTART}" == "true" ] || [ "${RESTART}" == "1" ]; then
  forever --minUptime=500 --spinSleepTime=1000 -c "node --max-old-space-size={{SERVER_MEMORY}}" "{{SCRIPT}}"
else
  node --max-old-space-size="{{SERVER_MEMORY}}" "{{SCRIPT}}"
fi
