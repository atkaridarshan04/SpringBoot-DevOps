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
                withDockerRegistry(credentialsID: 'docker-cred') {
                    sh "docker push atkaridarshan04/springboot-bankapp:${params.DOCKER_IMAGE_TAG}"
                }
            }
        }

        stage("Git: Code update and push to GitHub"){
            steps{
                script{
                    withCredentials([gitUsernamePassword(credentialsId: 'github-token', gitToolName: 'Default')]) {
                        
                        sh ''' 
                        # clone repo
                        git clone http://github.com/atkaridarshan04/SpringBoot-DevOps.git
                        cd SpringBoot-DevOps

                        repo_dir=${pwd}

                        # Change the image tag
                        sed -i 's|image: atkaridarshan04/springboot-bankapp:.*|image: atkaridarshan04/springboot-bankapp:'${params.DOCKER_IMAGE_TAG}'|'${repo_dir}/SpringBoot-DevOps/kubernetes/bankapp.yml
                        '''

                        sh '''
                        cd SpringBoot-DevOps

                        git config user.email "jenkins@example.com"
                        git config user.name "jenkins"

                        echo "Checking repository status: "
                        git status

                        echo "Adding changes to git: "
                        git add .
                        
                        echo "Commiting changes: "
                        git commit -m "Updated Image Tag to ${DOCKER_IMAGE_TAG}"
                        
                        echo "Pushing changes to github: "
                        git push https://github.com/atkaridarshan04/SpringBoot-DevOps.git main
                        '''
                    }
                }
            }
        }
    }
}



