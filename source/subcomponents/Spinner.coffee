# spinner = new Spinner
#     type: 'spinner'
#     rate: 0.5

# spinner.start()
# spinner.stop()
# spinner.setRate(0.1)
# spinner.speedUp()   # +0.1
# spinner.slowDown()  # -0.1
# spinner.bindTo(element_that_emits_progress)

BaseDoodad = require '../BaseDoodad'

SpinJS = require 'spin'

{ vendorPrefixCSS } = require '../misc/helpers'

class Spinner extends BaseDoodad

    tagName: 'SPAN'
    className: 'Spinner'

    initialize: (options) ->
        super()
        @_options = _.extend {},
            type            : 'arrows'
            variant         : 'dark'
            active          : false
            extra_classes   : []
            size            : null
        , options

        @_rate = 1
        @render()
        _.defer =>
            if @_options.active
                @start()
            else
                @stop()

    # Public: Add the label to the element. If the Button is type 'icon', the
    #         label is set as the title.
    #
    # Returns nothing.
    render: =>
        console.log 'Spinner.render'
        @_setClasses()
        return @el

    _setUpSpinner: (options) =>
        @_spinner?.stop()

        if @_options.variant is 'dark'
            color = '#000'
        else
            color = '#fff'

        { width, height } = @getSize()
        console.log width, height

        options = _.extend {
                radius: width / 4
                length: width / 4 - 1
                width: 3
                color: color
                className: ''
            }, options
        console.log options

        @_spinner = new SpinJS(options)
        @_spinner.spin(@el)

    isActive: =>
        return @_active

    start: =>
        console.log 'Spinner.start'
        @$el.addClass("#{ @className }-active")
        @_active = true
        @_setUpSpinner(speed: @_rate)
        return this

    stop: =>
        console.log 'Spinner.stop'
        clearInterval(@_rotation_interval)
        @$el.removeClass("#{ @className }-active")
        @_active = false
        @_setUpSpinner(speed: 0)
        return this

    # TODO: rate control

    # setRate: (rate) =>
    #     @_rate = rate
    #     @start() if @isActive()
    #     return this

    # speedUp: (by_rate=0.1) =>
    #     @_rate += by_rate
    #     @_setUpSpinner(speed: @_rate) if @isActive()
    #     return this

    # slowDown: (by_rate=0.1) =>
    #     console.log 'Spinner.slowDown', by_rate
    #     @_rate -= by_rate
    #     @_setUpSpinner(speed: @_rate) if @isActive()
    #     return this



module.exports = Spinner