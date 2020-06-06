### Overview

Docker container for a Jenkins server.

### Commands

**Run the Jenkins container locally.**

```bash
docker container stop jenkins-jarombek-io
docker container rm jenkins-jarombek-io

docker image build -t jenkins-jarombek-io:latest .
docker container run --name jenkins-jarombek-io -p 8080:8080 -p 50000:50000 jenkins-jarombek-io:latest
```

### Resources