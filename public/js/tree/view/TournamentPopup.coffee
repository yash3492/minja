tournamentViewTemplate = """
<form class="form-horizontal">
  <fieldset>
    <legend>Spieleinstellung</legend>

  <div class="control-group">
    <label class="control-label" for="pointsPerWin">Punkte/Sieg</label>
    <div class="controls">
      {{view App.NumberField id="pointsPerWin" valueBinding="tournament.winPoints"}}
    </div>
  </div>
  <div class="control-group">
    <label class="control-label" for="pointsPerDraw">Punkte/Unentschieden</label>
    <div class="controls">
      {{view App.NumberField id="pointsPerDraw" valueBinding="tournament.drawPoints"}}
    </div>
  </div>
  </fieldset>

  <fieldset>
    <legend>Spiele-Attribute</legend>
    <table class="table">
      <tr>
        <th>Name</th>
        <th>Typ</th>
        <th></th>
      </tr>
      {{#each gameAttribute in App.Tournament.gameAttributes}}
      <tr>
        <td>{{view App.DynamicTextField valueBinding="gameAttribute.name"}}</td>
        <td>{{view Ember.Select contentBinding="App.attributeTypes" 
          optionValuePath="content.id" 
          optionLabelPath="content.label" valueBinding="gameAttribute.type"}}</td>
        <td><i class="icon-remove" rel="tooltip" title="Delete" {{action "remove" target="gameAttribute"}}></i>
        </td>
      </tr>
      {{/each}}
    </table>
  <span class='btn btn-link' {{action "addAttribute"}}>Add Attribute</span>
  </fieldset>
</form>
"""
App.TournamentPopup = Em.View.create(
  template: Ember.Handlebars.compile tournamentViewTemplate
  classNames: ["hide"]
  tournamentBinding: "App.Tournament"

  show: ->
    @$().show()
    App.Popup.show
      title: "Turnierbaum-Einstellungen"
      bodyContent: @$()[0]

  addAttribute: ->
    App.Tournament.gameAttributes.pushObject App.GameAttribute.create()

).appendTo("body")