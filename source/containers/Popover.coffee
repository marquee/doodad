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
Button = require '../components/Button'

# Track all the popovers active, so soloing is possible. The popovers are
# tracked by their cid ()
active_popovers = {}


class Popover extends BaseDoodad
    className: 'Popover'
    initialize: (options={}) ->

        if options.content? and not _.isArray(options.content)
            options.content = [options.content]

        @_loadConfig options,
            type                : 'flag' # or 'modal
            content             : []
            width               : 'auto'
            offset              : [0,0]
            close_on_outside    : false
            close_on_confirm    : true
            title               : null
            visible             : false
            dismiss             : null
            confirm             : null
            solo                : true
            on                  : {}

        super(@_config)

        if @_config.type.indexOf('flag') isnt -1
            if not @_config.origin?
                @_config.origin = 'top-left'

        @_setClasses()

        @_is_showing = false

    _setClasses: ->
        super()
        if @_config.type.indexOf('flag') isnt -1
            origin = @_config.origin.split('-').join('_')
            @$el.addClass("-origin--#{ origin }")

    render: =>
        @$el.empty()
        @ui = {}
        @ui.content = $('<div class="Popover_Content"></div>')
        @ui.body    = $('<div class="Popover_Body"></div>')
        @ui.content.append(@ui.body)
        @ui.content.css(width: @_config.width)
        if @_config.title
            $title = $("""<div class="Popover_Title"></div>""")
            $title.text(@_config.title)
            @ui.content.prepend($title)
        _.each @_config.content, (item) =>
            @ui.body.append(item.render().el)
        if @_config.dismiss or @_config.confirm
            @ui.controls = $('<div class="Popover_Controls"></div>')
            if @_config.dismiss
                if @_config.dismiss.on?
                    @_config.dismiss.on 'click', =>
                        @trigger('dismiss', this)
                        @hide()
                else
                    @_config.dismiss = new Button
                        label: @_config.dismiss
                        on: click: =>
                            @trigger('dismiss', this)
                            @hide()
                @_config.dismiss.$el.addClass('Popover_Control -dismiss')
                @ui.controls.append(@_config.dismiss.render().el)

            if @_config.confirm
                if @_config.confirm.on?
                    @_config.confirm.on 'click', =>
                        @trigger('confirm', this)
                        @hide() if @_config.close_on_confirm
                else
                    @_config.confirm = new Button
                        label: @_config.confirm
                        on: click: =>
                            @trigger('confirm', this)
                            @hide() if @_config.close_on_confirm
                        variant: 'friendly'
                @_config.confirm.$el.addClass('Popover_Control -confirm')
                @ui.controls.append(@_config.confirm.render())

            @ui.content.append(@ui.controls)
        @$el.append(@ui.content)
        return this

    # Public:   Set the position of the popover depending on its type.
    #
    # Returns nothing.
    setPosition: (args...) ->
        if @_config.type is 'modal'
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

        [edge, position] = @_config.origin.split('-')

        strToPos(edge)
        strToPos(position)

        if edge is 'center'
            offset_y = @ui.content.height() / 2
        if position is 'center'
            if edge in ['top', 'bottom']
                offset_x = @ui.content.width() / 2
            else
                offset_y = @ui.content.height() / 2

        # TODO: Allow @_config.offset to be a function, that's given the triggering element
        @$el.css
            left: x + @_config.offset[0]# - offset_x
            top: y + @_config.offset[1]# - offset_y
        @ui.content.css
            left: 0 - offset_x
            top: 0 - offset_y

    show: (trigger=null) =>
        @_is_showing = true
        if @_config.close_on_outside
            _.defer =>
                $(window).one('click', @hide)
        if @_config.solo
            _.each active_popovers, (popover) =>
                if popover?
                    popover.hide()
        active_popovers[@cid] = this
        $('body').append(@render())
        @ui.content.css('opacity', 0)
        _.defer =>
            if @_config.type.indexOf('fixed') is -1
                @setPosition(trigger?.getPosition())
            else
                @setPosition(trigger?.getScreenPosition())
            @ui.content.css('opacity', 1)

    hide: =>
        @_is_showing = false
        active_popovers[@cid] = null
        @$el.detach()

    toggle: (trigger) =>
        if @_is_showing
            @hide()
        else
            @show(trigger)
        return @_is_showing

    _checkHide: (e) =>
        if e.target is @el
            @hide()
        else
            if @_config.close_on_outside
                e.stopPropagation()
        return

    events:
        'click'     : '_checkHide'




module.exports = Popover
