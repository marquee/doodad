
BaseDoodad  = require '../BaseDoodad'
Spinner     = require '../subcomponents/Spinner'



class Button extends BaseDoodad
    @__doc__ = '<Link to button docs>'
    DEFAULT_ICONS:
        default     : 'ok'
        friendly    : 'ok'
        warning     : 'warning'
        dangerous   : 'warning'
        action      : 'right'

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
    initialize: (options={}) ->
        options._icon_name = @DEFAULT_ICONS.default
        if options.variant
            # Allow the icon_name to be something like 'angle-right'. The variant
            # is always one word, unhyphenated.
            [variant, size] = options.variant.split(':')
            options._size = size
            options.variant = variant
            if variant
                [variant, icon_name...] = variant.split('-')
                unless icon_name.length > 0
                    icon_name = [@DEFAULT_ICONS[variant]]
                options.variant = variant
                options._icon_name = icon_name.join('-')

        super(options)

        @_loadConfig options,
            type            : 'text'
            label           : null
            variant         : null
            helptext        : null
            enabled         : true
            spinner         : false
            progress        : null
            classes         : []
            events          : {}
            action          : null
            url             : null

        if not @_config.action? and @_config.url
            @_config.action = =>
                window.location = @_config.url

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
    _setClasses: =>
        super()
        if @_config.spinner
            if @_config.spinner is 'replace'
                @$el.addClass('-spinner--replace')
            else
                @$el.addClass('-spinner--inline')
        if @_config._size
            @$el.addClass("-size--#{ @_config._size }")

    # Public: Add the label to the element. If the Button is type 'icon', the
    #         label is set as the title.
    #
    # Returns nothing.
    render: ->
        @$el.empty()
        @_setClasses()

        if @_config.label
            @$el.append('<span class="Button_Label"></span>')
            @setLabel(@_config.label)
        if @_config.type.indexOf('icon') isnt -1
            $icon_display = $('<div class="Button_Icon"></div>')
            if @_config._icon_name
                $icon_display.addClass("-#{ @_config._icon_name }")
            @$el.prepend($icon_display)
        if @_config.spinner
            @$el.append(@_spinner.render().el)
        @delegateEvents()
        return this

    # Public: Set the Button state to disabled.
    #
    # Returns nothing.
    disable: ->
        super()
        @$el.attr('disabled', true)
        @_setInactive()

    # Public: Set the Button state to enabled. Also sets the button as inactive.
    #
    # Returns nothing.
    enable: ->
        super()
        @$el.removeAttr('disabled')
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

    events: ->
        'click': '_handleClick'

    # Private: Handle the click event. Fires a 'click' event.
    #
    # Returns nothing.
    _handleClick: (e) =>
        e?.stopPropagation()
        if @_config.spinner
            @disable()
            @_setActive()
        @_config.action?(this)
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
            @$el.find('.Button_Label').text(label)
        return this


module.exports = Button
