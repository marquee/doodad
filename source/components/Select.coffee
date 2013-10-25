
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
#             class: 'align-left'
#         }
#         {
#             label: 'Set Align Right'
#             value: 'right'
#             class: 'align-right'
#         }
#     ]

class Select extends BaseDoodad


    @__doc__ = """
    """

    tagName: 'DIV'
    className: 'Select'

    initialize: (options) ->
        super(arguments...)
        @_options = _.extend {},
            type            : 'drop'
            width           : null
            height          : null
            label           : ''
            placeholder     : '- - -'
            variant         : null
            enabled         : true
            required        : false
            extra_classes   : []
        , options

        @render()

    # Private: Apply the necessary classes to the element.
    #
    # Returns nothing.
    _setClasses: ->
        class_list = @_options.type.split('+')
        if @_options.class?.length > 0
            class_list.push(@_options.class.split(' ')...)
        class_list = _.map class_list, (c) => "#{ @className }-#{ c }"
        class_list.push(@_options.extra_classes...)
        @$el.addClass(class_list.join(' '))

    # Public: Add the label to the element. If the Button is type 'icon', the
    #         label is set as the title.
    #
    # Returns nothing.
    render: ->
        @$el.empty()
        @_setClasses()
        @ui = {}

        switch @_options.type
            when 'drop'
                @_renderDrop()
            when 'grid'
                @_renderGrid()

        @delegateEvents()
        return @el

    events:
        'click .Select_value' : '_showChoices'
        'click .Select_label' : '_showChoices'

    _showChoices: ->
        # Keep it invisible until it is positioned.
        @ui.choices.css
            opacity: 0
            left: @ui.value.position().left
        @ui.choices.removeAttr('data-hidden')

        # Align the currently selected choice to the middle of the form.
        _.defer =>
            { top, left } = @_selected_choice_el.position()

            # TODO: Constrain within window

            @ui.choices.css
                top: -1 * top
                opacity: ''
            console.log top, left
            @ui.value.attr('data-hidden', true)


    _setChoice: (choice, opts={}) =>
        console.log 'setting choice', choice.value
        @ui.choices.find('[data-selected]').removeAttr('data-selected')
        if _.isFunction(choice.value)
            @value = choice.value(this)
        else
            @value = choice.value
        @_selected_choice_el = choice.$el
        @_selected_choice_el.attr('data-selected', true)
        @ui.value.text(choice.label)
        @ui.choices.attr('data-hidden', true)
        @ui.value.removeAttr('data-hidden')
        unless opts.silent
            @_options.action?(this, @value, choice.label)

    _renderGrid: ->
        @$el.html """
            <div class="Select_label">Category:</div>
            <div class="Select_choices">
                <div class="Select_choice">
                    <span class="Select_choice_label">Option 1
                </div>
                <div class="Select_choice" data-selected="true">Option 2</div>
                <div class="Select_choice">Option 3</div>
                <div class="Select_choice">Option 4</div>
                <div class="Select_choice">Option 5</div>
            </div>
        """

    _renderDrop: ->
        @ui.label = $("<div class='Select_label'>#{ @_options.label }</div>")
        @ui.value = $("<div class='Select_value'><div>")
        @ui.choices = $("<div class='Select_choices'></div>")

        has_default = false


        makeChoiceEl = (choice) =>
            choice.$el = $("""
                <div class='Select_choice#{ if choice.null_choice then '-null' else '' }'>
                    <span class='Select_choice_label'>
                        #{ choice.label }
                    </span>
                </div>
            """)
            choice.$el.attr('data-value', choice.value)
            choice.$el.on 'click', =>
                @_setChoice(choice)

        _.each @_options.choices, (choice) =>
            console.log choice
            makeChoiceEl(choice)
            if choice.default
                has_default = true
                @_setChoice(choice, silent: true)
            @ui.choices.append(choice.$el)

        # If it doesn't have a default set above, or is not required, add a
        # null choice to the list of choices that sets the value to null.
        unless has_default and @_options.required
            do =>
                null_choice =
                    null_choice: true
                    label: @_options.placeholder
                    value: null
                makeChoiceEl(null_choice)
                @ui.choices.prepend(null_choice.$el)
                # Set the choice if no default was set above.
                unless has_default
                    @_setChoice(null_choice, silent: true)

        @$el.append(@ui.label)
        @$el.append(@ui.value)
        @$el.append(@ui.choices)
    
    # setValue: (value, label=null) ->
    #     console.log 'Select.setValue', value, label

    getValue: ->
        return @value


module.exports = Select