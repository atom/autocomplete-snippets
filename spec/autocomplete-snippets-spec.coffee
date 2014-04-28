{WorkspaceView, $} = require "atom"

describe "AutocompleteSnippets", ->
  [activationPromise, completionDelay] = []

  beforeEach ->
    # Enable live autocompletion
    atom.config.set "autocomplete-plus.enableAutoActivation", true

    # Set the completion delay
    completionDelay = 100
    atom.config.set "autocomplete-plus.autoActivationDelay", completionDelay
    completionDelay += 100 # Rendering delay

    atom.workspaceView = new WorkspaceView
    atom.workspaceView.openSync "sample.js"
    atom.workspaceView.simulateDomAttachment()

    waitsForPromise ->
      atom.packages.activatePackage('grammar-selector')

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      activationPromise = $.Deferred()
      atom.packages.activatePackage("autocomplete-snippets")
        .then (pkg) => atom.packages.activatePackage("autocomplete-plus")
        .then =>
          atom.packages.on "autocomplete-snippets:loaded", =>
            activationPromise.resolve()

      return activationPromise.promise()

  it "shows autocompletions when there are snippets available", ->
    runs ->

      editorView = atom.workspaceView.getActiveView()
      editorView.attachToDom()
      editor = editorView.getEditor()

      expect(editorView.find(".autocomplete-plus")).not.toExist()

      editor.moveCursorToBottom()
      editor.insertText "d"
      editor.insertText "o"

      advanceClock completionDelay + 1000

      expect(editorView.find(".autocomplete-plus")).toExist()
      expect(editorView.find(".autocomplete-plus span.word:eq(0)")).toHaveText "do"
      expect(editorView.find(".autocomplete-plus span.label:eq(0)")).toHaveText "do"

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
