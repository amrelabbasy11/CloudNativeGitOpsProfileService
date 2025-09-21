# Cloud-Native GitOps Project

This repository contains the infrastructure, CI/CD pipelines, monitoring stack, and GitOps workflows for deploying a **microservices-based application** on **AWS EKS**. The project demonstrates **end-to-end DevOps automation**, covering Infrastructure as Code (IaC), Continuous Integration, Continuous Deployment, GitOps, Monitoring, and Alerting.

---

# Tools & Technologies

This project integrates **modern DevOps, GitOps, and Cloud-Native tools**:

* **Infrastructure as Code (IaC)** → Terraform (AWS VPC, EKS, Route53, Load Balancer, S3 backend)
* **Containerization** → Docker (App, DB, and Web services; based on official images)
* **Orchestration** → Kubernetes (EKS, Ingress, Services, Deployments)
* **Configuration Management** → Ansible (install ArgoCD, Prometheus, Grafana)
* **GitOps** → ArgoCD (Continuous Deployment)
* **CI/CD** → GitHub Actions (Workflows for App & Terraform)
* **Code Quality & Security** → Sonar Scanner, SonarCloud, Sonar Gate
* **Monitoring & Alerting** → Prometheus, Grafana, Alertmanager
* **Secrets Management** → GitHub Secrets, AWS Secrets Manager, External Secrets
* **Notifications** → Slack Webhook for real-time alerts
* **Version Control** → Git & GitHub

---

#  Requirements

### Accounts & Cloud Services

* AWS Account (EKS, S3, Route53, ECR, Secrets Manager)
* GitHub (repository, actions, and secrets)
* SonarCloud (for code quality)
* Slack Workspace (for webhook integration)

### Tools & CLI

* Terraform
* kubectl
* helm
* ansible
* docker & docker-compose
* git

### GitHub Secrets (Required Keys)

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `SONAR_TOKEN`
* `DOCKER_USERNAME`
* `DOCKER_PASSWORD`
* `SLACK_WEBHOOK`

---

# Project Workflow & Explanation

This project is divided into **four major stages**:

###  Infrastructure Setup (Terraform)

