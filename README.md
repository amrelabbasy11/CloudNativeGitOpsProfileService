# 🌐 Cloud-Native GitOps Project

This repository demonstrates a **production-grade cloud-native deployment** using **DevOps, GitOps, and Infrastructure as Code (IaC)**. It showcases a complete workflow starting from code quality analysis to automated deployment on AWS EKS with full observability and security.

The stack integrates **Terraform, Kubernetes, Ansible, ArgoCD, SonarCloud, Prometheus, Grafana, Slack, Route53, and AWS services (EKS, S3, ECR, Secrets Manager, Load Balancer)**.

---

## 📊 Project Architecture

```mermaid
flowchart TD
    User[User Browser] --> Route53[Route 53 - DNS]
    Route53 --> LB[AWS Load Balancer]
    LB --> Ingress[Ingress Controller (NGINX)]
    Ingress --> Service1[App Service]
    Ingress --> Service2[DB Service]
    Ingress --> Service3[Web Service]
    Service1 --> Pod1[App Pod]
    Service2 --> Pod2[MySQL Pod]
    Service3 --> Pod3[Nginx Pod]
```

---

## 🖥️ System Components

### 🔎 ArgoCD Dashboard

ArgoCD provides a **GitOps-based continuous delivery pipeline**. It continuously monitors the GitHub repo and automatically syncs Kubernetes manifests to the EKS cluster.
![ArgoCD Dashboard](images/argocd-dashboard.png)

---

### 🧪 Sonar (Scanner, Gate, SonarCloud)

Sonar ensures **code quality, bug detection, and vulnerability scanning**. GitHub Actions integrate with Sonar Scanner and SonarCloud to enforce Sonar Gate rules before deploying.
![SonarCloud](images/sonarcloud.png)

---

### 📈 Prometheus & Grafana

Prometheus collects metrics, while Grafana visualizes them in dashboards. Alertmanager integrates with Slack for real-time alerts.
![Prometheus & Grafana](images/prometheus-grafana.png)

---

### 🚀 Application

The deployed application (App, DB, Web) runs inside EKS and is exposed through Route53, Load Balancer, and Ingress.
![App](images/app.png)

---

## ⚙️ Terraform Infrastructure

Terraform provisions the AWS infrastructure and Kubernetes cluster.

### Backend State (S3)

```hcl
terraform {
  backend "s3" {
    bucket = "terraformstate2110"
    key    = "terraform/backend"
    region = "eu-north-1"
  }
}
```

### EKS Module (Terraform Registry)

Using the official [terraform-aws-modules/eks](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest):

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name          = "node-group-1"
      instance_types = ["t3.small"]
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name          = "node-group-2"
      instance_types = ["t3.small"]
      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
```

* **Cluster version**: Kubernetes `1.29`.
* **Two managed node groups** (`t3.small`) for scalability.
* **Networking** integrated with Terraform VPC and private subnets.
* **Cluster access** exposed via public endpoint.

---

## 🐳 Dockerfiles

### App Service (Java/Tomcat)

```dockerfile
FROM openjdk:11 AS BUILD_IMAGE
RUN apt update && apt install maven -y
RUN git clone https://github.com/amrelabbasy11/CloudNativeGitOpsProfileService.git
RUN cd CloudNativeGitOpsProfileService && mvn install

FROM tomcat:9-jre11
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=BUILD_IMAGE CloudNativeGitOpsProfileService/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
```

### Database (MySQL)

```dockerfile
FROM mysql:8.0.33
LABEL "Project"="Vprofile"
LABEL "Author"="Amr Elabbasy"

ENV MYSQL_ROOT_PASSWORD="vprodbpass"
ENV MYSQL_DATABASE="accounts"

ADD db_backup.sql docker-entrypoint-initdb.d/db_backup.sql
```

### Web (Nginx)

```dockerfile
FROM nginx
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY nginvproapp.conf /etc/nginx/conf.d/vproapp.conf
```

> 📌 All base images are **official Docker images** ([Docker Hub](https://hub.docker.com/)) for stability and security.

---

## 🔐 Secrets Management

Secrets are handled securely using:

* **GitHub Secrets** → for CI/CD (AWS keys, Sonar tokens, Docker creds, Slack webhook).
* **AWS Secrets Manager + ExternalSecrets** → sync into Kubernetes cluster.

Example:

```yaml
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
  DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
  DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
  SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 🛠️ CI/CD Workflows

### App-CI-CD Workflow

1. Runs **Sonar Scanner → SonarCloud → Sonar Gate**.
2. Builds Docker images → Pushes to **AWS ECR**.
3. ArgoCD automatically syncs manifests from GitHub to EKS.

### Terraform-IaC Workflow

1. Initializes **S3 backend**.
2. Provisions **VPC, EKS, Route53, and Load Balancer**.
3. Updates infrastructure incrementally (idempotent).

---

## 📂 Repository Structure

```
├── ansible/
│   ├── install-argocd.yaml
│   ├── install-kube-prometheus-stack.yaml
│   └── inventory.ini
│
├── monitoring/
│   ├── alertmanager-config.yaml
│   ├── clustersecretstore-aws.yaml
│   ├── external-secrets-crds.yaml
│   ├── prometheus-role.yaml
│   ├── secret-slack-webhook.yaml
│   └── test-slack-alert.yaml
│
├── terraform/
│   ├── backend.tf
│   ├── eks-cluster.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   └── variables.tf
│
├── k8s/
│   ├── deployments/
│   ├── services/
│   ├── ingress/
│   └── secrets/
│
├── docker/
│   ├── Dockerfile.app
│   ├── Dockerfile.db
│   └── Dockerfile.web
```

---

## 🌍 Accessing the Application

The flow for accessing the application is:

```
User → Route53 → Load Balancer → Ingress → Service → Pod
```

* **Domain**: managed by Route53.
* **Load Balancer**: distributes traffic to Ingress.
* **Ingress (NGINX)**: routes requests to app, DB, or web services.
* **Kubernetes Services**: expose Pods internally.

Example application URL:

```
http://myprofile.com
```

---

## 📚 References

* [Terraform Registry](https://registry.terraform.io/)
* [Kubernetes Documentation](https://kubernetes.io/docs/)
* [Docker Official Images](https://hub.docker.com/)
* [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
* [Prometheus Documentation](https://prometheus.io/docs/)
* [Grafana Documentation](https://grafana.com/docs/)
* [SonarCloud](https://sonarcloud.io/)

---
