module.exports =
  config:
    disableForSelector:
      title: 'Disable Snippet Autocompletion Selector String'
      description: 'Scope selector for which snippet autocompletion should be disabled'
      type: 'string'
      default: '.comment, .string'

  provider: null

  activate: ->

  deactivate: ->
    @provider = null

  provide: ->
    unless @provider?
      SnippetsProvider = require('./snippets-provider')
      @provider = new SnippetsProvider()
      @provider.setSnippetsSource(@snippets) if @snippets?

    @provider

  consumeSnippets: (@snippets) ->
    @provider?.setSnippetsSource(@snippets)
