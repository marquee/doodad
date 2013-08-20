
BaseDoodad = require '../BaseDoodad'

Spinner = require '../subcomponents/Spinner'



class Button extends BaseDoodad
    @__doc__ = '<Link to button docs>'

    tagName: 'BUTTON'
    className: 'Button'

    # Public: A button. Given an action function, it calls the function whenever
    #         it gets clicked. It can have a spinner, which causes the button to
    #         automatically go into a disabled state until told otherwise.
    #
    #     new Button
    #         label: 'Click Me!'
    #         action: (self) -> # do stuff
    #
    #     new Button
    #         type: 'icon'
    #         label: 'Title text'
    #         action: (self) -> # do stuff
    #
    #     new Button
    #         type: 'icon+text'
    #         label: 'Click Me!'
    #         spinner: true
    #         action: (self) ->
    #             # do stuff
    #             self.enable()
    #
    initialize: (options) ->
        super()
        @_options = _.extend {},
            type            : 'text'
            label           : null
            class           : null
            helptext        : null
            enabled         : true
            spinner         : false
            progress        : null
            extra_classes   : []
        , options

        @_validateOptions()

        unless @_options.enabled
            @disable()

        if @_options.spinner
            @_spinner = new Spinner
                variant: 'light'
        @render()

    # Private: Check that the required options were passed to the constructor.
    #          Throws Errors if the options are invalid or missing.
    #
    # Returns nothing.
    _validateOptions: ->
        if not @_options.type in ['text', 'icon', 'icon+text']
            throw new Error "Button type must be one of 'text', 'icon', 'icon+text', got #{ @_options.type }."
        if @_options.type is 'text' and not @_options.label
            throw new Error "Buttons of type='text' MUST have a label set."
        if not @_options.action? and not @_options.url?
            throw new Error "A Button action function or url must be specified."

    # Private: Apply the necessary classes to the element.
    #
    # Returns nothing.
    _setClasses: ->
        class_list = @_options.type.split('+')
        if @_options.spinner
            class_list.push('spinner')
        if @_options.class?.length > 0
            class_list.push(@_options.class.split(' ')...)
        class_list = _.map class_list, (c) => "#{ @className }-#{ c }"
        class_list.push(@_options.extra_classes...)
        @$el.addClass(class_list.join(' '))

    # Public: Add the label to the element. If the Button is type 'icon', the
    #         label is set as the title.
    #
    # Returns nothing.
    render: ->
        console.log 'Button.render'
        @$el.empty()
        @_setClasses()

        if @_options.label
            if @_options.type is 'icon'
                @$el.attr('title', @_options.label)
            else
                @$el.text(@_options.label)
        if @_options.type in ['icon', 'icon+text']
            @$el.prepend('<div class="Button_icon_display"></div>')
        if @_options.spinner
            @$el.append(@_spinner.render())
        @delegateEvents()
        return @el

    # Public: Set the Button state to disabled.
    #
    # Returns nothing.
    disable: ->
        super()
        @_setInactive()

    # Public: Set the Button state to enabled. Also sets the button as inactive.
    #
    # Returns nothing.
    enable: ->
        super()
        @_setInactive()

    # Private: Set the button as active (shows the spinner).
    #
    # Returns nothing.
    _setActive: ->
        @_spinner?.start()
        @$el.addClass('active')

    # Private: Set the button as inactive (hides the spinner).
    #
    # Returns nothing.
    _setInactive: ->
        @_spinner?.stop()
        @$el.removeClass('active')

    events:
        'click': '_handleClick'

    # Private: Handle the click event. Fires a 'click' event.
    #
    # Returns nothing.
    _handleClick: (e) =>
        console.log 'click!'
        e?.stopPropagation()

        if @_options.spinner
            @disable()
            @_setActive()

        @_options.action(this)
        return



module.exports = Button
