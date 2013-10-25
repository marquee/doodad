###

form 'form_name', model: @model,
    stringinput 'property'
    stringinput 'other_property', type: 'multiline'
    select 'prop', [
            {name: 'Value', value: 'value'}
            {name: 'Value 2', value: 'value2'}
            {name: 'Value 3', value: 'value3'}
        ]
    stringinput 'some_property'

dform 'form_name', model: @model,
    dstringinput 'property'
    dstringinput 'other_property', type: 'multiline'
    dselect 'prop', [
            {name: 'Value', value: 'value'}
            {name: 'Value 2', value: 'value2'}
            {name: 'Value 3', value: 'value3'}
        ]
    dstringinput 'some_property'

dForm 'form_name', model: @model,
    dStringInput 'property'
    dStringInput 'other_property', type: 'multiline'
    dSelect 'prop', [
            {name: 'Value', value: 'value'}
            {name: 'Value 2', value: 'value2'}
            {name: 'Value 3', value: 'value3'}
        ]
    dStringInput 'some_property'

# Equivalent to:

new Form
    name: 'form_name'
    model: @model
    content: [
        new StringInput
            name: 'property'
        new StringInput
            name: 'other_property'
            type: 'multiline'
        new Select
            name: 'prop'
            choices: [
                {name: 'Value', value: 'value'}
                {name: 'Value 2', value: 'value2'}
                {name: 'Value 3', value: 'value3'}
            ]
        new StringInput
            name: 'some_property'
    ]

###




BaseDoodad = require '../BaseDoodad'
Button = require '../components/Button'

# Track all the popovers active, so soloing is possible. The popovers are
# tracked by their cid ()
active_popovers = {}


class Form extends BaseDoodad
    className: 'Form'
    initialize: (options) ->
        super(arguments...)
        @_options = _.extend {},
            content             : []
            layout              : null
            on                  : {}
        , options

        @on(event, handler) for event, handler of @_options.on

        @_setClasses()
        @_is_showing = false

        @_captureFields()

    render: =>
        @$el.empty()
        @ui = {}
        @ui.content = $('<div class="Form_content"></div>')
        _.each @_options.content, (item, i) =>
            console.log item, i
            @ui.content.append(item.el)
        @$el.append(@ui.content)
        return @el

    _captureFields: ->
        console.log 'Form::_captureFields'
        @fields = {}
        console.log @_options.content
        _.each @_options.content, (field, i) =>
            console.log field.name, field
            field_name = if field.name then field.name else "field_#{ i }"
            @fields[field_name] = field

    getValue: ->
        console.log 'Form::getValue'
        values = {}
        _.each @fields, (field, field_name) ->
            values[field_name] = field.getValue()
            console.log field_name, field, values[field_name]
        console.log values
        return values




module.exports = Form











