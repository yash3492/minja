class Tournament extends require './mixIn'
  publicName: ""
  user_id: ""
  sport_id: ""
  gallery: {}
  info:
    name: ""
    description: ""
    venue: ""
    startDate: ""
    startTime: ""
    host: ""
    hostMail: ""
  members:
    members: []
    membersAttributes: []
  tree: null
  colors:
    default: true

module.exports = Tournament
