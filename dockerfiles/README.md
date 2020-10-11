### Overview

Dockerfiles for images used throughout my infrastructure, applications, and CI/CD.

### Commands

**Build the Dockerfiles locally**

```bash
docker image build -t pipenv-flask:latest -f pipenv-flask.dockerfile .
```

### Files

| Filename                              | Description                                                                  |
|---------------------------------------|------------------------------------------------------------------------------|
| `pipenv-flask.dockerfile`             | Dockerfile for an image that installs `pipenv` and exposes a port for flask. |