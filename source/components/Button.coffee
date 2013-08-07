
{ View }    = Backbone


DOC_URL = 'http://example.com/'

class Button extends View
    @__doc__ = """
    A basic button class. See #{ DOC_URL }button/
    """

    tagName: 'BUTTON'
    className: 'Button'

    initialize: (options) ->
        @_is_enabled = true
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
        @_setClasses()

        if @_options.label
            if @_options.type is 'icon'
                @$el.attr('title', @_options.label)
            else
                @$el.text(@_options.label)
        if @_options.type in ['icon', 'icon+text']
            @$el.prepend('<div class="Button-icon-display"></div>')
        if @_options.spinner
            @$el.append('<div class="Button-spinner-display"></div>')
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
    toggleEnabled: ->
        console.log 'Button.toggleEnabled'
        if @_is_enabled
            @disable()
        else
            @enable()
        return @_is_enabled

    # Private: Set the button as active (shows the spinner).
    #
    # Returns nothing.
    _setActive: ->
        @$el.addClass('active')

    # Private: Set the button as inactive (hides the spinner).
    #
    # Returns nothing.
    _setInactive: ->
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

    # TODO: Make a BaseUIView that has things like position, validateOptions
    getPosition: ->
        { top, left } = @$el.offset()
        width = @$el.width()
        height = @$el.height()
        x = left + width / 2
        y = top + height / 2
        return { x:x, y:y }

    getSize: ->
        return {
            width: @$el.width()
            height: @$el.height()
        }

    hide: ->
        @$el.hide()
        return this

    show: ->
        @$el.show()
        return this
module.exports = Button