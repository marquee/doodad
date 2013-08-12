spinner = new Spinner
    type: 'spinner'
    rate: 0.5

spinner.start()
spinner.stop()
spinner.setRate(0.1)
spinner.speedUp()   # +0.1
spinner.slowDown()  # -0.1
spinner.bindTo(element_that_emits_progress)
