FROM node:16.13.1

WORKDIR /home/node/app

COPY ./package*.json ./
RUN npm install && npm i -g truffle

COPY ./ ./

USER root

ENTRYPOINT ["/bin/bash"]