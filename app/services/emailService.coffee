email = require "emailjs"
config = require "../server-config"

class EmailService

  sendPasswordRecoveryEmail: (user, secret, callback) ->
    subject = "Minja Tournament Manager lost password"
    text = """
      Click the following link to recover your password:
      #{config.ROOTPATH}/user/recoverpassword?user=#{user._id}&secret=#{secret}
    """
    @send user.email, subject, text, callback

  sendWelcomeEmail: (to, password, callback) ->
    subject = 'Welcome to Minja Tournament Manager!'
    # News and updates on our developer blog: http://tournament-manager.blogspot.de/
    text = """
      Welcome to minja!

      your password is: #{password}
      create a tournament: #{config.ROOTPATH}/tournament/create

      Let us know if you have any issues or questions. Just
      respond to this email.
    """

    @send to, subject, text, callback

  send: (to, subject, text, callback) ->
    server = email.server.connect
      user: config.EMAIL_USER
      password: config.EMAIL_PASSWORD
      host: config.EMAIL_HOST
      ssl: config.EMAIL_SSL

    server.send
      text: text
      from: config.EMAIL_FROM
      to: to
      cc: ''
      subject: subject
    , callback


module.exports = new EmailService()
