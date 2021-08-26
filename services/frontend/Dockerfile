FROM ghcr.io/brandonsimon1/brandonsimon1/docker-node-nginx-alpine:latest 
COPY . /repo
WORKDIR /repo
RUN yarn install --ignore-engines
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf 
ENTRYPOINT ./start.sh