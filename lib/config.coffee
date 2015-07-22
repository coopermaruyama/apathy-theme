ApathyConfig =
semanticHighlighting:
  type: 'boolean'
  title: 'Enable semantic highlighting'
  description: 'Looks for text that has no grammar applied and semantically highlights them.'
  default: true
  order: 1
altFont:
  type: 'string'
  title: 'Select Font'
  default: 'Source Code Pro'
  enum: ['Source Code Pro', 'Inconsolata']
  order: 2
enableLeftWrapGuide:
  type: 'boolean'
  title: 'Enable wrap guide on left side'
  order: 3
  default: true
contentPaddingLeft:
  type: 'integer'
  title: 'Padding for left side of buffer in pixels'
  description: 'Use numbers only.'
  order: 4
  default: 30
  minimum: 0
bgColorDescription:
  type: 'boolean'
  title: 'Override Core Colors (NOTE: READ THE NOTES BELOW BEFORE TOUCHING THESE!!)'
  description: '(checkbox does nothing) Make sure to reload atom (ctrl+alt+cmd+L) after changing a color!'
  order: 5
  default: false
customSyntaxBgColor:
  type: 'color'
  title: 'Override syntax background color'
  description: 'Changes the background color your text lays on.'
  default: 'hsl(260, 25%, 6%)'
  order: 6
customInactiveOverlayColor:
  type: 'color'
  title: 'Custom overlay background color'
  description: 'Changes overall color of everything except tabs, tree-view, and the bottom bar.'
  default: 'hsla(261, 34%, 15%, 0.9)'
  order: 7
customUnderlayerBgColor:
  type: 'color'
  title: 'Custom under-layer background color'
  description: 'Dim color for inactive panes, under text.'
  default: 'hsl(258, 6%, 6%)'
  order: 8
customInactivePaneBgColor:
  type: 'color'
  title: 'Custom inactive pane background color'
  description: 'Dim color for inactive panes, above text.'
  default: 'hsl(260,5%,11%)'
  order: 9
enableTreeViewStyles:
  title: 'Enable tree view background image'
  description: 'Adds a background image to your tree view'
  type: 'boolean'
  default: false
  order: 10
enableTreeViewBorder:
  title: 'Enable tree view border'
  description: 'Makes it really easy to discern nesting'
  type: 'boolean'
  default: false
  order: 11
altStyle:
  type: 'string'
  title: 'Previous & Alternate color schemes'
  default: 'None'
  description: "If significant changes are made, the previous version(s)
    will be available for you here, as well as some alternate styles"
  enum: ['None']#, 'v0.2.0']
  order: 12

module.exports = ApathyConfig
