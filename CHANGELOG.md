## 0.1.0 - First Release
* Every feature added
* Every bug fixed

## 0.2.0 - Minor Release
* Bundle 'Source Code Pro' font
* Translate unmatched classes from Sublime conversion

## 1.0.0 - Major Release
* Significant additions/changes to the following grammars:
  * Javascript
  * Coffeescript
  * Meteor
  * CSS/SASS/LESS
  * Default Classes
* Added settings panel with the following options:
  * Enable tree view styling
  * Alternate font (Inconsolata)
  * Choose previous/alternate color schemes
* Use subpixel antialiasing instead of full antialiasing (seems to look better)
* Other styling changes:
  * Use LESS colors dictionary instead of discrete color values
  * Braces wrapping statements are darkened to be visibly subtle
  * When inside a method, the method's name glows
  * Current find/replace selection glows

### 1.0.3 - Patch
* Improved styles for Jasmine.

### 1.0.4 - Patch
* Slow down glow animations.

## 1.1.0 - Feature
* Add option in settings to enable tree view guides. Enabling the option adds
subtle outlines to make it easy to discern nesting in your tree view.

### 1.1.1 - Patch
* Fix conflict between tree view border and background when both options are
enabled.

### 1.1.2 - Patch
* Add styles for XML grammar.
* Fix keyword styles sometimes leaking onto semicolons.

### 1.1.3 - Patch
* Fix deprecated calls to `config.getDefault()`.

### 1.1.4 - Patch
Tree view: Fix leaked highlight when directory selected. Rounder borders.

### 1.1.5 - Patch
Temporary fix for cursor position on reload bug.

Reload character widths calculation after load so cursor is repainted, which
fixes the bug caused by using antialiased font in this theme. Since
observeTextEditor doesn't wait till DOM ready, instead attached to the 1st
movement of the cursor and immediately dispose. This is a band-aid solution
so eventually implement a better solution.

### 1.1.6 - Patch
* Only reload pane if it's a `TextEditor`.

### 1.1.7 - Patch
* No need for right-side border-radius on tree-view.

### 1.1.8 - Patch
* Fix filenames not normalizing correctly due to a typo.

### 1.1.9 - Patch
* Refactor languages into separate files.
* Jade syntax additions & some minor edits.
* Styles for TODO, FIXME, HACK, NOTE, XXX, & IDEA within comments.
* Update deprecated uses of API.
* Typo in font resource call fixed.
* More vivid tree-view background.
* Fix font-weight issue on Inconsolata font.

### 1.1.10 - Patch
* Darken `@tag` inside block comments.
* Brighten terminators a bit.
* Fix cursor issues by disabling some unsupported font features.
* Single-quoted strings are now green.

### 1.1.11 - Patch
* Less dimming on inactive panes. Makes it easier to reference code 
side-by-side.

### 1.1.12 - Patch
* Only re-measure characters if `paneItem` allows. Fixes a bug caused by trying
to remeasure character widths on `paneItems` that don't have a `linesComponent`.

### 1.1.13 - Patch
* Fixes #6. Tree view styles now deactivate correctly.

### 1.1.14 - Patch
* Lightened comments a bit.

## 1.2.0 - Feature
* Ability to customize colors and override the default colors with your own via
the settings panel! 

### 1.2.1 - Patch
* Typo.

## 1.3.0 - Feature
* Add left wrap guide and ability to center buffer.

Adds the ability to enable a wrap guide on the left side, and move the
buffer towards the center like in Sublimetext. Adds 2 options to the
setings panel: enable left wrap guide and adjust left padding.

* Coffeelint.json style guide added.
* Upgrade dependency on space pen views.
* The indent guides should be more subtle.

## 1.4.0 - Feature
* Semantically highlight text that grammars leave unscoped. This can be enabled
or disabled via settings panel.

## 1.5.0 - Feature
* More reliable semantic highlight activation.

The events we're listening to for activating semantic highlights
are inconsistent so I've experimented with some other combinations
to try to make it more reliable. The new setup seems to work a bit
better.

* Significant improvements to Semantic Highlighting.

* DRY up semantic highlighting methods.
* Now accurately can determine what word is under the cursor, and
make other occurences of that word which are visible glow.

Initially, semantic highlighting was just a secondary feature I added
in order to fill the gap where so many things were not scoped yet.
Even now, semantic highlighting only applies to text that whatever
grammar is loaded has left unscoped. Because of this, and because
scoping from grammars is much more thorough now, people might
consider this 'broken'.

* Drop fancy wrap guide for something more functional.

The old wrap guide was designed to look like a real 'groove' on your
text editor, but a wrap guide is meant to serve a function of making
it clear where N characters are, and I think a simpler guide is more
ideal for that.

* **Main feature:** Semantic highlighting support!

* Jasmine, JS, Tree view, & a few other things have improved styling.
