{ View } = Backbone

# si = new StringInput
#     placeholder: 'tags, comma-separated'
#     on_change: ->d
#     tokenize: ','
# si.value
# > ['Some Value', 'other', 'values']
# si.raw_value
# > 'Some Value,other,values'


class StringInput extends View
    @__doc__ = """
    """

    tagName: 'DIV'
    className: 'StringInput'

    initialize: (options) ->
        @_is_enabled = true
        @_options = _.extend {},
            tokenize        : null # true - tokenize on ,
            class           : null
            helptext        : null
            enabled         : true
            multiline       : false
            token_set       : false
            placeholder     : ''
            extra_classes   : []
        , options


        @_validateOptions()

        @raw_value = ''
        if @_options.tokenize
            @value = []
            @_current_token = ''
        else
            @value = ''

        unless @_options.enabled
            @disable()
        @render()

    # Private: Check that the required options were passed to the constructor.
    #          Throws Errors if the options are invalid or missing.
    #
    # Returns nothing.
    _validateOptions: ->
        # if not @_options.type in ['text', 'icon', 'icon+text']
        #     throw new Error "Button type must be one of 'text', 'icon', 'icon+text', got #{ @_options.type }."
        # if @_options.type is 'text' and not @_options.label
        #     throw new Error "Buttons of type='text' MUST have a label set."
        # if not @_options.action? and not @_options.url?
        #     throw new Error "A Button action function or url must be specified."

    # Private: Apply the necessary classes to the element.
    #
    # Returns nothing.
    _setClasses: ->
        class_list = []
        # class_list = _.map class_list, (c) => "#{ @className }-#{ c }"
        class_list.push(@_options.extra_classes...)
        @$el.addClass(class_list.join(' '))

    # Public: Add the label to the element.
    #
    # Returns nothing.
    render: ->
        @_setClasses()
        @_ui = {}
        if @_options.tokenize
            @$el.html """
                    <div class="StringInput-tokens"></div>
                    <input class="StringInput-input">
                """
            @_ui.tokens = @$el.find('.StringInput-tokens')
        else
            @$el.html('<input class="StringInput-input">')
        @_ui.input = @$el.find('.StringInput-input')
        @delegateEvents()
        return @el

    # Public: Set the StringInput state to disabled.
    #
    # Returns nothing.
    disable: ->
        @_is_enabled = false
        @$el.attr('disabled', true)

    # Public: Set the StringInput state to enabled.
    #
    # Returns nothing.
    enable: ->
        @_is_enabled = true
        @$el.removeAttr('disabled')

    # Public: Check the enabled status.
    # 
    # Returns true if enabled, false if disabled.
    isEnabled: -> @_is_enabled

    # Public: Toggle the enabled/disabled state.
    #
    # Returns true if enabled, false if disabled.
    toggleEnabled: ->
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

    # TODO: Make a BaseUIView that has things like position, validateOptions
    getPosition: ->
        { top, left } = @$el.offset()
        width = @$el.width()
        height = @$el.height()
        x = left + width / 2
        y = top + height / 2
        return { x:x, y:y }

    _renderTokens: ->
        # TODO: Make each token a view, use Collection to manage?
        token_html = _.map @value, (token) ->
            return "<span class='StringInput-token'>#{ token }</span>"
        @_ui.tokens.html(token_html.join(''))

    events:
        'keydown .StringInput-input': '_handleInput'



    _handleInput: (e) =>
        _.defer =>
            incoming_value = @_ui.input.val()
            if @_options.tokenize?
                if incoming_value.length > 0
                    incoming_value = incoming_value.split('')
                    incoming_char = incoming_value.pop()
                    if incoming_char is @_options.tokenize
                        incoming_value = incoming_value.join('')
                        @_ui.input.val('')
                        if incoming_value
                            @raw_value += incoming_char
                            @value.push(incoming_value)
                            @_renderTokens()
                            @_options.action(this, @value, @raw_value)
                else
                    if e.which is 8 # delete
                        prev_token = @value.pop()
                        @_renderTokens()
                        @_ui.input.val(prev_token)
                        @raw_value = @value.join(@_options.tokenize)
                        @_options.action(this, @value, @raw_value)
            else
                @raw_value = @value = incoming_value
                @_options.action(this, @value, @raw_value)
        return


module.exports = StringInput