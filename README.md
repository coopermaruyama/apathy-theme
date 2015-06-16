# Apathy   ////  Atom Syntax Theme

[![Join the chat at https://gitter.im/coopermaruyama/apathy-theme](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/coopermaruyama/apathy-theme?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

![Apathy main screenshot](https://s3.amazonaws.com/f.cl.ly/items/2H0w160E1T2y332e0f3G/apathy.png)



A vivid syntax theme that I polished over the years. Includes custom bundled fonts with multiple font-weights, **antialiased font smoothing** for clean rendering of text, and tons of other features!


# README before customizing colors!

* First I'd like to mention that the intention for the adjustable colors was not for changing the hue, but rather the lightness or saturation in order to counter-act differences between color profiles and calibrations of monitors.

* Technically, overriding the LESS variables of a theme is not supported by atom (see [#5903](https://github.com/atom/atom/issues/5903)). The solution in place is VERY hacky and causes errors if not done correctly. Without getting into the details, it looks like Atom had worked on this and then were not able to get it implemented, so the way it's working in this theme is that it's actually writing your custom settings into a file within the package every time you change the values.

  Also, when you change the values, the UI theme won't read the changes because it's already compiled LESS to CSS! So you have to live reload (`ctrl+alt+cmd+L`) _every_ time you change a color setting. Note that this will persist through updates fine since the settinsg are stored in your own config, but it's a hassle.
  
* If you want to go back to default, open your config (File > Open your config) and delete the color stuff under the 'apathy-theme' key.



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

### 6. Now supports semantic highlighting!



Although this is meant to be an opinionated theme, I am aware that not everyone has the same setup but I still want everyone to be able to get the most out of this theme, so it has a settings panel with options to configure stuff (more below).



### Notes
  - This will most likely override your current font in 'Settings'. If you don't like the font provided, you can override it in your custom stylesheet.  
  - This theme is meant to be combined with **[One Dark](https://github.com/atom/one-dark-ui)** - I personally think they match very well.
  - This syntax theme styles a few things that is out of its scope (e.g. the tree view), so I wouldn't be surpised if it has issues with some UI themes.
  - This theme includes the following font weights in case you want to use them in your user stylesheet: 300, 400, 700, 900


---

# Screenshots

### Javascript Colors:
![JS Screenshot](https://s3.amazonaws.com/f.cl.ly/items/2g403i3V0w2B2K0v2G2D/Image%202015-05-01%20at%207.36.00%20PM.png)

### Coffeescript:
![Coffeescript Screenshot](https://s3.amazonaws.com/f.cl.ly/items/2e2v1z1Q2S0r443z0u2j/Image%202015-05-01%20at%207.47.31%20PM.png)

### MeteorJS (w/ tree view styling enabled)
![Meteor Screenshot](https://s3.amazonaws.com/f.cl.ly/items/3b3s200N3C151Z101X12/Image%202015-05-01%20at%207.31.18%20PM.png)

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


