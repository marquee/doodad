BaseDoodad = require '../BaseDoodad'
 
# si = new StringField
#     placeholder: 'tags, comma-separated'
#     on_change: ->d
#     tokenize: ',' # or true for just enter/tab
# si.value
# > ['Some Value', 'other', 'values']
# si.raw_value
# > 'Some Value,other,values'


parseLimit = (limit) ->
    if limit[0] is '~'
        limit = parseInt(limit[1..])
        soft = true
    else
        limit = parseInt(limit)
        soft = false
    return [soft, limit]


class StringField extends BaseDoodad
    @__doc__ = """
    """
 
    tagName: 'DIV'
    className: 'StringField'
 
    initialize: (options={}) ->
        @_is_enabled = true
        if options.tokenize?
            console.warn "StringField `tokenize` option is deprecated. Use `type:'token'` and `delimiter:','` instead."
            if _.isString(options.tokenize)
                options.delimiter = options.tokenize
            options.type = 'token'
        if options.multiline?
            console.warn "StringField `multiline` option is deprecated. Used `type:'multiline'` instead."
            options.type = 'multiline'
        super(options)
        @_config = _.extend {},
            type            : 'singleline'
            delimiter       : null # instead of tokenize, then type: 'token', 'multiline'
            variant         : null
            helptext        : null
            enabled         : true
            unique          : false
            placeholder     : ''
            label           : ''
            classes         : []
            char_limit      : null
            word_limit      : null
            value           : ''
            on              : {}
        , options


        @raw_value = ''
        if @_config.type is 'token'
            @value = if @_config.value then @_config.value else []
            @raw_value = @value.join(@_config.delimiter)
            @_current_token = ''
        else
            @value = @_config.value

        if @_config.char_limit
            [@_config.limit_is_soft, @_config.char_limit] = parseLimit(@_config.char_limit)
        else if @_config.word_limit
            [@_config.limit_is_soft, @_config.word_limit] = parseLimit(@_config.word_limit)

        @on(event, handler) for event, handler of @_config.on

        @render()
 
 
    # Public: Add the label to the element.
    #
    # Returns nothing.
    render: ->
        @_setClasses()
        @_ui = {}
        if @_config.type is 'token'
            @$el.html """
                    <label class="StringFieldLabel"></label>
                    <div class="StringFieldTokenForm">
                        <input class="StringFieldInput" placeholder="#{ @_config.placeholder }">
                        <div class="StringFieldTokens"></div>
                    </div>
                """
            @_ui.tokens = @$el.find('.StringFieldTokens')
        else if @_config.type is 'multiline'
            @$el.html """
                    <label>
                        <span class="StringFieldLabel"></span>
                        <textarea class="StringFieldInput" placeholder="#{ @_config.placeholder }"></textarea>
                    </label>
                """
        else
            @$el.html """
                    <label>
                        <span class="StringFieldLabel"></span>
                        <input class="StringFieldInput" placeholder="#{ @_config.placeholder }">
                    </label>
                """
        @_ui.input = @$el.find('.StringFieldInput')
        @_ui.label = @$el.find('.StringFieldLabel')
        if @_config.placeholder
            @_ui.input.attr('placeholder', @_config.placeholder)
        if @_config.label
            @_ui.label.text(@_config.label)

        if @_config.type is 'token'
            @_renderTokens()
        else
            if @_config.char_limit or @_config.word_limit
                @_ui.limit_counter = $('<span class="StringFieldCounter"></span>')
                @_ui.label.append(@_ui.limit_counter)
                @_updateCharCount()
            @_ui.input.val(@value)
        @delegateEvents()
        unless @_config.enabled
            @disable()
        return @el
 
    # Public: Set the label of the StringField state
    #
    # value - (String) the value of the label
    #
    # Returns self for chaining.
    setLabel: (value) ->
        @_ui.label.text(value)
        return this

    # Public: Set the StringField state to disabled.
    #
    # Returns nothing.
    disable: ->
        @_ui.input.attr('disabled', true)
        return super()
        
 
    # Public: Set the StringField state to enabled.
    #
    # Returns nothing.
    enable: ->
        @_ui.input.removeAttr('disabled')
        super()

    _calcLimit: ->
        if @_config.char_limit
            limit = @_config.char_limit
            count = @value.length
        else 
            limit = @_config.word_limit
            count = @value.match(/[\d\w_-]+/g)?.length or 0
        @over_limit = count > limit
        return [@over_limit, count, limit]

    _updateCharCount: ->
        [over_limit, count, limit] = @_calcLimit()
        @_ui.limit_counter.text("#{ count }/#{ limit }")
        @unsetState('charcount--over').unsetState('charcount--close')
        if over_limit
            @setState('charcount--over')
        else if count > limit * 0.8
            @setState('charcount--close')

        return [over_limit, count, limit]


    _renderTokens: ->
        @_ui.tokens.empty()
        # TODO: Make each token a view, use Collection to manage?
        _.each @value, (token) =>
            $el = $ """
                    <span class='StringFieldToken'>
                        <span class="StringFieldTokenValue"></span>
                        <button class="StringFieldTokenRemove">x</button>
                    </span>
                """
            $el.find('.StringFieldTokenValue').text(token)
            $el.find('.StringFieldTokenRemove').on 'click', (e) =>
                e.stopPropagation()
                @_removeToken(token)
            @_ui.tokens.append($el)
 
    _updatePlaceholder: ->
        if @value.length > 0
            @_ui.input.attr('placeholder', '')
        else
            @_ui.input.attr('placeholder', @_config.placeholder)
 
    events:
        'keydown    .StringFieldInput'         : '_handleInput'
        'paste      .StringFieldInput'         : '_handleInput'
        'click      .StringFieldTokenForm'     : '_focusInput'
        'blur       .StringFieldInput'         : '_fireBlur'
        'focus      .StringFieldInput'         : '_fireFocus'

    _focusInput: ->
        if @_is_enabled
            @_ui.input.focus()

    _fireBlur: ->
        @unsetState('focus')
        @trigger('blur', this)

    _fireFocus: ->
        @setState('focus')
        @trigger('focus', this)
 
    _removeToken: (token) ->
        @value = _.without(@value, token)
        @_renderTokens()
        @raw_value = @value.join(@_config.delimiter)
        @trigger('change', this, @value, @raw_value)
 
    _processPaste: (e) ->
        _.defer =>
            incoming_value = @_ui.input.val()
            if @_config.type is 'token'?
                @_ui.input.val('')
                incoming_value = incoming_value.split(@_config.delimiter)
                incoming_value = _.map incoming_value, (x) -> x.trim()
                @value.push(incoming_value...)
                @_renderTokens()
            else
                @raw_value = @value = incoming_value
            @trigger('change', this, @value, @raw_value)
        return
 
    _handleInput: (e) ->
        was_token_trigger = e.which in [KEYCODES.ENTER, KEYCODES.TAB]
        if @_config.type is 'token'
            if was_token_trigger
                e.preventDefault()
            _.defer =>
                incoming_value = @_ui.input.val()
                if incoming_value.length > 0
                    was_token_delimiter = false
                    incoming_char = ''
                    if incoming_value[incoming_value.length-1] is @_config.delimiter
                        incoming_value = incoming_value.split('')
                        incoming_char = incoming_value.pop()
                        incoming_value = incoming_value.join('')
                        was_token_delimiter = true

                    if was_token_delimiter or was_token_trigger
                        incoming_value = incoming_value.trim()
                        @_ui.input.val('')
                        if incoming_value and not (@_config.unique and incoming_value in @value)
                            @raw_value += incoming_char
                            @value.push(incoming_value)
                            @_renderTokens()
                            @trigger('change', this, @value, @raw_value)
                else
                    if e.which is KEYCODES.DELETE
                        prev_token = @value.pop()
                        @_renderTokens()
                        @_ui.input.val(prev_token)
                        @raw_value = @value.join(@_config.delimiter)
                        @trigger('change', this, @value, @raw_value)
                @_updatePlaceholder()
        else
            previous_value = @value
            _.defer =>
                @raw_value = @value = @_ui.input.val()
                if @_config.char_limit or @_config.word_limit
                    [over_limit, count, limit] = @_calcLimit()
                    if over_limit and not @_config.limit_is_soft
                        @raw_value = @value = previous_value
                        @_ui.input.val(previous_value)
                    @_updateCharCount()
                @trigger('change', this, @value, @raw_value)

        # Command-/Control-X, which only takes effect after the keyup, so
        # reprocess the input.
        if e.which is 88 and e.metaKey
            _.defer => @_handleInput(e)
        return

    getValue: ->
        return @value

    showLabel: ->
        @ui.label.attr('data-visible', true)

    hideLabel: ->
        @ui.label.removeAttr('data-visible')

KEYCODES =
    DELETE  : 8
    TAB     : 9
    ENTER   : 13

module.exports = StringField