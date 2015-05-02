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
    altStyle:
      type: 'string'
      title: 'Previous & Alternate color schemes'
      default: 'None'
      description: "If significant changes are made, the previous version(s) will be available for you here, as well as some alternate styles"
      enum: ['None', 'v0.2.0']
  activate: ->
    @disposables = new CompositeDisposable
    @packageName = require('../package.json').name
    @disposables.add atom.config.observe """
      #{@packageName}.enableTreeViewStyles
    """, => @setTreeViewBackground()
    @disposables.add atom.config.observe "#{@packageName}.altStyle", => @doAltStyle()

  setTreeViewBackground: ->
    isEnabled = atom.config.get "#{@packageName}.enableTreeViewStyles"
    treeViewStylePath = "#{__dirname}/../styles/tree-view.less"
    if isEnabled
      @activeTreeStyle = @applyStylesheet treeViewStylePath
    else
      @activeTreeStyle?.dispose()
      

  deactivate: ->
   @disposables.dispose()

  doAltStyle: ->
    # No need to enable the theme if it is already active.
    if @noAltSyleSelected()
        @activeStyleSheet?.dispose()
        return
    try
      # Try to enable the requested theme.
      @activeStyleSheet?.dispose()
      @activeStyleSheet = @applyStylesheet @getStylePath(@selectedAltStyle())
      @activeAltStyle = @selectedAltStyle
    catch
      # If unsuccessfull enable the default theme.
      @activeStyleSheet?.dispose()
      console.debug 'setting default altStyle'
 
  getStylePath: (altStyle) ->
     path.join __dirname, "..", "themes", "#{@getNormalizedName(altStyle)}.less"

  isActiveStyle: (altStyle) ->
     altStyle is @activeAltStyle

  applyStylesheet: (sourcePath) ->
    stylesheetContent = fs.readFileSync sourcePath, 'utf8'
    source = atom.themes.lessCache.cssForFile sourcePath, stylesheetContent
    atom.styles.addStyleSheet source, sourcePath: sourcePath, priority: 1, context: 'atom-text-editor'

  noAltSyleSelected: ->
    @selectedAltStyle() is atom.config.getDefault "#{@packageName}.altStyle"
    
  selectedAltStyle: ->
    atom.config.get "#{@packageName}.altStyle"

  getNormalizedName: (name) ->
    "#{name}"
      .replace ' ', '-'
      .replace /\./g, ''
      .replace /\b\w\./g, (character) -> character.toLowerCase()

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
