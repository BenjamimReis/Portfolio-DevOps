## 📁 terraform

### **main.tf**

```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}
```

### **variables.tf**

```hcl
variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "devops-cluster"
}

variable "eks_role_arn" {}

variable "subnet_ids" {
  type = list(string)
}
```

### **outputs.tf**

```hcl
output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}
```

---

## 📁 app

### **Dockerfile**

```dockerfile
FROM python:3.10
WORKDIR /app
COPY src/requirements.txt .
RUN pip install -r requirements.txt
COPY src/ .
CMD ["python", "app.py"]
```

### 📁 src/app.py

```python
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Aplicação DevOps no ar!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

### **requirements.txt**

```txt
flask
```

---

## 📁 k8s

### **namespace.yaml**

```yaml
apiVersion: v1
type: Namespace
metadata:
  name: devops-app
```

### **deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-app
  namespace: devops-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: devops-app
  template:
    metadata:
      labels:
        app: devops-app
    spec:
      containers:
        - name: app
          image: docker.io/seuusuario/devops-app:latest
          ports:
            - containerPort: 5000
```

### **service.yaml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: devops-service
  namespace: devops-app
spec:
  type: LoadBalancer
  selector:
    app: devops-app
  ports:
    - port: 80
      targetPort: 5000
```

---

## 📁 .github/workflows

### **deploy.yml**

```yaml
name: Deploy Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Build Docker image
        run: docker build -t devops-app .

      - name: Dummy deploy (simulação)
        run: echo "Pipeline funcionando!"
```

---
