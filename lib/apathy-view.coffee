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
    
    # ____________________________________________________
    # Events
    # @viewDisposables.add atom.workspace.onDidAddTextEditor (event) =>
    #   editorView = atom.views.getView event.textEditor
    #   # do all decorations
    #   @decorateEditorView editorView
    # ____________________________________________________
    # wrap guide setting
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
      @textWrapObservers.add editor.onDidStopChanging =>
        editorView = atom.views.getView editor
        @wrapTextNodes editorView, '.line > .source', '<span class="apathy-span"/>'
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
    if @leftWrapGuides?.length > 0
      for wrapGuide in @leftWrapGuides
        $(wrapGuide).remove()
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
    #       moves, because jQuery.ready fires BEFORE the text has been added
    #       to the buffer. Need to get it to run just once on activation at the
    #       right time.
    $root = $(editorView.shadowRoot)
    $root.find(selector).each ->
      contents = $(this).contents()
      $.each contents, (i,val) ->
        if val.nodeType is 3
          # add tag which can be used for CSS
          match = $(this).text().trim().match /\b[\w]+\b/g
          firstWord = match?[0]
          # wrap the text
          $wrapped = $(this).wrap wrapWith
          self.customWrappedTextNodes.push $wrapped
          # --------------------
          # semantic highligting
          if atom.config.get "#{self.packageName}.semanticHighlighting"
            # update how many times this word is used (for semantic stuff).
            unless $.inArray(firstWord, self.apathyWordTracker) > -1
              self.apathyWordTracker.push firstWord
            numMatches =
              $root.find("[data-apathy-word=#{firstWord}]").length or 1
            # Apply to DOM
            $wrapped.parent().attr 'data-apathy-word', firstWord
            $root.find("[data-apathy-word=#{firstWord}]").each ->
              $(this).attr 'data-apathy-count', numMatches
              uniqueWordsCount = self.apathyWordTracker
              semanticIndex = $.inArray(firstWord, self.apathyWordTracker) % 8
              if semanticIndex > 0
                $(this).attr 'data-apathy-index', semanticIndex
                
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
