SnippetsLoader = require('../lib/snippets-loader')
path = require('path')

describe "AutocompleteSnippets", ->
  [workspaceElement, completionDelay, editor, editorView, autocompleteSnippets, provider] = []

  beforeEach ->
    runs ->
      # Set to live completion
      atom.config.set('autocomplete-plus.enableAutoActivation', true)
      # Set the completion delay
      completionDelay = 100
      atom.config.set('autocomplete-plus.autoActivationDelay', completionDelay)
      completionDelay += 100 # Rendering delay

    fakeUserSnippetsPath = path.join(__dirname, './fixtures', 'user-snippets.cson')
    spyOn(SnippetsLoader.prototype, 'getUserSnippetsPath').andReturn(fakeUserSnippetsPath)

    waitsForPromise ->
      atom.workspace.open('sample.js').then (e) ->
        editor = e
        editorView = atom.views.getView(editor)

    runs ->
      workspaceElement = atom.views.getView(atom.workspace)
      jasmine.attachToDOM(workspaceElement)

    waitsForPromise -> atom.packages.activatePackage('language-javascript')

    waitsForPromise -> atom.packages.activatePackage('autocomplete-plus')

    waitsForPromise -> atom.packages.activatePackage("autocomplete-snippets").then (a) -> autocompleteSnippets = a.mainModule

    runs ->
      provider = autocompleteSnippets.providers[0]

    waitsFor ->
      provider.ready

  describe "when autocomplete-plus is enabled", ->
    it "shows autocompletions when there are snippets available", ->
      runs ->
        expect(editorView.querySelector('.autocomplete-plus')).not.toExist()

        editor.moveToBottom()
        editor.insertText('d')
        editor.insertText('o')

        advanceClock(completionDelay + 1000)

        expect(editorView.querySelector('.autocomplete-plus')).toExist()
        expect(editorView.querySelector('.autocomplete-plus span.word')).toHaveText('do')
        expect(editorView.querySelector('.autocomplete-plus span.label')).toHaveText('do')

  it "loads matched snippets in user snippets", ->
    runs ->
      editor.moveToBottom()

      expect(editorView.querySelector('.autocomplete-plus')).not.toExist()

      editor.insertText('b')
      editor.insertText('f')

      advanceClock(completionDelay + 1000)

      expect(editorView.querySelector('.autocomplete-plus')).toExist()
      expect(editorView.querySelector('.autocomplete-plus span.word')).toHaveText('bf')
      expect(editorView.querySelector('.autocomplete-plus span.label')).toHaveText('BarFoo')

      editor.insertText(' ')
      expect(editorView.querySelector('.autocomplete-plus')).not.toExist()

      editor.moveToBottom()
      editor.insertText('f')
      editor.insertText('b')

      advanceClock(completionDelay + 1000)

      expect(editorView.querySelector('.autocomplete-plus')).not.toExist()
