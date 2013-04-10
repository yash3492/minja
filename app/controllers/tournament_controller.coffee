tournamentDao = require '../dao/TournamentDao'
chatDao = require '../dao/ChatDao'
Sport = require '../model/sport'
ControllerBase = require './controller_base'
config = require "./../server-config"
request = require 'request'
_ = require 'underscore'

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
          res.render "404"

  @navigation: (req) ->
    tournament = req.tournament
    id = tournament.identifier
    nav = [route: "/#{id}/info", icon: "info-sign", label: req.i18n.info.navName]
    if tournament.isOwner or tournament.members
      nav.push route: "/#{id}/members", icon: "group", label: req.i18n.members.navName
    if tournament.isOwner or tournament.tree
      nav.push route: "/#{id}/tree", icon: "table", label: req.i18n.tree.navName
    if config.isDevelopment
      if tournament.isOwner or tournament.gallery
        nav.push route: "/#{id}/gallery", icon: "picture", label: req.i18n.gallery.navName
    
    for navItem in nav
      navItem.selectedClass = "active" if req.url.indexOf(navItem.route) != -1
    nav

  "/tournaments": (req, res) =>
    res.render "tournaments"

  "/tournament/create": [@ensureAuthenticated, (req, res) ->
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
      user_id: req.user.id

    tournamentDao.save newTournament, (result) =>
      message =
        tournament_id: result.id
        text: req.i18n.chat.tournamentCreated
        authorType: chatDao.authorTypes.leader
      chatDao.save message, ->
      res.redirect "#{result.id}/info"
  ]

  "/:tid": (req, res) =>
    res.render "#{@viewPrefix}/dashboard"

  "/:tid/info": (req, res) =>
    if req.tournament.isOwner and not req.tournament.info.description?
      @redirectToEdit req, res
    res.render "#{@viewPrefix}/info"

  "/:tid/members": (req, res) =>
    if req.tournament.isOwner and not req.tournament.members?
      @redirectToEdit req, res
    res.render "#{@viewPrefix}/members"

  "/:tid/tree": (req, res) =>
    if req.tournament.isOwner and not req.tournament.tree?
      @redirectToEdit req, res
    res.locals.sports = Sport.values
    res.render "#{@viewPrefix}/tree",
      editable: false

  "/:tid/dashboard": (req, res) =>
    res.render "#{@viewPrefix}/dashboard"

  "/:tid/gallery": (req, res) =>
    if req.tournament.isOwner and not req.tournament.gallery?
      @redirectToEdit req, res
    res.render "#{@viewPrefix}/gallery",
      editable: false

  "/:tid/image/:imageId": (req, res) =>
    url = config.DB_URL + "/tournaments/#{req.params.tid}/image/#{req.params.imageId}"
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

    chatDao.save message, ->
      res.send "ok"

module.exports = new TournamentController()
