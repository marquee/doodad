
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
        super(arguments...)
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
                variant: if @_options.type.indexOf('bare') is -1 then 'light' else 'dark'
        @render()

    # Private: Check that the required options were passed to the constructor.
    #          Throws Errors if the options are invalid or missing.
    #
    # Returns nothing.
    _validateOptions: ->
        if not @_options.type in ['text', 'icon', 'icon+text', 'text-bare', 'icon-bare', 'icon+text-bare']
            throw new Error "Button type must be one of 'text', 'icon', 'icon+text', got #{ @_options.type }."
        if @_options.type is 'text' and not @_options.label
            throw new Error "Buttons of type='text' MUST have a label set."
        if not @_options.action? and not @_options.url?
            throw new Error "A Button action function or url must be specified."

    # Private: Apply the necessary classes to the element.
    #
    # Returns nothing.
    _setClasses: ->
        super()
        if @_options.spinner
            @$el.addClass('Button-spinner')

    # Public: Add the label to the element. If the Button is type 'icon', the
    #         label is set as the title.
    #
    # Returns nothing.
    render: ->
        @$el.empty()
        @_setClasses()

        if @_options.label
            @$el.append('<span class="Button_label"></span>')
            @setLabel(@_options.label)
        if @_options.type.indexOf('icon') isnt -1
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
        e?.stopPropagation()

        if @_options.spinner
            @disable()
            @_setActive()

        @_options.action(this)
        return

    # Public: Set the text label of the button.
    #
    # label - the String value of the label
    #
    # Returns self for chaining.
    setLabel: (label) =>
        if @_options.type in ['icon', 'icon-bare']
            @$el.attr('title', label)
        else
            @$el.find('.Button_label').text(label)
        return this


module.exports = Button
