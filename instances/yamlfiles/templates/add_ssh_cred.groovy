#!groovy

import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.*
import hudson.util.Secret
import java.nio.file.Files
import jenkins.model.Jenkins
import net.sf.json.JSONObject
import org.jenkinsci.plugins.plaincredentials.impl.*

// parameters
def jenkinsMasterKeyParameters = [
  description:  'Jenkins node SSH Key',
  id:           'jenkins-node-key',
  secret:       '',
  userName:     '${userName}',
  key:          new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource('''
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAt6a3N2XsOfWLcZVbZ9w7U0g3FVnq5ogvdXaDFrnWD8JeZ84f
1iGTSERHlQxcCzjicZ8eQ6Hqc9Iu9R2EhFsOxR2t6HARIT4xK7pf34UvqSmM4NQA
KoDhHVDd6Wxl0bAyjh4HEoat2jIRu4oP8mu3uM2e5wtivcyihmHyh35Iu4wnvbee
Cx4AKTigL7sTKF8tAjh1c27HIPYC6G+WHCfRoN1H6d7thxCtwu9VSvdyJeDU6xTa
ardkscdKRh/HpdtHhOEu2D7QI/mkiOja4BMxdxxyLYtdKtXnYIc+8+Bx9l5y2GAk
+Ez//InqWWAcxsSVmzvUGMVQtI1Y5C3WS2ZJ8wIDAQABAoIBAAdEKGGfvb35UiAX
Wbt9QjekVtGYcivW3ZHXM46VobuT5CpVRHszbuFgGjjyeT3UbVkzg34HjQAyI7t9
BH48IBR6fSQCMxtOm6FwSVTNrzoRM8q9eJg16zI+vdj7effW8dkfpQX9oClO69aw
urrLukQslonrsGd0DkYk3/SucXBCJRSRpDnruT2zmddHPekNjOsk7grMqO40e83L
maCZFB0yylcGAUH0cFGlmNFgQzVoJk1FhbPIUUzYcddTIgq5QPq0KXMoa1mXFbZ4
NeBOIxYUWnBlG2dGcj6dj1V7KmWGqEwPgzfTLDCodjQZ+X/rKpOHAqdEG/phJvsa
73+AIYECgYEA9FM9rni/P5O8HhYbTPmCUrDF7qcgoWvLjaztFvYfCh2JCoIvZu0m
taaTtX2DUPusmChqUJVrU8YU6wtjfdvxCwNXOZLkx1QyiY8pIQ0DneunXask+DCx
7BdAzZUkRjyJdPzt+CYYQsVQW1ndgpOtRIsatoCSwxUqlanEses6EbMCgYEAwG1E
pK5QnkiX5p3P1fNI3QORA9BIpS2ShAOXFsYy9t/x2rIw1LLSvcEkY8dsXwA1pfZR
Y+RNPh8oraRHEAwhwB0ehw9DFFyeZlk50UVJfZsckbhy2p9ThFBN2jbmCxPdsnUV
o9pcn50+m3sZZfu87ql+ZSUBj3M95tfjmmkYRsECgYEAsJYlQ5/D4midk0U5ECZZ
2fgn5rhmbiTh5xDv/yN+BaqZLL4xEnwe+TVfFtKTgYmVEhhL1thXzSGiZstBamr3
yZTtixAvSB4DtMaC3H9yeMYknh+fRb60KcYYsT21DQqd8q8IM80cxc2kqZHG9qRT
m/HKKdO9vz/iGm+sWUeBHd8CgYAPymexo+RVuNtOP3EIu5glGt/RkkwD0gON9cV2
RvlzrNjp+2lqaupETA8yaPEJsri0T8xKCDgWevQZm7uBI525aCpTJvt4NkmBWJ0Y
ATmQpyPnCV3TdvOhjf11hL/H9O9ib51A/vBO4NZ8Z9OjvM66PwpyPmEsZmaUBO9W
gn1NgQKBgQCytHWQ5m/WYqu/G7tdAvodR36JIf410ae9+fNCxqvWI6dEeSy1VX2b
5bPxekG6IJkSjZ7fE9/eCJg30Qn/7iaTPO5frniPfzpW4c7t8FX2TUHhL3wJxbR6
dUuxGB99SV94YRuCFeCZ4HhbHw8M1+ApnKnD5nm05Fkhkh+c8nFqfg==
-----END RSA PRIVATE KEY-----

''')
]

// get Jenkins instance
Jenkins jenkins = Jenkins.getInstance()

// get credentials domain
def domain = Domain.global()

// get credentials store
def store = jenkins.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

// define private key
def privateKey = new BasicSSHUserPrivateKey(
  CredentialsScope.GLOBAL,
  jenkinsMasterKeyParameters.id,
  jenkinsMasterKeyParameters.userName,
  jenkinsMasterKeyParameters.key,
  jenkinsMasterKeyParameters.secret,
  jenkinsMasterKeyParameters.description
)

// add credential to store
store.addCredentials(domain, privateKey)

// save to disk
jenkins.save()