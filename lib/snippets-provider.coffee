{Range}  = require('atom')
fuzzaldrin = require('fuzzaldrin')

module.exports =
class SnippetsProvider
  id: 'autocomplete-snippets-snippetsprovider'
  selector: '*'

  requestHandler: (options) ->
    return unless options?.cursor? and options.prefix?.length
    scopeSnippets = atom.config.get('snippets', {scope: options.cursor.getScopeDescriptor()})
    snippets = []
    for key, val of scopeSnippets
      val.label = key
      snippets.push(val)

    suggestions = @findSuggestionsForWord(snippets, options.prefix)
    return unless suggestions?.length
    return suggestions

  findSuggestionsForWord: (snippets, prefix) ->
    return [] unless snippets? and prefix?

    # Only accept snippets that start with prefix
    matchesPrefix = (snippet) ->
      snippet.prefix.lastIndexOf(prefix, 0) isnt -1

    results = for snippet in snippets when matchesPrefix(snippet)
      suggestion =
        snippet: snippet
        word: snippet.prefix
        prefix: prefix
        label: snippet.name
        isSnippet: true
      suggestion

    return results
