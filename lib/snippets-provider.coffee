{Range}  = require "atom"
{Provider, Suggestion} = require "autocomplete-plus"
fuzzaldrin = require "fuzzaldrin"
_ = require "underscore-plus"
SnippetsLoader = require "./snippets-loader"

module.exports =
class SnippetsProvider extends Provider
  initialize: ->
    @snippetsLoader = new SnippetsLoader @editor
    @snippetsLoader.loadAll (@snippets) =>
      # Turn snippet into array
      snippets = []
      for key, val of @snippets
        val.label = key
        snippets.push val
      @snippets = snippets

  ###
   * Gets called when the document has been changed. Returns an array with
   * suggestions. If `exclusive` is set to true and this method returns suggestions,
   * the suggestions will be the only ones that are displayed.
   * @return {Array}
   * @public
  ###
  buildSuggestions: ->
    selection = @editor.getSelection()
    prefix = @prefixOfSelection selection

    return unless prefix.length

    suggestions = @findSuggestionsForWord prefix

    return unless suggestions.length
    return suggestions

  ###
   * Gets called when a suggestion has been confirmed by the user. Return true
   * to replace the word with the suggestion. Return false if you want to handle
   * the behavior yourself.
   * @param  {Suggestion} suggestion
   * @return {Boolean}
   * @public
  ###
  confirm: (suggestion) ->
    @replaceTextWithMatch suggestion
    setTimeout(=>
      @editorView.trigger "snippets:expand"
    , 1)
    return false

  ###
   * Replaces the current prefix with the given match
   * @param {Object} match
   * @private
  ###
  replaceTextWithMatch: (match) ->
    selection = @editor.getSelection()
    startPosition = selection.getBufferRange().start
    buffer = @editor.getBuffer()

    # Replace the prefix with the new word
    cursorPosition = @editor.getCursorBufferPosition()
    buffer.delete Range.fromPointWithDelta(cursorPosition, 0, -match.prefix.length)
    @editor.insertText match.word

    # Move the cursor behind the new word
    suffixLength = match.word.length - match.prefix.length
    @editor.setSelectedBufferRange [startPosition, [startPosition.row, startPosition.column + suffixLength]]

  ###
   * Finds possible matches for the given string / prefix
   * @param  {String} prefix
   * @return {Array}
   * @private
  ###
  findSuggestionsForWord: (prefix) ->
    return [] unless @snippets?

    snippetsByPrefixes = {}
    prefixes = _.values(@snippets).map (snippet) ->
      snippetsByPrefixes[snippet.prefix] = snippet
      return snippet.prefix

    # Merge the scope specific words into the default word list
    words = fuzzaldrin.filter prefixes, prefix

    results = for word in words
      snippet = snippetsByPrefixes[word]
      new Suggestion this, word: word, prefix: prefix, label: snippet.label

    return results
