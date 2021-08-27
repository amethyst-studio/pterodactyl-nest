
const _ = require('bash-minifier')
const { readFileSync } = require('fs')
const { resolve } = require('path')

const _id = {
  name: 'Node.js',
  nest: 'Universe',
  description: 'Universe Node.js Runner for Pterodactyl. Built-in GitHub updater and nodemon for automatic restart.',
  version: '1.0.0'
}

const _variable = [
  {
    name: 'Main Script',
    description: "The name of the file to be executed with Node.js runtime. This is specific to your project, usually being './index.js' as the file.",
    env_variable: 'SCRIPT',
    default_value: './index.js',
    user_viewable: true,
    user_editable: true,
    rules: 'required|string|max:512'
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
    name: 'Restart via Nodemon',
    description: 'If the runtime should attempt to automatically restart your project upon exiting abnormaly.',
    env_variable: 'RESTART',
    default_value: '0',
    user_viewable: true,
    user_editable: true,
    rules: 'required|boolean'
  },
  {
    name: 'Git Remote',
    description: "The URL of upstream git host to clone from for 'Update via Git'.",
    env_variable: 'GIT_REMOTE',
    default_value: '',
    user_viewable: true,
    user_editable: true,
    rules: 'string|max:512'
  },
  {
    name: 'Username',
    description: 'The username to access the upstream git host.',
    env_variable: 'GIT_USERNAME',
    default_value: '',
    user_viewable: true,
    user_editable: true,
    rules: 'string|max:64'
  },
  {
    name: 'Access Token',
    description: 'The access token to access the upstream git host. You can use your password, but we greatly recommend access token if available.',
    env_variable: 'GIT_ACCESS_TOKEN',
    default_value: '',
    user_viewable: true,
    user_editable: true,
    rules: 'string|max:256'
  }
]

/**
 *
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
      'ghcr.io/amethyst-studio/yolks:node_16'
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
