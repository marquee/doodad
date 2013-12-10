# bar = new ProgressBar()
# bar.setValue(0.24)

BaseDoodad = require '../BaseDoodad'

class ProgressBar extends BaseDoodad

    tagName: 'SPAN'
    className: 'ProgressBar'

    initialize: (options) ->
        @_config = _.extend {},
            type            : 'bar' # text, bar+text
            classes         : []
            initial_value   : 0
        , options
        @_is_bar_type = @_config.type.indexOf('bar') > -1
        @_is_text_type = @_config.type.indexOf('text') > -1
        super(@_config)
        @render()

    # Public: Render the progress bar element.
    #
    # Returns self for chaining.
    render: =>
        @_ui = {}
        @$el.empty()
        if @_is_bar_type
            @_ui.bar = $('<span class="ProgressBar_Bar"></span>')
            @$el.append(@_ui.bar)
        if @_is_text_type
            @_ui.text = $('<span class="ProgressBar_Text"></span>')
            @$el.append(@_ui.text)
        @_setClasses()
        @setValue(@_config.initial_value)

        if @_is_bar_type and @_is_text_type
            _.defer =>
                console.log @_ui.bar.height(), @_ui.text.height()
                @_ui.text.css
                    top: (@_ui.bar.height() - @_ui.text.height()) / 2
        return this

    # Public: Set the value of the progress bar.
    #
    # value - a Number from 0 to 1 (inclusive) that is a percentage of the
    #         progress to display.
    #
    # Returns self for chaining.
    setValue: (value) ->
        val = "#{ (value * 100).toFixed(0) }%"
        if @_is_bar_type
            @_ui.bar.css(width: val)
        if @_is_text_type
            @_ui.text.text(val)
        return this


module.exports = ProgressBar