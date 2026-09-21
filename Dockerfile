FROM eclipse-temurin:17-jre

WORKDIR /app

# Wildcard copy so this keeps working as the pipeline bumps the
# version and the jar filename changes on every release build
COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]