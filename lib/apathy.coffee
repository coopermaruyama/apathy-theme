fs = require 'fs'
path = require 'path'
{CompositeDisposable, Color} = require 'atom'
ApathyView = require './apathy-view'
ApathyConfig = require './config'

class Apathy

  config: ApathyConfig
    # Option: Choose antialiasing/subpixel-antialiasing
    # Option: Choose brightness, saturation, contrast

  activate: (state) ->
    # Build initial state (previous state available at state.apathyViewState).
    @apathyView = new ApathyView state.apathyViewState
    @disposables = new CompositeDisposable
    @packageName = require('../package.json').name
    @customStylePath = "#{__dirname}/../styles/custom.less"

    # ----------------------------------------------
    # Handle tree-view styles
    @disposables.add atom.config.observe """
      #{@packageName}.enableTreeViewStyles
    """, => @setTreeViewBackground()

    @disposables.add atom.config.observe """
      #{@packageName}.enaAbleTreeViewBorder
    """, => @setTreeViewBorder()

    @disposables.add atom.config.observe "#{@packageName}.altStyle", => @doAltStyle()
    @disposables.add atom.config.observe "#{@packageName}.altFont", =>
      @doAltFont()

    customStylePath = "#{__dirname}/../styles/custom.less"
    @writeConfig customStylePath
    # watch for changes
    customColors = ["customSyntaxBgColor", "customUnderlayerBgColor", "customInactivePaneBgColor", "customInactiveOverlayColor"]
    for color in customColors
      @disposables.add atom.config.observe "#{@packageName}.#{color}", =>
        @writeConfig customStylePath


  generateConfig: =>
    getConfig = (theConfig) => atom.config.get("#{@packageName}.#{theConfig}")
    getColorConfig = (theConfig) =>
      atom.config.get("#{@packageName}.#{theConfig}").toRGBAString()
    syntaxBgColor = getColorConfig( "customSyntaxBgColor")
    underlayerBgColor = getColorConfig( "customUnderlayerBgColor")
    inactivePaneBgColor = getColorConfig( "customInactivePaneBgColor")
    inactiveOverlayColor = getColorConfig( "customInactiveOverlayColor")
    syntaxBrightness = getConfig("syntaxBrightness")
    syntaxSaturation = getConfig("syntaxSaturation")
    syntaxContrast = getConfig("syntaxContrast")
    theConfig = """
      @apathy-background-color: #{syntaxBgColor} !important;
      @apathy-underlayer-bg-color: #{underlayerBgColor} !important;
      @apathy-inactive-bg-color: #{inactivePaneBgColor} !important;
      @apathy-inactive-overlay-color: #{inactiveOverlayColor} !important;
      @config-syntax-brightness : #{syntaxBrightness};
      @config-syntax-saturation : #{syntaxSaturation};
      @config-syntax-contrast : #{syntaxContrast};
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
