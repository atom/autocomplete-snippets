path = require('path')

describe 'AutocompleteSnippets', ->
  [workspaceElement, completionDelay, editor, editorView, snippetsMain, autocompleteMain, autocompleteManager] = []

  beforeEach ->
    runs ->
      # Set to live completion
      atom.config.set('autocomplete-plus.enableAutoActivation', true)
      # Set the completion delay
      completionDelay = 100
      atom.config.set('autocomplete-plus.autoActivationDelay', completionDelay)
      completionDelay += 100 # Rendering delay
      workspaceElement = atom.views.getView(atom.workspace)
      jasmine.attachToDOM(workspaceElement)
      autocompleteMain = atom.packages.loadPackage('autocomplete-plus').mainModule
      spyOn(autocompleteMain, 'consumeProvider').andCallThrough()
      snippetsMain = atom.packages.loadPackage('autocomplete-snippets').mainModule
      spyOn(snippetsMain, 'provide').andCallThrough()

    waitsForPromise ->
      atom.workspace.open('sample.js').then (e) ->
        editor = e
        editorView = atom.views.getView(editor)

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.packages.activatePackage('autocomplete-plus')

    waitsFor ->
      autocompleteMain.autocompleteManager?.ready

    runs ->
      autocompleteManager = autocompleteMain.autocompleteManager
      spyOn(autocompleteManager, 'findSuggestions').andCallThrough()
      spyOn(autocompleteManager, 'displaySuggestions').andCallThrough()
      spyOn(autocompleteManager, 'showSuggestionList').andCallThrough()
      spyOn(autocompleteManager, 'hideSuggestionList').andCallThrough()

    waitsForPromise ->
      atom.packages.activatePackage('autocomplete-snippets')

    waitsFor ->
      snippetsMain.provide.calls.length is 1

    waitsFor ->
      autocompleteMain.consumeProvider.calls.length is 1

  afterEach ->
    jasmine.unspy(autocompleteMain, 'consumeProvider')
    jasmine.unspy(snippetsMain, 'provide')
    jasmine.unspy(autocompleteManager, 'findSuggestions')
    jasmine.unspy(autocompleteManager, 'displaySuggestions')
    jasmine.unspy(autocompleteManager, 'showSuggestionList')
    jasmine.unspy(autocompleteManager, 'hideSuggestionList')

  activateSnippetsPackage = ->
    module = null

    runs ->
      module = null

    waitsForPromise ->
      atom.packages.activatePackage('snippets').then ({mainModule}) ->
        module = mainModule
        module.loaded = false

    waitsFor 'all snippets to load', 3000, ->
      module.loaded

  describe 'when autocomplete-plus is enabled', ->

    it 'shows autocompletions when there are snippets available', ->
      activateSnippetsPackage()

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).not.toExist()

        editor.moveToBottom()
        editor.insertText('d')
        editor.insertText('o')

        advanceClock(completionDelay)

      waitsFor ->
        autocompleteManager.displaySuggestions.calls.length is 1

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).toExist()
        expect(editorView.querySelector('.autocomplete-plus span.word')).toHaveText('do')
        expect(editorView.querySelector('.autocomplete-plus span.completion-label')).toHaveText('do')

    # TODO: This test makes no sense - how does it test user snippet loading? Doesn't look like it does...
    it 'loads matched snippets in user snippets', ->
      activateSnippetsPackage()

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).not.toExist()

        editor.moveToBottom()
        editor.insertText('d')
        editor.insertText('o')

        advanceClock(completionDelay)

      waitsFor ->
        autocompleteManager.displaySuggestions.calls.length is 1

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).toExist()
        expect(editorView.querySelector('.autocomplete-plus span.word')).toHaveText('do')
        expect(editorView.querySelector('.autocomplete-plus span.completion-label')).toHaveText('do')
        editor.insertText(' ')
        advanceClock(completionDelay)

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).not.toExist()

        editor.moveToBottom()
        editor.insertText('f')
        editor.insertText('b')
        advanceClock(completionDelay)

      waitsFor ->
        autocompleteManager.findSuggestions.calls.length is 2

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).not.toExist()
