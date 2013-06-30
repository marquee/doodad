{ View } = Backbone



# app_bar = new AppBar
#     head: [
#             user_menu_trigger
#         ]
#     tail: [
#             layout_trigger
#             new_post_button
#         ]
#     position: 'top' # 'bottom', 'left', 'right'
#     auto_attach: true # false to 



class AppBar extends View
    className: 'AppBar'
    initialize: (options) ->
        @_options = _.extend {},
            head: []
            tail: []
            position: 'top'
            attach_to: 'body'
        , options

        @_validateOptions()
        @_setClasses()
        if @_options.attach_to
            @attachTo($(@_options.attach_to))

    _validateOptions: ->
        if not @_options.position in ['top', 'bottom', 'left', 'right']
            throw new Error "AppBar position must be one of 'top', 'bottom', 'left', 'right'. Got: #{ @_options.position }"

    _setClasses: ->
        @$el.addClass("#{ @className }-#{ @_options.position }")

    attachTo: ($target_el) =>
        @$el.detach()
        $target_el.append(@render())
        setTimeout =>
            if @_options.position in ['left', 'right']
                head_width = @$el.find('.AppBar-head').width()
                tail_width = @$el.find('.AppBar-tail').width()
                if head_width < tail_width
                    head_width = tail_width
                @$el.css(width: head_width)
            css_to_set =
                'padding-top': 0
                'padding-bottom': 0
                'padding-left': 0
                'padding-right': 0
            switch @_options.position
                when 'top'
                    css_to_set['padding-top'] = @$el.height()
                when 'bottom'
                    css_to_set['padding-bottom'] = @$el.height()
                when 'left'
                    css_to_set['padding-left'] = @$el.width()
                when 'right'
                    css_to_set['padding-right'] = @$el.width()
            $target_el.css(css_to_set)

    render: ->
        @$el.html """
            <div class='AppBar-head'></div>
            <div class='AppBar-tail'></div>
        """
        $head = @$el.find('.AppBar-head')
        _.each @_options.head, (element) ->
            $head.append(element.render())

        $tail = @$el.find('.AppBar-tail')
        _.each @_options.tail, (element) ->
            $tail.append(element.render())

        return @el



window.UI ?= {}
window.UI.AppBar = AppBar