module.exports =
  registration: null
  snippetsProvider: null

  activate: ->
    SnippetsProvider = require('./snippets-provider')
    @snippetsProvider = new SnippetsProvider()
    @registration = atom.services.provide('autocomplete.provider', '1.0.0', {provider: @snippetsProvider})

  deactivate: ->
    @registration?.dispose()
    @registration = null
    @snippetsProvider?.dispose()
    @snippetsProvider = null
