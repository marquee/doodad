{ spawn, exec }     = require('child_process')
util                = require('util')
fs                  = require('fs')

STATIC_SOURCE = 'ui_source/'    # relative to Cakefile
STATIC_OUTPUT = 'static/'

TO_COPY = ['common', 'libs', 'images', 'custom_images', 'vendor', 'admin_extras']     # relative to STATIC_SOURCE
TO_COPY_FAIL_SILENT = ['../custom_assets']

# Set by the -q option, determines the level of verbosity
quiet      = false
production = false



# Options

option '-q', '--quiet',      'Suppress non-error output'
option '-p', '--production', 'Compile for production'


compassExtraOptions = [
    #'--debug-info',
    '--relative-assets',
    '--require',         'animation',
    '--sass-dir',        'ui_source/',
    '--css-dir',         'static/',
    '--images-dir',      'static/images/',
    '--javascripts-dir', 'static/',
]


# Task definitions

task 'flush_static', 'Empty the static directory', (opts) ->
    { quiet } = opts
    flushStatic()

task 'build:scripts', '', (opts) ->
    coffee_builder = spawn 'coffee', ['--output', STATIC_OUTPUT, '--compile', STATIC_SOURCE]
    captureOutput(coffee_builder, 'COFFEE')

task 'build', 'Compile the static source (coffee/sass) and put it into static/', (opts) ->
    { quiet, production } = opts
    if not quiet
        console.log 'Building project:', process.cwd()

    flushStatic ->
        copyFolders ->
            invoke 'build:scripts'

            compassOptions = ['compile', '--force']

            compassOptions.push('--environment')
            if production
                compassOptions.push('production')
            else
                compassOptions.push('development')

            for flag in compassExtraOptions
                compassOptions.push(flag)

            compass_builder = spawn 'compass', compassOptions
            captureOutput(compass_builder, 'COMPASS')

task 'watch', 'Build, then watch the static source (coffee/sass) for changes', (opts) ->
    invoke 'build'
    { quiet, production } = opts

    if not quiet
        console.log 'Working on project:', process.cwd()

    coffee_watcher = spawn 'coffee', ['--output', STATIC_OUTPUT, '--watch', '--compile', STATIC_SOURCE]
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

# Copy the folders in TO_COPY from the STATIC_SOURCE to STATIC_OUTPUT.
copyFolders = (cb) ->
    for folder in TO_COPY
        console.log "copying #{ folder }"
        exec "cp -R #{ STATIC_SOURCE }#{ folder } #{ STATIC_OUTPUT }", (err) ->
            if err?
                throw err
    for folder in TO_COPY_FAIL_SILENT
        console.log "copying #{ folder }"
        exec "cp -R #{ STATIC_SOURCE }#{ folder } #{ STATIC_OUTPUT }", (err) ->
    cb()

# Remove the static folder and its contents, then make it again (empty)
flushStatic = (cb) ->
    after =  ->
        fs.mkdirSync(STATIC_OUTPUT)
        cb?()

    # The folder may not exist and removing it causes an error.
    try
        exec("rm -r #{ STATIC_OUTPUT }", after)
    catch err
        after()

# Given a child process, add listeners to its stdout, stderr, and exit output.
# If not suppressed, log this output to the console. Optionally takes a label to
# prepend the output with.
captureOutput = (operator, label='') ->
    if not quiet
        operator.stdout.on 'data', (data) ->
            if data?.length > 0
                console.log "#{ label }.stdout: #{ data }"
        operator.on 'exit', (code) ->
            console.log "#{ label }.exit:", code

    operator.stderr.on 'data', (data) ->
        if data?.length > 10 # because compass likes to push out color codes
            console.log "#{ label }.stderr: #{ data }"
