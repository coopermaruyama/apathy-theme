# Apathy   ////  Atom Syntax Theme

[![Join the chat at https://gitter.im/coopermaruyama/apathy-theme](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/coopermaruyama/apathy-theme?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

![Apathy main screenshot](https://s3.amazonaws.com/f.cl.ly/items/2H0w160E1T2y332e0f3G/apathy.png)



**Adds semantic highlighting to text that grammars leave unscoped!**
![Semantic Screenshot](https://s3.amazonaws.com/f.cl.ly/items/0D2U261Q1D3G3z010K31/Image%202015-05-29%20at%2011.14.28%20PM.png)


A syntax theme I polished over the years, originally in SublimeText. Includes custom bundled fonts with multiple font-weights and **antialiased font smoothing** for clean rendering of text.

### Features:
* Includes 'Source Code Pro' and 'Inconsolata' web font which can be changed via settings panel
* Thorough definitions for JS/Coffeescript/Meteor developers
* Custom tree-view background (optional)
* Optional alternate styles
* Customizable colors


This is a pretty opinionated theme, with more emphasis on design than function, although for me it's the ideal for both. I am aware that not everyone has the same setup but I still want everyone to be able to get the most out of this theme, so it has a settings panel with options to configure stuff (more below).



### Notes
  - This will most likely override your current font in 'Settings'. If you don't like the font provided, you can override it in your custom stylesheet.  
  - I **highly** recommend combining this with **[One Dark](https://github.com/atom/one-dark-ui)** - I personally think they match very well.
  - This syntax theme styles a few things that is out of its scope (e.g. the tree view), so I wouldn't be surpised if it has issues with some UI themes.
  - This theme includes the following font weights in case you want to use them in your user stylesheet: 300, 400, 700, 900


# README before customizing colors!

* First I'd like to mention that the intention for the adjustable colors was not for changing the hue, but rather the lightness or saturation in order to counter-act differences between color profiles and calibrations of monitors.

* Technically, overriding the LESS variables of a theme is not supported by atom (see [#5903](https://github.com/atom/atom/issues/5903)). The solution in place is VERY hacky and causes errors if not done correctly. Without getting into the details, it looks like Atom had worked on this and then were not able to get it implemented, so the way it's working in this theme is that it's actually writing your custom settings into a file within the package every time you change the values.

  Also, when you change the values, the UI theme won't read the changes because it's already compiled LESS to CSS! So you have to live reload (`ctrl+alt+cmd+L`) _every_ time you change a color setting. Note that this will persist through updates fine since the settinsg are stored in your own config, but it's a hassle.
  
* If you want to go back to default, open your config (File > Open your config) and delete the color stuff under the 'apathy-theme' key.







---

# Screenshots

### Javascript Colors:
![JS Screenshot](https://s3.amazonaws.com/f.cl.ly/items/2g403i3V0w2B2K0v2G2D/Image%202015-05-01%20at%207.36.00%20PM.png)

### Coffeescript:
![Coffeescript Screenshot](https://s3.amazonaws.com/f.cl.ly/items/2e2v1z1Q2S0r443z0u2j/Image%202015-05-01%20at%207.47.31%20PM.png)

### MeteorJS (w/ tree view styling enabled)
![Meteor Screenshot](https://s3.amazonaws.com/f.cl.ly/items/3b3s200N3C151Z101X12/Image%202015-05-01%20at%207.31.18%20PM.png)

### Spacebarss:
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
  4. I've noticed that opening the settings panel for this package will mess up current settings that use regex, so try to only edit this setting via File > Open your config.

### CSS/SASS/LESS:
![CSS](https://s3.amazonaws.com/f.cl.ly/items/2Q1H1W2R3o2F0C2b043K/Image%202015-05-01%20at%207.41.18%20PM.png)

### HTML:
![HTML Screenshot](https://s3.amazonaws.com/f.cl.ly/items/0L3E1F1F1r3G2y242a0E/Image%202015-05-01%20at%207.39.59%20PM.png)


## Contributing

* I would really appreciate if you guys can mention what things you think can be improved, as well as what things you think shouldn't change because they are already ideal.

* If you can help improve the JS/coffee part of the code, that would also be great.




## What's Next?

[] Semantic Highlighing (already in progress but just not happy with the color scheme)

[] There are a lot of things I've wanted to style in the syntax theme but couldn't, and I'm working on some additional grammars to make this possible. Some examples:
  - When inside a function block, it would be neat if the function name and closing brackets glowed! This way it's easy to see boundaries. Also want the same when editing a variable.
  - In semantic highlighting, I want the variables to change color little-by-little as you type the word, and that word becomes more similar to another. e.g. you define `fooBar` which is orange, and if you type `foo` its yellow, `fooB` is a bit more orange, and so on.
  - Detect typos and make them red.

[] Use font-size to improve code comprehension and readability. Currently it's the same font size throughout.

[] Clean! Code is super messy right now.
