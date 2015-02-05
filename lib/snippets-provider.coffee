{Range}  = require('atom')
fuzzaldrin = require('fuzzaldrin')

module.exports =
class SnippetsProvider
  id: 'autocomplete-snippets-snippetsprovider'
  selector: '*'

  requestHandler: ({cursor, prefix}) ->
    return unless prefix?.length
    scopeSnippets = atom.config.get('snippets', {scope: cursor.getScopeDescriptor()})
    snippets = []
    for key, val of scopeSnippets
      val.label = key
      snippets.push(val)

    @findSuggestionsForPrefix(snippets, prefix)

  findSuggestionsForPrefix: (snippets, prefix) ->
    return [] unless snippets? and prefix?

    # Only accept snippets that start with prefix
    matchesPrefix = (snippet) ->
      snippet.prefix.lastIndexOf(prefix, 0) isnt -1

    for snippet in snippets when matchesPrefix(snippet)
      suggestion =
        snippet: snippet
        word: snippet.prefix
        prefix: prefix
        label: snippet.name
        isSnippet: true
