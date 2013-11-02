###
They also provide convenient points to bind data changes, eg:
    
    p_node = new Doodad.Tags.P
        content: @model.get('text_property')
    @model.on 'change:text_property', ->
        p_node.setContent(@model.get('text_property'))


For Tags that contain content (ie non-self-closing), pass them strings:

    new Doodad.Tags.P
        content: 'Some text'

or lists of strings, other Tags, or other Doodads (or really anything that
implements a `.render()` method that returns an element to be appended):

    new Doodad.Tags.H1
        content: [
            new Doodad.Tags.A
                href: 'http://example.com'
                content: 'Some Title'
            new Doodad.Button
                type: 'icon'
                class: 'friendly'
                action: ->
            'Extra content'
        ]

Raw strings are wrapped in the element appropriate for the container,
eg as LI when in a UL or OL.

    new Doodad.Tags.UL
        content: [
            'List item content'
            'Other list item'
            'Third item in the list'
        ]

Otherwise, they are just text nodes:

    new Doodad.Tags.DIV
        extra_classes: ['inset', 'align-right']
        content: 'Some content inside a div'


Additional attributes used are added as HTML attributes:

    new Doodad.Tags.IMG
        src: 'http://placekitten.com/800/600/'
        title: 'Some kittens'
        'data-2x': 'http://placekitten.com/1600/1200/'

    link = new Doodad.Tags.A
        href: 'http://example.com'
        content: 'Link Content'
    link.setContent('other content')
    link.addContent('foo')

TODO:

* Perhaps p_node.bindToProperty(@model, 'text_property') that wraps the above?
* Allow for setting HTML as content (breaks down HTML text into correct nodes)
* Lowercase shortcut syntax, functions

    { p, h1, h2, h3, ul, div, img, a, ul, ol, li, span } = Doodad.Tags.Shortcuts

    tag({optional_attrs}, content_arguments...)

    p class:'classNames',
        'Paragraph content'
        a(href: 'http://example.com', 'Some Link in the P')
        'More text content'

###


BaseDoodad = require '../BaseDoodad'



class TextNode
    @__doc__ = ''

    # Public: A wrapper around ordinary text nodes that provide Doodad-compatible
    #        methods. However, unlike the other Tags, they are not full
    #        components (no getPosition, etc) since they are not tags in the DOM.
    constructor: ({ content }) ->
        @_node = document.createTextNode(content)

    # Public: A `.render()` method for compatibility with the Doodad components.
    #
    # Returns the text node.
    render: -> @_node

    # Public: Set the content of the node. Note: this wraps a text node, so the
    #         content MUST NOT be HTML. Any HTML characters will be escaped.
    #
    # content... - one or more String arguments to be concatenated
    #
    # Returns self for chaining.
    setContent: (content...) ->
        @_node.textContent = content.join('')
        return this

    # Public: Add content to the node, concatenating with existing content.
    #
    # Returns self for chaining.
    addContent: (content...) ->
        @setContent(@_node.textContent, content...)
        return this



class Tag extends BaseDoodad
    @__doc__ = """
    Public: A base class for Tag components. All Tag-base classes MUST specify
            a `@_takes_content` class property, either `true` or `false`. Also
            they MUST set a `tagName` (otherwise they'll just be a div). The
            classes also MAY specify a `@_default_child` class property which
            is a Tag-based class to use for bare strings passed to content.

    options - An object with configuration options for the tag.
        * content   - (optional) A String, Tag, TextNode, or Array of any
                        combination of the three. (optional since it MAY be
                        added later using `.addContent()` or `.setContent()`.)
        * ?options  - Any additional key-value attributes to be added to the el,
                        like an `href` for a link or `src` for an image.

    Generic example:

        new <tagclass>
            content: 'Some text content'
            title: 'A title attribute'

    """

    @_takes_content = null
    @_default_child = TextNode

    initialize: (options={}) ->
        @_options = _.extend
            type: ''
        , options
        super(@_options)

        unless @constructor._takes_content?
            throw new Error('Doodad.Tag classes require a @_takes_content class property')

        @_contents = []

        if @constructor._takes_content
            if options.content?
                if _.isArray(options.content)
                    @addContent(options.content...)
                else
                    @addContent(options.content)

        for k, v of options
            unless k in ['model', 'content', 'classes', 'variant', 'css', 'on']
                @$el.attr(k,v)

        @_setClasses()

    # Public: Add content to the Tag.
    #
    # contents...   - one or more String or Tag arguments to be added as
    #                   content. Strings are wrapped in the class' default
    #                   child class.
    #
    # Returns self for chaining.
    addContent: (contents...) =>
        _.each contents, (child_content) =>
            if _.isString(child_content) or _.isNumber(child_content)
                child = new @constructor._default_child(content: child_content.toString())
            else
                child = child_content
            @_contents.push(child)
            @$el.append(child.render())
        return this

    # Public: Set the content of the Tag (replaces existing content).
    #
    # contents...   - one or more String or Tag arguments to be added as
    #                   content. Strings are wrapped in the class' default
    #                   child class.
    #
    # Returns self for chaining.
    setContent: (contents...) =>
        @$el.empty()
        @_contents = []
        @addContent(contents...)
        return this

    # Public: Render the tag, adding its contents as DOM children.
    #
    # Returns self for chaining.
    render: =>
        @$el.empty()
        _.each @_contents, (content) =>
            @$el.append(content.render())
        @delegateEvents()
        return @el



# The actual tags:

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
    A           : A
    BR          : BR
    DIV         : DIV
    EM          : EM
    H1          : H1
    H2          : H2
    H3          : H3
    H4          : H4
    H5          : H5
    H6          : H6
    IMG         : IMG
    LI          : LI
    OL          : OL
    P           : P
    SPAN        : SPAN
    STRONG      : STRONG
    Tag         : Tag
    TextNode    : TextNode
    UL          : UL
