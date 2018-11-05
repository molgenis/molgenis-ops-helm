# Hubot
This chart is used to deploy a Hubot for ChatOps.
It is a simple configuration wrapper around the [`stable/hubot`](https://github.com/helm/charts/tree/master/stable/hubot) chart.

## Slack integration
Uses the [Hubot Slack adapter](https://slackapi.github.io/hubot-slack/) to
integrate with Slack.
Requires that the Hubot app is installed in Slack.

## Jenkins integration
Requires that the [`hubot-steps-plugin`](https://github.com/jenkinsci/hubot-steps-plugin) is
installed in Jenkins.
Configure it with the kubernetes DNS for the service, e.g.
`http://molgenis-hubot.molgenis-hubot.svc`

## Configuration
### Environment variables
Environment variables can be defined in `hubot.hubot.config`
#### `HUBOT_JENKINS_URL`
Location of the jenkins server.
#### `HUBOT_REGISTRY_URL`
Location of the nexus registry server.
#### `HUBOT_JENKINS_AUTH`
Create a [Jenkins authorization token](https://jenkins.dev.molgenis.org/me/configure) so hubot can
authenticate with Jenkins.
Go to the config map of the hubot in Kubernetes and fill it in in the form `user:token`.
It would be better if this token was also a secret but that would require changing the subchart.

### Scripts
`hubot.hubot.scripts` includes jenkins chatops scripts copied from [`https://github.com/jenkinsci/hubot-steps-plugin/tree/master/scripts`](https://github.com/jenkinsci/hubot-steps-plugin/tree/master/scripts).
You can add your own scripts here.

### Tokens
#### `hubot.hubot.slackToken`
Create a [Slack token](https://slackapi.github.io/hubot-slack/#getting-a-slack-token) so hubot
can join the Slack channel. 
Will be made available as `HUBOT_SLACK_TOKEN` into the environment.