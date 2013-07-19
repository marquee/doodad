AppBar      = require './components/AppBar'
Button      = require './components/Button'
Popover     = require './components/Popover'
Select      = require './components/Select'
Toggle      = require './components/Toggle'

Doodad =
    AppBar  : AppBar
    Button  : Button
    Popover : Popover
    Select  : Select
    Toggle  : Toggle
    VERSION : '{X VERSION X}'

window.Doodad = Doodad
