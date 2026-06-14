pipeline {
  agent {
    kubernetes {
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
      command:
        - cat
      tty: true

    - name: docker
      image: docker:dind
      securityContext:
        privileged: true
      env:
        - name: DOCKER_TLS_CERTDIR
          value: ""
      tty: true

    - name: kubectl
      image: bitnami/kubectl:latest
      command:
        - cat
      tty: true

  volumes:
    - name: docker-sock
      emptyDir: {}
"""
    }
  }

  triggers {
    pollSCM('H/5 * * * *')
  }

  stages {

    stage('Test python') {
      steps {
        container('python') {
          sh 'pip install -r requirements.txt'
          sh 'python test.py'
        }
      }
    }

    stage('Build image') {
      steps {
        container('docker') {
          sh 'dockerd &'  // démarre le daemon en arrière-plan
          sh 'sleep 5'    // attend que dockerd soit prêt
          sh 'docker build -t localhost:4000/pythontest:latest .'
          sh 'docker push localhost:4000/pythontest:latest'
        }
      }
    }

    stage('Deploy') {
      steps {
        container('kubectl') {
          sh 'kubectl apply -f ./kubernetes/deployment.yaml'
          sh 'kubectl apply -f ./kubernetes/service.yaml'
        }
      }
    }

  }
}