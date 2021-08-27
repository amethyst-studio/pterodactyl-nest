if [ -d .git ] && [ "${UPDATE}" == "1" ]; then
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
if [ "${UPDATE}" == "true" ] || [ "${UPDATE}" == "1" ]; then
  nodemon --max-old-space-size="{{SERVER_MEMORY}}" "{{SCRIPT}}"
else
  node --max-old-space-size="{{SERVER_MEMORY}}" "{{SCRIPT}}"
fi
