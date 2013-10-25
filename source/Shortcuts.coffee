
BaseDoodad  = require './BaseDoodad'
Select      = require './components/Select'
StringInput = require './components/StringInput'
Form        = require './containers/Form'


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
    return new StringInput(options)



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


