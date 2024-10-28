#----- Stage 1 -----
FROM maven:3.8.3-openjdk-17 as builder 

WORKDIR /app

COPY . .

RUN mvn clean install -DskipTests=true

#----- Stage 2 -----
FROM openjdk:17-alpine as deployer

COPY --from=builder target/*.jar app.jar

EXPOSE 8000

CMD ["java", "-jar", "app.jar", "--server.port=8000"]