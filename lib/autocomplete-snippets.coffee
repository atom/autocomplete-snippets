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

  provide: ->
    {provider: @getProvider()}
