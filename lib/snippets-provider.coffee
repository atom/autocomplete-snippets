{Range}  = require('atom')
fuzzaldrin = require('fuzzaldrin')

module.exports =
class SnippetsProvider
  id: 'autocomplete-snippets-snippetsprovider'
  selector: '*'

  requestHandler: ({cursor, prefix}) ->
    return unless prefix?.length
    scopeSnippets = atom.config.get('snippets', {scope: cursor.getScopeDescriptor()})
    @findSuggestionsForPrefix(scopeSnippets, prefix)

  findSuggestionsForPrefix: (snippets, prefix) ->
    return [] unless snippets?

    for __, snippet of snippets when snippet.prefix.lastIndexOf(prefix, 0) isnt -1
      {
        snippet: snippet
        word: snippet.prefix
        prefix: prefix
        label: snippet.name
        isSnippet: true
      }
