CSON = require "season"
async = require "async"
path = require "path"
fs = require "fs-plus"

module.exports =
class SnippetsLoader
  loaded: false
  constructor: (@editor) ->
    @grammar = @editor.getGrammar()

  getUserSnippetsPath: ->
    userSnippetsPath = CSON.resolve path.join(atom.getConfigDirPath(), "snippets")
    userSnippetsPath ? path.join atom.getConfigDirPath(), "snippets.cson"

  loadAll: (callback) ->
    @snippets = {}
    @loadUserSnippets =>
      @loadSyntaxPackages =>
        atom.packages.emit "autocomplete-snippets:loaded"
        @loaded = true
        callback? @snippets

  loadUserSnippets: (callback) ->
    @userSnippetsFile?.off()
    userSnippetsPath = @getUserSnippetsPath()
    fs.stat userSnippetsPath, (error, stat) =>
      if stat?.isFile()
        @loadSnippetsFile userSnippetsPath, callback
      else
        callback?()

  loadSyntaxPackages: (callback) ->
    grammarPath = @grammar.path

    if grammarPath
      packagePath = path.resolve grammarPath, "../.."
      @loadSnippetsDirectory path.join(packagePath, "snippets"), =>
        callback?()
    else
      callback?()

  loadSnippetsDirectory: (snippetsDirPath, callback) ->
    return callback?() unless fs.isDirectorySync(snippetsDirPath)

    fs.readdir snippetsDirPath, (error, entries) =>
      if error?
        console.warn(error)
        callback?()
      else
        paths = entries.map (file) -> path.join snippetsDirPath, file
        async.eachSeries paths, @loadSnippetsFile.bind(this), => callback?()

  loadSnippetsFile: (filePath, callback) ->
    return callback?() unless CSON.isObjectPath(filePath)

    CSON.readFile filePath, (error, object={}) =>
      unless error?
        @add filePath, object

      callback?()

  add: (filePath, snippetsBySelector) ->
    for selector, snippetsByName of snippetsBySelector
      continue if selector.indexOf(@grammar.scopeName) < 0
      for label, snippet of snippetsByName
        snippet.label = label
        @snippets[label] = snippet
