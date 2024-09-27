![license](https://badgen.net/github/license/flavien-perier/dockerfile-sandbox-dev)
[![docker pulls](https://badgen.net/docker/pulls/flavienperier/sandbox-dev)](https://hub.docker.com/r/flavienperier/sandbox-dev)
[![ci status](https://badgen.net/github/checks/flavien-perier/dockerfile-sandbox-dev)](https://github.com/flavien-perier/dockerfile-sandbox-dev)

# Dockerfile Sandbox-dev

Development environment accessible with SSH.

Contains development environments for:

- Rust
- Java (with GraalVM and Maven)
- Python
- NodeJs

## Env variables

- PASSWORD: Default sandbox password

## Ports

- 22: SSH (default username is admin)

## Volumes

- /home/admin

## Docker-compose example

```yaml
sandbox-dev:
    image: flavienperier/sandbox-dev
    container_name: sandbox-dev
    restart: always
    volumes:
      - ./documents:/home/admin
    ports:
      - 2222:22
    environment:
      PASSWORD: password
```
