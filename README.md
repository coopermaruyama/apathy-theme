# Apathy   ////  Atom Syntax Theme

### Note:
**In newer versions of Atom this syntax theme only works correctly when run in development mode. To get a version which only includes the syntax styles and supports newer versions of Atom, download [vivid-syntax](https://atom.io/themes/vivid).

[![Join the chat at https://gitter.im/coopermaruyama/apathy-theme](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/coopermaruyama/apathy-theme?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

![Apathy main
screenshot](https://dl.dropboxusercontent.com/u/1406414/cloud/hero.png)

[View full-screen](https://www.dropbox.com/s/dt8y45icuw6co8e/full-screen.png?dl=0)


This dark syntax theme sports a subtle, deep purple base with vivid candy-like colors which bring your syntax to life without going too far to the point of being impractical. It's also one of the only syntax themes with the ability to configure its colors through the settings panel.

#### Recommended Settings:

* **UI Theme:**  **[Atom Material UI](https://atom.io/themes/atom-material-ui)** or **[One Dark](https://github.com/atom/one-dark-ui)**

* **Font size:** 13-14px depending on resolution.

* **Font Family:** Source Code Pro


## Read me before customizing colors!

* Technically, overriding the LESS variables of a theme is not supported by atom (see [#5903](https://github.com/atom/atom/issues/5903)). The solution in place is hacky and can cause errors.

* When you change the color settings, you won't see the changes applied until you do a live reload (cmd-alt-ctrl-L). This is because atom has already compiled all the LESS files to CSS. For this reason, it's easier to open up dev tools and find the color you want there, then update your settings after - this way you don't have to reload over and over.

* If you want to go back to default, open your config (File > Open your config) and delete the color stuff under the 'apathy-theme' key.


### Roadmap

* The name of this theme will soon be changed to **"Vivid syntax"**.

* Features such as semantic highlights, wrap guide, etc. will be exported into their own packages so that you can use them with any syntax theme.


# Features

### 1. _Source Code Pro_ and _Inconsolata_ Font Included:

**Source Code Pro:**
![Source code pro Screenshot](https://s3.amazonaws.com/f.cl.ly/items/3C0y3L400K2S0g2F132o/Image%202015-06-03%20at%202.19.53%20AM.png)

**Inconsolata:**
![Inconsolata Screenshot](https://s3.amazonaws.com/f.cl.ly/items/0W0N2F181t2k0Z0a2M3x/Image%202015-06-03%20at%202.20.22%20AM.png)



### 2. Left wrap guide & customizable padding (optional)
![left wrap guide ss](https://s3.amazonaws.com/f.cl.ly/items/0e3O2E2s472q1w15383y/Image%202015-06-03%20at%202.37.21%20AM.png)



### 3. Semantic highlighting (Optional)

Applied only to text that is grammars leave unscoped:
![Semantic Screenshot](https://s3.amazonaws.com/f.cl.ly/items/2p1F2I451d3n3l0Z1M3p/Image%202015-06-03%20at%202.23.51%20AM.png)



### 4. Custom tree-view background (optional)

![Treeview bg](https://s3.amazonaws.com/f.cl.ly/items/1Y0g3E3G2C1t161A1i1q/treeview.png)



### 5. Directory structure visual guides (optional)

![Directory guides](https://s3.amazonaws.com/f.cl.ly/items/2L0z3R2K1Y1w3L3x3y2E/Image%202015-06-03%20at%202.26.45%20AM.png)

### 6. Calibration

Calibrate brightness, saturation, and contrast in the settings panel:
![colors calibration](https://www.dropbox.com/s/luij8bj2hzzzyjs/Screenshot%202015-07-24%2005.00.44.png?dl=1)



### Notes
  - This theme will most likely override your current font in 'Settings'. If you don't like the font provided, you can override it in your custom stylesheet, using this selector: `atom-text-editor::shadow .source` (make sure to add `!important`).
  - I highly recommend you combine this theme with either **[Atom Material UI](https://atom.io/themes/atom-material-ui)** or **[One Dark](https://github.com/atom/one-dark-ui)** - I personally think they match very well.
  - This syntax theme styles a few things that is out of its scope (e.g. the tree view), so I wouldn't be surpised if it has issues with some UI themes.
  - This theme includes the following font weights in case you want to use them in your user stylesheet: 200, 300, 400, 700, 800, 900 (Source Code Pro only!)


---

# Language Previews

### Javascript:
![JS Screenshot](https://www.dropbox.com/s/k16waf5hwbbyj4h/Screenshot%202015-07-25%2022.49.41.png?dl=1)

### Coffeescript:
![Coffeescript Screenshot](https://www.dropbox.com/s/j3v86tzekwbx9ie/Screenshot%202015-07-26%2012.19.55.png?dl=1)

### MeteorJS (w/ tree view styling enabled)
![Meteor Screenshot](https://www.dropbox.com/s/v3jowyau6q1dtt1/Screenshot%202015-07-26%2012.48.00.png?dl=1)

### Spacebars:
![Spacebars](https://s3.amazonaws.com/f.cl.ly/items/3J070V2h070X182c3F1R/Image%202015-05-01%20at%207.42.33%20PM.png)

### Jasmine:
![Jasmine
Screenshot](https://s3.amazonaws.com/f.cl.ly/items/2P453t1f2E250B1u2U3c/Image%202015-05-26%20at%209.46.57%20PM.png)

**Note:** To get Jasmine colors to work you need to:
  1.  name your files `someFile.spec.js`
  2.  make sure you have [file types](https://atom.io/packages/file-types) installed
  3.  add the following in your config:

      ```coffee
      "file-types":
        "^[^.]+.js$": "source.js"
        ".spec.js$": "source.spec.js"
      ```
* I've noticed that opening the settings panel for this package will mess up current settings that use regex, so try to only edit this setting via File > Open your config.

### CSS/SASS/LESS:
![CSS](https://s3.amazonaws.com/f.cl.ly/items/2Q1H1W2R3o2F0C2b043K/Image%202015-05-01%20at%207.41.18%20PM.png)

### HTML:
![HTML Screenshot](https://s3.amazonaws.com/f.cl.ly/items/0L3E1F1F1r3G2y242a0E/Image%202015-05-01%20at%207.39.59%20PM.png)
