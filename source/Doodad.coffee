BaseDoodad  = require './BaseDoodad'

ProgressBar = require './subcomponents/ProgressBar'
Spinner     = require './subcomponents/Spinner'
Tags        = require './subcomponents/Tags'

Button      = require './components/Button'
Select      = require './components/Select'
StringField = require './components/StringField'

# AppBar      = require './containers/AppBar'
Form        = require './containers/Form'
List        = require './containers/List'
# Layout      = require './containers/Layout'
Popover     = require './containers/Popover'

Shortcuts   = require './Shortcuts'


Doodad =
    # AppBar      : AppBar
    BaseDoodad  : BaseDoodad
    Button      : Button
    Form        : Form
    # Layout      : Layout
    List        : List
    Popover     : Popover
    ProgressBar : ProgressBar
    Select      : Select
    Shortcuts   : Shortcuts
    Spinner     : Spinner
    StringField : StringField
    Tags        : Tags
    # Toggle      : Toggle
    VERSION     : '{X VERSION X}'

window.Doodad = Doodad
