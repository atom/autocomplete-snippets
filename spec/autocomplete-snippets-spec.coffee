path = require('path')

describe 'AutocompleteSnippets', ->
  [workspaceElement, completionDelay, editor, editorView, autocompleteManager, didAutocomplete] = []

  beforeEach ->
    runs ->
      didAutocomplete = false
      # Set to live completion
      atom.config.set('autocomplete-plus.enableAutoActivation', true)
      # Set the completion delay
      completionDelay = 100
      atom.config.set('autocomplete-plus.autoActivationDelay', completionDelay)
      completionDelay += 100 # Rendering delay

    waitsForPromise ->
      atom.workspace.open('sample.js').then (e) ->
        editor = e
        editorView = atom.views.getView(editor)

    runs ->
      workspaceElement = atom.views.getView(atom.workspace)
      jasmine.attachToDOM(workspaceElement)

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise -> atom.packages.activatePackage('autocomplete-plus').then (a) ->
      autocompleteManager = a.mainModule.autocompleteManager
      spyOn(autocompleteManager, 'runAutocompletion').andCallThrough();
      spyOn(autocompleteManager, 'showSuggestions').andCallThrough()
      spyOn(autocompleteManager, 'showSuggestionList').andCallThrough()
      spyOn(autocompleteManager, 'hideSuggestionList').andCallThrough()
      autocompleteManager.onDidAutocomplete ->
        didAutocomplete = true

    waitsForPromise ->
      atom.packages.activatePackage('autocomplete-snippets')

  afterEach ->
    didAutocomplete = false
    jasmine.unspy(autocompleteManager, 'runAutocompletion')
    jasmine.unspy(autocompleteManager, 'showSuggestions')
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

        advanceClock(completionDelay + 1000)

      waitsFor ->
        autocompleteManager.showSuggestions.calls.length is 1

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).toExist()
        expect(editorView.querySelector('.autocomplete-plus span.word')).toHaveText('do')
        expect(editorView.querySelector('.autocomplete-plus span.label')).toHaveText('do')

    # TODO: This test makes no sense - how does it test user snippet loading? Doesn't look like it does...
    it 'loads matched snippets in user snippets', ->
      activateSnippetsPackage()

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).not.toExist()

        editor.moveToBottom()
        editor.insertText('d')
        editor.insertText('o')

        advanceClock(completionDelay + 1000)

      waitsFor ->
        autocompleteManager.showSuggestions.calls.length is 1

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).toExist()
        expect(editorView.querySelector('.autocomplete-plus span.word')).toHaveText('do')
        expect(editorView.querySelector('.autocomplete-plus span.label')).toHaveText('do')
        editor.insertText(' ')

      waitsFor ->
        autocompleteManager.hideSuggestionList.calls.length is 3

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).not.toExist()

        editor.moveToBottom()
        editor.insertText('f')
        editor.insertText('b')
        advanceClock(completionDelay + 1000)

      waitsFor ->
        autocompleteManager.runAutocompletion.calls.length is 2

      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).not.toExist()
