App.templates.roundSetting = """

<div id="qualifierPopover" class="hide">
  <ul>
    {{#each qualifier in round.qualifiers}}
      <li>{{qualifier.name}}<br /></li>
    {{/each}}
  </ul>
</div>

<div class="roundName" {{action 'toggleSettings' target='view'}}>{{#if editable}}<i class="fa fa-edit"></i>{{/if}}&nbsp;{{round.name}}</div>

{{#if editable}}
<div id="settings">
<button type="button" class="close" {{action 'toggleSettings' target='view'}}><i class="fa fa-times-circle"></i></button>
  <form role="form" style="float: left">
    <div>
      <label style="">Name</label>
      {{input classNames="s form-control" value=round.name}}
    </div>
  </form>
  <form role="form" style="float: left">
    <div>
      <label>{{i18n.bracket.games}}</label>
      {{view 'numberField' classNames="form-control xs" editable=round.isEditable value=round.matchesPerGame}}
    </div>
  </form>
  <form role="form" style="float: left">
      <label>{{i18n.bracket.actions}}</label>
    <div>
    <button class="btn btn-inverse" {{action "shuffle" target="view"}}><i class="fa fa-random"></i>{{i18n.bracket.shuffle}}</button>
    <button class="btn btn-inverse" {{action "addItem" target="round"}}><i class="fa fa-plus"></i>{{round._itemLabel}}</button>
    </div>
  </form>
</div>
{{/if}}
"""

App.RoundSettingView = Em.View.extend
  template: Ember.Handlebars.compile App.templates.roundSetting
  classNames: ["roundSetting box"]
  round: null

  didInsertElement: ->
    @_super()
    if not @get('round.isEditable')
      @$("#settings").hide "medium"

  showSettings: (->
    if @get('round.isEditable')
      @$("#settings").show "medium"
    else
      @$("#settings").hide "medium"
  ).observes('round.isEditable')

  actions:
    toggleSettings: ->
      if App.editable
        if @$("#settings").is(":visible")
          @$("#settings").hide "medium"
        else
          @$("#settings").show "medium"
    shuffle: ->
      #someGamesCompleted = @get('round.games').some (game) -> game.get('isCompleted')
      # Warnung ausgeben, falls dadurch Ergebnisse verfallen
      if true
        App.Popup.showQuestion
          title: App.i18n.bracket.shufflePlayers
          bodyContent: App.i18n.bracket.shufflePlayersDescription
          onConfirm: =>
            @round.shuffle()
      else
        @round.shuffle()