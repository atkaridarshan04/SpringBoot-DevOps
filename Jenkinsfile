pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_IMAGE_TAG', defaultValue: 'latest',  description: 'Tag for new docker image')
    }

    tools {
        maven 'maven'
    }

    environment {
        SONAR_HOME = tool 'sonar'
    }

    stages {
        stage("Workspace cleanup"){
            steps{
                script{
                    cleanWs()
                }
            }
        }

        stage ('Code Checkout') {
            steps {
                git branch: 'main', url: 'http://github.com/atkaridarshan04/SpringBoot-DevOps.git'
            }
        }

        stage ('Compile Code') {
            steps {
                sh "mvn compile"
            }
        }

        stage ('Run Unit Test Cases') {
            steps {
                sh "mvn test -DskipTests=true"
            }
        }

        stage ('File System Scan') {
            steps {
                sh "trivy fs --format table -o output fs.html ."
            }
        }

        stage ('Sonar Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''$SONAR_HOME/bin/sonar-scanner -Dsonar.projectName=bankapp -Dsonar.projectKey=bankapp \
                            -Dsonar.java.binaries=target '''
                }
            }
        }

        stage("Sonar: Code Quality Gates"){
            steps {
                timeout(time: 5, unit: "MINUTES"){
                waitForQualityGate abortPipeline: false
                }
            }
        }

        stage ('Build and Publish to Nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'maven-settings', jdk: '', maven: 'maven', mavenSettingsConfig: '', traceability: true) {
                    sh "mvn deploy -DskipTests=true"
                }
            }
        }

        stage ('Docker Build and Tag') {
            steps {
                script {
                    sh "docker build -t atkaridarshan04/springboot-bankapp:${params.DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage ('Image Scan') {
            steps {
                sh "trivy image --format table -o output dimage.html atkaridarshan04/springboot-bankapp:${params.DOCKER_IMAGE_TAG} "
            }
        }

        stage ('Push Images to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-token', passwordVariable: 'dockerhubpass', usernameVariable: 'dockerhubuser')]) {
                    sh "docker login -u ${dockerhubuser} -p ${dockerhubpass}"
                    }
                    sh "docker push atkaridarshan04/springboot-bankapp:${params.DOCKER_IMAGE_TAG}"
                }
            }
        }

        stage("Git: Code update and push to GitHub") {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_TOKEN')]) {

                        sh "echo 'Docker Image Tag: ${params.DOCKER_IMAGE_TAG}'"
                        sh "git clone https://github.com/atkaridarshan04/SpringBoot-DevOps.git"

                        dir('SpringBoot-DevOps/kubernetes') {
                            sh "sed -i -e 's/springboot-bankapp.*/springboot-bankapp:${params.DOCKER_IMAGE_TAG}/g' bankapp.yml"
                        }

                        dir('SpringBoot-DevOps') {
                            sh """
                                git config user.email "jenkins@example.com"
                                git config user.name "jenkins"
                                
                                git status
                                git add .
                                git commit -m "Updated Image Tag to ${params.DOCKER_IMAGE_TAG}"
                                git push https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/atkaridarshan04/SpringBoot-DevOps.git main
                            """
                        }
                    }
                }
            }
        }
    }
}



