{CompositeDisposable} = require('atom')
{$} = require 'atom-space-pen-views'

module.exports =
class ApathyView
  constructor: (serializedState) ->
    @packageName = require('../package.json').name
    @viewDisposables = new CompositeDisposable()

    $ =>
      atom.workspace.observeTextEditors (editor) =>
        self = this
        editorView = atom.views.getView editor
        $(editorView).load =>
          console.log 'editorView loaded'
          @remeasureCharacters editor
        # ____________________________________________________
        # Decorate already open editors
        @decorateEditorView editorView


    # --------------------------------------------------------------------------
    # Wrap Guide: toggle
    wrapKeyPath = "#{@packageName}.enableLeftWrapGuide"
    @wrapGuideObserver ?= new CompositeDisposable()
    @wrapGuideObserver.add atom.config.observe(
        wrapKeyPath
        (isEnabled) =>
          if isEnabled
            @forAllEditorViews (editorView) => @addLeftWrapGuides editorView
          else
            @destroyLeftWrapGuides()
    )
    # ____________________________________________________
    # Content padding setting
    cfgLeftPadding = "#{@packageName}.contentPaddingLeft"
    @viewDisposables.add atom.config.observe(
      "#{@packageName}.contentPaddingLeft"
      (newValue) =>
        @forAllEditorViews (editorView) =>
          @setLeftContentPadding editorView, newValue
    )
    # ____________________________________________________
    # Custom text wraps
    @textWrapObservers ||= new CompositeDisposable()
    @textWrapObservers.add atom.workspace.observeTextEditors (editor) =>
      editorView = atom.views.getView editor
      @wrapTextNodes editorView, '.line > .source', '<span class="apathy-span"/>'
      @textWrapObservers.add editor.onDidChangeCursorPosition (event) =>
        cursorEditorView = atom.views.getView event.cursor.editor
        @wrapTextNodes cursorEditorView, '.line > .source', '<span class="apathy-span"/>'


    # ____________________________________________________
    # Remove semantic highlights
    @viewDisposables.add atom.config.observe "#{@packageName}.semanticHighlighting", (isEnabled) =>
      @forAllEditorViews (editorView) =>
        if isEnabled
          @wrapTextNodes editorView, '.line > .source', '<span class="apathy-span"/>'
        else
          @removeSemanticHighlights editorView

    # ____________________________________________________
    # HACK: Workaround for cursor position bug when using
    #       antialiased font smoothing.
    editor = atom.workspace.getActiveTextEditor()
    @remeasureCharacters editor

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    state =
      characterWidths: {}
    editors = atom.workspace.getTextEditors()
    $.each editors, (editor) ->
      ev = atom.views.getView editor
      characterWidths =
        ev.component.linesComponent?.presenter?.characterWidthsByScope
      $.extend state.characterWidths, characterWidths
    return state


  # Tear down any state and detach
  destroy: ->
    # dispose disposables
    @textWrapObservers?.dispose()
    @viewDisposables?.dispose()
    @tmpDisposables?.dispose()
    @wrapGuideObserver?.dispose()

    @destroyLeftWrapGuides()
    @unwrapTextNodes()
    @forAllEditorViews (editorView) => @setLeftContentPadding editorView, 0
    @clearCursorStylesheets()

  ###===========================================================================
  = Apathy Methods =
  ===========================================================================###
  forAllEditorViews: (callback) ->
    for editor in atom.workspace.getTextEditors()
      editorView = atom.views.getView editor
      callback(editorView)

  decorateEditorView: (editorView) ->
    # ______________________________
    # add left wrap guide
    leftWrapGuideEnabled =
      atom.config.get "#{@packageName}.enableLeftWrapGuide"
    @addLeftWrapGuides editorView if leftWrapGuideEnabled
    # ____________________________________________________
    # Add left content padding
    leftContentPadding =
      atom.config.get "#{@packageName}.contentPaddingLeft"
    @setLeftContentPadding editorView, leftContentPadding if leftContentPadding?
    # ___________________________________________
    # custom wrap unselectable .source text nodes
    # wrapTextWith = '<span class="apathy-span"/>'
    # @wrapTextNodes editorView, '.source', wrapTextWith

  ###*
   * Adds a wrap guide to the left side of the text.
   * @method addLeftWrapGuides
  ###
  addLeftWrapGuides: (editorView) ->
    self = this
    @leftWrapGuides ?= []
    wrapGuideLeft = """
      <div class=\"wrap-guide apathy-wrap-guide" style=\"left: -5px; display: block; background-color:hsl(256,9%,6%);\"></div>
    """
    $(editorView.shadowRoot).find('.lines').each ->
      self.leftWrapGuides.push $(wrapGuideLeft).prependTo this
  ###*
   * Removes all previously injected left wrap guides from the view, unless
   * no guides exist, in which case it does nothing.
   * @param {View} editorView The view object for the editor.
   * @return {null}
  ###
  removeLeftWrapGuides: (editorView) =>
    $root = $(editorView.shadowRoot)
    $root.find('.apathy-wrap-guide').remove()
    @clearCursorStylesheets(editorView)
  ###*
   * Sets the 'left' pixel value of left wrap guides, effectively moving both
   *  wrap guides as well as the content within in to the left without causing
   *  the cursor to become misaligned.
   * @method setLeftContentPadding
   * @param  {Number}      leftPixels - Spacing between gutter and left wrap
   *                                     guide in pixels.
    ###
  setLeftContentPadding: (editorView, leftPixels = 30) ->
    $shadow = $(editorView.shadowRoot)
    $shadow.find('.lines').each ->
      $(this).css 'left', leftPixels
    # ____________________________________________________
    # Cursor fix
    cursorLineStyles = """
      <style data-name="apathy-cursor-styles">
        atom-text-editor /deep/ .line.cursor-line,
        :host(.is-focused) .line.cursor-line {
          transform: translateX(-#{leftPixels}px);
          padding-left: #{leftPixels}px;
        }
      </style>
    """
    unless $('style[data-name=apathy-cursor-styles]').length > 0
      $(cursorLineStyles).appendTo('body')
      $(cursorLineStyles).appendTo $shadow
  ###*
   * Destroy styles added to body to offset cursor line styles.
   * @method clearCursorStylesheets
  ###
  clearCursorStylesheets: ->
    $('style[data-name=apathy-cursor-styles]').remove()
  ###*
   * Destroy left wrap guides. Must be called on deactivate, otherwise if users
   *  switch themes from apathy to something else, the guides will stay.
   * @method destroyLeftWrapGuides
  ###
  destroyLeftWrapGuides: ->
    @debug 'destroying wrap guides'
    if @leftWrapGuides?.length
      $(wrapGuide).remove() for wrapGuide in @leftWrapGuides


  # -------------------------------------------------
  # Words to exclude from semantic highlighting
  excludedWords: ['function', 'var' ,'each', 'extend', '_', 'return', 'unless', 'if', 'else', 'not', 'for', 'while']

  ###*
   * Looks for text nodes and wraps them with a tag. Assuming we have the
   *  following HTML:
   *   <span>
   *     <span>lorem</span>
   *     hello // wraps this since we can't select just this via CSS otherwise.
   *   </span>
   *  There's no way to select just 'hello' with a CSS selector. Therefore, this
   *  method looks for these and wraps them with a `<span>` to make them
   *  selectable, and adds the first word in the tag into data-word attribute.
   * @method wrapTextNodes
   * @param  {string}      selector - Selector to .source.grammar nodes.
   * @param  {string}      wrapWith - String that will be used to generate a
   *                                  jQuery object to wrap matched text nodes
   *                                  with. example: '<span class="js"></span>'.
  ###
  wrapTextNodes: (editorView, selector, wrapWith) ->
    @customWrappedTextNodes ?= []
    @apathyWordTracker ?= [] # store number of times a keyword is used.
    self = this
    # FIXME Currently this doesn't happen until the 1st time the cursor
    #       moves, to ensure text is rendered in DOM.
    $root = $(editorView.shadowRoot)
    $root.find('[data-apathy-selected]').each ->
      $(this).attr 'data-apathy-selected', 'false'
    $root.find(selector).each ->
      contents = $(this).contents()
      $.each contents, (i, val) ->
        if val.nodeType is 3
          # add tag which can be used for CSS
          theText = $(this).text().trim()
          return unless theText? # move on if empty
          match = theText.match /\b[\w]+\b/g
          firstWord = match?[0]
          # wrap the text
          $wrapped = $(this).wrap wrapWith
          self.customWrappedTextNodes.push $wrapped
          # --------------------
          # semantic highligting
          self.decorateSemantic $root, $wrapped, firstWord

  ###*
   *  Given a bunch of text nodes as input, determines the importance of each
   *  by counting occurences and whether the word is selected, and semantically
   *  highlights all occurences of those words.
   *
   *  @param   {Object} $rootNode - jQuery element used as a starting point of
   *                                which all children will be processed.
   *  @param   {Object} $textNode - jQuery element containing the text node to
   *                                possibly semantically highlight.
   *  @param   {String} firstWord - First word inside $textNode.
    ###
  decorateSemantic: ($rootNode, $textNode, firstWord) ->
    return unless @validateSemantic(firstWord)
    # count how many times this word is used.
    unless $.inArray(firstWord, @apathyWordTracker) > -1
      @apathyWordTracker.push firstWord
    numMatches =
      $rootNode.find("[data-apathy-word=#{firstWord}]").length or 1
    # Check if word is under cursor
    re = new RegExp firstWord
    isSelectedWord = re.test @getWordUnderCursor()
    # Apply to DOM
    $textNode.parent().attr 'data-apathy-word', firstWord
    self = this
    $rootNode.find("[data-apathy-word=#{firstWord}]").each ->
      $(this).attr 'data-apathy-count', numMatches
      semanticIndex = $.inArray(firstWord, self.apathyWordTracker) % 6
      # Only style iff 2 or more matches
      if semanticIndex > 0 and numMatches >= 2
        $(this).attr 'data-apathy-index', semanticIndex
      # Glow if the word is under the cursor.
      if isSelectedWord
        $(this).attr 'data-apathy-selected', 'true'


  validateSemantic: (theWord) ->
    # Can't decorate if no text editor exists to be decorated!
    return false unless atom.workspace.getActiveTextEditor()?
    # Skip if user disabled this setting.
    return false unless atom.config.get "#{@packageName}.semanticHighlighting"
    # Strings only!
    return false unless typeof theWord is 'string'
    # require at least 3 letters
    return false unless theWord?.length > 3
    # check against invalid words
    return false if $.inArray(theWord, @excludedWords) > -1
    # Ok, should be fine
    return true

  ###*
   *  Get the word under the 1st cursor in the active text editor. Note that it
   *  won't return anything if you're in whitespace, or between punctuation or
   *  something.
   *  @return  {String} - Word under cursor.
  ###
  getWordUnderCursor: ->
    editor = atom.workspace.getActiveTextEditor()
    return "" unless editor?
    editorCursors = editor.cursors
    return "" unless editorCursors?.length > 0
    cursorWordBufferRange = editorCursors[0].getCurrentWordBufferRange()
    wordUnderCursor = editor.buffer.getTextInRange(cursorWordBufferRange)
    return wordUnderCursor

  removeSemanticHighlights: (editorView) ->
    attrs = 'data-apathy-index data-apathy-count'
    $(editorView.shadowRoot).find('[data-apathy-index]').removeAttr attrs
  ###*
   * Unwrap nodes wrapped by @wrapTextNodes().
   * @method unwrapTextNodes
  ###
  unwrapTextNodes: ->
    for node in @customWrappedTextNodes
      $(node).unwrap()
  ###*
   * Fixes the cursor getting mis-aligned upon re-opening files due to the
   *  characters being measured too early.
   * @method remeasureCharacters
   * @param  {object}            editor - Atom TextEditor instance.
  ###
  remeasureCharacters: (editor) ->
    @tmpDisposables ?= new CompositeDisposable()
    if editor?
      @tmpDisposables.add editor?.onDidChangeCursorPosition (event) =>
        editorView = atom.views.getView?(event.cursor.editor)
        editorView.component?.linesComponent?.remeasureCharacterWidths?()
        editorView.component?.remeasureCharacterWidths?()
        @tmpDisposables?.dispose()

  # ----------------------------------------------------------------------------
  # Debugging helpers
  #
  # To view debugging info, run the following in console:
  # > apathy = atom.packages.getActivePackage('apathy-theme').mainModule
  # > apathy.apathyView.getDebugLog()
  debug: (message) =>
    atom.notifications.addInfo "Apathy Theme: #{message}"
    @debugLog.push("Apathy Theme: #{message}")

  debugLog: []

  getDebugLog: => @debugLog.join("\n")
