# Production Web App Deployment – Cloud Engineer Assessment

## Project Overview

This repository contains the complete infrastructure-as-code, CI/CD pipeline, and containerized application for deploying a production-like web application on AWS using ECS Fargate, provisioned via Terraform.

---

## Architecture Overview

The architecture follows a standard two-tier, multi-AZ pattern:

- **Internet → ALB (Port 80)**: All inbound traffic enters through an Application Load Balancer.
- **ALB → ECS Fargate Tasks**: Traffic is distributed across two ECS Fargate tasks running in private subnets across two Availability Zones (AZ-A and AZ-B).
- **NAT Gateways**: Each public subnet hosts a NAT Gateway, allowing the private ECS tasks to pull images from ECR and reach the internet without being publicly exposed.
- **CloudWatch**: All container logs and performance metrics are shipped to AWS CloudWatch for observability.

---

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD pipeline
├── calculator-app/
│   ├── Dockerfile              # Multi-stage Docker build
│   ├── src/                    # Application source
│   └── package.json
└── terraform/
    ├── main.tf                 # Root module wiring all sub-modules
    ├── variables.tf
    ├── terraform.tfvars
    ├── outputs.tf
    ├── provider.tf
    └── modules/
        ├── vpc/                # VPC, subnets, IGW, NAT, route tables
        ├── security_group/     # ALB and ECS security groups
        ├── alb/                # Application Load Balancer + target group
        ├── ecr/                # Elastic Container Registry
        ├── ecs/                # ECS Cluster, Task Definition, Service (Fargate)
        ├── iam/                # IAM roles and policies
        ├── cloudwatch/         # Log groups, metrics
        └── autoscaling/        # ECS Auto Scaling policies
```

---

## Design Decisions

### 1. ECS Fargate over EC2
Although ECS Fargate may be more expensive than EC2 for continuously running workloads, it reduces operational overhead by eliminating EC2 instance management,OS patching,Capacity management,Cluster maintenance,This improves engineering efficiency and reduces infrastructure management complexity.

### 2. Multi-AZ Deployment
ECS tasks are distributed across two private subnets in two separate Availability Zones. This ensures the application remains available even if one AZ experiences an outage. The ALB spans both public subnets and load-balances traffic across both tasks.

### 3. Private Subnets for Application Workloads
ECS tasks run in private subnets with no direct internet access. Outbound internet access (e.g., pulling from ECR) is routed through NAT Gateways in the public subnets. This is a security best practice — the application surface is never directly reachable from the internet.

### 4. Application Load Balancer
An ALB was chosen over an NLB because the application serves HTTP traffic and benefits from Layer 7 features like path-based routing, health checks at the HTTP level, and easier HTTPS termination in future iterations.

### 5. Multi-stage Docker Build
The Dockerfile uses a two-stage build: Node 20 builds the application in the first stage, and only the compiled static assets (`dist/`) are copied into a lightweight Node 20 Alpine production image. This significantly reduces the final image size and removes build tooling from the production artifact.

### 6. Terraform Modular Structure
Infrastructure is split into independent modules (vpc, alb, ecs, ecr, iam, cloudwatch, autoscaling). This makes each component independently testable, reusable across environments, and easy to reason about. The root `main.tf` wires modules together via outputs.

### 7. GitHub Actions CI/CD Pipeline
The pipeline triggers on every push to `main`. It builds and tags the Docker image, pushes it to ECR, downloads the existing ECS task definition, renders a new revision with the updated image, and deploys it to the ECS service — waiting for service stability before completing. All sensitive values (keys, cluster names, repository URLs) are stored as GitHub Secrets.

### 8. Auto Scaling
ECS Service Auto Scaling is configured with configurable `min_capacity` and `max_capacity` to handle traffic spikes without manual intervention.

---

```
## Trade-offs Considered

