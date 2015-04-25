# Apathy   ////  Atom Syntax Theme

My awesome syntax theme I polished over the years, ported to Atom from Sublime Text. Includes __'Source Sans Pro'__ Web Font with multiple font-weights and **antialiased font smoothing** for clean rendering of text.

**Notes:**
  - This will most likely override your current font in 'Settings'. If you don't like the font provided, you can override it in your custom stylesheet.  
  - I **highly** recommend combining this with **[One Dark](https://github.com/atom/one-dark-ui)** - I personally think they match very well.
  - This theme includes the following font weights in case you want to use them: 300, 500, 700, 900

Check out the screenshots below:


### Javascript Colors:
![JS Screenshot](https://s3.amazonaws.com/f.cl.ly/items/0Y1J0S2N0x2b340g3E1M/Screenshot%202015-04-24%2023.56.22.png)

### Coffeescript:
![Coffeescript Screenshot](https://www.dropbox.com/s/aetb30siyuw5uku/Screenshot%202015-04-25%2000.10.27.png?dl=1)


### Jasmine:
![Jasmine Screenshot](https://www.dropbox.com/s/lozoygw89thxyo8/Screenshot%202015-04-24%2023.55.47.png?dl=1)

**Note:** To get Jasmine colors to work you need to:
  1.  name your files `someFile.spec.js`
  2.  make sure you have [file types](https://atom.io/packages/file-types) installed
  3.  add the following in your config:

```coffee
"file-types":
  '.spec.js$': "source.spec.js"
  '^[^\.]+.js$': "source.js"
```

### CSS/SASS/LESS:
![CSS](https://www.dropbox.com/s/fmcx4nyvyrgg4n9/Screenshot%202015-04-24%2023.56.28.png?dl=1)
