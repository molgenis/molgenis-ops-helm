# Description:
#   Rol preview instanties uit op het dev cluster.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_JENKINS_URL
#   HUBOT_JENKINS_AUTH
#   HUBOT_REGISTRY_URL
#
#   Auth should be in the "user:password" format.
#   password can be a token (which can be obtainined from the jenkins user configuration)
#
# Commands:
#   hubot preview list - Welke preview omgevingen staan er allemaal gedeployed
#   hubot preview delete <tag> - Verwijder de preview environment voor deze tag
#   hubot preview <tag> - Deploy een molgenis preview environment voor deze tag
#
# Author:
#   fdlk

querystring = require "querystring"

callback = (onSuccess, ifNotFound) -> (err, res, body) ->
  if err
    console.log("Something went wrong:\n```#{err}```")
  else if 200 <= res.statusCode < 400
    onSuccess(body)
  else if 404 == res.statusCode
    ifNotFound()
  else
    console.log("Something went wrong\n```#{res.statusCode} #{body}```")

createRequest = (msg, url) ->
  req = msg.http(url)
  if url.startsWith(process.env.HUBOT_JENKINS_URL) && process.env.HUBOT_JENKINS_AUTH
    auth = new Buffer(process.env.HUBOT_JENKINS_AUTH).toString("base64")
    req.headers Authorization: "Basic #{auth}"
  req.header("Content-Length", 0)
  return req

runPreviewJob = (msg, action, tag, onSuccess) ->
  url = "#{process.env.HUBOT_JENKINS_URL}/job/preview/buildWithParameters?ACTION=#{action}&TAG=#{querystring.escape(tag)}"
  req = createRequest msg, url
  req.post() callback(onSuccess, -> msg.reply "Ik verwacht een parameterized preview job in Jenkins, misschien kan een echt mens die even configureren.")

searchRegistry = (msg, params, ifFound, ifNotFound) ->
  req = createRequest msg, "#{process.env.HUBOT_REGISTRY_URL}service/rest/v1/search?repository=docker&name=molgenis%2Fmolgenis-app&#{params}"
  req.get() callback((body) ->
    items = JSON.parse(body).items
    if items && items.length
      ifFound(items)
    else
      ifNotFound()
  , ->
    ifNotFound())

listPreview = (msg) -> runPreviewJob msg, "list", null, -> msg.reply "Ik ga even voor je kijken ..."

deletePreview = (msg) ->
  tag = msg.match[1].replace(/`/g, '')
  runPreviewJob msg, "delete", tag, () ->
    cleanDeskPolicy = if Math.random() < 0.1 then "\nHet is belangrijk je bureau een beetje schoon te houden :innocent:" else ""
    msg.reply "Ik ga `#{tag}` voor je opruimen...#{cleanDeskPolicy}"

installPreview = (msg) ->
  tag = msg.match[1].replace(/`/g, '')
  searchRegistry msg, "version=#{querystring.escape(tag)}"
  , ->
    runPreviewJob msg, "install", tag, -> msg.reply "Ik ga `#{tag}` voor je klaarzetten..."
  , ->
    searchRegistry msg, "q=#{tag}"
    , (items) ->
      versions = items.map (item) -> item.version
      msg.reply "Tag `#{tag}` kan ik niet vinden, maar wel: `#{versions.join("`,`")}`"
    , ->
      msg.reply "Tag `#{tag}` kan ik niet vinden, en ook niets wat erop lijkt :thinking_face:"

module.exports = (robot) ->
  robot.respond /preview delete (.+)/i, (msg) -> deletePreview(msg)
  robot.respond /preview list/i, (msg) -> listPreview(msg)
  robot.respond /preview (?!delete|list)(.+)/i, (msg) -> installPreview(msg)