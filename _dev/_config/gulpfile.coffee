#    .aMMMMP dMP dMP dMP     dMMMMb  dMMMMMP dMP dMP     dMMMMMP
#   dMP"    dMP dMP dMP     dMP.dMP dMP     amr dMP     dMP
#  dMP MMP"dMP dMP dMP     dMMMMP" dMMMP   dMP dMP     dMMMP
# dMP.dMP dMP.aMP dMP     dMP     dMP     dMP dMP     dMP
# VMMMP"  VMMMP" dMMMMMP dMP     dMP     dMP dMMMMMP dMMMMMP
#
# By: Wellfire Interactive, LLC (wellfire.co)

# 01. Initialization
# 02. HTML / Jade
# 03. CSS / Stylus
# 04. JavaScript / CoffeeScript
# 05. Watches
# 06. Tasks
# ---- Complete / No Change----
# 07. Bower
# 08. Assets / Vendor files


#
#     dMP dMMMMb  dMP dMMMMMMP
#    amr dMP dMP amr    dMP
#   dMP dMP dMP dMP    dMP
#  dMP dMP dMP dMP    dMP
# dMP dMP dMP dMP    dMP
#
# LOAD DEPENDENCIES
#
gulp = require 'gulp'
del = require 'del'
utils = require 'gulp-util'
colors = utils.colors
plugins = do require 'gulp-load-plugins'
mainBowerFiles = require 'main-bower-files'
browserSync = require 'browser-sync'
browserReload = browserSync.reload

http = require 'http'
fs = require 'fs'
yaml = require 'js-yaml'


#
# Helper stream functions
#
renamer = (path) ->
    unless path.basename is 'index'
        dir = path.basename.split(".")
        if dir.length > 1
            path.basename = dir.pop()
            path.dirname = dir.join("/")
        else

    return path


#
# LOAD YAML CONFIGS
#
yamlLoad = (file) -> yaml.safeLoad fs.readFileSync file, 'utf8'

site = {}
config = yamlLoad(site_file) # this is not
src = config.path.src
build = config.path.build

# add config to the site object for use within Jade/Stylus/Coffeescript
for key, value of config
    site[key] = value

# lets add extra files in the data folder to the site object
for file in fs.readdirSync "./#{src.base}/#{src.data}/"
    file_name = file.split('.')[0]
    if file_name
        # site[file_name] = {}
        temp = yamlLoad("./#{src.base}/#{src.data}/#{file}")
        for obj_name, obj of temp
            site[obj_name] = temp[obj_name]

# Messages for BrowserSync
messages =
    jadeBuild: '<span style="color:goldenrod">Running:</span> jade'
    stylusBuild: '<span style="color:goldenrod">Running:</span> stylus'
    coffeeBuild: '<span style="color:goldenrod">Running:</span> coffeescript'


#
# GET ENVIRONMENT
#
# call up a size report
config.size_report = if utils.env.sizereport then true else false
# start watch of files
config.watch = if utils.env.watch then true else false
# minify css and js
config.unminify = if utils.env.unminify then true else false
# force a full recompile
config.force = if utils.env.force then true else false
# open browsersync debug browsers
config.debug = if utils.env.debug then true else false
# force specific url to open within browsersync browsers
config.view = if utils.env.url then utils.env.url else false
# open the browsersync ui for use
config.ui = if utils.env.ui then "ui" else false
# convert CSS background images to data URIs, not always recommended, run size report
config.dataURI = if utils.env.datauri then true else false


#
#     dMP dMP dMMMMMMP dMMMMMMMMb  dMP
#    dMP dMP    dMP   dMP"dMP"dMP dMP
#   dMMMMMP    dMP   dMP dMP dMP dMP
#  dMP dMP    dMP   dMP dMP dMP dMP
# dMP dMP    dMP   dMP dMP dMP dMMMMMP
#

