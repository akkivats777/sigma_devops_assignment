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

    stage('Smoke Test') {
      steps {
        sh '''
        echo "🧪 Running smoke test..."
        curl -sf http://wordpress.local || echo "⚠️ Smoke test failed. Check Ingress or Pod status."
        '''
      }
    }
  }

  post {
    success {
      echo '✅ Deployment completed successfully!'
    }
    failure {
      echo '❌ Deployment failed.'
    }
  }
}
