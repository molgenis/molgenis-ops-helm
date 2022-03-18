pipeline {
    agent {
        kubernetes {
            // the shared pod template defined on the Jenkins server config
            inheritFrom 'shared'
            // helm pod template defined in molgenis/molgenis-jenkins-pipeline repository
            yaml libraryResource("pod-templates/helm.yaml")
        }
    }
    stages {
        stage('Prepare') {
            steps {
                container('chart-testing') {
                    sh "helm repo add stable https://charts.helm.sh/stable"
                    sh "helm repo add molgenis https://helm.molgenis.org"
                    sh "helm repo add elastic https://helm.elastic.co/"
                    sh "helm repo add fusionauth https://fusionauth.github.io/charts"
                    sh "helm repo add bitnami https://charts.bitnami.com/bitnami"
                    sh "helm repo add jenkins https://charts.jenkins.io"
                    sh "helm repo add minio https://helm.min.io"
                    sh 'helm repo add jupyter https://jupyterhub.github.io/helm-chart'
                    sh 'helm repo add nfs https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner'
                    sh "helm repo add airflow https://airflow-helm.github.io/charts"
                    sh "helm repo add grafana https://grafana.github.io/helm-charts"
                }
            }
        }
        stage('Test and package [PR]') {
            when {
                changeRequest()
            }
            environment {
                CT_REMOTE='origin'
                CT_BUILD_ID="${CHANGE_ID}"
            }
            steps {
                container('chart-testing') {
                    sh "git fetch --no-tags origin ${CHANGE_TARGET}:refs/remotes/origin/${CHANGE_TARGET}"
                    sh "ct lint --validate-maintainers=false --target-branch ${CHANGE_TARGET}"
                    sh 'mkdir target'
                    sh 'for dir in $(ct list-changed --target-branch ${CHANGE_TARGET}); do helm package --destination target "$dir"; done'
                }
            }
        }
        stage('Test and package [master]') {
            when {
                branch 'master'
            }
            steps {
                container('chart-testing') {
                    sh "ct lint --all --validate-maintainers=false"
                    sh 'mkdir target'
                    sh 'for dir in charts/*; do helm package --destination target "$dir"; done'
                }
            }
        }
        stage('Deploy to nexus and chartmuseum') {
            when {
                branch 'master'
            }
            steps {
                container('vault') {
                    script {
                        env.NEXUS_USER = sh(script: 'vault read -field=username secret/ops/account/nexus', returnStdout: true)
                        env.NEXUS_PWD = sh(script: 'vault read -field=password secret/ops/account/nexus', returnStdout: true)
                        env.CHARTMUSEUM_USER = sh(script: 'vault read -field=username secret/ops/account/chartmuseum', returnStdout: true)
                        env.CHARTMUSEUM_PWD = sh(script: 'vault read -field=password secret/ops/account/chartmuseum', returnStdout: true)
                    }
                }
                container('alpine') {
                    sh 'set +x; for chart in target/*; do curl -L --fail -u $NEXUS_USER:$NEXUS_PWD $HELM_REPO --upload-file "$chart"; done'
                    sh 'set +x; for chart in target/*; do curl -L --fail -u $CHARTMUSEUM_USER:$CHARTMUSEUM_PWD ${HELM_REPOSITORY}api/charts --data-binary "@$chart"; done'
                }
            }
        }
    }
}