# USE gulp-htmlmin on jekyll templates perhaps?
jade_opts =
    pretty: config.jade.pretty || true
    compileDebug: config.jade.compileDebug || false
    doctype: 'html' # forces Jade to follow HTML5 attribute convention
    locals: site
    dest: config.jade.dest || "#{build.base}/#{build.html}/"
    cwd: config.jade.cwd || "#{src.base}/#{src.html}/"
    basedir: config.jade.basedir || "#{src.base}/#{src.html}/"


# set up which Jade files we're looking for
jade_glob = config.jade.glob

gulp.task 'jade-build',  ->
    browserSync.notify messages.jadeBuild

    gulp
        .src(
            jade_glob,
            cwd: jade_opts.cwd
        )
        .pipe(
            # check to find out which files have been edited,
            # based on changed status of corresponding build file
            # use force flag to compile all
            plugins.if(
                config.force,
                utils.noop(),
                plugins.newer(
                    dest: jade_opts.dest
                    ext: ".html"
                )
            )
        )
        .pipe( plugins.plumber() )
        .pipe( plugins.jade( jade_opts ) )
        .pipe( gulp.dest( jade_opts.dest ) )
        .pipe(
            utils.noop(
                console.log colors.yellow(colors.underline("[Jade] output to:")) + colors.gray(jade_opts.dest)
            )
        )


#
#    .aMMMb  .dMMMb  .dMMMb
#   dMP"VMP dMP" VP dMP" VP
#  dMP      VMMMb   VMMMb
# dMP.aMP dP .dMP dP .dMP
# VMMMP"  VMMMP"  VMMMP"
#
stylus_opts =
    compress: config.stylus.compress || false
    log: config.stylus.log || true
    showFiles: config.stylus.showFiles || false
    dest: config.stylus.dest ||"#{build.base}/#{build.static}/#{build.css}/"
    cwd: config.stylus.cwd || "#{src.base}/#{src.css}/"

# set up which Stylus files we're looking for
stylus_glob = config.stylus.glob
# asset_opts =
#     files: [ "**/*.*" ]
#     assets:
#         cwd: "./#{src.base}/#{src.assets}"
#         dest:

gulp.task 'stylus-build', ->
    browserSync.notify messages.stylusBuild

    gulp
        .src(
            stylus_glob
            cwd: stylus_opts.cwd
        )
        .pipe(
            # test for which files are newly editted
            # based on concatenate final file of app.js
            # todo: pull out concatenate final file
            # warning: assumes users want to concatenate
            plugins.if(
                config.force,
                utils.noop(),
                plugins.newer(
                    dest: stylus_opts.dest
                    ext: ".css"
                )
            )
        )
        .pipe( plugins.plumber() )
        .pipe( plugins.stylus( stylus_opts ) )
        .pipe(
            # filter out underscored files, in case they got through for some reason
            plugins.filter(
                (file) ->
                    !/\/_/.test(file.path) || !/^_/.test(file.relative);
            )
        )
        .pipe(
            # autoprefix css styles
            plugins.autoprefixer(
                'last 2 versions',
                'Explorer 9'
                'Explorer 10'
            )
        )
        .pipe(
            # minification of css files; minify by default, use flag to not minify
            plugins.if(
                config.unminify
                utils.noop()
                plugins.csso()
            )
        )
        .pipe(
            plugins.if(
                config.dataURI
                plugins.imageEmbed(
                    asset: "./#{build.base}/#{build.static}/#{build.assets}/"
                    extension: ['jpg', 'png', 'gif', 'svg']
                )
                utils.noop()
            )
        )
        .pipe(
            plugins.if(
                config.size_report
                plugins.sizereport( gzip: true )
                utils.noop()
            )
        )
        .pipe( gulp.dest( stylus_opts.dest ) )
        .pipe(
            # force livereload/inject of styles into browser
            plugins.if(
                config.watch,
                browserReload(
                    stream: true
                ),
                utils.noop()
            )
        )
        .pipe(
            utils.noop(
                console.log colors.yellow(colors.underline("[Stylus] output to:")) + colors.gray(stylus_opts.dest)
            )
        )


