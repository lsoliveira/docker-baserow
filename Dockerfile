FROM tiredofit/nginx:latest

ENV BASEROW_VERSION=0.7.0 \
    NGINX_ENABLE_CREATE_SAMPLE_HTML=FALSE

RUN apk update && \
    apk upgrade && \
    apk add -t .baserow-build-deps \
                g++ \
                git \
                jpeg-dev \
                make \
                mariadb-dev \
                nodejs \
                postgresql-dev \
                py3-pip \
                python3-dev \
                yarn \
                && \
    \
    apk add -t .baserow-run-deps \
                libpq \
                mariadb-connector-c-dev \
                nodejs \
                python3 \
                py3-virtualenv \
                postgresql-client \
                && \
    \
    ln -s /usr/bin/python3 /usr/bin/python && \
    yarn global add mjml && \
    git clone https://gitlab.com/bramw/baserow/ /app && \
    cd /app && \
    git checkout "${BASEROW_VERSION}" && \
    \
    ## Build Frontend
    cd /app/web-frontend && \
    yarn install && \
    cd /app/web-frontend && \
    /app/web-frontend/node_modules/nuxt/bin/nuxt.js build --config-file config/nuxt.config.demo.js && \
    \
    ## Build Backend
    cd /app/ && \
    virtualenv -p python3 /app/backend/env && \
    source backend/env/bin/activate && \
    pip3 install -e ./backend && \
    deactivate && \
    \
    ## Cleanup
    apk del .baserow-build-deps && \
    rm -rf /root/.cache /root/.config /var/cache/apk/*

ADD install /
