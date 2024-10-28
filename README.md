# Dockerizing SpringBoot Application

This guide provides detailed steps to dockerize the **SpringBoot-DevOps** bank application, deploying it with a MySQL database using both manual Docker commands and Docker Compose.

---

## Prerequisites

- Docker installed on your machine  
- Docker Compose installed for automation  
- Ensure port **8000** is open (or change it as needed).  

**Note:** By default, Spring Boot apps run on **port 8080**. We are overriding this to run on **port 8000** using the configuration property `service.port=8000`.

---

## Project Structure

```
SpringBoot-DevOps/
│
├── src/                # Application source code
├── Dockerfile          # Docker configuration for the Spring Boot app
├── docker-compose.yml  # Automated setup configuration
└── README.md           # This documentation file
```

---

## Manual Dockerization Steps

### 1. Clone the Repository and Build the Docker Image

```bash
git clone <repo-url> SpringBoot-DevOps
cd SpringBoot-DevOps

# Build the Docker image for the application
docker build -t springboot-bankapp .
```

### 2. Create a Docker Network

Create a Docker network named `bankapp` to allow the containers to communicate.

```bash
docker network create bankapp
```

### 3. Run the MySQL Database Container

```bash
docker run -itd --name mysql \
  -e MYSQL_ROOT_PASSWORD=Test@123 \
  -e MYSQL_DATABASE=bankappdb \
  --network=bankapp \
  mysql:latest
```

- **`MYSQL_ROOT_PASSWORD`**: Sets the root password for MySQL.  
- **`MYSQL_DATABASE`**: Creates a new database named `bankappdb`.  

### 4. Run the SpringBoot Application Container

```bash
docker run -itd --name BankApp \
  -e SPRING_DATASOURCE_USERNAME="root" \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://mysql:3306/bankappdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" \
  -e SPRING_DATASOURCE_PASSWORD="Test@123" \
  --network=bankapp \
  -p 8000:8000 \
  springboot-bankapp
```

- **`SPRING_DATASOURCE_URL`**: Points to the MySQL container on the `bankapp` network.  
- **`-p 8000:8000`**: Maps the application to **port 8000** on your machine.  
- **Note**: By setting `server.port=8000` in the application properties or environment variables, the app runs on **port 8000** instead of the default **8080**.

### 5. Verify the Running Containers

```bash
docker ps
```

You should see two containers: **MySQL** and **BankApp**.

---

### 6. Access the Application

- For remote instances:
  ```
  http://<public-ip>:8000
  ```
- For local instances:
  ```
  http://localhost:8000
  ```

---

## Automating Setup with Docker Compose

To automate the entire setup, use Docker Compose.


### 1. Start the Services

```bash
docker-compose up -d
```

This command launches both the MySQL and SpringBoot application containers in detached mode.

### 2. Verify the Running Services

```bash
docker ps
```

---

## Stopping and Cleaning Up

### 1. Stop and Remove the Containers

```bash
docker-compose down
```

### 2. Manually Remove Docker Network (Optional)

If needed, remove the custom network:

```bash
docker network rm bankapp
```

---