#
#    dMMMMMP .dMMMb
#       dMP dMP" VP
#      dMP  VMMMb
# dK .dMP dP .dMP
# VMMMP"  VMMMP"
#
lint_opts = # Coffeescript lint options
    arrow_spacing: true
    no_empty_param_list: true
    no_implicit_braces: true
    space_operators: true
    max_line_length:
        value: 100
    indentation:
        value: 4

coffee_opts = # Coffeescript options
    bare: config.coffee.bare || true
    join: config.coffee.join ||true
    src: config.coffee.glob
    output: config.coffee.output || "app.js"
    cwd: config.coffee.cwd || "#{src.base}/#{src.js}/"
    dest: config.coffee.dest || "#{build.base}/#{build.static}/#{build.js}/"


gulp.task 'coffee-build', ->
    browserSync.notify messages.coffeeBuild

    data = gulp
        .src(
            coffee_opts.src
            cwd: coffee_opts.cwd
        )
        .pipe(
            # test for which files are newly editted
            # based on concatenate final file of app.js
            # todo: pull out concatenate final file
            # warning: assumes users want to concatenate
            plugins.if(
                config.force,
                utils.noop(),
                plugins.newer(
                    "#{coffee_opts.dest}/app.js"
                )
            )
        )

    # lint and report
    data
        .pipe( plugins.coffeelint( lint_opts ) )
        .pipe( plugins.coffeelint.reporter() )

    # make sourcemap, parse coffeescript, concat into file
    data
        .pipe(
            plugins.sourcemaps.init()
        )
        .pipe(
            plugins.coffee( coffee_opts )
                .on('error', utils.log)
        )
        # warning: assumes users want to concatenate
        .pipe( plugins.concat(coffee_opts.output) )
        .pipe(
            # minification of js files; minify by default, use flag to not minify
            plugins.if(
                config.unminify
                utils.noop()
                plugins.uglify()
            )
        )
        .pipe(
            # use here so we don't read the js.map files
            plugins.if(
                config.size_report
                plugins.sizereport( gzip: true )
                utils.noop()
            )
        )
        .pipe(
            plugins.sourcemaps.write('./maps')
        )
        .pipe( gulp.dest( coffee_opts.dest ) )

    data.pipe(
        utils.noop(
            console.log colors.yellow(colors.underline("[CoffeeScript] output to:")) + colors.gray(coffee_opts.dest)
        )
    )


#
#    dMP dMP dMP .aMMMb dMMMMMMP .aMMMb  dMP dMP dMMMMMP .dMMMb
#   dMP dMP dMP dMP"dMP   dMP   dMP"VMP dMP dMP dMP     dMP" VP
#  dMP dMP dMP dMMMMMP   dMP   dMP     dMMMMMP dMMMP    VMMMb
# dMP.dMP.dMP dMP dMP   dMP   dMP.aMP dMP dMP dMP     dP .dMP
# VMMMPVMMP" dMP dMP   dMP    VMMMP" dMP dMP dMMMMMP  VMMMP"
#

# sync_reload = ->
#     # unless config.type == "jekyll"

gulp.task 'jade-watch', ["jade-build"], browserSync.reload
gulp.task 'stylus-watch', ["stylus-build"], browserSync.reload
gulp.task 'coffee-watch', ["coffee-build"], browserSync.reload

bSync = ->
    browserSync(
        proxy: "localhost:#{config.port}" # sets up what the proxy should be
        port: config.port+1 # set up port to watch/proxy
        ui:
            port: config.port+2 # where the UI can be accessed
            weinre: 9090
        watchOptions:
            debounceDelay: 1000
        ghostMode:
            clicks: true
            forms: true
            scroll: true
        logPrefix: "#{config.url} -- DEV" # give it a name
        open: if config.debug then true else config.ui # do we open a browser, or the ui?
        browser: if config.debug then ["google chrome", "firefox", "opera", "safari"] else false
        startPath: config.view # where should the browser open up to?
        xip: false
        reloadOnRestart: true
        notify: false # change to true after refactoring CIS
        injectChanges: false
    )

