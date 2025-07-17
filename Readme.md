# 🧪 Senior DevOps Assignment: WordPress on Kubernetes

## 🏗️ Architecture Overview
- **WordPress** – Web application (PHP)
- **MySQL** – Database backend
- **phpMyAdmin** – MySQL web administration interface
- **Ingress Controller** – NGINX (for domain-based routing)
- **CI/CD** – Jenkins pipeline (for GitHub → Build → Deploy)

---

## 🚀 Deployment Options

### ▶️ Docker Compose (Local Testing)
```bash
docker-compose up -d
```

### ☸️ Kubernetes on Minikube
```bash
minikube start
minikube addons enable ingress
kubectl apply -f k8s_manifests/
minikube tunnel  # To expose Ingress on localhost
```

---

## 🔧 Jenkins Pipeline Setup
- Use the provided `Jenkinsfile` for pipeline automation.
- Add your GitHub repo in Jenkins.
- Provide access to `kubeconfig` and Docker credentials if needed.
- Trigger the pipeline to deploy updated code to Minikube or a remote K8s cluster.

---

## ✅ Assumptions & Constraints
- Testing and deployment is done locally via **Minikube**
- Requires DNS mapping for Ingress to work
- Horizontal Pod Autoscaler (HPA) requires `metrics-server` enabled in Minikube

---

## 🌐 Local DNS Configuration (`/etc/hosts`)
> Replace `192.168.49.2` with the actual IP of your Minikube Ingress (use `minikube ip` to get it)

```bash
192.168.49.2 wordpress.local
192.168.49.2 phpmyadmin.local
```

---

## 🌍 Access Points
- 🌐 WordPress: http://wordpress.local
- 🛠️ phpMyAdmin: http://phpmyadmin.local

---

## 📜 Logs & Monitoring

### View logs from all WordPress pods:
```bash
kubectl get pods -l app=wordpress
kubectl logs <pod-name>                 # For a specific pod
kubectl logs -f <pod-name>              # Follow logs
```

### Example:
```bash
kubectl logs -f wordpress-7c96bcb5d5-pxkhz
```

---

## 🔁 Load Testing (to test HPA)
```bash
kubectl run -i --tty load-generator --image=busybox -- /bin/sh
```
Then inside the pod:
```sh
while true; do wget -q -O- http://wordpress; done
```

---

## 📂 Directory: `scripts/setup.sh`
Include automation here for setting up namespaces, secrets, or applying all manifests:

```bash
#!/bin/bash
kubectl apply -f ../k8s_manifests/
echo "Don't forget to add domains to /etc/hosts using:"
echo "$(minikube ip) wordpress.local phpmyadmin.local"
```

---