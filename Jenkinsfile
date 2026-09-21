#!/usr/bin/env groovy

// =====================================================================
// Jenkins Multibranch Pipeline
// Branch-aware CI/CD: test -> version -> build -> push -> deploy
// =====================================================================

pipeline {

    agent any

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20'))
        timeout(time: 30, unit: 'MINUTES')
    }

    environment {
        // ---- Docker registry (Docker Hub) ----
        DOCKER_REGISTRY        = 'docker.io/pierrechukason'
        DOCKER_CREDENTIALS_ID  = 'Docker-Hub-Credentials'
        APP_NAME               = 'my-demo-app'

        // ---- Deploy target ----
        DEPLOY_HOST               = '44.223.4.128'
        DEPLOY_USER               = 'ubuntu'
        DEPLOY_SSH_CREDENTIALS_ID = 'deploy-ssh-credentials'
        APP_PORT                  = '8080'

        // ---- Git write-back (for the version-commit stage) ----
        GIT_CREDENTIALS_ID = 'GitHub-PAT'
        GIT_REPO_URL       = 'github.com/Chukwuemeka-Peter-Eze/jenkins-multibranch-pipeline.git'
        GIT_USER_NAME      = 'Chukwuemeka-Peter-Eze'
        GIT_USER_EMAIL     = 'Chukwuemekapetereze@proton.me'

        // Marker used to detect and skip pipeline-generated commits
        VERSION_COMMIT_TAG = '[jenkins-skip]'
    }

    stages {

        stage('Check For Recursive Trigger') {
            steps {
                script {
                    def lastCommitMessage = sh(
                        script: 'git log -1 --pretty=%B',
                        returnStdout: true
                    ).trim()

                    if (lastCommitMessage.contains(env.VERSION_COMMIT_TAG)) {
                        echo "Last commit was a Jenkins version-commit (${env.VERSION_COMMIT_TAG}). Skipping the rest of the pipeline to avoid a recursive build loop."
                        env.SKIP_BUILD = 'true'
                    } else {
                        env.SKIP_BUILD = 'false'
                    }
                }
            }
        }

        stage('Test') {
            when {
                expression { env.SKIP_BUILD == 'false' }
            }
            steps {
                echo "Running tests on branch: ${env.BRANCH_NAME}"
                sh 'mvn test'
            }
        }

        stage('Determine Current Version') {
            when {
                expression { env.SKIP_BUILD == 'false' }
            }
            steps {
                script {
                    env.CURRENT_VERSION = sh(
                        script: "mvn -q help:evaluate -Dexpression=project.version -DforceStdout",
                        returnStdout: true
                    ).trim()
                    echo "Current version from pom.xml: ${env.CURRENT_VERSION}"
                }
            }
        }

        stage('Increment Version') {
            when {
                allOf {
                    expression { env.SKIP_BUILD == 'false' }
                    anyOf { branch 'main'; branch 'develop' }
                }
            }
            steps {
                script {
                    def parts = env.CURRENT_VERSION.tokenize('.')
                    def major = parts[0]
                    def minor = parts[1]
                    def patch = (parts[2] as Integer) + 1
                    env.NEW_VERSION = "${major}.${minor}.${patch}"

                    sh """
                        mvn org.codehaus.mojo:versions-maven-plugin:2.16.2:set \
                            -DnewVersion=${env.NEW_VERSION} \
                            -DgenerateBackupPoms=false
                    """
                    echo "Version bumped: ${env.CURRENT_VERSION} -> ${env.NEW_VERSION}"
                }
            }
        }

        stage('Build') {
            when {
                expression { env.SKIP_BUILD == 'false' }
            }
            steps {
                echo "Building application on branch: ${env.BRANCH_NAME}"
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            when {
                allOf {
                    expression { env.SKIP_BUILD == 'false' }
                    anyOf { branch 'main'; branch 'develop' }
                }
            }
            steps {
                script {
                    env.IMAGE_TAG = "${DOCKER_REGISTRY}/${APP_NAME}:${env.NEW_VERSION}"
                    sh "docker build -t ${env.IMAGE_TAG} ."
                    echo "Built image: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Push Docker Image') {
            when {
                allOf {
                    expression { env.SKIP_BUILD == 'false' }
                    anyOf { branch 'main'; branch 'develop' }
                }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDENTIALS_ID,
                    usernameVariable: 'REG_USER',
                    passwordVariable: 'REG_PASS'
                )]) {
                    sh """
                        echo \$REG_PASS | docker login ${DOCKER_REGISTRY} -u \$REG_USER --password-stdin
                        docker push ${env.IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy') {
            when {
                allOf {
                    expression { env.SKIP_BUILD == 'false' }
                    branch 'main'
                }
            }
            steps {
                sshagent(credentials: [DEPLOY_SSH_CREDENTIALS_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} '
                            docker login ${DOCKER_REGISTRY} &&
                            docker pull ${env.IMAGE_TAG} &&
                            docker stop ${APP_NAME} || true &&
                            docker rm ${APP_NAME} || true &&
                            docker run -d --name ${APP_NAME} -p ${APP_PORT}:${APP_PORT} ${env.IMAGE_TAG}
                        '
                    """
                }
                echo "Deployed ${env.IMAGE_TAG} to ${DEPLOY_HOST}"
            }
        }

        stage('Commit Version Change') {
            when {
                allOf {
                    expression { env.SKIP_BUILD == 'false' }
                    anyOf { branch 'main'; branch 'develop' }
                }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: GIT_CREDENTIALS_ID,
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_TOKEN'
                )]) {
                    sh """
                        git config user.name "${GIT_USER_NAME}"
                        git config user.email "${GIT_USER_EMAIL}"
                        git add pom.xml
                        git commit -m "${VERSION_COMMIT_TAG} bump version to ${env.NEW_VERSION}"
                        git push https://\$GIT_USER:\$GIT_TOKEN@${GIT_REPO_URL} HEAD:${env.BRANCH_NAME}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully on branch ${env.BRANCH_NAME}."
        }
        failure {
            echo "Pipeline failed on branch ${env.BRANCH_NAME}. Check the stage logs above."
        }
        always {
            sh 'docker logout ${DOCKER_REGISTRY} || true'
        }
    }
}