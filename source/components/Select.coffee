
new Select
    type: 'grid' # 'drop', 'grid'
    # if 'grid'
    width: 4 # autofills height
    # or
    # height: 2  # autofills width
    required: true # if true, does not allow for deselection
    action: (this_select) =>
        @model.saveProperty('layout.align', this_select.value)
    default: @model.getProperty('layout.align')
    options: [
        {
            label: 'Set Align Left'
            value: 'left'
            class: 'align-left'
        }
        {
            label: 'Set Align Right'
            value: 'right'
            class: 'align-right'
        }
    ]

class Select

module.exports = Select