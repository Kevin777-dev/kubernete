pipeline {
    agent {
        kubernetes {
            label 'jenkins-agent-my-app'

            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: ci
spec:
  containers:
  - name: python
    image: python:3.7
    command: ["cat"]
    tty: true
  - name: docker
    image: docker:24-cli
    command: ["cat"]
    tty: true
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-sock

  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
      type: Socket
"""
        }
    }

    triggers {
        pollSCM('* * * * *')
    }

    stages {

        stage('Test Python') {
            steps {
                container('python') {
                    sh 'pip install -r requirements.txt'
                    sh 'python test.py'
                }
            }
        }

        stage('Build Image') {
            steps {
                container('docker') {
                    sh 'docker version'
                    sh 'docker build -t localhost:4000/pythontest:latest .'
                    sh 'docker push localhost:4000/pythontest:latest'
                }
            }
        }
    }
}