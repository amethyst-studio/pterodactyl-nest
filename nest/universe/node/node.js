
const _ = require('bash-minifier')
const { readFileSync } = require('fs')
const { resolve } = require('path')

const _id = {
  name: 'Node.js',
  nest: 'Universe',
  description: 'Universe Node.js Runner for Pterodactyl. Built-in git update and forever-cli for rapid automated restarts.',
  version: '1.0.0'
}

const _variable = [
  {
    name: 'Initialization Script',
    description: "The javascript to be executed with the Node.js runtime.",
    env_variable: 'SCRIPT',
    default_value: './index.js',
    user_viewable: true,
    user_editable: true,
    rules: 'required|string|max:512'
  },
  {
    name: 'Restart with Forever',
    description: 'If restarting via the "forever" cli should be used.',
    env_variable: 'AUTOMATIC_RESTART',
    default_value: '0',
    user_viewable: true,
    user_editable: true,
    rules: 'required|boolean'
  },
  {
    name: 'NPM Core Packages',
    description: 'If core packages such as "node-gyp" and "@mapbox/node-pre-gyp" should be installed on each startup.',
    env_variable: 'INSTALL_CORE',
    default_value: '0',
    user_viewable: true,
    user_editable: true,
    rules: 'required|boolean'
  },
  {
    name: 'NPM Additional Packages',
    description: 'Additional packages to be installed on each startup via "npm install".',
    env_variable: 'INSTALL_ADDITIONAL',
    default_value: '',
    user_viewable: true,
    user_editable: true,
    rules: 'required|string|max:4096'
  },
  {
    name: 'Update via Git',
    description: 'If the runtime should attempt to automatically update your project by doing a hard clone of your remote. Local modifications will be lost on each startup.',
    env_variable: 'UPDATE',
    default_value: '0',
    user_viewable: true,
    user_editable: true,
    rules: 'required|boolean'
  },
  {
    name: 'Git Repository URL',
    description: "The URL of upstream git repository to clone from for 'Update via Git'.",
    env_variable: 'GIT_REMOTE',
    default_value: '',
    user_viewable: true,
    user_editable: true,
    rules: 'string|max:512'
  },
  {
    name: 'Git Username',
    description: 'The username to access the upstream git host.',
    env_variable: 'GIT_USERNAME',
    default_value: '',
    user_viewable: true,
    user_editable: true,
    rules: 'string|max:64'
  },
  {
    name: 'Git Token',
    description: 'The access token or password to the upstream git host. Tokens are greatly recommend if available.',
    env_variable: 'GIT_ACCESS_TOKEN',
    default_value: '',
    user_viewable: true,
    user_editable: true,
    rules: 'string|max:256'
  }
]

/**
 * The build function used to compile the final JSON.
 */
function build () {
  const _export = {
    meta: {
      version: 'PTDL_v1'
    },
    ..._id,
    images: [
      'ghcr.io/amethyst-studio/yolks:node_12',
      'ghcr.io/amethyst-studio/yolks:node_14',
      'ghcr.io/amethyst-studio/yolks:node_15',
      'ghcr.io/amethyst-studio/yolks:node_16',
      'ghcr.io/amethyst-studio/yolks:node_17',
    ],
    startup: _(readFileSync(resolve(__dirname, './startup.sh'), 'utf-8')),
    config: {
      files: {},
      startup: {
        done: '[Pterodactyl] We are ready.'
      },
      logs: {},
      stop: '^^C'
    },
    scripts: {
      installation: {
        script: _(readFileSync(resolve(__dirname, './install.sh'), 'utf-8')),
        container: 'ghcr.io/amethyst-studio/yolks:node_core',
        entrypoint: 'bash'
      }
    },
    variables: _variable
  }
  return _export
}

module.exports = { ...build() }
