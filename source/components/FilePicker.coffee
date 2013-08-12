


{ View } = Backbone

class FilePicker extends View
    


module.exports = FilePicker

###
new FilePicker
    multiple: true
    upload_url: ''
    upload_fn: (file_list) -> # alternate function to use for uploading
###

# TODO: Make this a doodad component
class FilePicker extends View
    className: 'FilePicker'
    initialize: ->
        @value = []
    render: ->
        @$el.html('<label>Attachments: <input type="file" multiple="true"></label>')
        @delegateEvents()
        return @el
    events:
        'change input': '_listFiles'
    _listFiles: (e) -> @value = e.target.files
    reset: ->
        @value = []
        @render()
        return this
    hide: ->
        @$el.hide()
        return this
    show: ->
        @$el.show()
        return this

sendFile = (url, file, callback) ->
    console.log url, file
    xhr = new XMLHttpRequest()
    xhr.open('POST', url, true)
    xhr.upload.onprogress = (e) ->
        if e.loaded is e.total
            callback()

    # Sending a form instead of just a blob or file so the Express bodyParser
    # can do all the work.
    form_data = new FormData()
    form_data.append('file', file, file.name)
    xhr.send(form_data)
