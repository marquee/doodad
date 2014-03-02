###

new List
    type: 'unordered' # or 'ordered'
    item_class: StringField # or [StringField, Select]
    num_items: '4+' # or 4 or '3-5', default 1+
    value: ['Some string', 'Other string.']
    label: ''

    item_label: 'Item <%= n %>)' # where `n` is the item number  <-- applied as label option to item


# 1st pass
new List
    type        : 'ordered'
    item_class  : StringField
    label       : ''
    num_items   : '1+'
    value       : []


list_field.addField(new StringField())
list_field.addField(StringField)

###

BaseDoodad  = require '../BaseDoodad'
StringField = require '../components/StringField'
Button = require '../components/Button'

parseLimit = (n) ->
    return [parseInt(n), n.substring?(n.length - 1) is '+']


class List extends BaseDoodad
    className: 'List'
    initialize: (options={}) ->
        super(arguments...)
        @_loadConfig options,
            type            : 'ordered' # 'unordered'
            value           : []
            label           : ''
            item_label      : '' # false -- list-style-type: none
            add_label       : 'Add Item'        # or false
            remove_label    : 'Remove Item'
            num_items       : '1+'
            binding         : 'set'         # 'set', 'save', false
            item_class      : StringField

        [@_item_limit, @_is_flexible] = parseLimit(@_config.num_items)
        @_setClasses()

        @value = @_config.value
        @_generateFields()

        console.log '_item_limit', @_item_limit, '@_is_flexible', @_is_flexible
        if @model?
            @bindTo(@model)
            @listenTo(@model, 'change', @_renderLabel)

    _setClasses: ->
        super()
        @$el.addClass('-is_flexible') if @_is_flexible

    render: =>
        @$el.empty()
        @ui = {}
        @ui.label = $('<div class="List_Label"></div>')

        list_tag = if @_config.type is 'unordered' then 'ul' else 'ol'
        @ui.fields = $("<#{ list_tag } class='List_Items'></#{ list_tag }>")

        @ui.add_field = new Button
            classes     : 'List_ItemAdd'
            type        : if @_config.add_label then 'icon+text-bare' else 'icon-bare'
            variant     : 'default-plus'
            label       : @_config.add_label or 'Add Item'
            enabled     : @fields.length < @_item_limit or @_is_flexible
            action      : => @addField()

        @_renderLabel()
        @_renderFields()

        @$el.append(@ui.label, @ui.fields, @ui.add_field.render().el)
        return this

    _renderLabel: =>
        context = if @model? then @model.toJSON() else {}
        @ui.label.text(_.template(@_config.label, context))

    _renderFields: =>
        _.each(@fields, @_renderField)

    _renderField: (field) =>
        $li = $('<li><div class="List_ItemContent"></div></li>')
        $li.children().append(field.render().el)
        if @_is_flexible
            rm_button = new Button
                variant : 'warning-cancel'
                classes : 'List_ItemRemove'
                label   : @_config.remove_label
                type    : 'icon-bare'
                action  : => @_removeField(field)
            $li.append(rm_button.el)
        @ui.fields.append($li)

    _removeField: (field) ->
        @stopListening(field)
        @value.splice(field.item_index, 1)
        @fields.splice(field.item_index, 1)
        @_generateFields()
        @render()
        @trigger('change', this)

    setValue: (value) ->
        @value = value
        _.each(@fields, @stopListening)
        @_generateFields()
        @render()
        return this

    addField: (value=null) ->
        field = @_makeField(value, @fields.length)
        @value.push(value)
        @fields.push(field)
        @_renderField(field)
        if field.focus?
            _.defer(field.focus)
        return this

    _makeField: (value, i) =>
        field = new @_config.item_class
            value   : value
            label   : _.template(@_config.item_label, n: i)
        field.item_index = i
        @listenTo(field, 'change', @_onFieldChange)
        unless field.name
            field.name = "field_#{ i }"
        return field

    # Internal:
    #
    # Returns nothing.
    _generateFields: ->
        @fields = []
        @fields = _.map(@value, @_makeField)
        return

    _onFieldChange: (field, value) =>
        console.log field.item_index, value
        @value[field.item_index] = value
        @trigger('change', this, field)


    bindTo: (model, opts={}) =>
        binding = opts.binding or @_config.binding
        if binding
            @listenTo model, "change:#{ @name }", ->
                value = model.get(@name)
                # Avoid getting stuck in change loops!
                if model.get(@name) isnt @getValue()
                    @setValue(value)
            @on 'change', =>
                value = @getValue()
                # Avoid getting stuck in change loops!
                if value isnt model.get(@name)
                    model[binding](@name, value)
        return this

    # Public: get the value of the form, pulling the values from each of its
    # contained fields and any nested forms.
    #
    # Returns an Array of field values.
    getValue: ->
        return _.invoke(@fields, 'getValue')

    enable: =>
        _.invoke(@fields, 'enable')
        return super()

    disable: =>
        _.invoke(@fields, 'disable')
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
            throw new Error('List does not have a model specified')
        if _.isFunction(kwargs)
            kwargs =
                success: kwargs
        values = @getValue()
        @disable()
        options =
            success: =>
                @enable()
                kwargs.success?(arguments...)
            error: =>
                @enable()
                kwargs.error?(arguments...)
        @model.save(values, options)


module.exports = List
