module.exports =
  provider: null
  ready: false

  activate: ->
    @ready = true

  deactivate: ->
    @provider = null

  provide: ->
    unless @provider?
      SnippetsProvider = require('./snippets-provider')
      @provider = new SnippetsProvider()

    {@provider}
