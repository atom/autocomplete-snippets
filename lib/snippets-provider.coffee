{Range}  = require('atom')
fuzzaldrin = require('fuzzaldrin')

module.exports =
class SnippetsProvider
  selector: '*'
  disableForSelector: '.comment'
  inclusionPriority: 1
  suggestionPriority: 2

  filterSuggestions: true

  constructor: ->
    @showIcon = atom.config.get('autocomplete-plus.defaultProvider') is 'Symbol'

  getSuggestions: ({scopeDescriptor, prefix}) ->
    return unless prefix?.length
    scopeSnippets = atom.config.get('snippets', {scope: scopeDescriptor})
    @findSuggestionsForPrefix(scopeSnippets, prefix)

  findSuggestionsForPrefix: (snippets, prefix) ->
    return [] unless snippets?

    suggestions = []
    for __, snippet of snippets when firstCharsEqual(snippet.prefix, prefix)
      suggestions.push
        iconHTML: if @showIcon then undefined else false
        type: 'snippet'
        text: snippet.prefix
        replacementPrefix: prefix
        rightLabel: snippet.name
        description: snippet.description
        descriptionMoreURL: snippet.descriptionMoreURL

    suggestions.sort(ascendingPrefixComparator)
    suggestions

  onDidInsertSuggestion: ({editor}) ->
    atom.commands.dispatch(atom.views.getView(editor), 'snippets:expand')

ascendingPrefixComparator = (a, b) -> a.prefix  - b.prefix

firstCharsEqual = (str1, str2) ->
  str1[0].toLowerCase() is str2[0].toLowerCase()
