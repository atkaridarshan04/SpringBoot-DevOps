# SpringBoot-DevOps Project

This guide provides detailed steps to **dockerize**, **publish**, and **deploy** the **SpringBoot-DevOps** bank application using **Docker** and **Kubernetes**. It covers both manual setup and automation with **Docker Compose** and **Kubernetes** using a **Kind cluster**.

## Table of Contents

| **Section**                                   | **Description**                                          |
|-----------------------------------------------|----------------------------------------------------------|
| [Dockerizing the Application](#dockerizing-the-application) | Containerize and run the Spring Boot app with MySQL. |
| [Tagging and Pushing to Docker Hub](#tagging-and-pushing-to-docker-hub) | Push the Docker image to Docker Hub for sharing. |
| [Deploying on Kubernetes](#deploying-on-kubernetes)         | Deploy the app using Kubernetes and Kind. |

---

## Dockerizing the Application  

This section explains how to containerize the **SpringBoot-DevOps** bank application and set it up manually and via Docker Compose.

### Manual Dockerization Steps  

#### 1. Clone the Repository and Build the Docker Image  

```bash
git clone https://github.com/atkaridarshan04/SpringBoot-DevOps.git
cd SpringBoot-DevOps

# Build the Docker image for the application
docker build -t springboot-bankapp .
```

#### 2. Create a Docker Network  

Create a custom network for inter-container communication:

```bash
docker network create bankapp
```

#### 3. Run the MySQL Database Container  

Start a MySQL container:

```bash
docker run -itd --name mysql \
  -e MYSQL_ROOT_PASSWORD=Test@123 \
  -e MYSQL_DATABASE=bankappdb \
  --network=bankapp \
  mysql:latest
```

#### 4. Run the SpringBoot Application Container  

Launch the Spring Boot application:

```bash
docker run -itd --name BankApp \
  -e SPRING_DATASOURCE_USERNAME="root" \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://mysql:3306/bankappdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" \
  -e SPRING_DATASOURCE_PASSWORD="Test@123" \
  --network=bankapp \
  -p 8000:8000 \
  springboot-bankapp
```

#### 5. Verify the Running Containers  

Check if both containers are up and running:

```bash
docker ps
```

#### 6. Access the Application  

- **Remote Instance**:  
  `http://<public-ip>:8000`  
- **Local Instance**:  
  `http://localhost:8000`  

---

### Automating Setup with Docker Compose  

#### 1. Start the Services  

Launch the containers in detached mode:

```bash
docker-compose up -d
```

#### 2. Verify the Running Services  

Confirm that the services are running:

```bash
docker ps
```

---

### Stopping and Cleaning Up  

#### 1. Stop and Remove the Containers  

Stop and remove all containers created by Docker Compose:

```bash
docker-compose down
```

#### 2. Remove Docker Network (Optional)  

To clean up the network:

```bash
docker network rm bankapp
```

---

## Tagging and Pushing to Docker Hub  

To publish the Docker image to **Docker Hub**, follow these steps:

### 1. Login to Docker Hub  

Authenticate with Docker Hub:

```bash
docker login
```

### 2. Tag the Docker Image  

Label your image for pushing:

```bash
docker tag springboot-bankapp atkaridarshan04/springboot-bankapp:v1
```

### 3. Push the Image to Docker Hub  

Upload the image to your Docker Hub repository:

```bash
docker push atkaridarshan04/springboot-bankapp:v1
```

---

## Deploying on Kubernetes  

This section details deploying the application using a **Kind** (Kubernetes-in-Docker) cluster.

### Kubernetes Setup with Kind Cluster

#### 1. Install Kind  

Download and install Kind:

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

#### 2. Verify the Installation  

Check the installed version of Kind:

```bash
kind version
```

#### 3. Create a Kind Cluster  

Create a `kind-config.yaml` file, as Kind runs Kubernetes in Docker containers, and by default, NodePorts might not be exposed outside the host (Docker bridge network).

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30008
        hostPort: 30008
        protocol: TCP

```
Set up a new Kind cluster:
```bash
kind create cluster --config kind-config.yaml
```

View the created cluster
```bash
kubectl cluster-info --context kind-kind
```

#### 4. Create and Set Namespace  

Establish a namespace for your application:

```bash
kubectl create ns bankapp
kubectl config set-context --current --namespace=bankapp
```

---

### Deploying Application and Services  

1. **Apply the Persistent Volume** configuration:  
   ```bash
   kubectl apply -f pv.yml
   ```

2. **Apply the Persistent Volume Claim**:  
   ```bash
   kubectl apply -f pvc.yml
   ```

3. **Apply Secrets** for BankApp and MySQL credentials:  
   ```bash
   kubectl apply -f secrets.yml
   ```

4. **Deploy the MySQL Database**:  
   ```bash
   kubectl apply -f mysql.yml
   ```

5. **Deploy the Spring Boot Application**:  
   ```bash
   kubectl apply -f bankapp.yml
   ```

6. **Verify the Pods and Services**:  
   ```bash
   kubectl get pods
   kubectl get svc
   ```

7. **Access the Application** at:  
   ```plaintext
   http://<instance-ip>:30008
   ```

---

### Cleanup  

To remove all resources, delete the **bankapp** namespace:

```bash
kubectl delete ns bankapp
kind delete cluster
```

---
