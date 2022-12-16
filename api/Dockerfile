FROM node:18-alpine

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

WORKDIR /home/node/app

COPY package*.json yarn*.lock ./

USER node

RUN npm install -g yarn
RUN yarn install

COPY --chown=node:node . .

EXPOSE 4000

CMD [ "yarn", "dev" ]