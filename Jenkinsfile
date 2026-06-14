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
        - name: DOCKER_OPTS
          value: "--insecure-registry kind-registry:5000"
      tty: true

    - name: kubectl
      image: alpine/k8s:1.28.3
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
          sh '''
            mkdir -p /etc/docker
            echo \'{"insecure-registries": ["kind-registry:5000"]}\' > /etc/docker/daemon.json
            kill -SIGHUP $(cat /var/run/docker.pid) || true
            sleep 3
            docker build -t kind-registry:5000/pythontest:latest .
            docker push kind-registry:5000/pythontest:latest
          '''
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