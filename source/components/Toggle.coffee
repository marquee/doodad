
{ View }    = Backbone


DOC_URL = 'http://example.com/'

class Toggle extends View
    @__doc__ = """
    A toggler. See #{ DOC_URL }toggle/
    """

    tagName: 'DIV'
    className: 'Toggle'

    initialize: (options) ->
        @_is_enabled = true
        @_value = false
        @_options = _.extend {},
            type            : 'text'
            inactive_label  : ''
            active_label    : ''
            class           : null
            helptext        : null
            enabled         : true
            active          : true
            on              : {}    # change, activate, deactivate
            extra_classes   : []
        , options

        @_validateOptions()

        _.each @_options.on, (e_handler, e_name) =>
            @on(e_name, e_handler)

        unless @_options.enabled
            @disable()

    # Private: Check that the required options were passed to the constructor.
    #          Throws Errors if the options are invalid or missing.
    #
    # Returns nothing.
    _validateOptions: ->
        # TODO: type = 'checkbox', 'image'
        if not @_options.type in ['switch',]
            throw new Error "Toggle type must be one of 'switch', got #{ @_options.type }."
        if @_options.type in ['switch'] and not @_options.label
            throw new Error "Buttons of type='switch' MUST have a label set."

    # Private: Apply the necessary classes to the element.
    #
    # Returns nothing.
    _setClasses: ->
        class_list = @_options.type.split('+')
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
        console.log 'Toggle.render'
        @$el.html("""
            <span class="Toggle-track">
                <span class="Toggle-switch"></span>
            </span>
        """)

        @_setClasses()

        if @_options.inactive_label
            $label = $('<label class="Toggle-label Toggle-label-inactive"></label>')
            $label.text(@_options.inactive_label)
            @$el.prepend($label)
        if @_options.active_label
            $label = $('<label class="Toggle-label Toggle-label-active"></label>')
            $label.text(@_options.active_label)
            @$el.append($label)
        @delegateEvents()
        return @el

    # Public: Set the Button state to disabled.
    #
    # Returns nothing.
    disable: ->
        console.log 'Button.disable'
        @_is_enabled = false
        @$el.attr('disabled', true)
        @_setInactive()

    # Public: Set the Button state to enabled. Also sets the button as inactive.
    #
    # Returns nothing.
    enable: ->
        console.log 'Button.enable'
        @_is_enabled = true
        @$el.removeAttr('disabled')
        @_setInactive()

    # Public: Check the enabled status.
    # 
    # Returns true if enabled, false if disabled.
    isEnabled: -> @_is_enabled

    # Public: Toggle the enabled/disabled state.
    #
    # Returns true if enabled, false if disabled.
    toggleEnabled: =>
        console.log 'Button.toggleEnabled'
        if @_is_enabled
            @disable()
        else
            @enable()
        return @_is_enabled

    toggleActive: =>
        if @_is_active
            @setInactive()
        else
            @setActive()
        return @_is_active

    _fire: (event_names...) ->
        _.each event_names, (name) =>
            @trigger(name, this)

    setActive: =>
        @_is_active = true
        @$el.addClass('active')
        @_fire('activate', 'change')

    setInactive: =>
        @_is_active = false
        @$el.removeClass('active')
        @_fire('deactivate', 'change')

    events:
        'click': '_handleClick'

    # Private: Handle the click event. Fires a 'click' event.
    #
    # Returns nothing.
    _handleClick: (e) =>
        console.log 'click!'
        e?.stopPropagation()
        @toggleActive()
        # @_options.action(this)
        return

    # TODO: Make a BaseUIView that has things like position, validateOptions
    getPosition: ->
        { top, left } = @$el.offset()
        width = @$el.width()
        height = @$el.height()
        x = left + width / 2
        y = top + height / 2
        return { x:x, y:y }




module.exports = Toggle