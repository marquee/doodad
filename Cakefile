{ spawn, exec }     = require 'child_process'
path                = require 'path'
util                = require 'util'
fs                  = require 'fs'
Walker              = require 'walker'
Sqwish              = require 'sqwish'
UglifyJS            = require 'uglify-js'
jade                = require 'jade'

VERSION = JSON.parse(fs.readFileSync('package.json')).version

PROJECT_ROOT = path.join(path.dirname(fs.realpathSync(__filename)))

SOURCE_FOLDER   = path.join(PROJECT_ROOT, 'source/')
BUILD_FOLDER    = path.join(PROJECT_ROOT, 'build/')
OUTPUT_FOLDER   = path.join(PROJECT_ROOT, 'dist/')
EXAMPLE_SOURCE_FOLDER = path.join(PROJECT_ROOT, 'examples/')
EXAMPLE_OUTPUT_FOLDER = path.join(OUTPUT_FOLDER, 'examples/')

JS_LIB_NAME             = "doodad-#{ VERSION }.js"
CSS_LIB_NAME            = "doodad-#{ VERSION }.css"
SASS_LIB_NAME           = "doodad-#{ VERSION }.sass"
MIN_JS_LIB_NAME         = "doodad-#{ VERSION }-min.js"
MIN_CSS_LIB_NAME        = "doodad-#{ VERSION }-min.css"


TO_COPY = []#'images',]     # relative to SOURCE_FOLDER
TO_COPY_FAIL_SILENT = []

# Set by the -q option, determines the level of verbosity
quiet      = false
production = false



# Options

option '-q', '--quiet',      'Suppress non-error output'
option '-p', '--production', 'Compile for production'


compassExtraOptions = [
    #'--debug-info',
    '--boring', # Disable colors, which fuck up the output
    '--relative-assets',
    '--sass-dir',        'source/',
    '--css-dir',         'build/',
    '--images-dir',      'build/images/',
    '--javascripts-dir', 'build/',
    '--load-all',  'node_modules/',
]


# Task definitions

task 'flush_static', 'Empty the static directory', (opts) ->
    { quiet } = opts
    flushStatic()

task 'build:examples', '', (opts) ->
    fs.readdir EXAMPLE_SOURCE_FOLDER, (err, files) ->
        files.forEach (file) ->
            filename_parts = file.split('.')
            if filename_parts.pop() is 'jade' and file[0] isnt '_'
                options =
                    VERSION: VERSION
                    example_name: filename_parts.join('.')
                jade.renderFile path.join(EXAMPLE_SOURCE_FOLDER, file), options, (err, data) ->
                    throw err if err?
                    filename_parts.push('html')
                    outfile = filename_parts.join('.')
                    fs.writeFile path.join(EXAMPLE_OUTPUT_FOLDER, outfile), data, (err) ->
                        console.log 'wrote', outfile
                        throw err if err?


# var html = jade.renderFile('path/to/file.jade', options);


task 'build:scripts', '', (opts) ->
    coffee_builder = spawn 'coffee', ['--output', BUILD_FOLDER, '--compile', SOURCE_FOLDER]
    captureOutput coffee_builder, 'COFFEE', ->
        browserify = require 'browserify'
        b = browserify()
        dist_file = path.join(BUILD_FOLDER, 'dist.js')
        b.add(path.join(dist_file))
        output_file = path.join(OUTPUT_FOLDER, JS_LIB_NAME)
        output_stream = fs.createWriteStream(output_file)
        b.bundle (err, src) ->
            fs.writeFile output_file, jsSourcePrefix(src), (err) ->
                throw err if err?
            minified = _minifyJS(src)
            fs.writeFile(path.join(OUTPUT_FOLDER, MIN_JS_LIB_NAME), jsSourcePrefix(minified), ->)


task 'build:sass', '', (opts) ->
    lines_to_concatenate = []
    file_list = []
    folders_to_process = ['global', 'subcomponents', 'components', 'containers']
    num_folders_processed = 0
    folders_to_process.forEach (folder) ->
        path_to_walk = path.join(SOURCE_FOLDER, folder)
        w = Walker(path_to_walk)
        w.on 'file', (f, stat) ->
            if f.split('.').pop() is 'sass'
                if f.split('/').pop()[0] is '_'
                    file_list.unshift(f)
                else
                    file_list.push(f)
        w.on 'end', ->
            while file_list.length > 0
                do ->
                    f = file_list.shift()
                    contents = fs.readFileSync(f).toString()
                    contents = contents.split('\n')
                    contents = contents.map (line) ->
                        if line.indexOf("@import './") is 0 or line.indexOf("@import '../") is 0
                            return ''
                        return line
                    lines_to_concatenate.push(contents...)
            num_folders_processed += 1
            if num_folders_processed is folders_to_process.length
                lines_to_concatenate = sassSourcePrefix(lines_to_concatenate.join('\n'))
                fs.writeFileSync(path.join(OUTPUT_FOLDER, SASS_LIB_NAME), lines_to_concatenate)




