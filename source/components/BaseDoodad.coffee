
{ View } = Backbone



class BaseDoodad extends View
    @__doc__ = """
    Public: The base view for all Doodad components. Provides methods for
            getting the size & position, hiding & showing, and enabling &
            disabling. The enable and disable only set an attribute and don't
            actually handle any disabling.

    """

    initialize: ->
        @_is_enabled = true

    # Public: Get the center position of the element.
    #
    # Returns an object with the x and y coordinates of the center, relative
    # to the document.
    getPosition: ->
        { top, left } = @$el.offset()
        width = @$el.width()
        height = @$el.height()
        x = left + width / 2
        y = top + height / 2
        return { x:x, y:y }

    # Public: Get the dimensions of the entire element.
    #
    # Returns an object with the width and height in pixels.
    getSize: ->
        return {
            width   : @$el.width()
            height  : @$el.height()
        }

    # Public: Hide the element, using `display: none`.
    #
    # Returns self for chaining.
    hide: ->
        @$el.hide()
        return this

    # Public: Show the element.
    #
    # Returns self for chaining.
    show: ->
        @$el.show()
        return this

    # Public: Set the element state to disabled.
    #
    # Returns nothing.
    disable: ->
        @_is_enabled = false
        @$el.attr('disabled', true)

    # Public: Set the element state to enabled.
    #
    # Returns nothing.
    enable: ->
        @_is_enabled = true
        @$el.removeAttr('disabled')

    # Public: Check the enabled status.
    # 
    # Returns true if enabled, false if disabled.
    isEnabled: -> @_is_enabled



module.exports = BaseDoodad
