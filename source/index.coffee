AppBar      = require './components/AppBar'
Button      = require './components/Button'
Popover     = require './components/Popover'
# Select      = require './components/Select'
StringInput = require './components/StringInput'
# Toggle      = require './components/Toggle'

Doodad =
    AppBar      : AppBar
    Button      : Button
    Popover     : Popover
    # Select  : Select
    StringInput : StringInput
    # Toggle      : Toggle
    VERSION     : '{X VERSION X}'

window.Doodad = Doodad
