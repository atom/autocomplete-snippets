$ = require 'jquery'

describe "AutocompleteSnippets", ->
  [workspaceElement, completionDelay, editor, editorView, autocompleteSnippets, provider] = []

  beforeEach ->
    runs ->
      # Set to live completion
      atom.config.set "autocomplete-plus.enableAutoActivation", true
      # Set the completion delay
      completionDelay = 100
      atom.config.set "autocomplete-plus.autoActivationDelay", completionDelay
      completionDelay += 100 # Rendering delay

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

    # waitsForPromise ->
    #   activationPromise = $.Deferred()
    #   atom.packages.activatePackage("autocomplete-snippets")
    #     .then =>
    #       atom.packages.on "autocomplete-snippets:loaded", =>
    #         activationPromise.resolve()
    #   return activationPromise.promise()

  describe "when autocomplete-plus is enabled", ->
    it "shows autocompletions when there are snippets available", ->
      runs ->
        expect(editorView.querySelector(".autocomplete-plus")).not.toExist()

        editor.moveToBottom()
        editor.insertText "d"
        editor.insertText "o"

        advanceClock completionDelay + 1000

        expect(editorView.querySelector(".autocomplete-plus")).toExist()
        expect(editorView.querySelector(".autocomplete-plus span.word")).toHaveText "do"
        expect(editorView.querySelector(".autocomplete-plus span.label")).toHaveText "do"

  # it "does not crash when typing an invalid folder", ->
  #   waitsForPromise ->
  #     activationPromise

  #   runs ->
  #     editorView = atom.workspaceView.getActiveView()
  #     editorView.attachToDom()
  #     editor = editorView.getEditor()

  #     expect(editorView.find(".autocomplete-plus")).not.toExist()

  #     editor.moveCursorToBottom()
  #     editor.insertText "./sample.js"
  #     editor.insertText "/"

  #     advanceClock completionDelay
