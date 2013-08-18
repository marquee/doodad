module.exports =
    vendorPrefixCSS: (property, value) ->
        rules = {}
        for prefix in ['', '-webkit-', '-moz-', '-ms-', '-o-']
            rules["#{ prefix }#{ property }"] = value
        return rules