task 'build', 'Compile the static source (coffee/sass) and put it into static/', (opts) ->
    { quiet, production } = opts
    if not quiet
        console.log 'Building project:', process.cwd()

    flushStatic ->
        copyFolders ->
            invoke 'build:scripts'
            invoke 'build:sass'
            invoke 'build:examples'

            compassOptions = ['compile', '--force']

            compassOptions.push('--environment')
            if production
                compassOptions.push('production')
            else
                compassOptions.push('development')

            for flag in compassExtraOptions
                compassOptions.push(flag)

            compass_builder = spawn 'compass', compassOptions
            captureOutput compass_builder, 'COMPASS', ->
                unminified = fs.readFileSync(path.join(BUILD_FOLDER, 'dist.css')).toString()
                minified = Sqwish.minify(unminified)
                fs.writeFile path.join(OUTPUT_FOLDER, CSS_LIB_NAME), cssSourcePrefix(unminified), (err) ->
                    throw err if err?
                fs.writeFile path.join(OUTPUT_FOLDER, MIN_CSS_LIB_NAME), cssSourcePrefix(minified), (err) ->
                    throw err if err?


task 'watch', 'Build, then watch the static source (coffee/sass) for changes', (opts) ->
    invoke 'build'
    { quiet, production } = opts

    if not quiet
        console.log 'Working on project:', process.cwd()

    coffee_watcher = spawn 'coffee', ['--output', BUILD_FOLDER, '--watch', '--compile', SOURCE_FOLDER]
    captureOutput(coffee_watcher, 'COFFEE')

    compassOptions = ['watch']

    compassOptions.push('--environment')
    if production
        compassOptions.push('production')
    else
        compassOptions.push('development')

    for flag in compassExtraOptions
        compassOptions.push(flag)

    compass_watcher = spawn 'compass', compassOptions

    captureOutput(compass_watcher, 'COMPASS')



# Helper/DRY functions

# Copy the folders in TO_COPY from the STATIC_SOURCE to BUILD_FOLDER.
copyFolders = (cb) ->
    for folder in TO_COPY
        console.log "copying #{ folder }"
        exec "cp -R #{ path.join(SOURCE_FOLDER,folder) } #{ BUILD_FOLDER }", (err) ->
            if err?
                throw err
    for folder in TO_COPY_FAIL_SILENT
        console.log "copying #{ folder }"
        exec "cp -R #{ path.join(SOURCE_FOLDER,folder) } #{ BUILD_FOLDER }", (err) ->
    cb()

# Remove the static folder and its contents, then make it again (empty)
flushStatic = (cb) ->

    after1 = ->
        # The folder may not exist and removing it causes an error.
        try
            exec("rm -r #{ OUTPUT_FOLDER }", after2)
        catch err
            after2()

    after2 =  ->
        fs.mkdirSync(BUILD_FOLDER)
        fs.mkdirSync(OUTPUT_FOLDER)
        fs.mkdirSync(EXAMPLE_OUTPUT_FOLDER)
        cb?()

    # The folder may not exist and removing it causes an error.
    try
        exec("rm -r #{ BUILD_FOLDER }", after1)
    catch err
        after1()


_minifyJS = (js_script_code) ->
    toplevel_ast = UglifyJS.parse(js_script_code)
    toplevel_ast.figure_out_scope()

    compressor = UglifyJS.Compressor
        drop_debugger   : true
        warnings        : false
    compressed_ast = toplevel_ast.transform(compressor)
    compressed_ast.figure_out_scope()
    compressed_ast.mangle_names()

    min_code = compressed_ast.print_to_string()
    return min_code

build_date = new Date()
doodad_source_prefix = """
    Doodad v#{ VERSION }
    Public Domain, https://github.com/marquee/doodad
    #{ build_date.getFullYear() }-#{ build_date.getMonth() + 1 }-#{ build_date.getDate() }
"""
sassSourcePrefix = (source) ->
    return """
    // Doodad v#{ VERSION }
    // Public Domain, https://github.com/marquee/doodad
    // #{ build_date.getFullYear() }-#{ build_date.getMonth() + 1 }-#{ build_date.getDate() }

    #{ source }
    """

cssSourcePrefix = (source) ->
    return """
    /*
    #{ doodad_source_prefix }
    */
    #{ source }
    """

jsSourcePrefix = (source) ->
    return """
    /*
    #{ doodad_source_prefix }

    Contains a copy of spin.js, http://fgnass.github.io/spin.js
    Copyright (c) 2011-2013 Felix Gnass
    Licensed under the MIT license
    */

    #{ source }
    """


# Given a child process, add listeners to its stdout, stderr, and exit output.
# If not suppressed, log this output to the console. Optionally takes a label to
# prepend the output with.
captureOutput = (operator, label='', cb=->) ->
    if not quiet
        operator.stdout.on 'data', (data) ->
            if data?.toString().match(/[^\s]+/g)
                console.log "#{ label }.stdout: #{ data }"
        operator.stderr.on 'data', (data) ->
            console.log 'match', data?.toString().match(/[^\s]+/g)
            if data?.toString().match(/[^\s]+/g)
                console.log "#{ label }.stderr: #{ data }"
        operator.on 'exit', (code) ->
            console.log "#{ label }.exit:", code
            if code is 0
                cb()

    operator.stderr.on 'data', (data) ->
        if data?.length > 10 # because compass likes to push out color codes
            console.log "#{ label }.stderr: #{ data }"
