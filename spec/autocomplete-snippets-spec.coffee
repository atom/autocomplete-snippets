describe 'AutocompleteSnippets', ->
  [completionDelay, editor, editorView] = []

  beforeEach ->
    atom.config.set('autocomplete-plus.enableAutoActivation', true)
    completionDelay = 100
    atom.config.set('autocomplete-plus.autoActivationDelay', completionDelay)
    completionDelay += 100 # Rendering delay

    workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceElement)

    snippetsMainModule = null
    autocompleteManager = null

    waitsForPromise ->
      Promise.all [
        atom.workspace.open('sample.js').then (e) ->
          editor = e
          editorView = atom.views.getView(editor)

        atom.packages.activatePackage('language-javascript')

        atom.packages.activatePackage('autocomplete-snippets')

        atom.packages.activatePackage('autocomplete-plus').then (pack) ->
          autocompleteManager = pack.mainModule.getAutocompleteManager()

        atom.packages.activatePackage('snippets').then ({mainModule}) ->
          snippetsMainModule = mainModule
          snippetsMainModule.loaded = false
      ]

    waitsFor 'snippets provider to be registered', 1000, ->
      autocompleteManager?.providerManager.providers.length > 0

    waitsFor 'all snippets to load', 3000, ->
      snippetsMainModule.loaded

  describe 'when autocomplete-plus is enabled', ->
    it 'shows autocompletions when there are snippets available', ->
      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).not.toExist()

        editor.moveToBottom()
        editor.insertText('D')
        editor.insertText('o')

        advanceClock(completionDelay)

      waitsFor 'autocomplete view to appear', 1000, ->
        editorView.querySelector('.autocomplete-plus span.word')

      runs ->
        expect(editorView.querySelector('.autocomplete-plus span.word')).toHaveText('do')
        expect(editorView.querySelector('.autocomplete-plus span.right-label')).toHaveText('do')

    it "expands the snippet on confirm", ->
      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).not.toExist()

        editor.moveToBottom()
        editor.insertText('D')
        editor.insertText('o')

        advanceClock(completionDelay)

      waitsFor 'autocomplete view to appear', 1000, ->
        editorView.querySelector('.autocomplete-plus')

      runs ->
        atom.commands.dispatch(editorView, 'autocomplete-plus:confirm')
        expect(editor.getText()).toContain '} while (true);'

  describe 'when showing suggestions', ->
    it 'sorts them in alphabetical order', ->
      unorderedPrefixes = [
        "",
        "dop",
        "do",
        "dad",
        "d"
      ]

      snippets = {}
      snippets[x] = {prefix: x, name: "", description: "", descriptionMoreURL: ""} for x in unorderedPrefixes

      SnippetsProvider = require('../lib/snippets-provider')
      sp = new SnippetsProvider()
      sp.setSnippetsSource({snippetsForScopes: (scope) -> snippets})
      suggestions = sp.getSuggestions({scopeDescriptor: "", prefix: "d"})

      suggestionsText = suggestions.map((x) -> x.text)
      expect(suggestionsText).toEqual(["d", "dad", "do", "dop"])
