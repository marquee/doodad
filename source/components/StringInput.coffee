{ View } = Backbone
 
# si = new StringInput
#     placeholder: 'tags, comma-separated'
#     on_change: ->d
#     tokenize: ',' # or true for just enter/tab
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
            unique          : false
            placeholder     : ''
            label           : ''
            extra_classes   : []
            value           : ''
            on              : {}
        , options
 
 
        @_validateOptions()
 
        @raw_value = ''
        if @_options.tokenize
            @value = if @_options.value then @_options.value else []
            @raw_value = @value.join(@_options.tokenize)
            @_current_token = ''
        else
            @value = @_options.value
 
        unless @_options.enabled
            @disable()

        @on(event, handler) for event, handler of @_options.on

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
        if @_options.tokenize?
            class_list.push('StringInput_tokenize')
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
                    <label class="StringInput_label">
                        #{ @_options.label }
                    </label>
                    <div class="StringInput_token_form">
                        <div class="StringInput_tokens"></div>
                        <input class="StringInput_input" placeholder="#{ @_options.placeholder }">
                    </div>
                """
            @_ui.tokens = @$el.find('.StringInput_tokens')
        else if @_options.multiline
            @$el.html """
                    <label class="StringInput_label">
                        #{ @_options.label }
                        <textarea class="StringInput_input" placeholder="#{ @_options.placeholder }"></textarea>
                    </label>
                """
        else
            @$el.html """
                    <label class="StringInput_label">
                        #{ @_options.label }
                        <input class="StringInput_input" placeholder="#{ @_options.placeholder }">
                    </label>
                """
        @_ui.input = @$el.find('.StringInput_input')
         
        if @_options.tokenize
            @_renderTokens()
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
        @_ui.tokens.empty()
        # TODO: Make each token a view, use Collection to manage?
        _.each @value, (token) =>
            $el = $ """
                    <span class='StringInput_token'>
                        <span class="StringInput_token_value"></span>
                        <button class="StringInput_token_remove">x</button>
                    </span>
                """
            $el.find('.StringInput_token_value').text(token)
            $el.find('.StringInput_token_remove').on 'click', =>
                @_removeToken(token)
            @_ui.tokens.append($el)
 
    _updatePlaceholder: ->
        console.log '_updatePlaceholder', @value.length
        if @value.length > 0
            @_ui.input.attr('placeholder','')
        else
            @_ui.input.attr('placeholder',@_options.placeholder)
 
    events:
        'keydown    .StringInput_input' : '_handleInput'
        'paste      .StringInput_input' : '_processPaste'
        'click      .StringInput_token_form': '_focusInput'
        'blur       .StringInput_input' : '_fireBlur'
        'focus      .StringInput_input'         : '_fireFocus'

    _focusInput: ->
        @_ui.input.focus()

    _fireBlur: ->
        @trigger('blur', this)

    _fireFocus: ->
        @trigger('focus', this)
 
    _removeToken: (token) ->
        @value = _.without(@value, token)
        @_renderTokens()
        @raw_value = @value.join(@_options.tokenize)
        @_options.action(this, @value, @raw_value)
 
    _processPaste: (e) ->
        _.defer =>
            if @_options.tokenize?
                incoming_value = @_ui.input.val()
                @_ui.input.val('')
                incoming_value = incoming_value.split(@_options.tokenize)
                incoming_value = _.map incoming_value, (x) -> x.trim()
                @value.push(incoming_value...)
                @_renderTokens()
            @_options.action(this, @value, @raw_value)
        return
 
    _handleInput: (e) ->
        was_token_trigger = e.which in [KEYCODES.ENTER, KEYCODES.TAB]
        if @_options.tokenize
            if was_token_trigger
                e.preventDefault()
            _.defer =>
                incoming_value = @_ui.input.val()
                if incoming_value.length > 0
                    was_token_delimiter = false
                    incoming_char = ''
                    if incoming_value[incoming_value.length-1] is @_options.tokenize
                        incoming_value = incoming_value.split('')
                        incoming_char = incoming_value.pop()
                        incoming_value = incoming_value.join('')
                        was_token_delimiter = true
                    console.log was_token_delimiter, incoming_value
                    if was_token_delimiter or was_token_trigger
                        incoming_value = incoming_value.trim()
                        @_ui.input.val('')
                        if incoming_value and not (@_options.unique and incoming_value in @value)
                            @raw_value += incoming_char
                            @value.push(incoming_value)
                            @_renderTokens()
                            @_options.action(this, @value, @raw_value)
                else
                    if e.which is KEYCODES.DELETE
                        prev_token = @value.pop()
                        @_renderTokens()
                        @_ui.input.val(prev_token)
                        @raw_value = @value.join(@_options.tokenize)
                        @_options.action(this, @value, @raw_value)
                @_updatePlaceholder()
        else
            _.defer =>
                @raw_value = @value = @_ui.input.val()
                @_options.action(this, @value, @raw_value)
        return

KEYCODES =
    DELETE  : 8
    TAB     : 9
    ENTER   : 13

module.exports = StringInput