"""
Sometimes you do just need a simple tag. The classes in the Tags module provide 
wrappers for the standard HTML tags, like P, DIV, H1, and so on, that implement
the functions that let them interoperate with Doodads.
They also provide convenient points to bind data changes, eg:
    
    p_node = new P
        content: @model.get('text_property')
    @model.on 'change:text_property', ->
        p_node.setContent(@model.get('text_property'))

Perhaps p_node.bindToProperty(@model, 'text_property') that wraps the above?

For tags that contain content (ie non-self-closing), use content: ''

new Doodad.P
    content: 'Some text'

Tags can also contain other tags (or other Doodads)
new Doodad.H1
    content: [
        new Doodad.A
            href: 'http://example.com'
            content: 'Some Title'
        new Button
            type: 'icon'
            class: 'friendly'
            action: ->
        'Extra content'
    ]



Raw strings are wrapped in the element appropriate for the container,
eg as LI when in a UL or OL
Inside a div, just text nodes

new Doodad.UL
    content: [
        'List item content'
        'Other list item'
        'Third item in the list'
    ]

new Doodad.DIV
    extra_classes: ['inset', 'align-right']
    content: '<span>Some content</span> inside a div'

Additional attributes used are added as HTML attributes

new Doodad.IMG
    src: 'http://placekitten.com/800/600/'
    title: 'Some kittens'
    'data-2x': 'http://placekitten.com/1600/1200/'

link = new Doodad.A
    href: 'http://example.com'
    content: 'Link Content'
link.setContent('other content')
link.addContent('foo')


TODO: allow for setting HTML as content (breaks down HTML text into correct nodes)

TODO: Lowercase shortcut syntax, functions
{ p, h1, h2, h3, ul, div, img, a, ul, ol, li, span } = Doodad.Tags.Shortcuts

tag({optional_attrs}, content_arguments...)

p class:'classNames',
    'Paragraph content'
    a(href: 'http://example.com', 'Some Link in the P')
    'More text content'

"""


BaseDoodad = require '../BaseDoodad'




class TextNode
    @__doc__ = """
    Public: A wrapper
    """
    constructor: ({ content }) ->
        console.log 'TextNode.constructor', content
        @_node = document.createTextNode(content)
    render: -> @_node
    setContent: (content...) ->
        @_node.textContent = content.join('')
    addContent: (content...) ->
        @setContent(@_node.textContent, content...)




class Tag extends BaseDoodad
    @_takes_content = null
    @_default_child = TextNode

    initialize: (options={}) ->
        console.log @tagName, options
        super(arguments...)
        unless @constructor._takes_content?
            throw new Error('Doodad.Tag classes require a @_takes_content class property')

        @_contents = []

        if @constructor._takes_content
            if _.isArray(options.content)
                @addContent(options.content...)
            else
                @addContent(options.content)
            delete options.content
        for k, v of options
            @$el.attr(k,v)

    addContent: (contents...) =>
        console.log 'adding', contents
        _.each contents, (child_content) =>
            if _.isString(child_content)
                child = new @constructor._default_child(content: child_content)
            else
                child = child_content
            console.log 'child', child
            @_contents.push(child)
            @$el.append(child.render())

    setContent: (contents...) =>
        @$el.empty()
        @_contents = []
        @addContent(contents...)

    render: =>
        @$el.empty()
        console.log 'Tag.render', @_contents
        _.each @_contents, (content) =>
            console.log 'rendering', content
            @$el.append(content.render())
        return @el

class IMG extends Tag
    @_takes_content = false
    tagName: 'IMG'
    className: 'IMG'

class A extends Tag
    @_takes_content = true
    tagName: 'A'
    className: 'A'

class STRONG extends Tag
    @_takes_content = true
    tagName: 'STRONG'
    className: 'STRONG'

class EM extends Tag
    @_takes_content = true
    tagName: 'EM'
    className: 'EM'

class SPAN extends Tag
    @_takes_content = true
    tagName: 'SPAN'
    className: 'SPAN'

class DIV extends Tag
    @_takes_content = true
    tagName: 'DIV'
    className: 'DIV'

class P extends Tag
    @_takes_content = true
    tagName: 'P'
    className: 'P'

class LI extends Tag
    @_takes_content = true
    tagName: 'LI'
    className: 'LI'

class UL extends Tag
    @_takes_content = true
    @_default_child = LI
    tagName: 'UL'
    className: 'UL'

class OL extends Tag
    @_takes_content = true
    @_default_child = LI
    tagName: 'OL'
    className: 'OL'

class H1 extends Tag
    @_takes_content = true
    tagName: 'H1'
    className: 'H1'

class H2 extends Tag
    @_takes_content = true
    tagName: 'H2'
    className: 'H2'

class H3 extends Tag
    @_takes_content = true
    tagName: 'H3'
    className: 'H3'

class H4 extends Tag
    @_takes_content = true
    tagName: 'H4'
    className: 'H4'

class H5 extends Tag
    @_takes_content = true
    tagName: 'H5'
    className: 'H5'

class H6 extends Tag
    @_takes_content = true
    tagName: 'H6'
    className: 'H6'

class BR extends Tag
    @_takes_content = false
    tagName: 'BR'
    className: 'BR'


module.exports =
    TextNode: TextNode
    Tag: Tag
    SPAN: SPAN
    DIV: DIV
    P: P
    LI: LI
    UL: UL
    OL: OL
    H1: H1
    H2: H2
    H3: H3
    H4: H4
    H5: H5
    H6: H6
    IMG: IMG
    A: A
    EM: EM
    STRONG: STRONG
    BR: BR
