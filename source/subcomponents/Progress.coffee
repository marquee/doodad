BaseDoodad = require '../BaseDoodad'

###

progress_bar = new ProgressIndicator()

progress_bar.start()

progress_bar.setValue()
progress_bar.getValue()
progress_bar.reset()
progress_bar.bindTo(element_that_emits_progress_event)

###

# Progress bar or spinner
class Progress extends BaseDoodad
    className: 'Progress'
    initialize: (options) ->
        @_options = _.extend {},
            variant         : 'dark'
            extra_classes   : []
        , options
        @_value = 0
        @$el.addClass("#{ @className }-#{ @_options.variant }")
        super(arguments...)

    render: =>
        @ui =
            bar: $('<div class="Progress_bar"></div>')
        @$el.empty().append(@ui.bar)
        _.defer(@setValue(@_value))
        return @el

    setValue: (value) ->
        if value < 0
            value = 0
        else if value > 1
            value = 1
        @ui.bar.css
            width: "#{ value * 100 }%"
        @_value = value
        return this

    getValue: -> @_value

    reset: -> @setValue(0)

module.exports = Progress