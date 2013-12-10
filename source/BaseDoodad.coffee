
{ View } = Backbone



class BaseDoodad extends View
    @__doc__ = """
    Public: The base view for all Doodad components. Provides methods for
            getting the size & position, hiding & showing, and enabling &
            disabling. The enable and disable only set an attribute and don't
            actually handle any disabling.

    """

    # # Enabling this crazy shit makes the Doodad component behave like an
    # # Array-like jQuery/Zepto object, so $('div').append(doodad_instance) works.
    # constructor: ->
    #     super(arguments...)
    #     self = []
    #     self.__proto__ = this
    #     self[0] = @el
    #     return self

    initialize: (options={}) ->
        if options.class?
            console.warn "#{ @className } `class` option is deprecated. Use the `variant` option instead."
            options.variant = options.class
        if options.extra_classes?
            console.warn "#{ @className } `extra_classes` option is deprecated. Use the `classes` option instead."
            options.classes = options.extra_classes

        @name = options.name
        @_is_enabled = true

        if options.css
            @_setCSS(options.css)

        options.visible ?= true
        if options.visible
            @show()
        else
            @hide()

        _.each options.events, (handler, event) => @on(event, handler)
        _.each options.on, (handler, event) => @on(event, handler)
        _.each options.state, (value, name) => @setState(name, value)


    # Internal: Load configuration from passed options, as well as from the
    #           class definition if present. The final config is stored in the
    #           instance's `_config` property.
    #
    # options - an Object of options passed to the constructor (may be empty)
    # defaults - an Object of defaults to use
    #
    # Returns nothing.
    _loadConfig: (options, defaults) =>
        # Grab any new defaults from the class definition, in case this is a
        # customized component using class extension.
        default_config = {}
        for k, v of defaults
            class_default = @[k]
            if _.isFunction(class_default) and k isnt 'action'
                class_default = @[k](this)
            default_config[k] = class_default or v
        @_config = _.extend({}, default_config, options)

    # Public: Get the center position of the element relative to the document.
    #
    # Returns an object with the x and y coordinates of the center.
    getPosition: =>
        { top, left } = @$el.offset()
        width = @$el.width()
        height = @$el.height()
        x = left + width / 2
        y = top + height / 2
        return { x:x, y:y }

    # Public: Get the center position of the element relative to the screen.
    #
    # Returns an object with the x and y coordinates of the center.
    getScreenPosition: =>
        pos = @getPosition()
        pos.y -= $(window).scrollTop()
        return pos

    # Public: Get the dimensions of the entire element.
    #
    # Returns an object with the width and height in pixels.
    getSize: =>
        return {
            width   : @$el.width()
            height  : @$el.height()
        }

    # Public: Hide the element, using `display: none`.
    #
    # Hides the element using inline `display: none`, so that it can be revealed
    # in a less-forceful way using `@show`.
    #
    # Returns self for chaining.
    hide: =>
        @is_visible = false
        @$el.css(display: 'none')
        return this

    # Public: Show the element.
    #
    # Assumes the element was hidden using inline `display: none` and simply
    # removes it. `jQuery::show` adds inline styles corresponding to the
    # tag's defaults, which interferes with styles.
    #
    # Returns self for chaining.
    show: =>
        @is_visible = true
        @$el.css(display: '')
        return this

    # Public: Toggle the visibility of the element.
    #
    # Returns self for chaining.
    toggle: =>
        if @is_visible
            @hide()
        else
            @show()
        return this

    # Public: Set the element state to disabled.
    #
    # Returns nothing.
    disable: =>
        @_is_enabled = false
        @setState('disabled')

    # Public: Set the element state to enabled.
    #
    # Returns nothing.
    enable: =>
        @_is_enabled = true
        @unsetState('disabled')

    # Public: Check the enabled status.
    # 
    # Returns true if enabled, false if disabled.
    isEnabled: => @_is_enabled

    # Public: Toggle the enabled/disabled state.
    #
    # Returns true if enabled, false if disabled.
    toggleEnabled: =>
        if @_is_enabled
            @disable()
        else
            @enable()
        return @_is_enabled

    # Internal: Trap click events by stopping propagation.
    #
    # Returns nothing.
    _trapClick: (e) ->
        e.stopPropagation()
        return

    # Internal: Add classes to the el using info from the options. Primary
    #          classes are derived from the type, and get prefixed with the
    #          module name, while the secondary classes in the `extra_classes`
    #          option get added unmodified.
    #
    # Returns nothing.
    _setClasses: ->

        # Create the primary classes from the type
        class_list = []

        # Not all Doodads have a type.
        if @_config.type?.split?
            for c in @_config.type.split('+')
                class_list.push(c.split('-')...)
        if @_config.variant?.length > 0
            class_list.push(@_config.variant.split(' ')...)

        # Prefix the variants as Shiny variants.
        class_list = _.map class_list, (c) => "-#{ c }"

        if @_config?.classes
            if _.isArray(@_config?.classes)
                class_list.push(@_config.classes...)
            else
                class_list.push(@_config.classes)

        @$el.addClass(class_list.join(' '))


    # Internal: Set extra CSS rules (useful for z-index, etc)
    #
    # css - an object with key-value CSS properties to set using $().css()
    #
    # Returns nothing
    _setCSS: (css_rules) ->
        @$el.css(css_rules)

    # Public: Set the state of the component, using a data-attribute. State is
    #         stored in `data-`attributes as part of the Shiny Sass technique.
    #
    # state - (String) name of the state to set.
    # value - (Boolean|Number|String|ObjectArray:true) value to set the
    #           attribute MUST be JSON-serializable (and becomes a string in
    #           the actual DOM attribute).
    #
    # Example:
    #
    #     > doodad_instance.setState('active')
    #     > doodad_instance.getState('active')
    #     true
    #     > doodad_instance.$el.attr('data-active')
    #     "true"
    #
    #     > doodad_instance.setState('progress', 50)
    #     > doodad_instance.getState('progress')
    #     50
    #     > doodad_instance.$el.attr('data-progress')
    #     "50"
    #
    # Returns self for chaining.
    setState: (state, value=true) ->
        @$el.attr("data-#{ state }", value)
        return this

    # Public: Get the state of the component.
    #
    # state - (String) name of the state to get.
    #
    # Returns the state in its original type, using `JSON.parse`, or
    # `undefined` if not set.
    getState: (state) ->
        state_value = @$el.attr("data-#{ state }")
        if state_value
            state_value = JSON.parse(state_value)
        return state_value

    # Public: Unset the state of the component.
    #
    # state - (String) name of the state to unset
    #
    # Returns self for chaining
    unsetState: (state) ->
        @$el.removeAttr("data-#{ state }")
        return this



module.exports = BaseDoodad
