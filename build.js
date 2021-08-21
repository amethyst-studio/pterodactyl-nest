const { existsSync, mkdirSync } = require('fs')
const { readFile, writeFile } = require('fs/promises')
const { basename, resolve } = require('path')
const { getAllFiles } = require('./util/walk')

async function parallel (path) {
  const files = getAllFiles(resolve(__dirname, './nest/'))
  const tasks = []
  for (const file of files) {
    tasks.push(new Promise((resolve, reject) => {
      async function _ (resolve, reject) {
        console.info(`[Build] ${new Date().toISOString()} T:${tasks.length + 1} | Threaded build for '${basename(file)}'`)
        const content = await readFile(file, 'utf8')
        const json = JSON.parse(content)
        json._comment = 'DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO'
        json.meta = {
          version: 'PTDL_v1',
          update_url: null
        }
        json.exported_at = new Date().toISOString()
        json.author = 'postmaster@mxsrv.amethyst.live'
        json.startup = require('bash-minifier')(json.startup.join('\n'))
        if (json.startup === undefined || json.startup === '') return reject(new Error(`[Build] Failed @ ${file} due to missing startup command.`))
        json.config.files = JSON.stringify(json.config.files, null, 2)
        json.config.startup = JSON.stringify(json.config.startup, null, 2)
        json.config.logs = JSON.stringify(json.config.logs, null, 2)
        json.scripts.installation.script = require('bash-minifier')(json.scripts.installation.script.join('\n'))
        if (!existsSync('./distribution/')) mkdirSync('./distribution/')
        writeFile('./distribution/' + basename(file), JSON.stringify(json, null, 2), 'utf8')
        return resolve({ out: JSON.stringify(json, null, 2), file, content, json })
      }
      _(resolve, reject)
    }))
  }
  const results = await Promise.all(tasks)
  return results
}

parallel().catch((err) => {
  console.error('[Build] Parallel build of the Nest has failed.')
  throw err
})
