fs = require 'fs'
path = require 'path'
{CompositeDisposable} = require 'atom'

class Apathy

  config:
    enableTreeViewStyles:
      title: 'Enable tree view background image'
      description: 'Adds a background image to your tree view'
      type: 'boolean'
      default: false
      order: 1
    enableTreeViewBorder:
      title: 'Enable tree view border'
      description: 'Makes it really easy to discern nesting'
      type: 'boolean'
      default: false
      order: 2
    altStyle:
      type: 'string'
      title: 'Previous & Alternate color schemes'
      default: 'None'
      description: "If significant changes are made, the previous version(s)
        will be available for you here, as well as some alternate styles"
      enum: ['None', 'v0.2.0']
      order: 4
    altFont:
      type: 'string'
      title: 'Select Font'
      default: 'Source Code Pro'
      enum: ['Source Code Pro', 'Inconsolata']
      order: 3
  activate: ->
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
          console.log "changed pane"
          atom.views.getView(paneItem)
            .component.linesComponent.remeasureCharacterWidths()
          @tempDisposables?.dispose()

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
   @disposables.dispose()

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

  applyStylesheet: (sourcePath) ->
    stylesheetContent = fs.readFileSync sourcePath, 'utf8'
    source = atom.themes.lessCache.cssForFile sourcePath, stylesheetContent
    atom.styles.addStyleSheet source, sourcePath: sourcePath, priority: 1, context: 'atom-text-editor'

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
