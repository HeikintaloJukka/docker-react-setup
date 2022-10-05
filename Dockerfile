# build environment
FROM node:18-alpine AS build-step
WORKDIR /buildapp
ENV PATH /buildapp/node_modules/.bin:$PATH
COPY package.json ./
COPY package-lock.json ./
RUN npm ci --silent
COPY . .
RUN npm run build

# production environment
FROM nginx:1.22-alpine
COPY --from=build-step /buildapp/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
