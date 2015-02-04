module.exports =
  provider: null
  ready: false

  activate: ->
    @ready = true

  deactivate: ->
    @provider = null

  getProvider: ->
    return @provider if @provider?
    SnippetsProvider = require('./snippets-provider')
    @provider = new SnippetsProvider()
    return @provider

  provide: ->
    return {provider: @getProvider()}
