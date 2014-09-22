App.KoRound = App.Round.extend
  _itemLabel: ""
  isKoRound: true

  init: ->
    @_super()
    @_itemLabel = App.i18n.game

  addItem: ->
    if not @get('editable')
      App.Popup.showInfo
        bodyContent: App.i18n.roundItemNotAddable
      return
    game = App.RoundGame.create
      name: "#{App.i18n.game} " + (@items.get("length") + 1)
      _round: @

    @items.pushObject game
    for i in [0..1]
      if @getFreeMembers()?[i]?
        game.players.pushObject @getFreeMembers()[i]
      else
        game.players.pushObject App.PlayerPool.getNewPlayer
          name: "#{App.i18n.player} " + (i + 1)



