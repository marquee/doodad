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
            content : []
            layout  : null
            on      : {}
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

    # Internal: gather the fields of this form into a `@fields` object so that
    # the fields may be accessed directly, eg `form.fields.field_1`. Nested
    # forms are also included in the fields object.
    #
    # The fields are referenced by name. If the field or form does not have a
    # name, it is assigned a sequential one, starting from either 'field_1' or
    # 'form_1', based on its position in the `content` list, relative to its
    # type.
    #
    # Components without a `.getValue` method are ignored, allowing for
    # buttons and other elements to be in the form.
    #
    # Returns nothing.
    _captureFields: ->
        console.log 'Form::_captureFields'
        @fields = {}
        num_fields = 0
        num_forms = 0
        _.each @_options.content, (field, i) =>
            if field.getValue?
                if field instanceof Form
                    num_forms += 1
                    index = num_forms
                    type = 'form'
                else
                    num_fields += 1
                    index = num_fields
                    type = 'field'
                field_name = if field.name then field.name else "#{ type }_#{ index }"
                @fields[field_name] = field
        return

    # Public: get the value of the form, pulling the values from each of its
    # contained fields and any nested forms.
    #
    # kwargs -
    #       flatten - (Boolean:true) whether or not to flatten the nested forms
    #
    # Returns an Object of the field name/value pairs.
    getValue: (kwargs={}) ->
        console.log 'Form::getValue'
        kwargs.flatten ?= true
        values = {}
        _.each @fields, (field, field_name) ->
            field_value = field.getValue()
            if field instanceof Form and kwargs.flatten
                _.extend(values, field_value)
            else
                values[field_name] = field.getValue()
        return values



module.exports = Form
