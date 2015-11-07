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
syntaxSaturation:
  type: 'string'
  title: 'Syntax Saturation (requires reload)'
  default: '90%'
  description: 'How colorful do you want your syntax highlights?'
  enum: ['70%', '80%', '90%', '100%', '110%', '120%', '130%']
  order: 13
syntaxBrightness:
  type: 'string'
  title: 'Syntax Brightness (requires reload)'
  default: '90%'
  description: 'How bright?'
  enum: ['70%', '80%', '90%', '100%', '110%', '120%', '130%']
  order: 14
syntaxContrast:
  type: 'string'
  title: 'Syntax Contrast (requires reload)'
  default: '90%'
  description: 'How much contrast?'
  enum: ['70%', '80%', '90%', '100%', '110%', '120%', '130%']
  order: 15

module.exports = ApathyConfig
