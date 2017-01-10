FROM elixir:1.4-slim

RUN apt-get update && apt-get -y install \
        git make g++ wget curl build-essential locales python \
        mysql-client \
        imagemagick \
        # for wkhtmltopdf
        xvfb libxrender1 xfonts-utils xfonts-base xfonts-75dpi \
        libfontenc1 x11-common xfonts-encodings libxfont1 \
        ttf-freefont fontconfig dbus && \
        curl -sL https://deb.nodesource.com/setup_6.x | bash && \
        apt-get -y install nodejs && \
        rm -rf /var/lib/apt/lists/*

# Set the locale
RUN locale-gen en_US.UTF-8 && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN \
    mkdir -p /opt/app && \
    chmod -R 777 /opt/app && \
    update-ca-certificates --fresh

# Install wkhtmltopdf for event certificates
RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -P /tmp/ && \
        cd /opt/ && \
        tar xf /tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz && \
        rm /tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz

# Add local node module binaries to PATH
ENV PATH=./node_modules/.bin:$PATH \
    HOME=/opt/app

# Install Hex+Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /opt/app

# Set exposed ports
EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

# Same with npm deps
ADD package.json package.json
RUN npm install

ADD . .

# Run frontend build, compile, and digest assets
RUN brunch build --production && \
    mix do compile, phoenix.digest

# USER default

CMD ["mix", "phoenix.server"]
