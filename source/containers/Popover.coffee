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
#     contents: [
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
            contents : []
            width    : 500
            offset   : [0,0]
            close_on_outside: false
        , options

        if @_options.type is 'flag' and not @_options.origin?
            @_options.origin = 'top-left'

        @_setClasses()

        @_is_showing = false

    _setClasses: ->
        super()
        @$el.addClass("#{ @className }-#{ @_options.origin }")

    render: =>
        @$el.empty()
        @ui = {}
        @ui.contents = $('<div class="Popover_contents"></div>')
        @ui.contents.css(width: @_options.width)
        _.each @_options.contents, (item) =>
            @ui.contents.append(item.render())
        @$el.append(@ui.contents)
        return @el

    setPosition: (args...) ->
        if @_options.type is 'modal'
            @_setModalPosition(args...)
        else
            @_setFlagPosition(args...)

    _setModalPosition: ->
        console.log 'center it, yo'
        width = @ui.contents.width()
        height = @ui.contents.height()
        $w = $(window)
        w_delta = ($w.width() - width) / 2
        h_delta = ($w.height() - height) / 2
        console.log $w.width(), width, w_delta
        console.log $w.height(), height, h_delta
        padding = parseInt(@ui.contents.css('padding'))
        w_delta -= padding
        h_delta -= padding
        if w_delta < 50
            w_delta = 50
        if h_delta < 50
            bottom = top = 50
        else if h_delta > 100
            top = 100
            bottom = h_delta + (h_delta - 100)

        @ui.contents.css
            left    : w_delta
            right   : w_delta
            top     : top
            bottom  : bottom


    _setFlagPosition: ({x,y}) =>
        console.log x, y

        offset_x = 0
        offset_y = 0

        strToPos = (str) =>
            switch str
                when 'left'
                    offset_x = 0
                when 'right'
                    offset_x = @ui.contents.width()
                when 'top'
                    offset_y = 0
                when 'bottom'
                    offset_y = @ui.contents.height()

        [edge, position] = @_options.origin.split('-')

        strToPos(edge)
        strToPos(position)

        if edge is 'center'
            offset_y = @ui.contents.height() / 2
        if position is 'center'
            offset_x = @ui.contents.width() / 2

        console.log edge, position, offset_x, offset_y, @_options.offset

        # TODO: Allow @_options.offset to be a function, that's given the triggering element

        # TODO: Allow for growing from right based on origin: <div class="Popover-anchor">
        @$el.css
            left: x + @_options.offset[0]# - offset_x
            top: y + @_options.offset[1]# - offset_y
        @ui.contents.css
            left: 0 - offset_x
            top: 0 - offset_y

    show: (trigger=null) =>
        console.log 'showing popover'
        @_is_showing = true
        $('body').append(@render())
        if @_options.close_on_outside
            _.defer =>
                $(window).one('click', @hide)
        @ui.contents.css('opacity', 0)
        _.defer =>
            @setPosition(trigger?.getPosition())
            @ui.contents.css('opacity', 1)

    hide: =>
        console.log 'hiding popover'
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
