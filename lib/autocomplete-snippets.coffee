_ = require "underscore-plus"

module.exports =
  autocompletes: []
  editorSubscription: null

  activate: ->
    @editorSubscription = atom.workspaceView.eachEditorView (editor) =>
      if editor.attached and not editor.mini
        autocomplete = new Autocomplete editor
        editor.on "editor:will-be-removed", =>
          autocomplete.dispose()
          _.remove @autocompletes, autocomplete
        @autocompletes.push autocomplete

  ###
   * Cleans everything up, removes all AutocompleteView instances
  ###
  deactivate: ->
    @editorSubscription?.off()
    @editorSubscription = null
    @autocompletes.forEach (autocomplete) -> autocomplete.dispose()
    @autocompletes = []
