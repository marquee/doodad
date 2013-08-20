BaseDoodad  = require './BaseDoodad'

Spinner     = require './subcomponents/Spinner'
Tags        = require './subcomponents/Tags'

Button      = require './components/Button'
Select      = require './components/Select'
StringInput = require './components/StringInput'

AppBar      = require './containers/AppBar'
Layout      = require './containers/Layout'
Popover     = require './containers/Popover'



Doodad =
    AppBar      : AppBar
    BaseDoodad  : BaseDoodad
    Button      : Button
    Layout      : Layout
    Popover     : Popover
    Select      : Select
    Spinner     : Spinner
    StringInput : StringInput
    Tags        : Tags
    # Toggle      : Toggle
    VERSION     : '{X VERSION X}'

window.Doodad = Doodad
