{Range}  = require('atom')
fuzzaldrin = require('fuzzaldrin')

module.exports =
class SnippetsProvider
  selector: '*'

  getSuggestions: ({scopeDescriptor, prefix}) ->
    return unless prefix?.length
    scopeSnippets = atom.config.get('snippets', {scope: scopeDescriptor})
    @findSuggestionsForPrefix(scopeSnippets, prefix)

  findSuggestionsForPrefix: (snippets, prefix) ->
    return [] unless snippets?

    suggestions = for __, snippet of snippets when snippet.prefix.lastIndexOf(prefix, 0) isnt -1
      iconHTML: '<i class="icon-move-right"></i>'
      type: 'snippet'
      text: snippet.prefix
      replacementPrefix: prefix
      rightLabel: snippet.name
    suggestions.sort (a,b) ->
      return -1 if a.replacementPrefix == a.text
      return +1 if b.replacementPrefix == b.text
      return 0

  onDidInsertSuggestion: ({editor}) ->
    atom.commands.dispatch(atom.views.getView(editor), 'snippets:expand')
