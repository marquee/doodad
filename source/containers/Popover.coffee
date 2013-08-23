# Popover.coffee
# Popover.sass
# - simple enough that they only need those two files

# button1 = new Button
#     action: -> console.log 'click'
#     label: 'Item 1'

# popover = new Popover
#     type: 'flag'
#     origin: 'top-left' # <edge>-<position>
#                        #
#                        #          top-left       top-center       top-right
#                        # left-top                                          right-top
#
#
#                        # left-center             center-center             right-center
#
#
#                        # left-bottom                                       right-bottom
#                        #        bottom-left       bottom-center      bottom-right
#
#     content: [
#         button1
#     ]

# new_post_button = new Button
#     action: ->
#         popover.setPosition(new_post_button.getPosition())
#         popover.toggle()
#     label: 'Change Layout'



BaseDoodad = require '../BaseDoodad'

class Popover extends BaseDoodad
    className: 'Popover'
    initialize: (options) ->
        super(arguments...)
        @_options = _.extend {},
            type     : 'flag' # or 'modal
            content  : []
            width    : 500
            offset   : [0,0]
            close_on_outside: false
            title    : null
            dismiss  : null
            confirm  : null
            on       : {}
        , options

        if @_options.type is 'flag' and not @_options.origin?
            @_options.origin = 'top-left'

        @_setClasses()

        @_is_showing = false

    _setClasses: ->
        super()
        if @_options.type is 'flag'
            @$el.addClass("#{ @className }-#{ @_options.origin }")

    render: =>
        @$el.empty()
        @ui = {}
        @ui.content = $('<div class="Popover_content"></div>')
        @ui.content.css(width: @_options.width)
        _.each @_options.content, (item) =>
            @ui.content.append(item.render())
        @$el.append(@ui.content)
        return @el

    # Public:   Set the position of the popover depending on its type.
    #
    # Returns nothing.
    setPosition: (args...) ->
        if @_options.type is 'modal'
            @_setModalPosition(args...)
        else
            @_setFlagPosition(args...)

    # Private:  Center the popover in the window, keeping it a nice distance
    #           from the edges. It positions itself toward the top, which
    #           looks nicer, and keeps itself within the window.
    #
    # Returns nothing.
    _setModalPosition: ->
        width   = @ui.content.width()
        height  = @ui.content.height()
        $w = $(window)
        w_delta = ($w.width() - width) / 2
        h_delta = ($w.height() - height) / 2

        # Grab the padding of the content to factor into calculations.
        padding = parseInt(@ui.content.css('padding'))
        w_delta -= padding
        h_delta -= padding

        if w_delta < 50
            w_delta = 50

        bottom = ''
        if h_delta < 50
            bottom = top = 50
        else if h_delta > 100
            top = 100

        @ui.content.css
            left    : w_delta
            right   : w_delta
            top     : top
            bottom  : bottom

    # Private:  Position the popover at the specified position, orienting
    #           based on its origin setting.
    #
    # Returns nothing.
    _setFlagPosition: ({x,y}) =>

        offset_x = 0
        offset_y = 0

        strToPos = (str) =>
            switch str
                when 'left'
                    offset_x = 0
                when 'right'
                    offset_x = @ui.content.width()
                when 'top'
                    offset_y = 0
                when 'bottom'
                    offset_y = @ui.content.height()

        [edge, position] = @_options.origin.split('-')

        strToPos(edge)
        strToPos(position)

        if edge is 'center'
            offset_y = @ui.content.height() / 2
        if position is 'center'
            if edge in ['top', 'bottom']
                offset_x = @ui.content.width() / 2
            else
                offset_y = @ui.content.height() / 2


        console.log edge, position, offset_x, offset_y, @_options.offset

        # TODO: Allow @_options.offset to be a function, that's given the triggering element
        @$el.css
            left: x + @_options.offset[0]# - offset_x
            top: y + @_options.offset[1]# - offset_y
        @ui.content.css
            left: 0 - offset_x
            top: 0 - offset_y

    show: (trigger=null) =>
        @_is_showing = true
        $('body').append(@render())
        if @_options.close_on_outside
            _.defer =>
                $(window).one('click', @hide)
        @ui.content.css('opacity', 0)
        _.defer =>
            @setPosition(trigger?.getPosition())
            @ui.content.css('opacity', 1)

    hide: =>
        @_is_showing = false
        @$el.detach()

    toggle: (trigger) =>
        if @_is_showing
            @hide()
        else
            @show(trigger)
        return @_is_showing

    events:
        'click *'   : '_trapClick'
        'click'     : 'hide'

    setContents: (els...) ->

    addContent: (els...) ->


module.exports = Popover
