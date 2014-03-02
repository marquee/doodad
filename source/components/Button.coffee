
BaseDoodad  = require '../BaseDoodad'
Spinner     = require '../subcomponents/Spinner'
ProgressBar = require '../subcomponents/ProgressBar'


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
        instance_variant = options.variant or @variant
        if instance_variant
            # Allow the icon_name to be something like 'angle-right'. The variant
            # is always one word, unhyphenated.
            [variant, size] = instance_variant.split(':')
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
            type        : 'text'
            label       : null
            variant     : null
            helptext    : null
            enabled     : true
            spinner     : false
            progress    : null
            classes     : []
            events      : {}
            action      : null
            url         : null

        if not @_config.action? and @_config.url
            @_config.action = =>
                window.location = @_config.url

        @_validateOptions()

        unless @_config.enabled
            @disable()

        if @_config.spinner
            @_spinner = new Spinner
                color: if @_config.type.indexOf('bare') is -1 then '#fff' else '#000'
        else if @_config.progress
            @_progress = new ProgressBar()

        @render()

        # Listen to the change event of the model, rerendering the label,
        # which MAY be an Underscore template that depends on model attributes.
        if @model?
            @listenTo(@model, 'change', @_renderLabel)

    # Private: Check that the required options were passed to the constructor.
    #          Throws Errors if the options are invalid or missing.
    #
    # Returns nothing.
    _validateOptions: ->
        if not @_config.type in ['text', 'icon', 'icon+text', 'text-bare', 'icon-bare', 'icon+text-bare']
            throw new Error "Button type MUST be one of 'text', 'icon', 'icon+text', got #{ @_config.type }."
        if @_config.type is 'text' and not @_config.label
            throw new Error "Buttons of type 'text' MUST have a label set."
        if @_config.spinner and @_config.progress
            throw new Error "Buttons MUST NOT have both spinner and progress."

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
        else if @_config.progress
            @$el.addClass('-progress')
        if @_config._size
            @$el.addClass("-size--#{ @_config._size }")

    # Public: Render the component.
    #
    # Returns self for chaining.
    render: =>
        @$el.empty()
        @_setClasses()

        # Add the label element. (Not visible if icon-only.)
        if @_config.label
            @$el.append('<span class="Button_Label"></span>')
            @setLabel(@_config.label)

        # Add the icon element.
        if @_config.type.indexOf('icon') isnt -1
            $icon_display = $('<div class="Button_Icon"></div>')
            if @_config._icon_name
                $icon_display.addClass("-#{ @_config._icon_name }")
            @$el.prepend($icon_display)

        # Add the spinner or progress element (exclusive options).
        if @_config.spinner
            @$el.append(@_spinner.render().el)
        else if @_config.progress
            @$el.prepend(@_progress.render().el)

        # Ensure the events are bound.
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
        if @_progress
            @_progress.hide()
            @setProgress(0)
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

    # Private: Handle the click event. Fires a 'click' event and calls the
    #          specified `action` function, if any.
    #
    # Returns nothing.
    _handleClick: (e) =>
        e?.stopPropagation()

        if @_config.spinner or @_config.progress
            @disable()
            @_setActive()
            if @_config.progress
                @_progress.show()
        @_config.action?(this)
        @trigger('click', this)
        return

    # Public: Set the text label of the button.
    #
    # label - the String value of the label
    #
    # Returns self for chaining.
    setLabel: (label) =>
        @_current_label = label
        @_renderLabel()
        return this

    # Internal: Render the label text, using `@_current_label` as an Underscore
    #           template. If a `model` property was provided when initializing,
    #           its serialized form will be used as the template context.
    #
    # Returns nothing.
    _renderLabel: =>
        context = if @model then @model.toJSON() else {}
        label = _.template(@_current_label, context)
        if @_config.type in ['icon', 'icon-bare']
            @$el.attr('title', label)
        else
            @$el.find('.Button_Label').text(label)

    # Public: Set the value of the progress bar. Requires the Button to be
    #         constructed with the option `progess: true`.
    #
    # val - a Number value, from 0 to 1, representing the progress percentage
    #
    # Returns self for chaining.
    setProgress: (val) ->
        if not @_config.progress
            throw new Error 'CANNOT call `setProgress` on a Button without the progress option'
        @_progress.setValue(val)
        return this


module.exports = Button
