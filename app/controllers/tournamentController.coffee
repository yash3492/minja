tournamentDao = require '../daos/tournamentDao'
chatDao = require '../daos/chatDao'
sports = require '../models/sports'
ControllerBase = require './controllerBase'
config = require "./../server-config"
request = require 'request'
_ = require 'underscore'
fs = require 'fs'
less = require 'less'
colorService = require '../services/colorService'
config = require '../server-config'

class TournamentController extends ControllerBase

  viewPrefix: "tournament"

  params:
    tid: (req, res, next, id) =>
      tournamentDao.findTournamentByIdentifier id, (tournament) =>
        if tournament
          if config.isDevelopment
            tournament.isOwner = true
          else
            tournament.isOwner = req.isAuthenticated() and tournament.user_id == req.user.id
          if req.isAuthenticated() and _.contains req.user.favorites, tournament.id
            tournament.isFavorite = true
          if tournament.publicName
            tournament.identifier = tournament.publicName
          else
            tournament.identifier = tournament.id

          req.tournament = tournament
          res.locals.tournament = tournament
          res.locals.title = tournament.name
          res.locals.navigation = @navigation req
          next()
        else
          res.status 404
          res.render "404"

  @navigation: (req) ->
    tournament = req.tournament
    id = tournament.identifier
    nav = [route: "info", icon: "info-circle", label: req.i18n.info.navName]
    if tournament.isOwner or tournament.members
      nav.push route: "participants", icon: "group", label: req.i18n.members.navName
    if tournament.isOwner or tournament.tree
      nav.push route: "bracket", icon: "sitemap fa-rotate-180", label: req.i18n.bracket.navName
    # if config.isDevelopment
    #   if tournament.isOwner or tournament.gallery
    #     nav.push route: "/#{id}/gallery", icon: "picture", label: req.i18n.gallery.navName
    nav.push route: "chat", icon: "wechat", label: req.i18n.chat.messageStream, xs: true
    if tournament.isOwner
      nav.push route: "settings", icon: "cog", label: req.i18n.settings.navName, xs: true

    for navItem in nav
      navItem.selectedClass = "active" if req.url.indexOf(navItem.route) isnt - 1
    nav

  "/tournaments": (req, res) =>
    res.render "tournaments"

  "/tournament/create": [@ensureAuthenticated, (req, res) ->
    res.locals.sports = sports
    res.render "#{@viewPrefix}/create"
  ]

  "/tournament/checkPublicName": (req, res) =>
    publicName = req.param "publicName"
    tournamentDao.checkPublicName publicName, (isAvailable) ->
      res.send isAvailable

  "POST:/tournament/create": [@ensureAuthenticated, (req, res) ->
    newTournament =
      info:
        name: req.param "name"
      sport: req.param "sport"
      user_id: req.user.id

    tournamentDao.save newTournament, (result) =>
      message =
        tournament_id: result.id
        text: req.i18n.chat.tournamentCreated
        authorType: chatDao.authorTypes.leader
      chatDao.save message, ->
      res.redirect "#{result.id}/info"
  ]

  renderTournament: (req, res) ->
    req.tournament.settings =
      colors: colorService.getColors req.tournament
      hasLogo: req.tournament.hasLogo
    res.locals.sport = if req.tournament.sport then sports[req.tournament.sport] else sports.other
    paginator =
      first: 0
      limit: 100
    chatDao.findMessagesByTournamentId req.tournament.id, req.i18n, paginator, (messages) =>
      res.render "#{@viewPrefix}/index",
        isOwner: req.tournament.isOwner
        hasLogo: req.tournament.hasLogo
        messages: messages
        isProduction: config.isProduction

  "/:tid": (req, res) =>
    @renderTournament req, res

  "/:tid/info": (req, res) =>
    @renderTournament req, res

  "/:tid/info/edit": (req, res) =>
    @renderTournament req, res

  "/:tid/participants": (req, res) =>
    @renderTournament req, res

  "/:tid/participants/edit": (req, res) =>
    @renderTournament req, res

  "/:tid/tree": (req, res) =>
    res.redirect "/#{req.params.tid}/bracket"

  "/:tid/bracket": (req, res) =>
    @renderTournament req, res

  "/:tid/bracket/edit": (req, res) =>
    @renderTournament req, res

  "/:tid/dashboard": (req, res) =>
    @renderTournament req, res

  "/:tid/settings": (req, res) =>
    @renderTournament req, res

  "/:tid/gallery": (req, res) =>
    if req.tournament.isOwner and not req.tournament.gallery?
      @redirectToEdit req, res
    res.render "#{@viewPrefix}/gallery",
      editable: false

  "/:tid/chat": (req, res) =>
    @renderTournament req, res

  "/:tid/image/:imageId": (req, res) =>
    url = config.DB_URL + "/tournaments/#{req.params.tid}/image/#{req.params.imageId}"
    request(url: url).pipe(res)

  "/:tid/logo/display": (req, res) =>
    url = config.DB_URL + "/tournaments/#{req.params.tid}/logo"
    request(url: url).pipe(res)

  "/:tid/messages": (req, res) =>
    paginator =
      first: req.param "first" or 0
      limit: req.param "limit" or 5
    chatDao.findMessagesByTournamentId req.tournament.id, req.i18n, paginator, (messages) ->
      res.send messages

  "POST:/:tid/messages/create": (req, res) =>
    message = req.param "message"
    if not message.text then return
    message.tournament_id = req.tournament.id

    if req.tournament.isOwner
      message.authorType = chatDao.authorTypes.leader
    else
      message.authorType = chatDao.authorTypes.guest

    chatDao.save message, (result) ->
      chatDao.findById result.id, req.i18n, (message) ->
        res.send message

  "/:tid/tournament_colors.css": (req, res) =>
    path = config.CLIENT_DIR + "/less/colors_template.less"
    colors = colorService.getColors req.tournament
    contentOpaque = colorService.opaque colors.content
    linkColor = colorService.generateLinkColor colors
    prefix = """
      @normal: #{colors.content};
      @textColor: #{colors.contentText};
      @light: #{colors.background};
      @dark: #{colors.footer};
      @footerText: #{colors.footerText};
      @normalOpaque: #{contentOpaque};
    """

    fs.readFile path, "utf8", (err, data) ->
      if err then throw err
      data = prefix.concat data
      less.render data, (err, css) ->
        if err then throw err
        res.header "Content-type", "text/css"
        res.send css

  "/:tid/colors": (req, res) =>
    colors = colorService.getColors req.tournament
    res.send colors

module.exports = new TournamentController()
