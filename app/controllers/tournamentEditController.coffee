fs = require 'fs'
tournamentDao = require '../daos/tournamentDao'
chatDao = require '../daos/chatDao'
sports = require '../models/sports'
moment = require 'moment'
ControllerBase = require './controllerBase'
config = require '../server-config'
colorService = require '../services/colorService'
Tournament = require '../models/tournament'
_ = require "underscore"
gm = require 'gm'
gm = gm.subClass({ imageMagick: true })

class TournamentEditController extends ControllerBase

  viewPrefix: "tournament"

  before: (req, res, next) ->
    if config.isProduction
      if not req.isAuthenticated()
        res.redirect "/user/login?next=#{req.path}"
        return
      if req.user.id isnt req.tournament.user_id
        res.redirect "/"
    next()

  "POST:/:tid/participants/edit": (req, res) =>
    t = req.tournament
    t.members = req.body
    # console.log Tournament.validate t
    tournamentDao.merge req.tournament.id, members: req.body, ->
      res.send "ok"

  "POST:/:tid/info/edit": (req, res) =>
    tournamentDao.merge req.tournament.id, info: req.body, ->
      res.send "ok"

  "/:tid/tree/edit": (req, res) =>
    res.redirect "/#{req.params.tid}/bracket/edit"

  "POST:/:tid/bracket/edit": (req, res) =>
    {tree, members} = req.body
    members =
      members: members
      membersAttributes: req.tournament.members?.membersAttributes
    tournamentDao.merge req.tournament.id, members: members, ->
      tournamentDao.merge req.tournament.id, tree: tree, ->
        res.send "ok"

  "/:tid/gallery/edit": (req, res) =>
    if not req.tournament.gallery?
      res.addInfo req.i18n.infoAlert.gallery
    res.render "#{@viewPrefix}/gallery",
      editable: true

  "POST:/:tid/gallery/edit": (req, res) =>
    req.body = {} if req.body.empty?
    tournamentDao.merge req.tournament.id, gallery: req.body, (result) ->
      tournamentDao.mergeImages result, req.tournament._attachments, req.body, req.files, ->
        res.send "ok"

  "/:tid/duplicate": (req, res) =>
    newTournament =
      info: req.tournament.info
      user_id: req.user.id
      members: req.tournament.members
      tree: req.tournament.tree
      gallery: req.tournament.gallery
    newTournament.info.name += " [#{req.i18n.copied}]"
    tournamentDao.save newTournament, =>
      res.redirect "/me/tournaments"

  "/:tid/remove": (req, res) =>
    tournamentDao.remove req.tournament.id, req.tournament.rev, ->
      res.redirect "/me/tournaments"

  "POST:/:tid/messages/remove": (req, res) =>
    chatDao.remove req.param("id"), req.param("rev"), ->
      res.send "ok"

  "POST:/:tid/savePublicName": (req, res) =>
    publicName = req.param("publicName").toLowerCase()
    # if req.tournament.publicName then res.send 500
    tournamentDao.checkPublicName publicName, (isAvailable) ->
      if isAvailable
        tournamentDao.merge req.tournament.id, publicName: publicName, ->
          res.send "ok"
      else
        res.send 500

  "/:tid/logo": (req, res) =>
    hasLogo = req.tournament.hasLogo == true

    res.render "#{@viewPrefix}/settings",
      hasLogo: hasLogo

  "POST:/:tid/logo": (req, res) =>
    if req.param("save")
      hasLogo = req.tournament.hasLogo is true
      logoFile = req.files['logo']

      if logoFile.size is 0
        res.addError "No image specified"
      else if logoFile.type not in ["image/png", "image/jpg", "image/jpeg", "image/gif"]
        res.addError "Image must be of type png, jpg, or gif"
      if res.locals.errors?
        return res.redirect "/#{req.tournament.id}/settings"

      logo = gm logoFile.path
      logo.resize(200).toBuffer (err, buffer) =>
        if err then throw err
        logoImage =
          name: 'logo'
          contentType: logoFile.type
          body: buffer
        tournamentDao.saveAttachments [logoImage], req.tournament, =>
          tournamentDao.merge req.tournament.id, hasLogo: true, =>
            res.redirect "/#{req.tournament.id}/settings"
    else
      tournamentDao.merge req.tournament.id, hasLogo: false, =>
        tournamentDao.removeAttachments req.tournament, ["logo"], =>
          res.redirect "/#{req.tournament.id}/settings"

  "POST:/:tid/settings/colors": (req, res) =>
    if colorService.isDefaultColor req.body
      req.body = null
    tournamentDao.merge req.tournament.id, colors: req.body, =>
      res.redirect "/#{req.tournament.id}/settings"

module.exports = new TournamentEditController()
