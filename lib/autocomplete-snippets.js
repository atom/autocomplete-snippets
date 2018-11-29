const {CompositeDisposable} = require('atom')

module.exports = {
  subscriptions: null,
  provider: null,

  activate() {
    this.subscriptions = new CompositeDisposable()
    this.subscriptions.add(atom.config.observe('autocomplete-snippets.useAutocompletePlusMinimumWordLength', (value) => {
      if (!this.provider) return
      if (value) {
        this.provider.minPrefixLength = atom.config.get('autocomplete-plus.minimumWordLength')
      } else {
        this.provider.minPrefixLength = atom.config.get('autocomplete-snippets.minimumWordLength')
      }
    }))
    this.subscriptions.add(atom.config.observe('autocomplete-snippets.minimumWordLength', (value) => {
      if (!this.provider || atom.config.get('autocomplete-snippets.useAutocompletePlusMinimumWordLength')) return
      this.provider.minPrefixLength = value
    }))
    this.subscriptions.add(atom.config.observe('autocomplete-plus.minimumWordLength', (value) => {
      if (!this.provider || !atom.config.get('autocomplete-snippets.useAutocompletePlusMinimumWordLength')) return
      this.provider.minPrefixLength = value
    }))
  },

  deactivate() {
    this.provider = null
    this.subscriptions.dispose()
  },

  provide() {
    if (this.provider == null) {
      const SnippetsProvider = require('./snippets-provider')
      this.provider = new SnippetsProvider()
      if (this.snippets != null) {
        this.provider.setSnippetsSource(this.snippets)
      }
    }

    return this.provider
  },

  consumeSnippets(snippets) {
    this.snippets = snippets
    return (this.provider != null ? this.provider.setSnippetsSource(this.snippets) : undefined)
  }
}
