const { existsSync, mkdirSync, rmSync } = require('fs')
const { writeFile } = require('fs/promises')
const { basename, resolve } = require('path')
const { getAllFiles } = require('./util/walk')

async function parallel (path) {
  const files = getAllFiles(resolve(__dirname, './nest/'))
  const tasks = []
  if (existsSync('./.nest/')) rmSync('./.nest/', { recursive: true })
  for (const file of files) {
    if (!file.endsWith('.js')) continue
    tasks.push(new Promise((resolve, reject) => {
      async function _ (resolve, reject) {
        console.info(`[Build] ${new Date().toISOString()} T:${tasks.length + 1} | Threaded build for '${basename(file)}'`)
        const json = require(file)
        json._comment = 'DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO'
        json.exported_at = new Date().toISOString()
        json.author = 'postmaster@mxsrv.amethyst.live'
        json.config.files = JSON.stringify(json.config.files)
        json.config.startup = JSON.stringify(json.config.startup)
        json.config.logs = JSON.stringify(json.config.logs)
        if (!existsSync('./.nest/')) mkdirSync('./.nest/')
        if (!existsSync(`./.next/${json.nest}`)) mkdirSync(`./.nest/${json.nest}`)
        writeFile(`./.nest/${json.nest}/${json.name}-${json.meta.version}-${json.version}.json`, JSON.stringify(json, null, 2), 'utf8')
        return resolve({ out: JSON.stringify(json, null, 2), file, json })
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
