App.BracketLineDrawer =
  ctx: null
  canvas: null
  lastChange: new Date().getTime()

  init: ->
    @canvas = document.getElementById "bracket-lines"
    $(@canvas).hide()
    @ctx = @canvas.getContext "2d"
    window.addEventListener 'resize', (=> @update()), false
    $("#treeWrapper").bind "DOMSubtreeModified", => setTimeout (=> @update()), 10
    @update()
    $(@canvas).fadeIn 'slow'

  update: ->
    if not @ctx then return
    if new Date().getTime() - @lastChange < 500 then return
    @lastChange = new Date().getTime()
    @clear()
    @resize()
    App.tournament.bracket.forEach (round) =>
      prev = round._previousRound
      if not prev then return
      if prev.isGroupRound or round.isGroupRound then return

      for gameCurrent in round.items
        playersCurrent = gameCurrent.get "players"
        for gamePrev in prev.items
          if _.intersection(playersCurrent, gamePrev.get("qualifiers")).length > 0
            @draw gameCurrent, gamePrev



  draw: (from, to) ->
    posFrom = @centerPos $("." + from.get('itemId')), true
    posTo = @centerPos $("." + to.get('itemId'))
    if not posFrom or not posTo
      return

    midY = posFrom.y + ((posTo.y - posFrom.y) / 2)
    @ctx.lineWidth = 2
    @ctx.beginPath()
    @ctx.moveTo posFrom.x, posFrom.y
    @ctx.lineTo posFrom.x, midY
    @ctx.lineTo posTo.x, midY
    @ctx.lineTo posTo.x, posTo.y

    @ctx.strokeStyle = App.tournament.settings.colors.content
    @ctx.stroke()

  centerPos: (element, top) ->
    if element.length is 0
      return undefined
    pos =
      x: element.offset().left + element.width() / 2
      y: element.offset().top + if not top then element.height() else 0

  resize: ->
    @canvas.width = @width()
    @canvas.height = @height()

  width: ->
    $(window).width()

  height: ->
    $('body').height()


  show: ->
    $(@canvas).fadeIn 'slow'

  hide: ->
    $(@canvas).hide()

  clear: ->
    if not @ctx then return
    @ctx.clearRect 0, 0, @width(), @height()

