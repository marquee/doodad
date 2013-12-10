
BaseDoodad = require '../BaseDoodad'

# new Select
#     type: 'grid' # 'drop', 'grid'
#     # if 'grid'
#     width: 4 # autofills height
#     # or
#     # height: 2  # autofills width
#     required: true # if true, does not allow for deselection
#     action: (this_select) =>
#         @model.saveProperty('layout.align', this_select.value)
#     default: @model.getProperty('layout.align')
#     choices: [
#         {
#             label: 'Set Align Left'
#             value: 'left'
#             classes: 'align-left'
#         }
#         {
#             label: 'Set Align Right'
#             value: 'right'
#             classes: ['align-right']
#         }
#     ]

class Select extends BaseDoodad


    @__doc__ = """
    """

    tagName: 'DIV'
    className: 'Select'

    initialize: (options={}) ->
        if options.action?
            console.warn "Select `action` option is deprecated. Use `on: change: ->` event instead."
            options.on ?= {}
            options.on.change = options.action
        super(arguments...)

        @_loadConfig options,
            type            : 'drop'
            width           : null
            height          : null
            label           : ''
            choices         : null
            placeholder     : '- - -'
            variant         : null
            enabled         : true
            required        : false
            classes         : []

        @render()

    # Public: Add the label to the element. If the Button is type 'icon', the
    #         label is set as the title.
    #
    # Returns nothing.
    render: ->
        @$el.empty()
        @_setClasses()
        @ui = {}

        switch @_config.type
            when 'drop', 'drop-inline'
                @_renderDrop()
            when 'grid'
                @_renderGrid()

        @delegateEvents()
        return this

    events:
        'click .Select_Value' : '_showChoices'
        'click .Select_Label' : '_showChoices'

    _showChoices: ->
        # Keep it invisible until it is positioned.
        @ui.choices.css
            opacity : 0
            left    : @ui.value.position().left
            width   : @ui.value.width()
        @ui.choices.removeAttr('data-hidden')

        # Align the currently selected choice to the middle of the form.
        _.defer =>
            { top, left } = @_selected_choice_el.position()

            top -= @ui.value.position().top
            # TODO: Constrain within window

            @ui.choices.css
                top: -1 * top
                opacity: ''
            @ui.value.attr('data-hidden', true)


    _setChoice: (choice, opts={}) =>
        @ui.choices.find('[data-selected]').removeAttr('data-selected')
        if _.isFunction(choice.value)
            @value = choice.value(this)
        else
            @value = choice.value
        @_selected_choice_el = choice.$el
        @_selected_choice_el.attr('data-selected', true)
        @ui.value_label.text(choice.label)
        @ui.choices.attr('data-hidden', true)
        @ui.value.removeAttr('data-hidden')
        if choice.null_choice
            @ui.value.addClass('-null')
            @unsetState('has_value')
            @_has_value = false
        else
            @ui.value.removeClass('-null')
            @setState('has_value')
            @_has_value = true
        unless opts.silent
            @trigger('change', this, @value, choice.label)

    _renderGrid: ->
        @$el.html """
            <div class="Select_Label">Category:</div>
            <div class="Select_Choices">
                <div class="Select_Choice">
                    <span class="Select_ChoiceLabel">Option 1
                </div>
                <div class="Select_Choice" data-selected="true">Option 2</div>
                <div class="Select_Choice">Option 3</div>
                <div class="Select_Choice">Option 4</div>
                <div class="Select_Choice">Option 5</div>
            </div>
        """

    _makeChoiceEl: (choice) =>
        choice.$el = $("""
            <div class='Select_Choice #{ if choice.null_choice then '-null' else '' }'>
                <span class='Select_ChoiceLabel'>
                </span>
            </div>
        """)
        if choice.classes?
            if _.isArray(choice.classes)
                choice.$el.addClass(choice.classes.join(' '))
            else
                choice.$el.addClass(choice.classes)
        choice.$el.find('.Select_ChoiceLabel').text(choice.label)
        choice.$el.attr('data-value', choice.value)
        choice.$el.on 'click', =>
            @_setChoice(choice)


    _renderDrop: ->
        @ui.label = $("<div class='Select_Label'>#{ @_config.label }</div>")
        @ui.value = $("<div class='Select_Value'><div>")
        @ui.value_label = $("<div class='Select_ValueLabel'><div>")
        @ui.value_icon = $("<div class='Select_ValueIcon'><div>")
        @ui.value.append(@ui.value_label, @ui.value_icon)
        @ui.choices = $("<div class='Select_Choices'></div>")

        has_default = false

        _.each @_config.choices, (choice) =>
            @_makeChoiceEl(choice)
            if choice.default
                has_default = true
                @_setChoice(choice, silent: true)
            @ui.choices.append(choice.$el)

        # If it doesn't have a default set above, or is not required, add a
        # null choice to the list of choices that sets the value to null.
        unless has_default and @_config.required
            do =>
                null_choice =
                    null_choice: true
                    label: @_config.placeholder
                    value: null
                @_makeChoiceEl(null_choice)
                @ui.choices.prepend(null_choice.$el)
                # Set the choice if no default was set above.
                unless has_default
                    @_setChoice(null_choice, silent: true)

        @$el.append(@ui.label, @ui.value, @ui.choices)
    
    setValue: (value, label=null) ->
        target_choice = _.find @_config.choices, (choice) -> choice.value is value
        console.log 'Select.setValue', value, label
        if not target_choice and label
            target_choice = 
                value: value
                label: label
            @_config.choices.push(target_choice)
            @_makeChoiceEl(target_choice)
            @ui.choices.append(target_choice.$el)
        @_setChoice(target_choice)
        return this

    getValue: ->
        return @value

    hasValue: ->
        return @_has_value


module.exports = Select