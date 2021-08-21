const fs = require('fs')
const path = require('path')

function getAllFiles (folder, files = []) {
  files = files || []

  fs.readdirSync(folder).forEach((file) => {
    if (fs.statSync(folder + '/' + file).isDirectory()) {
      files = getAllFiles(folder + '/' + file, files)
    } else {
      files.push(path.join(folder, '/', file))
    }
  })

  return files
}

module.exports = { getAllFiles }
