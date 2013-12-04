# Doodad UI Elements

Doodad is a set of UI elements with a JavaScript-oriented API. To use, simply
create a new instance of the element and then manipulate it as desired. No
back-and-forth between the markup and script, adding funky classes or
attributes to the markup, or specifying templates in the script.

```javascript
var button = new Button({
        label: 'Do Something',
        action: function(self) {
                console.log('clicked', self);
            }
    });

$('#app').append(button.el);
```

Or in [CoffeeScript](http://coffeescript.org) (which all other examples are in):

```coffeescript
button = new Button
    label: 'Do Something'
    action: (self) ->
        console.log('clicked', self)

$('#app').append(button.el)
```

The element contructors take various options which control their appearance
and behavior. Also, the element classes are based on Backbone Views, and can
be used as such.

```coffeescript
new Button
    type    : 'icon'
    variant : 'dangerous'
    spinner : true
    action  : (self) ->
        console.log('Did something')
        self.enable()
```

Alternatively, customized components can be defined as classes, so they are
more reusable:

```coffeescript
class SaveButton extends Button
    type    : 'icon+text'
    label   : 'Save'
    variant : 'friendly-disk'
    spinner : 'replace'
    action: (self) =>
        @model.save {},
            success: ->
                self.enable()
```


## Usage

Include the [`doodad.js`](http://cdn.droptype.com/doodad/doodad-0.1.0-min.js) and
[`doodad.css`](http://cdn.droptype.com/doodad/doodad-0.1.0-min.css) files in the
page. Doodad requires [Zepto](http://cdnjs.cloudflare.com/ajax/libs/zepto/1.0/zepto.min.js)
or [jQuery](//cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min.js),
[Underscore](//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.5.1/underscore-min.js),
and [Backbone](//cdnjs.cloudflare.com/ajax/libs/backbone.js/1.0.0/backbone-min.js).

All elements support a `classes` option, which is a string or list of
strings to add to the element’s `className`.


## Elements

### Components

* `Button` - A clickable button that can have icons and spinners built-in
  
  Bare minimum, a `Button` requires a label and an action. The action is a
  function that is called whenever the button is clicked, and receives the
  button instance as an argument.

  ```coffeescript
  new Button
      label: 'Click Me'
      action: (self) ->
  ```

* `Select` - A drop-down menu

  The `Select` takes a list of choices, one of which can be marked as a default.
  By default it is not required.

  ```coffeescript
  new Select
      action: (self, value) =>
          @model.save('align', self.value)
      choices: [
          {
              label: 'Align Left'
              value: 'left'
              default: true
          }
          {
              label: 'Align Right'
              value: 'right'
          }
      ]
  ```

* `StringField` - A single- or multi-line text input

  The `StringField` serves as a text input, or a textarea. It can have a
  character or word limit that is hard, preventing any additional input, or
  soft, only warning. The input can also be tokenized, with a delimiter or on
  enter.

  ```coffeescript
  new StringField
      on: change: (self, value) ->
         console.log(value)
  ```

#### Subcomponents

* `Spinner` - A progress indicator used by the Button


### Containers

Containers are elements that take components and automatically render them
as they are added.

* `Popover` - A container that overlays, either as a flag or a modal

The Popover in flag form can be positioned using its origin option. The origin
is a string in the form `'<edge>-<position>'`, where `<edge>` is the side of
the popover element — `'top'`, `'bottom'`, `'left'`, `'right'` — and
`<position>` is a location along that edge — `'left'`, `'center'`, `'right'`
or `'top'`, `'center'`, `'bottom'`, depending on the edge.

```coffeescript
modal = new Popover
    type: 'modal'
    origin: 'bottom-left'
    content: [
        new Button
            label: 'Do Stuff'
            action: someActionFn
    ]
```


### Tags

Sometimes you do just need a simple tag. The classes in the Tags module provide 
wrappers for the standard HTML tags, like P, DIV, H1, and so on, that implement
the functions that let them interoperate with Doodads. (Only certain tags are
implemented, mainly the content-oriented ones. Input-oriented tags are of
course handled by the regular Doodads.) There’s also a TextNode class that
wraps a text node

For Tags that contain content, pass them strings:

```coffeescript
new Doodad.Tags.P
    content: 'Some text'
```

or lists of strings, other Tags, or other Doodads (or really anything that
implements a `.render()` method that returns itself and has an `el`):

```coffeescript
new Doodad.Tags.H1
    content: [
        'Some Title'
        new Doodad.Tags.A
            href: 'http://example.com'
            content: 'Link'
        new Doodad.Button
            type: 'icon'
            class: 'friendly'
            action: ->
    ]
```

Bare strings in the content are converted to the appropriate element for the
containing tag. When passed to a `UL` they become `LIs`, or passed to a `P`
then become `TextNodes`.

The full list of tags:

* `A`
* `BR`
* `DIV`
* `EM`
* `H1`
* `H2`
* `H3`
* `H4`
* `H5`
* `H6`
* `IMG`
* `LI`
* `OL`
* `P`
* `SPAN`
* `STRONG`
* `Tag`
* `TextNode`
* `UL`


## Authors

* [Alec Perkins](https://github.com/alecperkins) ([Droptype Inc](http://droptype.com))

## License

Unlicensed aka Public Domain. See /LICENSE for more information.
