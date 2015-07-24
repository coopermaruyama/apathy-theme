{CompositeDisposable} = require('atom')
{$} = require 'atom-space-pen-views'

module.exports =
class ApathyView
  constructor: (serializedState) ->
    @packageName = require('../package.json').name
    @viewDisposables = new CompositeDisposable()
    self = this

    $ =>
      @debug 'Got event - jQuery.ready'
      ###*
       * Initialize & decorate newly-created TextEditor instances.
       * @param {TextEditor} editor - Text editor to decorate using config.
       * @return {Disposable}
      ###
      @viewDisposables.add atom.workspace.observeTextEditors (editor) =>
        editorView = atom.views.getView editor
        @decorateEditorView editorView
        @debug 'event triggered - observeTextEditor'
        setTimeout =>
          wrapWith = '<span class="apathy-span"/>'
          @wrapTextNodes(editorView, '.line > .source', wrapWith)
          @debug 'Wrapped text nodes.'
          # HACK Fixes misaligned cursors due to character measurement
          # occuring  before our custom font is actually loaded. Here we
          # fix this by waiting a bit then forcing another measurement.
          # TODO Only run this on already-open editors.
          @remeasureCharacters editor
          @debug('Remeasured characters')
        , 500


    # --------------------------------------------------------------------------
    # Wrap Guide: toggle
    wrapKeyPath = "#{@packageName}.enableLeftWrapGuide"
    @wrapGuideDisposables ?= new CompositeDisposable()
    wrapGuideConfigObserver =
      atom.config.onDidChange wrapKeyPath, (isEnabled) =>
        @debug 'got event - config.enableLeftWrapGuide changed.'
        if isEnabled
          @forAllEditorViews (editorView) =>
            theEditor = editorView.model
            editorScope = theEditor.getLastCursor().getScopeDescriptor()
            @updateWrapGuides(editorView, editorScope)
        else
          @destroyLeftWrapGuides()
    @wrapGuideDisposables.add(wrapGuideConfigObserver)

    # --------------------------------------------------------------------------
    # Content padding setting
    cfgLeftPadding = "#{@packageName}.contentPaddingLeft"
    leftPaddingConfigObserver =
      atom.config.onDidChange cfgLeftPadding, (newValue) =>
        softWrapEnabled = @getSetting('editor.softWrap')
        return unless softWrapEnabled?
        @forAllEditorViews (editorView) =>
          @setLeftContentPadding editorView, newValue
    @viewDisposables.add(leftPaddingConfigObserver)

    # --------------------------------------------------------------------------
    # Semantic highlights enabled/disabled
    semHighlightPath = "#{@packageName}.semanticHighlighting"
    highlightConfigObserver =
      atom.config.onDidChange semHighlightPath, (isEnabled) =>
        @forAllEditorViews (editorView) =>
          if isEnabled
            wrapWith = '<span class="apathy-span"/>'
            @wrapTextNodes(editorView, '.line > .source', wrapWith)
          else
            @removeSemanticHighlights(editorView)
    @viewDisposables.add(highlightConfigObserver)

    # --------------------------------------------------------------------------
    # Event: user enables/disables soft wrap.
    softWrapConfigObserver =
      atom.config.onDidChange "editor.softWrap", (isEnabled) =>
        @debug 'got event - editor.softwrap config changed'
        @forAllEditorViews (editorView) =>
          editorModel = editorView.model
          editorScope = editorModel.getLastCursor().getScopeDescriptor()
          @updateWrapGuides(editorView, editorScope)
    @viewDisposables.add(softWrapConfigObserver)


    # Text editor observers
    @editorDisposables = new CompositeDisposable()
    @viewDisposables.add atom.workspace.observeTextEditors (editor) =>
      editorView = atom.views.getView(editor)
      editorScope = editor.getLastCursor().getScopeDescriptor()
      softWrapDisposable = editor.onDidChangeSoftWrapped =>
        @updateWrapGuides(editorView, editorScope)
      semanticDisposable = editor.onDidStopChanging =>
        wrapWith = '<span class="apathy-span"/>'
        @wrapTextNodes(editorView, '.line > .source', wrapWith)
      @editorDisposables.add(softWrapDisposable)
      editor.onDidDestroy -> softWrapDisposable?.dispose()

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    state =
      characterWidths: {}
    editors = atom.workspace.getTextEditors()
    $.each editors, (editor) ->
      ev = atom.views.getView(editor)
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
    @wrapGuideDisposables?.dispose()

    @destroyLeftWrapGuides()
    @unwrapTextNodes()
    @forAllEditorViews (editorView) =>
      @setLeftContentPadding editorView, 0
      @clearCursorStylesheets(editorView)

  ###===========================================================================
  = Apathy Methods =
  ===========================================================================###
  forAllEditors: (callback) ->
    for editor in atom.workspace.getTextEditors()
      callback(editor)

  forAllEditorViews: (callback) ->
    @forAllEditors (editor) ->
      callback(atom.views.getView(editor))

  getSetting: (configPath, external = false) =>
    fullConfigPath =
      if external then configPath else "#{@packageName}.#{configPath}"
    return atom.config.get(fullConfigPath)

  decorateEditorView: (editorView) =>
    @updateWrapGuides(editorView)
    @debug 'method called: decorateEditorView'
    # ___________________________________________
    # custom wrap unselectable .source text nodes
    # wrapTextWith = '<span class="apathy-span"/>'
    # @wrapTextNodes editorView, '.source', wrapTextWith

  ###*
   * Perform all actions relevant to the wrap guides for the passed-in view.
   * Should be called after any event occurs that should affect the state of
   * the wrap guides, such as disabling soft wrap or left wrap guide padding.
   * @param {obj} editorView The view of any {TextEditor} instance.
   * @return {null}
  ###
  updateWrapGuides: (editorView, editorScope) =>
    unless editorView?
      throw new Error('updateWrapGuides: editorView undefined')
      @debug 'ERROR: editorView undefined in updateWrapGuides!'
      return
    @debug 'method called: updateWrapGuides'
    editor = editorView.model
    # Get config
    cfgOptions = {scope: editorScope}
    leftWrapGuideEnabled =
      atom.config.get "#{@packageName}.enableLeftWrapGuide", cfgOptions
    softWrapEnabled = editor.isSoftWrapped()
    leftContentPadding =
      atom.config.get "#{@packageName}.contentPaddingLeft", cfgOptions
    @debug "leftContentPadding: #{leftContentPadding}"
    @debug "softWraEnabled: #{softWrapEnabled}"
    @debug "leftWrapGuideEnabled: #{leftWrapGuideEnabled}"
    # Add or remove wrap guide accordingly.
    if leftWrapGuideEnabled and softWrapEnabled
      @debug "Should add left wrap guides: true"
      @addLeftWrapGuides(editorView)
      if leftContentPadding?
        @setLeftContentPadding(editorView, leftContentPadding)
    else
      @debug "Should add left wrap guides: false"
      @removeLeftWrapGuides editorView
      @clearCursorStylesheets(editorView)

  ###*
   * Adds a wrap guide to the left side of the text.
   * @method addLeftWrapGuides
  ###
  addLeftWrapGuides: (editorView) =>
    @leftWrapGuides ?= []
    @debug 'called: addLeftWrapGuides'
    $existing = $('.scroll-view .apathy-wrap-guide', editorView.shadowRoot)
    return if $existing.length
    wrapGuideLeft = """
      <div class=\"wrap-guide apathy-wrap-guide" style=\"left: -5px; display: block;\"></div>
    """
    $lines = $('.scroll-view .lines', editorView.shadowRoot)
    wrapGuideElement = $(wrapGuideLeft).prependTo($lines)
    @leftWrapGuides.push(wrapGuideElement)

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
  setLeftContentPadding: (editorView, leftPixels = 30) =>
    setTimeout =>
      @debug "did event - setLeftContentPadding -> editorView.onDidAttach"
      @clearCursorStylesheets(editorView)
      @debug 'called setLeftContentPadding'
      editor = editorView.model
      lineHeight = editor.getLineHeightInPixels()
      buffer = editor.getBuffer()
      # Generated stylesheet to fix offsets caused by left padding.
      cursorLineStyles = """
        <style data-name="apathy-cursor-styles">
          atom-text-editor /deep/ .line.cursor-line,
          :host(.is-focused) .line.cursor-line {
            transform: translateX(-#{leftPixels}px);
            padding-left: #{leftPixels}px;
          }
          atom-text-editor /deep/ .lines, :host .lines {
            left: #{leftPixels}px !important;
          }
          :host .jshint-line::after {
            content: ' ';
            position: absolute;
            width: #{leftPixels}px;
            top: 0;
            bottom: 0;
            background-color: inherit;
            left: -#{leftPixels}px;
          }
          atom-text-editor .highlights .region:after,
          :host .highlights .region:after {
            content: ' ';
            position: absolute;
            width: 100%;
            top: 0;
            bottom: 0;
            background-color: inherit;
            transform: translateX(-#{editor.getWidth()}px) translateY(#{lineHeight}px);
            right: 0;
            left: 0;
          }
        </style>
      """
      stylesName = 'style[data-name=apathy-cursor-styles]'
      unless $(stylesName, editorView.stylesElement).length > 0
        $(cursorLineStyles).appendTo(editorView.stylesElement)
    , 500
  ###*
   * Destroy styles added to body to offset cursor line styles.
   * @method clearCursorStylesheets
  ###
  clearCursorStylesheets: (editorView) ->
    @debug 'Clearing cursor styles'
    $('style[data-name=apathy-cursor-styles]', editorView.stylesElement).remove()
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
    @debug 'called: wrapTextNodes'
    self = this
    $root = $(editorView.shadowRoot)
    $root.find('[data-apathy-selected]').attr('data-apathy-selected', 'false')
    $root.find(selector).each ->
      $(this)
        .contents()
        .filter (i, val) -> val.nodeType is 3
        .each (i, val) ->
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
    if @getSetting('debug')
      atom.notifications.addInfo "Apathy Theme: #{message}"
      @debugLog.push("Apathy Theme: #{message}")

  debugLog: []

  getDebugLog: => console.log @debugLog.join("\n")