* Uses **Terraform Registry modules** to provision AWS resources.
* Backend state stored in **S3 bucket**.
* EKS cluster (`v1.29`) with two managed node groups:

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
      min_size      = 1
      max_size      = 3
      desired_size  = 2
    }
    two = {
      name          = "node-group-2"
      instance_types = ["t3.small"]
      min_size      = 1
      max_size      = 2
      desired_size  = 1
    }
  }
}
```

* **Route53** manages DNS.
* **Load Balancer + Ingress** handle traffic.
* Flow: **User → Browser → Route53 → Load Balancer → Ingress → Kubernetes Services → Pods**.

---

### Application Build & CI/CD

* GitHub Actions workflow runs on **push/merge**.
* **Sonar Scanner → SonarCloud → Sonar Gate** ensures code quality.
* Docker images built for:

  * **App (Java + Tomcat)**
  * **DB (MySQL + schema restore)**
  * **Web (Nginx reverse proxy)**
* Images pushed to **AWS ECR**.
* GitHub Secrets handle credentials securely.

Example App Dockerfile:

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

---

### GitOps with ArgoCD

* ArgoCD installed in EKS (via Ansible).
* Watches GitHub repo for manifests: Deployments, Services, Ingress.
* Automatically syncs changes → Continuous Deployment.

---

### Monitoring, Alerts & Notifications

* **Prometheus** scrapes metrics.
* **Grafana** dashboards provide visualization.
* **Alertmanager** sends alerts to **Slack**.
* **External Secrets** syncs with **AWS Secrets Manager** for Kubernetes workloads.

---

# Architecture & Dashboards

###  Overview Architecture

This diagram shows the full flow of the system:

* Users access the app via browser → Route53 → LoadBalancer → Ingress → Services → Pods.
* GitHub Actions handles CI/CD.
* ArgoCD manages GitOps deployment.
* Prometheus & Grafana monitor the cluster.
* SonarCloud ensures code quality.
* Slack receives alerts.

<img width="6000" height="3375" alt="Public Subnet (1)" src="https://github.com/user-attachments/assets/4924f840-ffc4-4f94-84fc-beaebf09ef19" />


---

### ArgoCD Dashboard

Manages GitOps, syncing manifests with EKS.
<img width="1920" height="949" alt="image" src="https://github.com/user-attachments/assets/d2cf92e8-1ee9-40ac-926e-3bc187f89075" />


---

### SonarCloud Dashboard

Ensures code quality with gates before deployment.
![WhatsApp Image 2025-09-20 at 20 15 59_75733796](https://github.com/user-attachments/assets/2f0665eb-234a-475c-850a-09a850061ed4)


---

### 🔹 Prometheus & Grafana

Provides monitoring & visualization of metrics.
![WhatsApp Image 2025-09-21 at 11 40 24_316baa55](https://github.com/user-attachments/assets/dede3545-2ee6-49a5-af32-7a78fb706a50)

![WhatsApp Image 2025-09-21 at 11 40 02_c0ca66d5](https://github.com/user-attachments/assets/e1903285-0ba6-4e76-b56f-729596832aad)

![WhatsApp Image 2025-09-21 at 11 39 21_6cb41056](https://github.com/user-attachments/assets/f2a4678c-f41d-41b2-864a-ccb34e978afe)



---

###  Application (Web UI)

The application deployed on EKS, accessible at:
 **[https://cloudnativegitopsservice.com](https://cloudnativegitopsservice.com)**
![WhatsApp Image 2025-09-20 at 19 37 26_d0b19c43](https://github.com/user-attachments/assets/4a30a3d4-5def-40c2-8a71-96b29c8eada9)


---

# Repository Structure

```
├── terraform/  
│   ├── backend.tf  
│   ├── eks-cluster.tf  
│   ├── main.tf  
│   ├── outputs.tf  
│   ├── terraform.tf  
│   ├── variables.tf  
│  
├── ansible/  
│   ├── install-argocd.yaml  
│   ├── install-kube-prometheus-stack.yaml  
│   ├── inventory.ini  
│  
├── monitoring/  
│   ├── alertmanager-config.yaml  
│   ├── clustersecretstore-aws.yaml  
│   ├── external-secrets-crds.yaml  
│   ├── prometheus-role.yaml  
│   ├── secret-slack-webhook.yaml  
│   ├── test-slack-alert.yaml  
│  
├── docker/  
│   ├── Dockerfile-app  
│   ├── Dockerfile-db  
│   ├── Dockerfile-web  
│   ├── nginvproapp.conf  
│   └── db_backup.sql  
│  
├── k8s/  
│   ├── deployments/  
│   ├── services/  
│   ├── ingress.yaml  
│  
├── .github/workflows/  
│   ├── app-ci-cd.yaml  
│   ├── terraform-iac.yaml  
```

---

#  Project Flow Overview

1. Developer pushes code → **GitHub Actions CI pipeline runs**.
2. **Sonar Scanner checks code quality**.
3. **Docker images built → pushed to AWS ECR**.
4. **Terraform provisions AWS infrastructure**.
5. **ArgoCD syncs manifests → deploys to EKS**.
6. **Prometheus & Grafana monitor metrics**.
7. **Alertmanager notifies Slack** for incidents.
8. End users access the app at **[https://cloudnativegitopsservice.com](https://cloudnativegitopsservice.com)**.

---

# References

* [Terraform Registry](https://registry.terraform.io/)
* [Kubernetes Documentation](https://kubernetes.io/docs/)
* [Docker Official Docs](https://docs.docker.com/)
* [ArgoCD](https://argo-cd.readthedocs.io/)
* [Prometheus](https://prometheus.io/docs/)
* [Grafana](https://grafana.com/docs/)
* [SonarCloud](https://docs.sonarcloud.io/)
* [Slack Webhooks](https://api.slack.com/messaging/webhooks)

---
