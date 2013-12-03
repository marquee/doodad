{ View } = Backbone



# app_bar = new AppBar
#     head: [
#             user_menu_trigger
#         ]
#     tail: [
#             layout_trigger
#             new_post_button
#         ]

#     # (defaults)
#     position: 'top'
#     attach_to: 'body'
#     pinned: true
#     inject_padding: true
#     responsive: true

class AppBar extends View
    @__doc__ = ''
    @_name = 'AppBar'
    initialize: (options={}) ->
        console.log 'AppBar.initialize'
        @_loadConfig options,
            head            : []
            tail            : []
            responsive      : true
            pinned          : true
            position        : 'top'
            attach_to       : 'body'
            inject_padding  : true

        @_validateOptions()
        @_setClasses()
        if @_config.attach_to
            @attachTo($(@_config.attach_to))

    _validateOptions: ->
        if not @_config.position in ['top', 'bottom', 'left', 'right']
            throw new Error "AppBar position must be one of 'top', 'bottom', 'left', 'right'. Got: #{ @_config.position }"

    _setClasses: ->
        @$el.addClass(@constructor._name)
        @$el.addClass("AppBar-#{ @_config.position }")
        if @_config.responsive
            @$el.addClass('AppBar-responsive')

    attachTo: ($target_el) =>
        @$el.detach()
        $target_el.append(@render())
        _.defer =>
            if @_config.position in ['left', 'right']
                head_width = @$el.find('.AppBar_head').width()
                tail_width = @$el.find('.AppBar_tail').width()
                if head_width < tail_width
                    head_width = tail_width
                @$el.css(width: head_width)

            if @_config.inject_padding
                css_to_set =
                    'padding-top'       : 0
                    'padding-bottom'    : 0
                    'padding-left'      : 0
                    'padding-right'     : 0
                switch @_config.position
                    when 'top'
                        css_to_set['padding-top'] = @$el.height()
                    when 'bottom'
                        css_to_set['padding-bottom'] = @$el.height()
                    when 'left'
                        css_to_set['padding-left'] = @$el.width()
                    when 'right'
                        css_to_set['padding-right'] = @$el.width()
                $target_el.css(css_to_set)

    render: =>
        @$el.html """
            <div class='AppBar_head'></div>
            <div class='AppBar_tail'></div>
        """
        $head = @$el.find('.AppBar_head')
        _.each @_config.head, (element) ->
            $head.append(element.render())

        $tail = @$el.find('.AppBar_tail')
        _.each @_config.tail, (element) ->
            $tail.append(element.render())

        return @el

    addToHead: (item) =>
        @_config.head.push(item)
        @render()
    addToTail: (item) =>
        @_config.tail.push(item)
        @render()

module.exports = AppBar
