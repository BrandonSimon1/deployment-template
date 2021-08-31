FROM node:lts
COPY . /repo
WORKDIR /repo
RUN yarn
CMD ["yarn", "db-migrate-up"]