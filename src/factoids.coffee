# Description:
#   A better implementation of factoid support for your hubot.
#   Supports history (in case you need to revert a change), as
#   well as factoid popularity, aliases and @mentions.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_FACTOID_PREFIX - prefix character to use for retrieving a factoid (! is the default)
#   HUBOT_BASE_URL - URL of Hubot (ex. http://myhubothost.com:5555/)
#
# Commands:
#   hubot factoid learn <factoid> = <details> - learn a new factoid
#   hubot factoid learn <factoid> =~ s/expression/replace/gi - edit a factoid
#   hubot factoid alias <factoid> = <factoid>
#   hubot factoid forget <factoid> - forget a factoid
#   hubot factoid remember <factoid> - remember a factoid
#   hubot factoid drop <factoid> - permanently forget a factoid
#   hubot factoid(s) - get a link to the raw factoid data
#   hubot factoid list( all factoids) - list all factoids
#   hubot factoid search <substring> - list factoids which match (by factoid key or result)
#   !<factoid> - play back a factoid
#
# Author:
#   therealklanni

Factoids = require './factoids-core'

module.exports = (robot) ->
  @factoids = new Factoids robot
  robot.router.get "/#{robot.name}/factoids", (req, res) =>
    res.end JSON.stringify @factoids.data, null, 2

  prefix = process.env.HUBOT_FACTOID_PREFIX or '!'

  robot.hear new RegExp("^[#{prefix}]([\\w\\s-]{2,}\\w)( @.+)?", 'i'), (msg) =>
    fact = @factoids.get msg.match[1]
    to = msg.match[2]
    if not fact? or fact.forgotten
      msg.reply "Not a factoid"
    else
      fact.popularity++
      to ?= msg.message.user.name
      msg.send "#{to.trim()}: #{fact.value}"

  robot.respond new RegExp("[#{prefix}]([\\w\\s-]{2,}\\w)", 'i'), (msg) =>
    fact = @factoids.get msg.match[1]
    if not fact? or fact.forgotten
      msg.reply "Not a factoid"
    else
      fact.popularity++
      msg.send "#{fact.value}"

  robot.respond /factoid learn (.{3,}) = ([^@].+)/i, (msg) =>
    [key, value] = [msg.match[1], msg.match[2]]
    factoid = @factoids.set key, value, msg.message.user.name

    if factoid.value?
      msg.reply "OK, #{key} is now #{factoid.value}"

  robot.respond /factoid learn (.{3,}) =~ s\/(.+)\/(.+)\/(.*)/i, (msg) =>
    key = msg.match[1]
    re = new RegExp(msg.match[2], msg.match[4])
    fact = @factoids.get key
    value = fact?.value.replace re, msg.match[3]

    factoid = @factoids.set key, value, msg.message.user.name if value?

    if factoid? and factoid.value?
      msg.reply "OK, #{key} is now #{factoid.value}"
    else
      msg.reply 'Not a factoid'

  robot.respond /factoid forget (.{3,})/i, (msg) =>
    if @factoids.forget msg.match[1]
      msg.reply "OK, forgot #{msg.match[1]}"
    else
      msg.reply 'Not a factoid'

  robot.respond /factoid remember (.{3,})/i, (msg) =>
    factoid = @factoids.remember msg.match[1]
    if factoid? and not factoid.forgotten
      msg.reply "OK, #{msg.match[1]} is #{factoid.value}"
    else
      msg.reply 'Not a factoid'

  robot.respond /factoid list( all)?( factoids)?/i, (msg) =>
    all = @factoids.getAll()
    out = ''

    if not all? or Object.keys(all).length is 0
      msg.reply "No factoids defined"
    else
      for f of all
        out += prefix + f + ': ' + all[f] + "\n"
      msg.reply "All factoids: \n" + out

  robot.respond /factoids?$/i, (msg) =>
    url = process.env.HUBOT_BASE_URL or "http://not-yet-set/"
    msg.reply "#{url.replace /\/$/, ''}/#{robot.name}/factoids"

  robot.respond /factoid search (.{3,})/i, (msg) =>
    factoids = @factoids.search msg.match[1]

    if factoids.length > 0
      found = prefix + factoids.join("*, *#{prefix}")
      msg.reply "Matched the following factoids: *#{found}*"
    else
      msg.reply 'No factoids matched'

  robot.respond /factoid alias (.{3,}) = (.{3,})/i, (msg) =>
    who = msg.message.user.name
    alias = msg.match[1]
    target = msg.match[2]
    msg.reply "OK, aliased #{alias} to #{target}" if @factoids.set msg.match[1], "@#{msg.match[2]}", msg.message.user.name, false

  robot.respond /factoid drop (.{3,})/i, (msg) =>
    user = msg.envelope.user
    isAdmin = robot.auth?.hasRole(user, 'factoids-admin') or robot.auth?.hasRole(user, 'admin')
    if isAdmin or not robot.auth?
      factoid = msg.match[1]
      if @factoids.drop factoid
        msg.reply "OK, #{factoid} has been dropped"
      else msg.reply "Not a factoid"
    else msg.reply "You don't have permission to do that."
