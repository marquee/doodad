
{ View } = Backbone



class BaseDoodad extends View
    @__doc__ = """
    Public: The base view for all Doodad components. Provides methods for
            getting the size & position, hiding & showing, and enabling &
            disabling. The enable and disable only set an attribute and don't
            actually handle any disabling.

    """

    initialize: (options) ->
        @_is_enabled = true

        # TODO: DRY up the child classes using something like:
        # @_options = @_validateOptions(options)
        # @_configure()
        # @_setClasses()

    # Public: Get the center position of the element.
    #
    # Returns an object with the x and y coordinates of the center, relative
    # to the document.
    getPosition: =>
        { top, left } = @$el.offset()
        width = @$el.width()
        height = @$el.height()
        x = left + width / 2
        y = top + height / 2
        return { x:x, y:y }

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
    # Returns self for chaining.
    hide: =>
        @$el.hide()
        return this

    # Public: Show the element.
    #
    # Returns self for chaining.
    show: =>
        @$el.show()
        return this

    # Public: Set the element state to disabled.
    #
    # Returns nothing.
    disable: =>
        @_is_enabled = false
        @$el.attr('disabled', true)

    # Public: Set the element state to enabled.
    #
    # Returns nothing.
    enable: =>
        @_is_enabled = true
        @$el.removeAttr('disabled')

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

    # Private: Trap click events by stopping propagation.
    #
    # Returns nothing.
    _trapClick: (e) ->
        e.stopPropagation()
        return

    # Private: Add classes to the el using info from the options. Primary
    #          classes are derived from the type, and get prefixed with the
    #          module name, while the secondary classes in the `extra_classes`
    #          option get added unmodified.
    #
    # Returns nothing.
    _setClasses: ->

        # Create the primary classes from the type
        class_list = @_options.type.split('+')
        if @_options.class?.length > 0
            class_list.push(@_options.class.split(' ')...)

        # Prefix the primary classes
        class_list = _.map class_list, (c) => "#{ @className }-#{ c }"

        if @_options?.extra_classes
            if _.isArray(@_options?.extra_classes)
                class_list.push(@_options.extra_classes...)
            else
                class_list.push(@_options.extra_classes)

        @$el.addClass(class_list.join(' '))

module.exports = BaseDoodad
