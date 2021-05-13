pipeline {
  agent any

  environment {
    GIT_NAME = "eea.docker.plone"
  }

  parameters {
    string(defaultValue: '', description: 'Run tests with GIT_BRANCH env enabled', name: 'TARGET_BRANCH')
  }
  
  stages {
    stage('Build & Test') {
      steps {
        node(label: 'clair') {
          script {
            try {
              checkout scm
              sh '''docker build -t ${BUILD_TAG,,} .'''
              //sh '''TMPDIR=`pwd` clair-scanner --ip=`hostname` --clair=http://clair:6060 -t=Critical ${BUILD_TAG,,}'''
              sh '''docker run -d --name=${BUILD_TAG,,} ${BUILD_TAG,,} fg'''
              sh '''docker run -i --rm --link=${BUILD_TAG,,}:plone --name=${BUILD_TAG,,}-test --entrypoint /plone/instance/bin/zopepy ${BUILD_TAG,,} -c "from six.moves.urllib.request import urlopen; import time; time.sleep(15); con = urlopen('http://plone:8080'); print(con.read())"'''
              sh '''./test/run.sh ${BUILD_TAG,,}'''
            } finally {
              sh '''echo $(docker stop ${BUILD_TAG,,})'''
              sh '''echo $(docker rm -v ${BUILD_TAG,,})'''
              sh '''echo $(docker rmi ${BUILD_TAG,,})'''
            }
          }
        }
      }
    }
 
    stage('Release on tag creation') {
      when {
        buildingTag()
      }
      steps{
        node(label: 'docker') {
          withCredentials([string(credentialsId: 'eea-jenkins-token', variable: 'GITHUB_TOKEN'),  string(credentialsId: 'plone-trigger', variable: 'TRIGGER_MAIN_URL'), usernamePassword(credentialsId: 'jekinsdockerhub', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
           sh '''docker pull eeacms/gitflow; docker run -i --rm --name="$BUILD_TAG"  -e GIT_BRANCH="$BRANCH_NAME" -e GIT_NAME="$GIT_NAME" -e DOCKERHUB_REPO="eeacms/plone" -e GIT_TOKEN="$GITHUB_TOKEN" -e DOCKERHUB_USER="$DOCKERHUB_USER" -e DOCKERHUB_PASS="$DOCKERHUB_PASS"  -e TRIGGER_MAIN_URL="$TRIGGER_MAIN_URL" -e DEPENDENT_DOCKERFILE_URL="eea/eea.docker.plonesaas/blob/master/Dockerfile" -e GITFLOW_BEHAVIOR="RUN_ON_TAG" eeacms/gitflow'''
         }

        }
      }
    }


 }

  post {
    always {
      cleanWs(cleanWhenAborted: true, cleanWhenFailure: true, cleanWhenNotBuilt: true, cleanWhenSuccess: true, cleanWhenUnstable: true, deleteDirs: true)
    }
    changed {
      script {
        def url = "${env.BUILD_URL}/display/redirect"
        def status = currentBuild.currentResult
        def subject = "${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
        def summary = "${subject} (${url})"
        def details = """<h1>${env.JOB_NAME} - Build #${env.BUILD_NUMBER} - ${status}</h1>
                         <p>Check console output at <a href="${url}">${env.JOB_BASE_NAME} - #${env.BUILD_NUMBER}</a></p>
                      """

        def color = '#FFFF00'
        if (status == 'SUCCESS') {
          color = '#00FF00'
        } else if (status == 'FAILURE') {
          color = '#FF0000'
        }
      }
    }
  }
}
