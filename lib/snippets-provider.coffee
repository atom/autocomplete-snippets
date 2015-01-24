{Range}  = require('atom')
fuzzaldrin = require('fuzzaldrin')

module.exports =
ProviderClass: (Provider, Suggestion)  ->
  class SnippetsProvider extends Provider
    initialize: (editor) =>
      @ready = false
      @editor = editor
      @snippets = atom.config.get 'snippets', scope: @editor.getLastCursor().getScopeDescriptor()
      snippets = []
      for key, val of @snippets
        val.label = key
        snippets.push(val)
      @snippets = snippets
      @ready = true

    ###
     * Gets called when the document has been changed. Returns an array with
     * suggestions. If `exclusive` is set to true and this method returns suggestions,
     * the suggestions will be the only ones that are displayed.
     * @return {Array}
     * @public
    ###
    buildSuggestions: ->
      return unless @ready
      selection = @editor.getLastSelection()
      prefix = @prefixOfSelection(selection)

      return unless prefix.length

      suggestions = @findSuggestionsForWord(prefix)

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
      @replaceTextWithMatch(suggestion)
      setTimeout(=>
        atom.commands.dispatch(atom.views.getView(@editor), 'snippets:expand')
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
      buffer.delete(Range.fromPointWithDelta(cursorPosition, 0, -match.prefix.length))
      @editor.insertText(match.word)

    ###
     * Finds possible matches for the given string / prefix
     * @param  {String} prefix
     * @return {Array}
     * @private
    ###
    findSuggestionsForWord: (prefix) ->
      return [] unless @snippets?

      # Only accept snippets that start with prefix
      matchesPrefix = (snippet) ->
        snippet.prefix.lastIndexOf(prefix, 0) isnt -1

      results = for snippet in @snippets when matchesPrefix(snippet)
        word = snippet.prefix
        label = snippet.name
        new Suggestion(this, word: word, prefix: prefix, label: label)

      return results
