# Apathy   ////  Atom Syntax Theme

My awesome syntax theme I polished over the years, ported to Atom from Sublime Text. Includes custom bundled fonts with multiple font-weights and **antialiased font smoothing** for clean rendering of text.

### Features:
* Includes 'Source Code Pro' and 'Inconsolata' web font which can be changed via settings panel
* Thorough definitions for JS/Coffeescript/Meteor developers
* Custom tree-view background (optional)
* Optional alternate styles

**Notes:**
  - This will most likely override your current font in 'Settings'. If you don't like the font provided, you can override it in your custom stylesheet.  
  - I **highly** recommend combining this with **[One Dark](https://github.com/atom/one-dark-ui)** - I personally think they match very well.
  - This theme includes the following font weights in case you want to use them: 300, 500, 700, 900

---

# Screenshots

### Javascript Colors:
![JS Screenshot](https://s3.amazonaws.com/f.cl.ly/items/2g403i3V0w2B2K0v2G2D/Image%202015-05-01%20at%207.36.00%20PM.png)

### Coffeescript:
![Coffeescript Screenshot](https://s3.amazonaws.com/f.cl.ly/items/0c1J2r1v3u0Z3f1j3l0t/Image%202015-05-01%20at%201.43.50%20PM.png)

### MeteorJS (w/ tree view styling enabled)
![Meteor Screenshot](https://s3.amazonaws.com/f.cl.ly/items/3b3s200N3C151Z101X12/Image%202015-05-01%20at%207.31.18%20PM.png)

### Spacebarss:
![Spacebars](https://s3.amazonaws.com/f.cl.ly/items/3J070V2h070X182c3F1R/Image%202015-05-01%20at%207.42.33%20PM.png)

### Jasmine:
![Jasmine Screenshot](https://s3.amazonaws.com/f.cl.ly/items/221H441D1p0q3o1b452n/Image%202015-05-01%20at%207.36.58%20PM.png)

**Note:** To get Jasmine colors to work you need to:
  1.  name your files `someFile.spec.js`
  2.  make sure you have [file types](https://atom.io/packages/file-types) installed
  3.  add the following in your config:

      ```coffee
      "file-types":
        "^[^.]+.js$": "source.js"
        ".spec.js$": "source.spec.js"
      ```
  4. I've noticed that opening the settings panel for this package will mess up current settings that use regex, so try to only edit this setting via File > Open your config.

### CSS/SASS/LESS:
![CSS](https://s3.amazonaws.com/f.cl.ly/items/2Q1H1W2R3o2F0C2b043K/Image%202015-05-01%20at%207.41.18%20PM.png)

### HTML:
![HTML Screenshot](https://s3.amazonaws.com/f.cl.ly/items/0L3E1F1F1r3G2y242a0E/Image%202015-05-01%20at%207.39.59%20PM.png)
