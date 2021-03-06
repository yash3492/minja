App.FilterButtonView = Ember.View.extend
  classNames: ['btn-group']
  content: []
  value: null

  template: Ember.Handlebars.compile """
      <button type="button" class="btn btn-inverse dropdown-toggle noPrint" data-toggle="dropdown">
        <i class="fa fa-filter"></i>{{view.buttonLabel}} <span class="caret"></span>
      </button>
      <ul class="dropdown-menu" role="menu">
        {{#each view.content}}
          <li><a {{action "select" this target="view"}} href="#">{{label}}</a></li>
        {{/each}}
      </ul>
  """

  init: ->
    @_super()
    @set 'buttonLabel', ''

  actions:
    select: (selected) ->
      @set 'buttonLabel', selected.label
      @set 'value', selected.id

