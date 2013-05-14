# Description:
#   Allows Hubot to store a recent chat history for services like IRC that
#   won't do it for you.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_HISTORY_LINES
#   HUBOT_LOG_SERVER_HOST
#   HUBOT_LOG_SERVER_TOKEN
#
# Commands:
#   hubot show history [<lines>] - Shows <lines> of history, otherwise all history
#   hubot clear history - Clears the history
#
# Author:
#   wubr (modified for IRC by mattetti, modified to log to separate server by parkr)

http        = require('http')
querystring = require('querystring')

class History
  constructor: (@robot, @keep) ->
    @cache = {}

  add: (room, event) ->
    if process.env.HUBOT_LOG_SERVER_TOKEN? and process.env.HUBOT_LOG_SERVER_HOST?
      process.nextTick ->
        console.log("SENDING MESSAGE To #{process.env.HUBOT_LOG_SERVER_HOST}...")
        data = querystring.stringify
          access_token: process.env.HUBOT_LOG_SERVER_TOKEN,
          room:  room,
          text:  event.message,
          author: event.name,
          time:  event.time.toUTCString()

        opts =
          host: process.env.HUBOT_LOG_SERVER_HOST,
          port: 80,
          path: "/api/messages/log",
          method: 'POST',
          headers:
            'Content-Type': 'application/x-www-form-urlencoded',
            'Content-Length': data.length

        try
          console.log("Logging that #{data['author']} said '#{data['text']} at #{data['time']} in #{data['room']}'")
          req = http.request opts, (res) ->
            res.setEncoding('utf8')
            res.on 'data', (chunk) ->
              console.log("Response: #{chunk}")

          req.on 'error', (e) ->
            console.error(e)

          req.write(data)
          req.end()
        catch e
          console.error(e)

class HistoryEntry
  constructor: (@room, @name, @message) ->
    @time = new Date()
    @hours = @time.getHours()
    @minutes = @time.getMinutes()
    if @minutes < 10
      @minutes = '0' + @minutes

module.exports = (robot) ->

  options =
    lines_to_keep:  process.env.HUBOT_HISTORY_LINES

  unless options.lines_to_keep
    options.lines_to_keep = 50

  history = new History(robot, options.lines_to_keep)

  robot.hear /(.*)/i, (msg) ->
    historyentry = new HistoryEntry(msg.message.room, msg.message.user.name, msg.match[1])
    history.add msg.message.room, historyentry
