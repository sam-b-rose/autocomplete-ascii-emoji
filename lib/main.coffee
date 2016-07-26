provider = require('./provider')

module.exports =
  activate: ->
    provider.loadProperties()

    atom.commands.add 'atom-workspace',
      'autocomplete-ascii-emoji:show-cheat-sheet': ->
        require('./cheat-sheet').show()

  getProvider: -> provider
