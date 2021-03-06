App.templates.game = """

<table {{bind-attr class=":box game.itemId :round-item-table App.editable::blurringBox :noPadding"}} {{action 'tableClicked' target='view'}} cellpadding="2" width="100%" id="gamesTable">
  <thead>
    <th colspan="10">
      <span>{{view 'dynamicTextField' value=game.name editable=App.editable}}</span>

      <span class="actionIcons">
        {{#if App.editable}}
          <i class="fa fa-search" {{action "openGameDetailView" game}}></i>
        {{/if}}
        {{#if view.round.isEditable}}
          <i class="fa fa-times removeItem" {{action "remove" target="game"}}></i>
        {{/if}}
      </span>
    </th>
  </thead>
  <tr>
    <td style="max-width: 110px; width: 110px" class="player tableCellBottom" title="{{unbound game.player1.name}}">
      <div id="itemIndex" class="hide">{{view.gameIndex}}</div><div id="playerIndex" class="hide">0</div>
      {{#if App.editable}}
        {{view 'dynamicTextField' value=game.player1.name editable=game.player1.editable}}
      {{else}}
        {{game.player1.name}}
      {{/if}}
    </td>
    {{#each g in game.games}}

      <td class="tableCellBottom">
        {{view 'gameResult' player=game.player1 gBinding="g"}}
      </td>
    {{/each}}
  </tr>
  <tr>
    <td style="max-width: 110px; width: 110px" class="player tableCellTop" title="{{unbound game.player2.name}}">
      <div id="itemIndex" class="hide">{{view.gameIndex}}</div><div id="playerIndex" class="hide">1</div>
      {{#if App.editable}}
        {{view 'dynamicTextField' value=game.player2.name editable=game.player2.editable}}
      {{else}}
        {{game.player2.name}}
      {{/if}}
    </td>
    {{#each g in game.games}}
      <td class="tableCellTop">
        {{view 'gameResult' player=game.player2 g=g}}
      </td>
    {{/each}}
  </tr>
</table>
  """

App.GameView = App.RoundItemView.extend Ember.TargetActionSupport,
  template: Ember.Handlebars.compile App.templates.game
  classNames: ['roundItem']

  actions:
    tableClicked: ->
      if not App.editable
        @triggerAction
          action: 'openGameDetailView'
          actionContext: @get('game')
          target: @get('controller')

  round: (->
    @game?._round
  ).property("game._round")

  gameIndex: (->
    @game._round.items.indexOf @game
  ).property("game._round.items.@each")

  itemId: (->
    @game.getId()
  ).property("game._round.items.@each")


App.GameResultView = Em.View.extend
  template: Ember.Handlebars.compile """
    {{view 'numberField' value=view.result editable=App.editable}}
  """

  result: ((key, value) ->
    if @get("g.player1") is @get("player")
      index = "1"
    else
      index = "2"

    # SETTER
    if arguments.length > 1
      @get("g").set "result#{index}", value
    # GETTER
    return @get("g.result#{index}")
  ).property("player", "g.result1", "g.result2")
