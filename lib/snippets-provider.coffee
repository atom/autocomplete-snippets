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

    for __, snippet of snippets when snippet.prefix.lastIndexOf(prefix, 0) isnt -1
      text: snippet.prefix
      replacementPrefix: prefix
      rightLabel: snippet.name

  onDidInsertSuggestion: ({editor}) ->
    atom.commands.dispatch(atom.views.getView(editor), 'snippets:expand')
