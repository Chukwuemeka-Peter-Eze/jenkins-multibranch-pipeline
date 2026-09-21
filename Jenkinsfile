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

    tools {
        maven 'maven-3.9'
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

        // Application listens on container port 8080.
        // Jenkins already uses host port 8080,
        // so the application is exposed on host port 8081.
        APP_PORT      = '8080'
        HOST_APP_PORT = '8081'

        // ---- Git write-back ----
        GIT_CREDENTIALS_ID = 'GitHub-PAT'
        GIT_REPO_URL       = 'github.com/Chukwuemeka-Peter-Eze/jenkins-multibranch-pipeline.git'
        GIT_USER_NAME      = 'Chukwuemeka-Peter-Eze'
        GIT_USER_EMAIL     = 'Chukwuemekapetereze@proton.me'

        // Marker used to detect and skip pipeline-generated commits
        VERSION_COMMIT_TAG = '[jenkins-skip]'
    }

    stages {

        // =================================================================
        // CHECK FOR RECURSIVE TRIGGER
        // =================================================================

        stage('Check For Recursive Trigger') {
            steps {
                script {
                    def lastCommitMessage = sh(
                        script: 'git log -1 --pretty=%B',
                        returnStdout: true
                    ).trim()

                    if (lastCommitMessage.contains(env.VERSION_COMMIT_TAG)) {
                        echo "Last commit was a Jenkins version-commit (${env.VERSION_COMMIT_TAG})."
                        echo "Skipping the rest of the pipeline to avoid a recursive build loop."

                        env.SKIP_BUILD = 'true'
                    } else {
                        env.SKIP_BUILD = 'false'
                    }
                }
            }
        }

        // =================================================================
        // TEST
        // =================================================================

        stage('Test') {
            when {
                expression { env.SKIP_BUILD == 'false' }
            }

            steps {
                echo "Running tests on branch: ${env.BRANCH_NAME}"
                sh 'mvn test'
            }
        }

        // =================================================================
        // DETERMINE CURRENT VERSION
        // =================================================================

        stage('Determine Current Version') {
            when {
                expression { env.SKIP_BUILD == 'false' }
            }

            steps {
                script {
                    env.CURRENT_VERSION = sh(
                        script: 'mvn -q help:evaluate -Dexpression=project.version -DforceStdout',
                        returnStdout: true
                    ).trim()

                    echo "Current version from pom.xml: ${env.CURRENT_VERSION}"
                }
            }
        }

        // =================================================================
        // INCREMENT VERSION
        // =================================================================

        stage('Increment Version') {
            when {
                allOf {
                    expression { env.SKIP_BUILD == 'false' }
                    anyOf {
                        branch 'main'
                        branch 'develop'
                    }
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

        // =================================================================
        // BUILD APPLICATION
        // =================================================================

        stage('Build') {
            when {
                expression { env.SKIP_BUILD == 'false' }
            }

            steps {
                echo "Building application on branch: ${env.BRANCH_NAME}"
                sh 'mvn clean package -DskipTests'
            }
        }

        // =================================================================
        // BUILD DOCKER IMAGE
        // =================================================================

        stage('Build Docker Image') {
            when {
                allOf {
                    expression { env.SKIP_BUILD == 'false' }
                    anyOf {
                        branch 'main'
                        branch 'develop'
                    }
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

        // =================================================================
        // PUSH DOCKER IMAGE
        // =================================================================

        stage('Push Docker Image') {
            when {
                allOf {
                    expression { env.SKIP_BUILD == 'false' }
                    anyOf {
                        branch 'main'
                        branch 'develop'
                    }
                }
            }

            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDENTIALS_ID,
                    usernameVariable: 'REG_USER',
                    passwordVariable: 'REG_PASS'
                )]) {

                    sh """
                        echo \$REG_PASS | docker login ${DOCKER_REGISTRY} \
                            -u \$REG_USER \
                            --password-stdin

                        docker push ${env.IMAGE_TAG}
                    """
                }
            }
        }

        // =================================================================
        // DEPLOY
        // =================================================================

        stage('Deploy') {
            when {
                allOf {
                    expression { env.SKIP_BUILD == 'false' }
                    branch 'main'
                }
            }

            steps {

                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDENTIALS_ID,
                    usernameVariable: 'REG_USER',
                    passwordVariable: 'REG_PASS'
                )]) {

                    sshagent(credentials: [DEPLOY_SSH_CREDENTIALS_ID]) {

                        // -------------------------------------------------
                        // 1. Authenticate deployment server to Docker Hub
                        // -------------------------------------------------

                        echo "Authenticating deployment server to Docker Hub..."

                        sh """
                            printf '%s\\n' "\$REG_PASS" | ssh \
                                -o StrictHostKeyChecking=no \
                                ${DEPLOY_USER}@${DEPLOY_HOST} \
                                "docker login ${DOCKER_REGISTRY} -u '\$REG_USER' --password-stdin"
                        """

                        // -------------------------------------------------
                        // 2. Pull new image
                        // 3. Stop existing application
                        // 4. Remove existing application
                        // 5. Start new application
                        // -------------------------------------------------

                        echo "Deploying ${env.IMAGE_TAG} to ${DEPLOY_HOST}..."

                        sh """
                            ssh \
                                -o StrictHostKeyChecking=no \
                                ${DEPLOY_USER}@${DEPLOY_HOST} '
                                    docker pull ${env.IMAGE_TAG} &&
                                    (docker stop ${APP_NAME} || true) &&
                                    (docker rm ${APP_NAME} || true) &&
                                    docker run -d \
                                        --name ${APP_NAME} \
                                        -p ${HOST_APP_PORT}:${APP_PORT} \
                                        ${env.IMAGE_TAG}
                                '
                        """

                        // -------------------------------------------------
                        // 6. Remove Docker Hub credentials from server
                        // -------------------------------------------------

                        echo "Logging out of Docker Hub on deployment server..."

                        sh """
                            ssh \
                                -o StrictHostKeyChecking=no \
                                ${DEPLOY_USER}@${DEPLOY_HOST} \
                                'docker logout ${DOCKER_REGISTRY} || true'
                        """
                    }
                }

                echo "Deployed ${env.IMAGE_TAG} to ${DEPLOY_HOST}:${HOST_APP_PORT}"
            }
        }

        // =================================================================
        // COMMIT VERSION CHANGE
        // =================================================================

        stage('Commit Version Change') {
            when {
                allOf {
                    expression { env.SKIP_BUILD == 'false' }
                    anyOf {
                        branch 'main'
                        branch 'develop'
                    }
                }
            }

            steps {

                withCredentials([usernamePassword(
                    credentialsId: GIT_CREDENTIALS_ID,
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_TOKEN'
                )]) {

                    script {

                        // Configure Git identity
                        sh """
                            git config user.name "${GIT_USER_NAME}"
                            git config user.email "${GIT_USER_EMAIL}"
                        """

                        // Stage the version change
                        sh 'git add pom.xml'

                        // Create Jenkins version commit
                        sh """
                            git commit \
                                -m "${VERSION_COMMIT_TAG} bump version to ${env.NEW_VERSION}"
                        """

                        // Push using the Jenkins GitHub credentials.
                        //
                        // GIT_ASKPASS prevents the username/token from
                        // appearing directly in the Git remote URL.
                        withEnv([
                            "GIT_ASKPASS=${WORKSPACE}/.git-askpass.sh",
                            "GIT_TERMINAL_PROMPT=0"
                        ]) {

                            writeFile(
                                file: '.git-askpass.sh',
                                text: '''#!/bin/sh
case "$1" in
    *Username*) printf '%s\\n' "$GIT_USER" ;;
    *Password*) printf '%s\\n' "$GIT_TOKEN" ;;
esac
'''
                            )

                            sh 'chmod 700 .git-askpass.sh'

                            sh """
                                git push \
                                    https://${GIT_REPO_URL} \
                                    HEAD:${env.BRANCH_NAME}
                            """
                        }

                        // Remove the temporary authentication helper
                        sh 'rm -f .git-askpass.sh'
                    }
                }
            }
        }
    }

    // =====================================================================
    // POST ACTIONS
    // =====================================================================

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