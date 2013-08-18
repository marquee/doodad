
BaseDoodad = require './BaseDoodad'

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
#     options: [
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
    A basic button class. See #{ DOC_URL }button/
    """

    tagName: 'DIV'
    className: 'Select'

    initialize: (options) ->
        super()
        @_options = _.extend {},
            type            : 'drop'
            width           : null
            height          : null
            label           : null
            variant         : null
            enabled         : true
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

        switch @_options.type
            when 'drop'
                @_renderDrop()
            when 'grid'
                @_renderGrid()

        @delegateEvents()
        return @el

    _renderGrid: ->

    _renderDrop: ->
        @$el.html """
            <div class="Select_label">Category:</div>
            <div class="Select_current_value">Selected</div>
            <div class="Select_options">
                <div class="Select_option">Option 1</div>
                <div class="Select_option">Option 2</div>
                <div class="Select_option">Option 3</div>
                <div class="Select_option">Option 4</div>
                <div class="Select_option">Option 5</div>
            </div>
        """
    



module.exports = Select