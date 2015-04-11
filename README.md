# django-gulp
Wellfire's Django-centric front-end buiuld process

## Package.json

01. gulp: gulp build processor
02. browser-sync: live sync front-end editting
03. coffee-script: process coffescript files (or run gulp)
04. del: cleans up unneccesary files.
05. gulp-autoprefixer: update CSS files with supported prefixes
06. gulp-changed: check files for changed status. speeds up front-end processing, used on media files
07. gulp-coffee: process coffeescript -> javqascript within gulp build flow
08. gulp-coffeelint: lint coffeescript files
09. gulp-concat: concatenate coffeescript and resulting javascript files
10. gulp-csso: minify CSS files
11. gulp-exec: run commands from CLI
12. gulp-filter: filter files within stream
13. gulp-if: logic for build flow
14. gulp-image-embed: process css files and replace linked background images with data URIs
15. gulp-imagemin: compress images, may require imagemin processors
16. gulp-jade: process jade -> HTML files within gulp build flow
17. gulp-load-plugins: easy loading plugins for gulp
18. gulp-newer: check for newer files, used with jade, stylus, coffeescript
19. gulp-plumber: checks for errors within streams and keeps gulp running without fatal errors (usually)
20. gulp-sizereport: check for your final and gzip size of files
21. gulp-sourcemaps: maps coffeescript to javascript files
22. gulp-stylus: process stylus -> CSS files within gulp build flow
23. gulp-uglify: minimizes your js files
24. gulp-util: adds helpful utilities to gulp. color CLI, get environment variables
25. gulp-watch: extends gulp watch
26. imagemin-gifsicle: imagemin required processor, circumvents npm build errors
27. imagemin-jpegtran: imagemin required processor, circumvents npm build errors
28. imagemin-optipng: imagemin required processor, circumvents npm build errors
29. imagemin-pngquant: imagemin required processor, circumvents npm build errors
30. imagemin-svgo: imagemin required processor, circumvents npm build errors
31. js-yaml: process YAML config files
32. main-bower-files: run bower processing
33. marked: process Markdown files


## Setup

01. run `npm install --global gulp`
02. run `npm install`
03. open `gulpfile.js` and switch out the `site_file` value
    with the correct path for your `site.yaml` file (already set up in this project)
04. run `gulp` or `gulp help` to see the options

## Using Browser-Sync

You can view your site at the given Django dev server localhost (`localhost:8000` here). However,
when running front-end watches, you'll want to use Browser-Sync. For the first time run, add the
flags `--watch --ui`, which will start your file watches, run Browser-Sync, and open B-S's UI. The
UI will help you launch a browser-synced proxy of the Django dev server.

By using Browser-Sync, we are removing the need to embed livereload script directly into the
templates. This is a serious win.

## A word on some Gulp Plugins

### Gulp-Combine-Media-Queries

We do not recommend the use of combining media queries. Once completed, the order of the combined
queries is not logical and unforeseen layout issues occur. Please gzip compress the CSS files for
better usage of minification.

### Bower

We do not recommend using bower files and instead use CDN versions instead, if possible. This will
lessen the amount of concurrent same-host downloads initially and users may already have dependencies
already downloaded on their computer, allowing for a cached version.


### Gulp-imagemin

Lately we've had build errors with this plugin. However, it is the best that we've run into for its
functionality. Therefore, the individual dependencies are installed as well. This seems to circumvent
the build errors.

If you still receive build errors, try removing `gulp-imagemin` from `package.json`, run
`npm install`, then replace `gulp-imagemin`, and run `npm install` again.

### Gulp-image-embed

This is a nifty script that will parse your css files for background-images and the like and convert
them to base64 data URIs. This is up to you if it saves some bytes and transfer costs. Run with
`--sizereport` to see what your savings are. **Note**: There is not much gzip compression on images,
you may see some gzip dividends with the data URIs.

## Minify by default

We minify CSS and JS by default as we generally use Chrome Dev Tools for checking out problem issues.
By not minifying at the outset, we may forget to minify for commits/promotions. Use `--unminify` if
you need to look at a processed file without minification.

### Minify HTML files?

We do not minify HTML files as these are run through Django Templates and have Django template tags
embedded in them. HTML minifiers appear to choke on some of the logic embedded with the template tags.
These files are gzipped on the server regardless and so should be fine with the gzip compression.

# Site.yaml
Configuration for Gulp is located in the `_config/site.yaml` file. The following is a breakdown of
each section

## Site Content Centric

Static data used within the Jade templates

## Django Centric

Static variables used within the Django template portion of the HTML templates

## JavaScript Centric

Booleans used within the Jade templates to process script tags. The `dev_server` key-value pair will
perclude the given development/staging server from Google Analytics.

## CSS Centric

Booleans used with the Jade templates to process link tags or conditional comments

## Project Centric

01. **type**: determines what type of project is being built (`static`, `django`, `jekyll`). For
    this project, we've remove the Gulp Static and Jekyll portions as they are not needed.
02. **host**: generally `localhost`, but this is for serving a static site and is used by
    browser-sync for proxing off the Django development server.
03. **port**: the port that browser-sync will proxy off of.


## Pre-processors

Important object declarations for usaage in Gulp's pre-processors. Used for the `glob` object, which
dicates which files Gulp should include in its streams. Usage of a `!` before a file name instructs
Gulp to not include that file or structure.

For CoffeeScript, the `glob` determines what is concactenated on processing and the `output`
key:value determines what the concactenated file is called.

## Asset Paths

This structure maps where development files live (`src`) and where they end up (`build`). The `data`
key:value pair is a folder that Gulp will process for YAML files for static content structures or
fixtures and introduce into the Jade templates.

For `build.static`, this is used to map where the static folder for Django is kept.
