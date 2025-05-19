FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    wget

RUN curl -1sLf 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/setup.deb.sh' | bash

RUN apt-get update && apt-get install -y erlang

ARG RABBITMQ_DEB_URL=https://github.com/rabbitmq/server-packages/releases/download/alphas.1747625884815/rabbitmq-server_4.2.0-alpha.d68ca77e-1_all.deb
RUN wget -O /tmp/rabbitmq-server.deb "$RABBITMQ_DEB_URL"

RUN apt-get update && apt-get install -y /tmp/rabbitmq-server.deb

RUN rm /tmp/rabbitmq-server.deb && apt-get clean

EXPOSE 5672 15672

CMD ["rabbitmq-server"]

