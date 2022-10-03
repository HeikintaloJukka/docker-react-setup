# Play video when scrolled into view

TODO

## Install steps
### Docker desktop install instructions
From: https://docs.docker.com/desktop/install/archlinux/

- sudo pacman -S gnome-terminal
- dl: https://docs.docker.com/desktop/release-notes/
- sudo pacman -U ./docker-desktop-4.12.0-x86_64.pkg.tar.zst
- systemctl --user start docker-desktop

<br />

### Docker cli install instructions

From: https://wiki.archlinux.org/title/Docker

- sudo pacman -S docker
- sudo usermod -aG docker $USER
- RELOG

<br />

### Troubleshooting:

#### Credential store not initialized:

- gpg --generate-key
- pass init 87######################################
- Now docker-desktop sign in should work

<br />

#### Error: still waiting to update HTTP proxy on http-proxy-control.sock after
From: https://docs.docker.com/desktop/install/linux-install/

- ls -al /dev/kvm
- sudo usermod -aG kvm $USER
- RELOG

#### Support rootless

From: https://docs.docker.com/engine/security/rootless/#prerequisites
- grep ^$(whoami): /etc/subuid
- /etc/subuid and /etc/subgid should contain at least 65,536 subordinate UIDs/GIDs for the user. In the following example, the user testuser has 65,536 subordinate UIDs/GIDs (231072-296607).

- sudo pacman -S fuse-overlayfs
- /etc/sysctl.conf
```
kernel.unprivileged_userns_clone=1
```
- sudo sysctl --system
- reboot

Important most likely allowed docker-desktop to start:
- grep "$USER" /etc/subuid >> /dev/null 2&>1 || (echo "$USER:100000:65536" | sudo tee -a /etc/subuid)
- grep "$USER" /etc/subgid >> /dev/null 2&>1 || (echo "$USER:100000:65536" | sudo tee -a /etc/subgid)
- reboot

At this point docker-desktop should succesfully start

#### Docker-compose doesn't work:

- Enable Docker Compose V1/V2 compatibility mode
- Apply and restart
- reboot?

#### The path /mnt/GITWORK/ is not shared from the host and is not known to Docker.

- You can configure shared paths from Docker -> Preferences... -> Resources -> File Sharing.
- Apply and restart

At this point docker-desktop should manage to build

<br />

### Dockerize react app instructions 

From: https://towardsdev.com/react-app-in-docker-a1128c7147ba

- npx create-react-app scrollview-test
- cd scrollview-test
- touch Dockerfile
```
FROM node:14.9.0 AS build-step

WORKDIR /build
COPY package.json package-lock.json ./
RUN npm install

COPY . .
RUN npm run build

FROM nginx:1.18-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build-step /build/build /frontend/build
```
- touch nginx.conf
```
user  nginx;
worker_processes  1;

events {
  worker_connections  1024;
}

http {
  include /etc/nginx/mime.types;
  server {
    listen 80;
    root /frontend/build;
    index index.html;

    location / {
      try_files $uri /index.html;
    }
  }
}
```
	
- touch .dockerignore
```
.gitignore file into the .dockerignore
Don't add build folder in dockerignore to allow it
```


- touch docker-compose.yml
```
version: '3.2'
services:
  scrollview-test:
    build:
      context: .
      dockerfile: 'Dockerfile'
    ports:
      - '3000:80' #maps the port of the nginx server (80) to an external port 3000.
    volumes:
      - ./:/frontend
```

- docker-compose up -d --build scrollview-test

Visible at localhost:3000
