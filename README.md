docker desktop install instructions from:
https://docs.docker.com/desktop/install/archlinux/

sudo pacman -S gnome-terminal


dl: https://docs.docker.com/desktop/release-notes/

sudo pacman -U ./docker-desktop-<version>-<arch>.pkg.tar.zst
sudo pacman -U ./docker-desktop-4.12.0-x86_64.pkg.tar.zst

systemctl --user start docker-desktop

docker cli install instructions from (also troubleshooting docker desktop):
https://wiki.archlinux.org/title/Docker
sudo pacman -S docker
sudo usermod -aG docker $USER
relog

troubleshooting:
Credential store not initialized:

gpg --generate-key
pass init 87######################################
now you can sign in

Error:
still waiting to update HTTP proxy on http-proxy-control.sock after
try to reboot

have to support reqs:
https://docs.docker.com/desktop/install/linux-install/

ls -al /dev/kvm
sudo usermod -aG kvm $USER

logout login

support rootless?
https://docs.docker.com/engine/security/rootless/#prerequisites
grep ^$(whoami): /etc/subuid
/etc/subuid and /etc/subgid should contain at least 65,536 subordinate UIDs/GIDs for the user. In the following example, the user testuser has 65,536 subordinate UIDs/GIDs (231072-296607).

sudo pacman -S fuse-overlayfs
/etc/sysctl.conf
	kernel.unprivileged_userns_clone=1
sudo sysctl --system
reboot

grep "$USER" /etc/subuid >> /dev/null 2&>1 || (echo "$USER:100000:65536" | sudo tee -a /etc/subuid)
grep "$USER" /etc/subgid >> /dev/null 2&>1 || (echo "$USER:100000:65536" | sudo tee -a /etc/subgid)
reboot

NOW IT FINALLY STARTS

Enable Docker Compose V1/V2 compatibility mode
Apply and restart
reboot?

The path /mnt/GITWORK/ is not shared from the host and is not known to Docker.
You can configure shared paths from Docker -> Preferences... -> Resources -> File Sharing.
Apply and restart

BUILDS CORRECTLY

dockerize react app instructions from:
https://towardsdev.com/react-app-in-docker-a1128c7147ba

npx create-react-app scrollview-test

cd scrollview-test

touch Dockerfile
	FROM node:14.9.0 AS build-step

	WORKDIR /build
	COPY package.json package-lock.json ./
	RUN npm install

	COPY . .
	RUN npm run build

	FROM nginx:1.18-alpine
	COPY nginx.conf /etc/nginx/nginx.conf
	COPY --from=build-step /build/build /frontend/build

touch nginx.conf
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

touch .dockerignore
	.gitignore file into the .dockerignore


touch docker-compose.yml
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

docker-compose up -d --build scrollview-test

visible at localhost:3000