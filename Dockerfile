FROM 116370539244.dkr.ecr.eu-west-1.amazonaws.com/flutter-sonar-scanner:latest

LABEL version="2.0.1" \
      repository="https://github.com/hassan-saleh-ml/sonarqube-scan-action" \
      homepage="https://github.com/hassan-saleh-ml/sonarqube-scan-action" \
      maintainer="hassan-saleh-ml" \
      com.github.actions.name="SonarQube Flutter Scan" \
      com.github.actions.description="Scan your Flutter code with SonarQube to detect Bugs, Vulnerabilities and Code Smells!" \
      com.github.actions.icon="check" \
      com.github.actions.color="green"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY cleanup.sh /cleanup.sh
RUN chmod +x /cleanup.sh
ENTRYPOINT ["/entrypoint.sh"]
