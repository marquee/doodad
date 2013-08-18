AppBar      = require './components/AppBar'
Button      = require './components/Button'
Popover     = require './components/Popover'
Select      = require './components/Select'
StringInput = require './components/StringInput'
# Toggle      = require './components/Toggle'
Layout      = require './components/Layout'

Spinner     = require './subcomponents/Spinner'

Doodad =
    AppBar      : AppBar
    Button      : Button
    Layout      : Layout
    Popover     : Popover
    Select      : Select
    Spinner     : Spinner
    StringInput : StringInput
    # Toggle      : Toggle
    VERSION     : '{X VERSION X}'

window.Doodad = Doodad
