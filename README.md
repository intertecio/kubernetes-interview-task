# Kubernetes Interview Task

The given task was split into multiple parts/stages which allowed me to complete it. The steps can be [checked below](#steps).

## Folder structure

To better structure the repository, we can logically split the resources in three components. Those are:

- *Application resources*
- *Infrastructure resources*
- *Scripts*

For each logical unit we will create a folder which will contain all the resources for the corresponding unit.

The folder structure will look similiaar to the one displayed in the tree diagram below.

Note: _The diagram was generated using the command `tree -L 2 -I "node_modules"`_.

```
.
├── Dockerfile
├── README.md
├── app
│   ├── app.js
│   ├── bin
│   ├── ...
│   ├── package-lock.json
│   └── package.json
├── infrastructure
├── helm
│   └── app
└── terraform
    ├── manifests
    ├── ...
    ├── provider.tf
    ├── variables.tf
    └── vpc.tf
│
```

## Technology stack used

To complete this project I used: 

- [AWS](https://aws.amazon.com/) as a Cloud Provider, 
- [Terraform](https://www.terraform.io/) as a IaC tool to provision resources on AWS, 
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) as a CD tool, which will deploy the applications. 

Even do CI packing and testing was not integrated (due to time scope), possibility is [Github Actions](https://docs.github.com/en/actions) since the application resides there initialy.

## Steps

### Step 1

To create a demo/skeleton application for Node.JS, I used the Express Framework for Node.JS which allows a command to create an application's skeleton.

```bash
npx express-generator
npm install
npm start
```

Using `npm install` I installed all dependencies needed for the application. Then, using `npm start`, I started the application to see if it was functional and would operate as it should.

### Step 2

The second step involved "Dockerization" of my demo application. Because we'll require separate versions of the application to demonstrate a blue-green deployment, I built the 'blue' version first, then built the 'green' version. The application have a minor change which could be spotted once deployed.

I wanted to use multi-stage build which will optimize my building process and at end will produce me a minimal runtime image of my application. This way the final application image will be as little as possible.

After that, I run the container locally to see if it is functioning and if any error appear.

```bash
docker build -t node-demo-app:blue .
docker run --name node-demo-app -p 3000:3000 -d node-demo-app:blue
# Change something in code
docker build -t node-demo-app:green .
docker run --name node-demo-app -p 3000:3000 -d node-demo-app:green
```

Note: Later we will push these images to the ECR repository we create.

### Step 3

This step I used Terraform to provision all the resources present on the AWS Account. 

#### Terraform

I started with connecting to an AWS account, where later I executed the below mentioned command to provision a S3 bucket. This S3 bucket will be used to store Terraform's state file. The Terraform execution will happen locally for convenience.

```bash
aws s3api create-bucket \
    --bucket <BUCKET_NAME> \
    --region <REGION> \
    --create-bucket-configuration LocationConstraint=eu-central-1
```

With the S3 bucket setup in place, everything regarding Cloud Resources else onwards will be provisioned and managed from Terraform.

#### AWS Network, Role(s)&Permission, and the Cluster
 
The steps to provision an EKS cluster were:

- Provision a `VPC` with `Private Subnets` and `Public Subnets` in each AZ. Provison a `NAT Gateway` so resources in the Private Subnet could reach out to the internet. And provision `IGW` for Public Subnets.

- Next, I wrote code for creating `IAM roles` for the EKS Cluster and Node Group.

- Provisioning of `EKS Cluster` and `Node Groups`.


Note: To make the Cluster more robust and flexible, I added the `EBS CSI Driver add-on` which will dynamically spin up EBS volumes for Pods through PersistentVolumeClaim. `ALB Controller` was also installed on the Cluster using Helm, to make use of the managed Load Balancing service offered by AWS.

### Step 4

In order to deploy the applications on the Cluster, my choice was to deploy ArgoCD and manage the deployment through the CRD that ArgoCD provides.

To fetch the admin password of the ArgoCD I used the command:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Step 5

With ArgoCD deployed and functional. I could then execute the commands to create Application resource in ArgoCD for both versions of the application.

The manifests are located in `infrastructure/terraform/manifests/argocd/applications/*.yaml`.

### Step 6

With both versions of the applications deployed on our EKS cluster, I created a ALB Ingress Controller which will point to one of the versions of the application (primarily blue version).

Even though the blue-green deployment was not automated. We could simulate one with changing the parameter `spec.rules.http.paths.backend.service.name` in the file `infrastructure/terraform/manifests/app_ingress.yaml`

## Possible Improvements

- ECR could be leveraged for Helm Chart storage. In this demo, the ECR is used only for storing the Docker images.

- Automating of the blue-green switch while leveraging Github Actions, and a "Manual-approve job" to do the switch.
