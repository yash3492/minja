App.RoundItem = Em.Object.extend
  name: ""
  _round: null
  players: []
  games: []
  dummies: []

  init: ->
    @_super()
    @set "players", []
    @set "games", []
    @set "dummies", []

  remove: ->
    @_round.removeItem @

  replace: (from, to) ->
    App.tournament.bracket.replacePlayer from, to, @get("_round")

  matchDays: (->
    matchDays = []
    playerCount = @get("players.length")
    gamesPerMatchDay = Math.floor(playerCount/2)
    roundItemName = @name
    _.chain(@get("games"))
    .groupBy((item, index) -> Math.floor(index/gamesPerMatchDay))
    .map((chunk, index) ->
      games = []
      for game in chunk
        game.set "_roundItemName", roundItemName
        games.pushObject game
      matchDays.pushObject Em.Object.create
        matchDay: parseInt(index) + 1
        games: games
    )
    matchDays
  ).property("games.@each")

  matchDayCount: (->
    @get("matchDays.length")
  ).property("matchDays.@each")

  completedGames: (->
    @games.filter (game) -> game.get("isCompleted")
  ).property("games.@each.isCompleted")

  completion: (->
    @get("completedGames.length")
  ).property("completedGames")

  itemId: (->
    itemIndex = @get('_round.items').indexOf @
    roundIndex = App.tournament.bracket.indexOf @get('_round')
    roundIndex + '-' + itemIndex
  ).property('_round.items.@each')

