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
    dStringField 'property'
    dStringField 'other_property', type: 'multiline'
    dSelect 'prop', [
            {name: 'Value', value: 'value'}
            {name: 'Value 2', value: 'value2'}
            {name: 'Value 3', value: 'value3'}
        ]
    dStringField 'some_property'

# Equivalent to:

new Form
    name: 'form_name'
    model: @model
    content: [
        new StringField
            name: 'property'
        new StringField
            name: 'other_property'
            type: 'multiline'
        new Select
            name: 'prop'
            choices: [
                {name: 'Value', value: 'value'}
                {name: 'Value 2', value: 'value2'}
                {name: 'Value 3', value: 'value3'}
            ]
        new StringField
            name: 'some_property'
    ]

###




BaseDoodad = require '../BaseDoodad'
Button = require '../components/Button'
{ DIV, P } = require '../subcomponents/Tags'



class FormLabel extends DIV
    className: 'FormLabel'

class FormText extends P
    className: 'FormText'

class Form extends BaseDoodad
    className: 'Form'
    initialize: (options={}) ->
        super(arguments...)
        @_loadConfig options,
            content : @content?() or []
            layout  : @layout

        @_setClasses()
        @_is_showing = false

        @_captureFields()


    render: =>
        @$el.empty()
        @ui = {}
        @ui.content = $('<div class="Form_Content"></div>')
        if @_config.layout
            @$el.addClass('-autolayout')
            used = {}
            _.each @_config.layout, (row) =>
                $row = $('<div class="Form_ContentRow"></div>')
                _.each row, (cell) =>
                    $cell = $('<div class="Form_ContentCell"></div>')
                    $cell.css
                        width: "#{ 100/row.length }%"
                    _.each cell, (field_name) =>
                        unless used[field_name]
                            field = @components[field_name]
                            if field?
                                $cell.append(field.render().el)
                                used[field_name] = true
                            else
                                console.error "Component \"#{ field_name }\" defined in layout, but not found in content for", this
                        else
                            console.error "Component \"#{ field_name }\" already used in layout for", this
                    $row.append($cell)
                @ui.content.append($row)

            # Check for unused components and warn that they weren’t used.
            _.each @components, (field, field_name) =>
                unless used[field_name]
                    console.warn "Component \"#{ field_name }\" not used in layout for", this

        else
            _.each @_config.content, (item, i) =>
                @ui.content.append(item.render().el)
        @$el.append(@ui.content)
        return this

    appendContent: (contents...) ->
        @_config.content.push(contents...)
        return this

    appendLayout: (layouts...) ->
        @_config.layout ?= []
        @_config.layout.push(layouts...)
        return this

    # Internal: gather the components of this form into a `@components` object
    # and if it’s a field (has a getValue), a `@fields` object, so that the
    # fields may be accessed directly, eg `form.fields.field_1`. Nested forms
    # are also included in the fields object. These references are used by the
    # layout, if specified.
    #
    # The fields are referenced by name. If the field or form does not have a
    # name, it is assigned a sequential one, starting from either 'field_1' or
    # 'form_1', based on its position in the `content` list, relative to its
    # type.
    #
    # Components without a `.getValue` method are ignored by fields, allowing
    # for buttons and other elements to be in the form.
    #
    # Returns nothing.
    _captureFields: ->
        @fields = {}
        @components = {}
        num_fields = 0
        num_forms = 0
        component_index = {}
        _.each @_config.content, (field, i) =>
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
            else
                name = field.className.toLowerCase()
                component_index[name] ?= 0
                component_index[name] += 1
                field_name = if field.name then field.name else "#{ name }_#{ component_index[name] }"
            @components[field_name] = field
        return

    # Public: get the value of the form, pulling the values from each of its
    # contained fields and any nested forms.
    #
    # kwargs -
    #       flatten - (Boolean:true) whether or not to flatten the nested forms
    #
    # Returns an Object of the field name/value pairs.
    getValue: (kwargs={}) ->
        kwargs.flatten ?= true
        values = {}
        _.each @fields, (field, field_name) ->
            field_value = field.getValue()
            if field instanceof Form and kwargs.flatten
                _.extend(values, field_value)
            else
                values[field_name] = field.getValue()
        return values

    enable: =>
        _.each @components, (c) ->
            c.enable()
        return super()

    disable: =>
        _.each @components, (c) ->
            c.disable()
        return super()

    # Public: save the values of this form to the specified model, using the
    # names of the fields as property names.
    #
    # kwargs - an Object or success callback as Function
    #     if Object,
    #       - success: (Function:null) called when the model completes saving
    #       - flatten: (Boolean:true) flatten any nested forms
    #
    # Returns nothing.
    save: (kwargs={}) ->
        unless @model?
            throw new Error("Form does not have a model specified")
        if _.isFunction(kwargs)
            kwargs =
                success: kwargs
        kwargs.flatten ?= true
        values = @getValue(flatten: kwargs.flatten)
        @disable()
        options =
            success: =>
                @enable()
                kwargs.success?(arguments...)
            error: =>
                @enable()
                kwargs.error?(arguments...)
        @model.save(values, options)



Form.FormLabel = FormLabel
Form.FormText = FormText

module.exports = Form
