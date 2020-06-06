### Overview

Docker container for a Jenkins server.

### Commands

**Start the Jenkins container locally**

```bash
python3.8 -m venv env
source ./env/bin/activate
python3.8 -m pip install -r requirements.txt

python3.8 push-image.py

deactivate

docker container stop jenkins-jarombek-io
docker container rm jenkins-jarombek-io

docker container run --name jenkins-jarombek-io -p 8080:8080 -p 50000:50000 jenkins-jarombek-io:latest
```

### Resources