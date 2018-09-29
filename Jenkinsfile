pipeline {
    agent {
        kubernetes {
            label 'helm'
        }
    }
    stages {
        stage('Test') {
            steps {
                container('chart-testing') {
                    sh "chart_test.sh --no-install --all"
                }
            }
        }
    }
}