
BaseDoodad  = require '../BaseDoodad'
Spinner     = require '../subcomponents/Spinner'



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
    #         on: click: (self) -> # do stuff
    #
    #     new Button
    #         type: 'icon'
    #         label: 'Title text'
    #         on: click: (self) -> # do stuff
    #
    #     new Button
    #         type: 'icon+text'
    #         label: 'Click Me!'
    #         spinner: true
    #         on: click: (self) ->
    #             # do stuff
    #             self.enable()
    #
    initialize: (options) ->
        if options.action?
            console.warn 'Button `action` option is deprecated. Used the `on.click` event option instead.'
            options.on ?= {}
            options.on.click = options.action
        if not options.on?.click? and options.url
            options.on.click = ->
                window.location = options.url

        super(arguments...)
        @_config = _.extend {},
            type            : 'text'
            label           : null
            variant         : null
            helptext        : null
            enabled         : true
            spinner         : false
            progress        : null
            classes         : []
            on              : {}
        , options

        @_validateOptions()

        unless @_config.enabled
            @disable()

        if @_config.spinner
            @_spinner = new Spinner
                color: if @_config.type.indexOf('bare') is -1 then '#fff' else '#000'
        @render()

    # Private: Check that the required options were passed to the constructor.
    #          Throws Errors if the options are invalid or missing.
    #
    # Returns nothing.
    _validateOptions: ->
        if not @_config.type in ['text', 'icon', 'icon+text', 'text-bare', 'icon-bare', 'icon+text-bare']
            throw new Error "Button type must be one of 'text', 'icon', 'icon+text', got #{ @_config.type }."
        if @_config.type is 'text' and not @_config.label
            throw new Error "Buttons of type 'text' MUST have a label set."

    # Private: Apply the necessary classes to the element.
    #
    # Returns nothing.
    _setClasses: ->
        super()
        if @_config.spinner
            @$el.addClass('-spinner')
            if @_config.spinner is 'replace'
                @$el.addClass('-spinner--replace')
            else
                @$el.addClass('-spinner--inline')

    # Public: Add the label to the element. If the Button is type 'icon', the
    #         label is set as the title.
    #
    # Returns nothing.
    render: ->
        @$el.empty()
        @_setClasses()

        if @_config.label
            @$el.append('<span class="ButtonLabel"></span>')
            @setLabel(@_config.label)
        if @_config.type.indexOf('icon') isnt -1
            @$el.prepend('<div class="ButtonIcon"></div>')
        if @_config.spinner
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
        @setState('active')

    # Private: Set the button as inactive (hides the spinner).
    #
    # Returns nothing.
    _setInactive: ->
        @_spinner?.stop()
        @unsetState('active')

    events:
        'click': '_handleClick'

    # Private: Handle the click event. Fires a 'click' event.
    #
    # Returns nothing.
    _handleClick: (e) =>
        e?.stopPropagation()

        if @_config.spinner
            @disable()
            @_setActive()
        @trigger('click', this)
        return

    # Public: Set the text label of the button.
    #
    # label - the String value of the label
    #
    # Returns self for chaining.
    setLabel: (label) =>
        if @_config.type in ['icon', 'icon-bare']
            @$el.attr('title', label)
        else
            @$el.find('.ButtonLabel').text(label)
        return this


module.exports = Button
