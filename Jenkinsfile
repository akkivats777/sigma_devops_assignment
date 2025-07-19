pipeline {
  agent any

  environment {
    K8S_NAMESPACE = "default"
    KUBECONFIG = "${WORKSPACE}/.kube/config"
  }

  stages {
    stage('Clone Repository') {
      steps {
        git branch: 'main', url: 'https://github.com/akkivats777/sigma_devops_assignment.git'
      }
    }

    stage('Start Minikube and Setup') {
      steps {
        sh '''
        if ! minikube status > /dev/null 2>&1; then
          echo "🚀 Starting Minikube..."
          minikube start --driver=docker

          echo "🔌 Enabling addons..."
          minikube addons enable ingress
          minikube addons enable metrics-server

          echo "💾 Installing Local Path Provisioner..."
          kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

          echo "📦 Setting local-path as default storage class..."
          kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
        else
          echo "✅ Minikube is already running."
        fi
        '''
      }
    }

    // Uncomment if needed
    // stage('Setup Kubeconfig') {
    //   steps {
    //     sh '''
    //     echo "🔧 Setting up kubeconfig for Jenkins..."
    //     mkdir -p $WORKSPACE/.kube
    //     minikube update-context
    //     cat ~/.kube/config > $KUBECONFIG
    //     chmod 600 $KUBECONFIG
    //     '''
    //   }
    // }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('Sonar') {
          sh '''
          $SONAR_HOME/bin/sonar-scanner \
          -Dsonar.projectKey=laravel \
          -Dsonar.projectName=laravel \
          -Dsonar.java.binaries=target/classes
          '''
        }
      }
    }

    stage("Quality Gate Check") {
      steps {
        script {
          waitForQualityGate abortPipeline: false, credentialsId: 'Sonarqube-token'
        }
      }
    }

    // Uncomment if OWASP Dependency Check is configured
    stage('OWASP Dependency-Check') {
      steps {
        dependencyCheck additionalArguments: '''
          -o './'
          -s './'
          -f 'ALL'
          --prettyPrint
          --scan ./
          --disableYarnAudit
          --disableNodeAudit
        ''', odcInstallation: 'OWASP'
        dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
      }
    }

    stage('Trivy File Scan') {
      steps {
        sh 'trivy fs --format table -o trivy-fs-report.html .'
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
        echo "🚢 Applying Kubernetes manifests..."
        kubectl apply -f k8s_manifests/ --namespace=$K8S_NAMESPACE
        '''
      }
    }

    stage('Post Deployment Verification') {
      steps {
        sh '''
        echo "🔍 Verifying deployment..."
        kubectl get all -n $K8S_NAMESPACE
        '''
      }
    }

    // Uncomment if Smoke test is required
    // stage('Smoke Test') {
    //   steps {
    //     sh '''
    //     echo "🧪 Running smoke test..."
    //     curl -sf http://wordpress.local || echo "⚠️ Smoke test failed. Check Ingress or Pod status."
    //     '''
    //   }
    // }
  }

  post {
    always {
      script {
        def jobName = env.JOB_NAME
        def buildNumber = env.BUILD_NUMBER
        def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
        def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'
        def jenkinsHost = BUILD_URL.split('/job/')[0]

        def body = """
          <html>
          <body>
          <div style="border: 4px solid ${bannerColor}; padding: 10px;">
              <h2>${jobName} - Application Build Number - ${buildNumber}</h2>
              <div style="background-color: ${bannerColor}; padding: 10px;">
                  <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
              </div>
              <p>Project: ${jobName}</p>
              <p>Build Number: ${buildNumber}</p>
              <p>URL: <a href="${BUILD_URL}">${BUILD_URL}</a></p>
              <p>Check the <a href="${BUILD_URL}console">console output</a>.</p>
              <p>DNS: <strong>${jenkinsHost}</strong></p>

              <div style="background-color: #FFA07A; padding: 10px; margin-bottom: 10px;">
                  <p style="color: black; font-weight: bold;">Project: ${env.JOB_NAME}</p>
              </div>
              <div style="background-color: #90EE90; padding: 10px; margin-bottom: 10px;">
                  <p style="color: black; font-weight: bold;">Build Number: ${env.BUILD_NUMBER}</p>
              </div>
              <div style="background-color: #87CEEB; padding: 10px; margin-bottom: 10px;">
                  <p style="color: black; font-weight: bold;">URL: ${env.BUILD_URL}</p>
              </div>
          </div>
          </body>
          </html>
        """

        emailext (
          subject: "${jobName} Application - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
          body: body,
          to: 'aakashsharma8527@gmail.com',
          from: 'aakashsharma8527@gmail.com',
          replyTo: 'aakashsharma8527@gmail.com',
          mimeType: 'text/html',
          attachmentsPattern: 'trivy-image-report.html, build.log, dependency-check-report.xml, trivy-fs-report.html',
          attachLog: true
        )
      }
    }

    success {
      echo '✅ Deployment completed successfully!'
    }

    failure {
      echo '❌ Deployment failed.'
    }
  }
}