gulp.task 'browser-sync', ->
    if config.watch
        bSync()

        gulp
            .watch("#{jade_opts.cwd}**", ['jade-watch'])

        gulp
            .watch("#{stylus_opts.cwd}**", ['stylus-watch'])

        gulp
            .watch("#{coffee_opts.cwd}**", ['coffee-watch'])

gulp.task 'jekyll-browser-sync', ->
    if config.watch
        bSync()

        gulp
            .watch("#{jade_opts.cwd}**", ['jade-jekyll-watch'])

        # gulp
        #     .watch("#{stylus_opts.cwd}**", ['stylus-watch'])
        #
        # gulp
        #     .watch("#{coffee_opts.cwd}**", ['coffee-watch'])

        if config.type == "jekyll"
            gulp
                .watch("#{build.base}/**", ['jekyll-watch'])

        # gulp
        #     .watch("/__site/*.html")
        #     .on('change', browserReload)



#  dMMMMMMP .aMMMb  .dMMMb  dMP dMP .dMMMb
#    dMP   dMP"dMP dMP" VP dMP.dMP dMP" VP
#   dMP   dMMMMMP  VMMMb  dMMMMK"  VMMMb
#  dMP   dMP dMP dP .dMP dMP"AMF dP .dMP
# dMP   dMP dMP  VMMMP" dMP dMP  VMMMP"

# for help file/maker
task_def = (task_name, task_def, dev, build) ->
    if task_name
        task_name = colors.green("#{task_name} :: ")
    else
        task_name = ""

    task = task_def

    if dev
        dev = colors.yellow(dev)
        task = task.replace /::dev::/, dev

    if build
        build = colors.yellow(build)
        task = task.replace /::build::/, build

    console.log task_name + task


# default shouldn't do anything aside show what tasks are available to the user
gulp.task 'default',
  [], ->
    console.log "\n\n"
    task_def "coffee", "compile coffeescript files from ::dev:: to ::build::", coffee_opts.cwd, coffee_opts.dest
    task_def "jade", "compile jade files from ::dev:: to ::build::", jade_opts.cwd, jade_opts.dest
    task_def "stylus", "compile stylus files, autoprefix, [combine media queries,] minify, "
    task_def null, "          report size from ::dev:: to ::build::", stylus_opts.cwd, stylus_opts.dest
    console.log ""
    task_def "bower", "install bower files from ::dev:: and send to ::build::.", "bower.json", asset_opts.vendors.dest
    task_def null, "         Requires bower be installed on system."
    task_def "assets", "transfer assets from ::dev:: to ::build:: and minify images", asset_opts.assets.cwd, asset_opts.assets.dest
    task_def "vendor", "transfer vendor files from ::dev:: to ::build::", asset_opts.vendors.cwd, asset_opts.vendors.dest
    console.log ""
    task_def "media", "process and copy assets and vendor to build"
    task_def "django", "run jade, stylus, coffee for use in Django"
    console.log ""
    task_def "FLAGS", ""
    task_def "--sizereport", "give size of compiled files and their associated gzip size"
    task_def "--unminify", "unminify CSS/JS"
    task_def "--force", "force a compilation of all files"
    task_def "---watch", "run browser-sync and reload live pages"
    task_def "--ui", "when used with --watch, will open browser-sync ui"
    task_def "--url <project url>", "when used with --watch, will open browser"
    task_def null, "                       with given url of project"
    task_def "--debug", "when used with --watch, will open"
    task_def null, "           [chrome, firefox, opera, safari] for testing concurrently"
    task_def "--datauri","convert CSS background images to data URIs, not always recommended, "
    task_def null, "             run --sizereport"
    console.log "\n\n"

gulp.task 'jade',
[
    'jade-build'
    'browser-sync'
], ->
    console.log colors.yellow 'Compiled project through GulpJS for Jade'

gulp.task 'stylus',
[
    'stylus-build'
    'browser-sync'
], ->
    console.log colors.yellow 'Compiled project through GulpJS for Stylus'

