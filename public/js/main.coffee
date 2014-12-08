window.UniqueId =
  create: (length=8) ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length

############ error handling ##################
window.onerror = (errorMessage, errorUrl, errorLine) ->
    $.ajax
        type: 'POST',
        url: '/errors/report',
        data:
            msg: errorMessage,
            url: errorUrl,
            line: errorLine
            hostUrl: document.URL
        success: ->
            if (console && console.log)
                console.log('JS error report successful.')
        error: ->
            if (console && console.error)
                console.error('JS error report submission failed!')
    return false

############ after each Page-Load ##################
$(document).ready ->
  # $("[rel='tooltip']").tooltip()

  # Favorite Tournament Toggle
  $favIcon = $("#favoriteStar")
  if $favIcon
  	isFavorite = $favIcon.attr "isFavorite"
  	if isFavorite then $favIcon.addClass "icon-star" else $favIcon.addClass "icon-star-empty"
  	$favIcon.click ->
  	  $.post "/me/favorites/toggle", tid: $favIcon.attr "tid"
  	  $favIcon.toggleClass "icon-star"
  	  $favIcon.toggleClass "icon-star-empty"
