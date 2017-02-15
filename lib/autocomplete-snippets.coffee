module.exports =
  config:
    highInclusionPriority:
      title: 'High inclusion priority'
      description: 'Do not allow other packages to suppress this provider (restart required)'
      type: 'boolean'
      default: false
      order: 1

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
