BaseDoodad = require '../BaseDoodad'

###

progress_bar = new ProgressIndicator()

progress_bar.start()

progress_bar.setValue()
progress_bar.getValue()
progress_bar.reset()
progress_bar.bindTo(element_that_emits_progress_event)

###

# Progress bar or spinner
class ProgressIndicator extends BaseDoodad



module.exports = ProgressIndicator