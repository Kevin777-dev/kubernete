pipeline {
    agent {
        kubernetes {
            label 'jenkins-agent-my-app'
            defaultContainer 'jnlp'
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: python
    image: python:3.9
    command:
    - cat
    tty: true

  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker

  volumes:
  - name: docker-config
    emptyDir: {}
"""
        }
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install dependencies') {
            steps {
                container('python') {
                    sh '''
                        python -m pip install --upgrade pip
                        pip install -r requirements.txt
                    '''
                }
            }
        }

        stage('Test') {
            steps {
                container('python') {
                    sh 'python test.py'
                }
            }
        }

        stage('Build image (Kaniko)') {
            steps {
                container('kaniko') {
                    sh '''
                        /kaniko/executor \
                        --context `pwd` \
                        --dockerfile Dockerfile \
                        --destination localhost:4000/pythontest:latest \
                        --insecure
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline OK 🎉"
        }
        failure {
            echo "Pipeline FAILED ❌"
        }
    }
}