module.exports = {
  root: true,
  parserOptions: {
    ecmaVersion: 2020,
    ecmaFeatures: {
      impliedStrict: true
    }
  },
  plugins: [],
  extends: [
    'eslint:recommended',
    'standard',
    'plugin:node/recommended',
    'plugin:promise/recommended'
  ],
  env: {
    node: true,
    mocha: true
  }
}
