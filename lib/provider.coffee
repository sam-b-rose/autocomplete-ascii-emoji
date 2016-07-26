fs = require('fs')
path = require('path')
fuzzaldrin = require('fuzzaldrin')

module.exports =
  selector: '.source.gfm, .text.md, .text.html, .text.slim, .text.plain, .text.git-commit, .comment, .string'

  wordRegex: /::?[\w\d_\+-]+$/
  properties: {}
  keys: []

  loadProperties: ->
    fs.readFile path.resolve(__dirname, '..', 'properties.json'), (error, content) =>
      return if error

      @properties = JSON.parse(content)
      @keys = Object.keys(@properties)

  getSuggestions: ({editor, bufferPosition}) ->
    prefix = @getPrefix(editor, bufferPosition)
    return [] unless prefix?.length >= 2

    asciiEmojiSuggestions = @getAsciiEmojiSuggestion(prefix)
    return asciiEmojiSuggestions

  getPrefix: (editor, bufferPosition) ->
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
    line.match(@wordRegex)?[0] or ''

  getAsciiEmojiSuggestion: (prefix) ->
    words = fuzzaldrin.filter(@keys, prefix.slice(1))
    for word in words
      {
        text: @properties[word].asciiEmoji
        replacementPrefix: prefix
        rightLabel: word
      }
