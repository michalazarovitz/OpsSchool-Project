#!groovy

import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.domains.Domain
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret
import com.cloudbees.plugins.credentials.CredentialsScope

def jenkins = Jenkins.getInstance()

def domain = Domain.global()
def store = jenkins.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

def slackCredentialParameters = [
  description:  'Slack Jenkins integration token',
  id:           'slack-token',
  secret:       'dZDfzhctQQJlarMmscSmG0Gx'
]

def secretText = new StringCredentialsImpl(
  CredentialsScope.GLOBAL,
  slackCredentialParameters.id,
  slackCredentialParameters.description,
  Secret.fromString(slackCredentialParameters.secret)
)
  
store.addCredentials(domain, secretText)

def slack = jenkins.getDescriptorByType(jenkins.plugins.slack.SlackNotifier.DescriptorImpl.class)
// slack.setBaseUrl - only needed for slack compatible applications e.g. Mattermost
slack.setTeamDomain('OpsSchool')
slack.setTokenCredentialId(slackCredentialParameters.id)
slack.setBotUser(false )
slack.setRoom('UNX1CC18R')

slack.save()
jenkins.save()
