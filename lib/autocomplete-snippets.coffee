module.exports =
  provider: null

  activate: ->

  deactivate: ->
    @provider = null

  provide: ->
    unless @provider?
      SnippetsProvider = require('./snippets-provider')
      @provider = new SnippetsProvider()

    @provider
