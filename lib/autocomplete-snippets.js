module.exports = {
  provider: null,

  activate() {},

  deactivate() {
    this.provider = null
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
  },

  // Expose the inclusionPriority and suggestionPriority for the autocomplete menu
  config: {
    inclusionPriority: {
      title: 'Inclusion Priority',
      description: 'Increasing this setting makes snippets more likely to appear in the autocomplete menu',
      type: 'integer',
      default: 1,
      minimum: 0,
    },
    inclusionPriority: {
      title: 'Suggestion Priority',
      description: 'Increasing this setting makes snippets appear higher in the autocomplete menu',
      type: 'integer',
      default: 2,
      minimum: 0,
    },
  }
}
