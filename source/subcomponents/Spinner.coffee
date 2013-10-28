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

{ vendorPrefixCSS } = require '../global/helpers'

class Spinner extends BaseDoodad

    tagName: 'SPAN'
    className: 'Spinner'

    initialize: (options) ->
        @_config = _.extend {},
            type            : 'throbber'
            color           : '#000'
            active          : false
            classes         : []
            size            : null
            auto_hide       : true
        , options
        super(@_config)

        @_rate = 1
        @render()
        if @_config.auto_hide and @_config.active
            @hide()
        _.defer =>
            if @_config.active
                @start()
            else
                @stop()

    # Public: Add the label to the element. If the Button is type 'icon', the
    #         label is set as the title.
    #
    # Returns nothing.
    render: =>
        @_setClasses()
        return @el

    _setUpSpinner: (options) =>
        @_spinner?.stop()

        # { width, height } = @getSize()

        width = parseInt(@$el.css('width').replace('px', ''))
        height = parseInt(@$el.css('height').replace('px', ''))

        options = _.extend {
                radius: width / 4
                length: width / 4 - 1
                width: 3
                color: @_config.color
                className: ''
            }, options

        @_spinner = new SpinJS(options)
        @_spinner.spin(@el)
        @$el.children().css
            left: '50%'
            top: '50%'

    isActive: =>
        return @_active

    start: =>
        @$el.addClass("#{ @className }-active")
        @_active = true
        @_setUpSpinner(speed: @_rate)
        if @_config.auto_hide
            @show()
        return this

    stop: =>
        clearInterval(@_rotation_interval)
        @$el.removeClass("#{ @className }-active")
        @_active = false
        @_setUpSpinner(speed: 0)
        if @_config.auto_hide
            @hide()
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