**Fargate over EC2**
Fargate eliminates EC2 instance management (no patching, no capacity planning). However, at sustained 24/7 load, a right-sized EC2 instance can be cheaper per compute hour than Fargate's per-second billing. For a low-to-medium traffic application like this, Fargate's operational simplicity outweighs the cost difference.

**Single NAT Gateway**
A single NAT Gateway is used to reduce cost. Both private subnets route outbound traffic through this one NAT Gateway. The trade-off is that if the NAT Gateway's AZ experiences an outage, outbound connectivity for both private subnets is affected. For a production-grade setup, a NAT Gateway per AZ would eliminate this risk, but for this assessment a single NAT keeps infrastructure cost minimal.

**HTTP only, no HTTPS**
Kept simple for assessment scope. In a real production environment, an ACM certificate would be attached to the ALB with an HTTPS listener on port 443 and an HTTP to HTTPS redirect enforced. Skipping this here avoids domain and certificate setup but is not acceptable in production.

**Docker Image Tagging with Git Commit SHA**
Each Docker image is tagged with the Git commit SHA in the CI/CD pipeline. This ensures every build is uniquely identifiable, fully traceable to its source commit, and any previous version can be redeployed on demand without ambiguity.

**Local Terraform State**
Terraform state is stored locally for this assessment. In a team or production setting, state must be stored remotely in an S3 bucket with DynamoDB locking to prevent concurrent modifications and state corruption.

**Modular Terraform over a flat structure**
Breaking infrastructure into modules (vpc, alb, ecs, ecr, iam, cloudwatch, autoscaling) adds some initial complexity compared to a single flat file. The benefit is that each module is independently maintainable, reusable across environments, and easier to test in isolation.
```
---

## Cost Awareness and Optimization

### Current Cost Drivers
- **ECS Fargate tasks**: Billed per vCPU and GB of memory per second while running.
- **NAT Gateways**: NAT Gateway pricing includes both hourly charges and data processing costs. Since ECS tasks run in private subnets, outbound internet access requires NAT.
- **Application Load Balancer**: Fixed hourly cost plus LCU charges based on traffic.
- **ECR**: Storage cost per GB of stored image data.
- **CloudWatch**: Log ingestion and storage charges.



### Optimization Approaches

**Right-size tasks**: Start with the minimum CPU/memory that keeps the application stable under expected load. For a static React app served by `serve`, very low resource allocations (e.g., 256 CPU units, 512MB) are typically sufficient.

**Auto Scaling**: The autoscaling module ensures tasks scale out only when needed and scale back in during low-traffic periods, avoiding over-provisioning at rest.

**Single NAT Gateway**: Can use a single NAT Gateway for the  ECS tasks that runs across 2 Availability Zones in the same region

**ECR lifecycle policies**: Add lifecycle rules to automatically delete untagged or old images from ECR to control storage costs.

**CloudWatch log retention**: Set a log retention policy (e.g., 7–30 days) on log groups rather than retaining logs indefinitely.

---

## How to Deploy

### 1. Provision Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Configure GitHub Secrets

Set the following secrets in your GitHub repository:

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM user access key |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `AWS_REGION` | AWS region (e.g., `ap-south-1`) |
| `ECR_REPOSITORY` | ECR repository name |
| `ECS_CLUSTER` | ECS cluster name |
| `ECS_SERVICE` | ECS service name |
| `ECS_TASK_DEFINITION` | Task definition family name |
| `CONTAINER_NAME` | Container name in task definition |

### 3. Trigger Deployment

Push any change to the `main` branch. The GitHub Actions workflow will automatically build the Docker image, push it to ECR, and deploy the updated task to ECS.

---

## Monitoring

Application logs are streamed to AWS CloudWatch Logs. The CloudWatch module provisions the log group and wires the ECS task definition to ship container stdout/stderr automatically. Metrics such as CPU and memory utilization are available in the ECS console and can be used as Auto Scaling triggers.
