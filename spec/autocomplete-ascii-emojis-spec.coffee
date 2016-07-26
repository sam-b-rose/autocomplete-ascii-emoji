asciiEmojiCheatSheet = require('../lib/cheat-sheet')

packagesToTest =
  gfm:
    name: 'language-gfm'
    file: 'test.md'

describe "Ascii Emoji autocompletions", ->
  [editor, provider] = []

  getCompletions = ->
    cursor = editor.getLastCursor()
    start = cursor.getBeginningOfCurrentWordBufferPosition()
    end = cursor.getBufferPosition()
    prefix = editor.getTextInRange([start, end])
    request =
      editor: editor
      bufferPosition: end
      scopeDescriptor: cursor.getScopeDescriptor()
      prefix: prefix
    provider.getSuggestions(request)

  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage('autocomplete-ascii-emoji')

    runs ->
      provider = atom.packages.getActivePackage('autocomplete-ascii-emoji').mainModule.getProvider()

    waitsFor -> Object.keys(provider.properties).length > 0

  Object.keys(packagesToTest).forEach (packageLabel) ->
    describe "#{packageLabel} files", ->
      beforeEach ->
        waitsForPromise -> atom.packages.activatePackage(packagesToTest[packageLabel].name)
        waitsForPromise -> atom.workspace.open(packagesToTest[packageLabel].file)
        runs -> editor = atom.workspace.getActiveTextEditor()

      it "returns no completions without a prefix", ->
        editor.setText('')
        expect(getCompletions().length).toBe 0

      it "returns no completions with an improper prefix", ->
        editor.setText(':')
        editor.setCursorBufferPosition([0, 0])
        expect(getCompletions().length).toBe 0
        editor.setCursorBufferPosition([0, 1])
        expect(getCompletions().length).toBe 0

        editor.setText(':*')
        editor.setCursorBufferPosition([0, 1])
        expect(getCompletions().length).toBe 0

      it "autocompletes ACSII emoji with a proper prefix", ->
        editor.setText """
          :sh
        """
        editor.setCursorBufferPosition([0, 3])
        completions = getCompletions()
        expect(completions.length).toBe 4
        expect(completions[0].text).toBe '(๑•́ ₃ •̀๑)'
        expect(completions[0].replacementPrefix).toBe ':sh'
        expect(completions[1].text).toBe '¯\\_(ツ)_/¯'
        expect(completions[1].replacementPrefix).toBe ':sh'
        expect(completions[1].rightLabel).toMatch 'shrug'
        expect(completions[2].text).toBe '( ˇ෴ˇ )'
        expect(completions[2].replacementPrefix).toBe ':sh'
        expect(completions[2].rightLabel).toMatch 'shark'

        editor.setText """
          :cry
        """
        editor.setCursorBufferPosition([0, 4])
        completions = getCompletions()
        expect(completions.length).toBe 4
        expect(completions[0].text).toBe 'ಥ_ಥ'
        expect(completions[0].replacementPrefix).toBe ':cry'
        expect(completions[1].text).toBe '｡ﾟ( ﾟஇ‸இﾟ)ﾟ｡'
        expect(completions[1].replacementPrefix).toBe ':cry'
        expect(completions[1].rightLabel).toMatch 'cry-face'

      it "should not autocomplete markdown with prefix '::'", ->
        editor.setText """
          ::sh
        """
        editor.setCursorBufferPosition([0, 4])
        completions = getCompletions()
        expect(completions.length).toBe 0

  describe 'when the autocomplete-ascii-emoji:showCheatSheet event is triggered', ->
    workspaceElement = null
    beforeEach ->
      workspaceElement = atom.views.getView(atom.workspace)

    it 'opens ASCII Emoji Cheat Sheet in browser', ->
      spyOn asciiEmojiCheatSheet, 'openUrlInBrowser'

      atom.commands.dispatch workspaceElement, 'autocomplete-ascii-emoji:show-cheat-sheet'

      expect(asciiEmojiCheatSheet.openUrlInBrowser).toHaveBeenCalledWith 'https://gist.github.com/samrose3/37d15db8821fe1fc8edf01db24670ceb'
