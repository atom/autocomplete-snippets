describe 'AutocompleteSnippets', ->
  [completionDelay, editor, editorView, snippetsMain, autocompleteMain, autocompleteManager] = []

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
      Promise.all [
        atom.packages.activatePackage('language-javascript')
        atom.packages.activatePackage('autocomplete-plus')
        atom.packages.activatePackage('autocomplete-snippets')
      ]

    waitsFor ->
      autocompleteMain.autocompleteManager?.ready and
        snippetsMain.provide.calls.length is 1 and
        autocompleteMain.consumeProvider.calls.length is 1

    runs ->
      autocompleteManager = autocompleteMain.autocompleteManager
      spyOn(autocompleteManager, 'findSuggestions').andCallThrough()
      spyOn(autocompleteManager, 'displaySuggestions').andCallThrough()

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

    it "expands the snippet on confirm", ->
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

      runs ->
        atom.commands.dispatch(editorView, 'autocomplete-plus:confirm')
        expect(editor.getText()).toContain '} while (true);'
