buster.testCase "Game Model",
  setUp: ->
    @hans = App.Player.create name: "Hans"
    @peter = App.Player.create name: "Peter"
    @game = App.Game.create
      player1: @hans
      player2: @peter

  "test ember obj": ->
    p1 = App.Player.create()
    p2 = App.Player.create()

    p1.isDummy = true

    assert.equals true, p1.isDummy
    assert.equals false, p2.isDummy

    p1.set("name", "hi")
    assert.equals "hi", p1.name
    assert.equals "", p2.name

  "Gewinner eines Spiels wird korrekt ermittelt": ->
    assert.equals null, @game.getWinner()

    @game.setResult 2, 1
    assert.equals @hans, @game.getWinner()

    @game.setResult 2, 2
    assert.equals false, @game.getWinner()

    @game.setResult 2, 3
    assert.equals @peter, @game.getWinner()

  "Swap Players": ->
    assert.equals @hans, @game.get 'player1'
    assert.equals @peter, @game.get 'player2'

    @game.set 'result1', 1
    @game.set 'result2', 2

    @game.swapPlayers()

    assert.equals @hans, @game.get 'player2'
    assert.equals @peter, @game.get 'player1'
    assert.equals 2, @game.get 'result1'
    assert.equals 1, @game.get 'result2'
    
  "Swap Players: result attributes": ->
    attr = App.GameAttribute.create
      type: 'result'
      id: 'attr-id'
      name: 'name'
    
    App.tournament.bracket.gameAttributes.pushObject attr

    assert.equals @hans, @game.get 'player1'
    assert.equals @peter, @game.get 'player2'

    @game.set 'result1', 1
    @game.set 'result2', 2

    @game.set 'attr-id', '1:2'
    @game.swapPlayers()
    assert.equals '2:1', @game.get 'attr-id'

    
    @game.set 'attr-id', ':'
    @game.swapPlayers()
    assert.equals ':', @game.get 'attr-id'
