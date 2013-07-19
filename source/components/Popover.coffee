# Popover.coffee
# Popover.sass
# - simple enough that they only need those two files

# button1 = new Button
#     action: -> console.log 'click'
#     label: 'Item 1'

# popover = new Popover
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



{ View } = Backbone

class Popover extends View
    className: 'Popover'
    initialize: (options) ->
        @_options = _.extend {},
            origin   : ''
            contents : []
            offset   : [0,0]
            close_on_outside: false
        , options

        @_setClasses()

        @_is_showing = false

    _setClasses: ->
        @$el.addClass("#{ @className }-#{ @_options.origin }")

    render: =>
        @$el.html """
            <div class="Popover-contents"></div>
        """
        $contents = @$el.find('.Popover-contents')
        _.each @_options.contents, (item) ->
            $contents.append(item.render())
        return @el

    setPosition: ({x,y}) =>
        console.log x, y

        offset_x = 0
        offset_y = 0

        strToPos = (str) =>
            switch str
                when 'left'
                    offset_x = 0
                when 'right'
                    offset_x = @$el.width()
                when 'top'
                    offset_y = 0
                when 'bottom'
                    offset_y = @$el.height()

        [edge, position] = @_options.origin.split('-')

        strToPos(edge)
        strToPos(position)

        if edge is 'center'
            offset_y = @$el.height() / 2
        if position is 'center'
            offset_x = @$el.width() / 2

        console.log edge, position, offset_x, offset_y, @_options.offset

        # TODO: Allow @_options.offset to be a function, that's given the triggering element

        @$el.css
            left: x - offset_x + @_options.offset[0]
            top: y - offset_y + @_options.offset[1]

    show: =>
        console.log 'showing popover'
        @_is_showing = true
        $('body').append(@render())
        if @_options.close_on_outside
            _.defer =>
                $(window).one('click', @hide)

    hide: =>
        console.log 'hiding popover'
        @_is_showing = false
        @$el.detach()

    toggle: (trigger) =>
        if @_is_showing
            @hide()
        else
            _.defer =>
                @setPosition(trigger.getPosition())
            @show()
        return @_is_showing

    events:
        'click': '_trapClick'

    _trapClick: (e) ->
        e.stopPropagation()


module.exports = Popover
