App.DynamicTypeAheadTextFieldView = Em.TextField.extend
  attribute: null
  classNames: ['l']

  focusIn: ->
    @_super()
    values = (game[@attribute.id] for game in App.tournament.bracket.get("games"))
    @$().typeahead
      source: _.uniq _.compact values
