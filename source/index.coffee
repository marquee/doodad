AppBar      = require './components/AppBar'
Button      = require './components/Button'
Popover     = require './components/Popover'
Select      = require './components/Select'
StringInput = require './components/StringInput'
# Toggle      = require './components/Toggle'
Layout      = require './components/Layout'

Doodad =
    AppBar      : AppBar
    Button      : Button
    Layout      : Layout
    Popover     : Popover
    Select      : Select
    StringInput : StringInput
    # Toggle      : Toggle
    VERSION     : '{X VERSION X}'

window.Doodad = Doodad