gulp.task 'coffee',
[
    'coffee-build'
    'browser-sync'
], ->
    console.log colors.yellow 'Compiled project through GulpJS for CoffeScript'

gulp.task 'media',
[
    'assets'
    'vendor'
], ->
    console.log colors.yellow 'Compiled media files through GulpJS'


gulp.task 'django',
[
    'jade-build'
    'stylus-build'
    'coffee-build'
    'browser-sync'
], ->
    console.log colors.yellow 'Compiled project through GulpJS for Django'

gulp.task 'help',
[
    'default'
]





#     dMMMMb  .aMMMb  dMP dMP dMP dMMMMMP dMMMMb
#    dMP"dMP dMP"dMP dMP dMP dMP dMP     dMP.dMP
#   dMMMMK" dMP dMP dMP dMP dMP dMMMP   dMMMMK"
#  dMP.aMF dMP.aMP dMP.dMP.dMP dMP     dMP"AMF
# dMMMMP"  VMMMP"  VMMMPVMMP" dMMMMMP dMP dMP

# run series of bower pieces based off of bower.json
gulp.task 'bower', ['bower_init', 'bower_copy', 'bower_cleanup'], ->
    console.log colors.green "Bower components installed at: ./#{src.base}/#{ src.vendor }"


gulp.task 'bower_init', ->
    gulp.src("./")
        .pipe(
            plugins.exec "bower install"
        )


gulp.task 'bower_copy', ['bower_init'], ->
    gulp.src(mainBowerFiles())
        .pipe(
            gulp.dest("./#{src.base}/#{ src.vendor }")
        )


gulp.task 'bower_cleanup', ['bower_init', 'bower_copy'], (cb) ->
    del(
        ["./bower_components"],
        cb
    )


#
#     .aMMMb  .dMMMb  .dMMMb  dMMMMMP dMMMMMMP .dMMMb
#    dMP"dMP dMP" VP dMP" VP dMP        dMP   dMP" VP
#   dMMMMMP  VMMMb   VMMMb  dMMMP      dMP    VMMMb
#  dMP dMP dP .dMP dP .dMP dMP        dMP   dP .dMP
# dMP dMP  VMMMP"  VMMMP" dMMMMMP    dMP    VMMMP"
#

# asset and vendor options
asset_opts =
    files: [ "**/*.*" ]
    assets:
        cwd: "./#{src.base}/#{src.assets}"
        dest: "./#{build.base}/#{build.static}/#{build.assets}/"
    vendors:
        cwd: "./#{src.base}/#{src.vendor}"
        dest: "./#{build.base}/#{build.static}/#{build.vendor}/"

# transfer asset files over to build location, run through imagemin
gulp.task 'assets', ->
    gulp
        .src(
            asset_opts.files
            cwd: asset_opts.assets.cwd
        )
        .pipe(
            # test for which files are newly editted
            # based on concatenate final file of app.js
            # todo: pull out concatenate final file
            # warning: assumes users want to concatenate
            plugins.if(
                config.force,
                utils.noop(),
                plugins.changed( asset_opts.assets.dest )
            )
        )
        .pipe( plugins.imagemin() )
        .pipe( gulp.dest asset_opts.assets.dest )

    console.log colors.yellow(colors.underline("[Assets] output to:")) + colors.gray(asset_opts.assets.dest)

# transfer vendor files over to build location
gulp.task 'vendor', ->
    gulp
        .src(
            asset_opts.files
            cwd: asset_opts.vendors.cwd
        )
        .pipe(
            # test for which files are newly editted
            # based on concatenate final file of app.js
            # todo: pull out concatenate final file
            # warning: assumes users want to concatenate
            plugins.if(
                config.force,
                utils.noop(),
                plugins.changed( asset_opts.assets.dest )
            )
        )
        .pipe( gulp.dest asset_opts.vendors.dest )

    console.log colors.yellow(colors.underline("[Vendor] output to:")) + colors.gray(asset_opts.vendors.dest)
