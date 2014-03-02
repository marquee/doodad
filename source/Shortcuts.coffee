
BaseDoodad  = require './BaseDoodad'
Select      = require './components/Select'
StringField = require './components/StringField'
Form        = require './containers/Form'
Tags        = require './subcomponents/Tags'


module.exports.dform = (name, args...) ->
    options = {}
    unless _.isString(name)
        args.unshift(name)
        name = null
    unless args[0] instanceof BaseDoodad
        options = args.shift()

    _.extend options,
        name: name
        content: args
    return new Form(options)



module.exports.dstringinput = (name, args...) ->
    unless _.isString(name)
        args.unshift(name)
        name = null
    options = args[0] or {}
    _.extend options,
        name: name
    return new StringField(options)



module.exports.dformtext = (content) ->
    return new Form.FormText
        content: content



module.exports.dformlabel = (content) ->
    return new Form.FormLabel
        content: content



module.exports.dselect = (name, args...) ->
    options = {}
    unless _.isString(name)
        args.unshift(name)
        name = null
    unless _.isArray(args[0])
        options = args.shift()
    choices = args[0]
    _.extend options,
        name: name
        choices: choices
    return new Select(options)


module.exports.dh1 = (content...) ->
    return new Tags.H1
        content: content
module.exports.dh2 = (content...) ->
    return new Tags.H2
        content: content
module.exports.dh3 = (content...) ->
    return new Tags.H3
        content: content
module.exports.dh4 = (content...) ->
    return new Tags.H4
        content: content
module.exports.dh5 = (content...) ->
    return new Tags.H5
        content: content
module.exports.dh6 = (content...) ->
    return new Tags.H6
        content: content

module.exports.dp = (content...) ->
    return new Tags.P
        content: content

module.exports.ddiv = (content...) ->
    return new Tags.DIV
        content: content

module.exports.dspan = (content...) ->
    return new Tags.SPAN
        content: content

module.exports.dbr = ->
    return new Tags.BR()
