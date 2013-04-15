App.templates.gamesDetail = """
  <div class="roundItemTitle">
    <div class="roundItemTitleLabel">
      {{#if view.roundItem}}
        <span class="carousel-control left noPrint" title="previous" {{action "navigateToLeft" target="view"}}>
          <i class="icon-arrow-left"></i>
        </span>
        
        {{view.roundItem.name}}

        <span class="carousel-control right noPrint" title="next" {{action "navigateToRight" target="view"}}>
          <i class="icon-arrow-right"></i>
        </span>
      {{/if}}
    </div>
    <div class="noPrint actionButtons">
      <span title="print" class="carousel-control printView" {{action "printView" target="view"}}>
        <i class="icon-print"></i>
      </span><!--
      <span title="prefill Attributes" class="carousel-control prefillAttributesView" {{action "prefillAttributes" target="view"}}>
        <i class="icon-ok"></i>
      </span>-->
    </div>
  </div>

{{#if view.table}}
  <fieldset>
    <legend>{{App.i18n.table}}</legend>

    <table class="table table-striped tableTable" style="max-width: 800px; margin: 0 auto;">
      <thead>
        <tr>
          <th>{{App.i18n.rank}}</th>
          <th>Name</th>
          <th>{{App.i18n.games}}</th>
          <th>{{App.i18n.goals}}</th>
          <th>{{App.i18n.goalsAgainst}}</th>
          <th>{{App.i18n.difference}}</th>
          <th>{{App.i18n.points}}</th>
        </tr>
      </thead>
      <tbody>
        {{#each view.roundItem.table}}
          {{#if qualified}}
            <tr class="player qualified" >
          {{else}}
            <tr class="player">
          {{/if}}
          <td class="tableCell">
            {{rank}}.
          </td>
          <td class="tableCell reallyNoPadding">
            {{view App.DynamicTextField valueBinding="player.name" editableBinding="player.editable"}}
          </td>
          <td class="tableCell">{{games}}</td>
          <td class="tableCell">{{goals}}</td>
          <td class="tableCell">{{goalsAgainst}}</td>
          <td class="tableCell">{{difference}}</td>
          <td class="tableCell"><b>{{points}}</b></td>
        </tr>
        {{/each}}
      </tbody>
    </table>
  </fieldset>
  <br />
{{/if}}
  <fieldset>
    <legend>{{App.i18n.schedule}}

      <span style="float:right" class="noPrint">
        {{view Em.TextField valueBinding="view.gameFilter" placeholder="Filter ..."}}
      </span>
    </legend>
    <table class="table table-striped">
      <thead>
        <tr>
          <th width="70px"></th>
          <th></th>
          <th>{{App.i18n.home}}</th>
          <th>{{App.i18n.guest}}</th>
          {{#each attribute in App.Tournament.gameAttributes}}
            <th>{{attribute.name}}</th>
          {{/each}}
          <th>{{App.i18n.result}}</th>
        </tr>
      </thead>
      {{#each matchday in view.filteredGames}}
        <tr><td colspan="15" class="roundSeperator">{{matchday.matchDay}}. {{App.i18n.matchday}}</td></tr>
        {{#each game in matchday.games}}
          <tr>
            <td></td>
            <td>{{game._roundItemName}}</td>
            <td>
              {{game.player1.name}}
            </td>
            <td>
              {{game.player2.name}}
            </td>
            {{#each attribute in App.Tournament.gameAttributes}}
              {{view App.GameAttributeValueView attributeBinding="attribute" gameBinding="game"}}
            {{/each}}
            <td>
            {{#if App.editable}}
                {{view App.NumberField editableBinding="App.editable" valueBinding="game.result1"}}
                :
                {{view App.NumberField editableBinding="App.editable" valueBinding="game.result2"}}
            {{else}}
              {{game.result1}} : {{game.result2}}
            {{/if}}
            </td>
          </tr>
        {{/each}}
      {{/each}}
    </table>
    <div style="text-align: right" class="noPrint"><em>{{view.gamesCount}} {{App.i18n.games}}</em></div>
  </fieldset>
"""

App.GamesDetailView = App.DetailView.extend
  template: Ember.Handlebars.compile App.templates.gamesDetail
  gameFilter: ""

  printView: ->
    window.print()

  gamesCount: (->
    @get('filteredGames').reduce (count, matchDay) ->
      count += matchDay.games.length
    , 0
  ).property("filteredGames")
