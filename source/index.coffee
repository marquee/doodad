BaseDoodad  = require './BaseDoodad'

Spinner     = require './subcomponents/Spinner'
Tags        = require './subcomponents/Tags'

Button      = require './components/Button'
Select      = require './components/Select'
StringInput = require './components/StringInput'

AppBar      = require './containers/AppBar'
Form        = require './containers/Form'
Layout      = require './containers/Layout'
Popover     = require './containers/Popover'

Shortcuts   = require './Shortcuts'

Doodad =
    AppBar      : AppBar
    BaseDoodad  : BaseDoodad
    Button      : Button
    Form        : Form
    Layout      : Layout
    Popover     : Popover
    Select      : Select
    Shortcuts   : Shortcuts
    Spinner     : Spinner
    StringInput : StringInput
    Tags        : Tags
    # Toggle      : Toggle
    VERSION     : '{X VERSION X}'

window.Doodad = Doodad
