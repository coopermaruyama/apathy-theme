fs = require 'fs'
path = require 'path'
{CompositeDisposable, Color} = require 'atom'
ApathyView = require './apathy-view'

class Apathy

  config:
    altFont:
      type: 'string'
      title: 'Select Font'
      default: 'Source Code Pro'
      enum: ['Source Code Pro', 'Inconsolata']
      order: 1
    enableLeftWrapGuide:
      type: 'boolean'
      title: 'Enable wrap guide on left side'
      order: 2
      default: true
    contentPaddingLeft:
      type: 'integer'
      title: 'Padding for left side of buffer in pixels'
      description: 'Use numbers only.'
      order: 3
      default: 30
      minimum: 0
    bgColorDescription:
      type: 'boolean'
      title: 'Override Core Colors (NOTE: READ THE NOTES BELOW BEFORE TOUCHING THESE!!)'
      description: '(checkbox does nothing) Make sure to reload atom (ctrl+alt+cmd+L) after changing a color!'
      order: 4
      default: false
    customSyntaxBgColor:
      type: 'color'
      title: 'Override syntax background color'
      description: 'Changes the background color your text lays on.'
      default: 'hsl(263, 20%, 9%)'
      order: 5
    customInactiveOverlayColor:
      type: 'color'
      title: 'Custom overlay background color'
      description: 'Changes overall color of everything except tabs, tree-view, and the bottom bar.'
      default: 'hsla(261, 34%, 15%, 0.9)'
      order: 6
    customUnderlayerBgColor:
      type: 'color'
      title: 'Custom under-layer background color'
      description: 'Dim color for inactive panes, under text.'
      default: 'hsl(258, 6%, 6%)'
      order: 7
    customInactivePaneBgColor:
      type: 'color'
      title: 'Custom inactive pane background color'
      description: 'Dim color for inactive panes, above text.'
      default: 'hsl(200, 5%, 11%)'
      order: 8
    enableTreeViewStyles:
      title: 'Enable tree view background image'
      description: 'Adds a background image to your tree view'
      type: 'boolean'
      default: false
      order: 9
    enableTreeViewBorder:
      title: 'Enable tree view border'
      description: 'Makes it really easy to discern nesting'
      type: 'boolean'
      default: false
      order: 10
    altStyle:
      type: 'string'
      title: 'Previous & Alternate color schemes'
      default: 'None'
      description: "If significant changes are made, the previous version(s)
        will be available for you here, as well as some alternate styles"
      enum: ['None', 'v0.2.0']
      order: 11

  activate: (state) ->
    @apathyView = new ApathyView state.apathyViewState
    @disposables = new CompositeDisposable
    @packageName = require('../package.json').name
    @disposables.add atom.config.observe """
      #{@packageName}.enableTreeViewStyles
    """, => @setTreeViewBackground()

    @disposables.add atom.config.observe """
      #{@packageName}.enableTreeViewBorder
    """, => @setTreeViewBorder()

    @disposables.add atom.config.observe "#{@packageName}.altStyle", => @doAltStyle()
    @disposables.add atom.config.observe "#{@packageName}.altFont", =>
      @doAltFont()

    # ------------------------------------------------
    #  Workaround for reload issues w/ antialiased font
    @tempDisposables = new CompositeDisposable
    paneItems = atom.workspace.getPaneItems()
    for paneItem in paneItems
      if paneItem.constructor.name is "TextEditor"
        @tempDisposables.add paneItem.onDidChangeCursorPosition =>
          atom.views?.getView?(paneItem)
            .component?.linesComponent?.remeasureCharacterWidths?()
          @tempDisposables?.dispose()
    # -----------------------------------------------
    # Apply custom overrides
    customStylePath = "#{__dirname}/../styles/custom.less"
    @writeConfig customStylePath
    # watch for changes
    customColors = ["customSyntaxBgColor", "customUnderlayerBgColor", "customInactivePaneBgColor", "customInactiveOverlayColor"]
    for color in customColors
      @disposables.add atom.config.observe "#{@packageName}.#{color}", =>
        @writeConfig customStylePath


  generateConfig: ->
    syntaxBgColor = atom.config.get( "#{@packageName}.customSyntaxBgColor").toRGBAString()
    underlayerBgColor = atom.config.get( "#{@packageName}.customUnderlayerBgColor").toRGBAString()
    inactivePaneBgColor = atom.config.get( "#{@packageName}.customInactivePaneBgColor").toRGBAString()
    inactiveOverlayColor = atom.config.get( "#{@packageName}.customInactiveOverlayColor").toRGBAString()
    theConfig = """
      @apathy-background-color: #{syntaxBgColor} !important;
      @apathy-underlayer-bg-color: #{underlayerBgColor} !important;
      @apathy-inactive-bg-color: #{inactivePaneBgColor} !important;
      @apathy-inactive-overlay-color: #{inactiveOverlayColor} !important;
    """
    return theConfig
  writeConfig: (path) ->
    fs.writeFileSync path, @generateConfig()

  setTreeViewBackground: ->
    isEnabled = atom.config.get "#{@packageName}.enableTreeViewStyles"
    treeViewStylePath = "#{__dirname}/../styles/tree-view.less"
    if isEnabled
      @activeTreeStyle = @applyStylesheet treeViewStylePath
    else
      @activeTreeStyle?.dispose()

  setTreeViewBorder: ->
    isEnabled = atom.config.get "#{@packageName}.enableTreeViewBorder"
    treeViewBorderPath = "#{__dirname}/../styles/tree-view-border.less"
    if isEnabled
      @activeTreeBorder = @applyStylesheet treeViewBorderPath
    else
      @activeTreeBorder?.dispose()


  deactivate: ->
    @disposables?.dispose()
    @activeTreeStyle?.dispose()
    @activeTreeBorder?.dispose()
    @apathyView?.destroy()

  doAltStyle: ->
    @activeStyleSheet?.dispose()
    # No need to enable the theme if it is already active.
    return if @noAltSyleSelected()
    try
      # Try to enable the requested theme.
      @activeStyleSheet = @applyStylesheet @getStylePath(@selectedAltStyle())
      @activeAltStyle = @selectedAltStyle
    catch
      # If unsuccessfull enable the default theme.
      console.debug 'setting default altStyle'

  doAltFont: ->
    @renderedFontStyle?.dispose()
    selectedFont = atom.config.get "#{@packageName}.altFont"
    unless selectedFont is atom.config.get "#{@packageName}.altFont", {excludeSources: [atom.config.getUserConfigPath()]}
      altFontStylePath = "#{__dirname}/../styles/#{@getNormalizedName(selectedFont)}.less"
      @renderedFontStyle = @applyStylesheet altFontStylePath

  getStylePath: (altStyle) ->
     path.join __dirname, "..", "themes", "#{@getNormalizedName(altStyle)}.less"

  isActiveStyle: (altStyle) ->
     altStyle is @activeAltStyle

  applyStylesheet: (sourcePath, preliminaryContent = "") ->
    stylesheetContent = fs.readFileSync sourcePath, 'utf8'
    source = atom.themes.lessCache.cssForFile sourcePath, [preliminaryContent, stylesheetContent].join '\n'
    atom.styles.addStyleSheet source, sourcePath: sourcePath, priority: 0, context: 'atom-text-editor'

  noAltSyleSelected: ->
    @selectedAltStyle() is atom.config.get "#{@packageName}.altStyle", {excludeSources: [atom.config.getUserConfigPath()]}

  selectedAltStyle: ->
    atom.config.get "#{@packageName}.altStyle"

  getNormalizedName: (name) ->
    "#{name}"
      .replace ' ', '-'
      .replace /\./g, ''
      .replace /\b\w/g, (character) -> character.toLowerCase()

  setThemeConfig: (altStyle) ->
    atom.config.set "#{@packageName}.altStyle", altStyle


  isSelectedStyle: (altStyle) ->
    selectedAltStyle = atom.config.get "#{@packageName}.altStyle"
    altStyle is selectedAltStyle

  # Resolve and apply the stylesheet specified by the path.
  #
  # This supports both CSS and Less stylsheets.
  #
  # * `stylesheetPath` A {String} path to the stylesheet that can be an
  #  absolute path or a relative path that will be resolved against the
  #  load path.
  #
  # Returns a {Disposable} on which `.dispose()` can be called to
  # remove the required stylesheet.
  requireStylesheet: (stylesheetPath) ->
    if fullPath = @resolveStylesheet(stylesheetPath)
      content = @loadStylesheet(fullPath)
      @applyStylesheet(fullPath, content)
    else
      throw new Error("Could not find a file at path '#{stylesheetPath}'")



module.exports = new Apathy
