pipeline {
  agent any
  environment {
    GIT = credentials('github')
  }
  stages {
    stage('Prerequisites') {
      steps {
        sh '/usr/local/bin/pod install --repo-update'
      }
    }
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace Gini-iOS-SDK.xcworkspace -scheme "GiniSDK Example" -destination \'platform=iOS Simulator,name=iPhone 6\''
      }
    }
    stage('Unit tests') {
      steps {
        sh 'xcodebuild test -workspace Gini-iOS-SDK.xcworkspace -scheme "Gini-iOS-SDKTests" -destination \'platform=iOS Simulator,name=iPhone 6\''
      }
    }
    stage('Documentation') {
      when {
        branch 'master'
        expression {
            def tag = sh(returnStdout: true, script: 'git tag --contains $(git rev-parse HEAD)').trim()
            return !tag.isEmpty()
        }
      }
      steps {
        withEnv(["PATH+=/usr/local/bin"]) {
            sh 'scripts/build-documentation-sphinx.sh'
            sh 'scripts/build-documentation-api.sh'
        }
        sh 'scripts/push-documentation.sh $GIT_USR $GIT_PSW'
      }
    }
    stage('Pod lint') {
      when {
        branch 'master'
        expression {
            def tag = sh(returnStdout: true, script: 'git tag --contains $(git rev-parse HEAD)').trim()
            return !tag.isEmpty()
        }
      }
      steps {
        sh '/usr/local/bin/pod lib lint --allow-warnings'
      }
    }
  }
}
