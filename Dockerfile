FROM ubuntu:24.04

# Set our our meta data for this container.
LABEL name="FlyingFlip Studios, LLC. Platform Docker Container"
LABEL author="Michael R. Bagnall <mbagnall@flyingflip.com>"

WORKDIR /root

ENV TERM=xterm

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Update apt repos and install base apt packages.
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  git \
  libnss3 \
  nano \
  netcat-openbsd \
  ntp \
  redis-server \
  sudo \
  vim \
  wget \
  zip \
  gcc \
  g++ \
  make \
  mariadb-client \
  curl \
  net-tools \
  python3 \
  gettext \
  rsync \
  unzip \
  libgd-dev

# Install PHP, PHP packages, Postgresql, and Apache2 apt packages.
RUN apt-get install -y \
  imagemagick \
  apache2 \
  apache2-utils

# Add ondrej/php PPA repository for PHP.
RUN apt-get update && apt-get install -y gpg && echo -n 'deb http://ppa.launchpad.net/ondrej/php/ubuntu jammy main' > /etc/apt/sources.list.d/ondrej-ubuntu-php-jammy.list && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C && \
  apt-get update -y && \
  apt-get upgrade -y

# RUN wget https://launchpad.net/ubuntu/+source/icu/70.1-2/+build/23145450/+files/libicu70_70.1-2_amd64.deb && \
#   dpkg -i libicu70_70.1-2_amd64.deb

RUN wget https://launchpad.net/ubuntu/+source/icu/70.1-2ubuntu1/+build/23839596/+files/libicu70_70.1-2ubuntu1_arm64.deb && \
  dpkg -i libicu70_70.1-2ubuntu1_arm64.deb

RUN apt-get install -y \
  php8.2 \
  php8.2-bcmath \
  php8.2-bz2 \
  php8.2-cli \
  php8.2-common \
  php8.2-curl \
  php8.2-dba \
  php8.2-dev \
  php8.2-gd \
  php8.2-mbstring \
  php8.2-mysql \
  php8.2-opcache \
  php8.2-apcu \
  php8.2-mongodb \
  php8.2-readline \
  php8.2-soap \
  php8.2-zip \
  php8.2-pgsql \
  php8.2-dev \
  php8.2-xml \
  php8.2-redis \
  php8.2-uuid \
  php8.2-imap \
  php8.2-intl \
  php8.2-uploadprogress \
  libapache2-mod-php8.2

RUN useradd apache2
COPY etc/apache2/envvars /etc/apache2/envvars
COPY etc/apache2/apache2-noauth.conf /etc/apache2/apache2-noauth.conf
COPY etc/apache2/sites-available/00x-default.conf /etc/apache2/sites-available/00x-default.conf
RUN rm /etc/apache2/sites-enabled/000-default.conf

COPY etc/php/8.2/apache2/php.ini /etc/php/8.2/apache2/php.ini

COPY /osticket/osticket.zip /var/www/osticket.zip
RUN unzip /var/www/osticket.zip -d /var/www

# Add our localhost certificate
ADD etc/ssl/localhost.crt /etc/ssl/certs/localhost.crt
ADD etc/ssl/localhost.key /etc/ssl/private/localhost.key

RUN echo 'Mutex posixsem' >> /etc/apache2/apache2-auth.conf
RUN echo 'Mutex posixsem' >> /etc/apache2/apache2-noauth.conf
RUN echo 'Mutex posixsem' >> /etc/apache2/apache2.conf

# Configure Apache. Be sure to enable apache mods or you're going to have a bad time.
RUN rm -rf /var/www/html \
  && a2enmod rewrite \
  && a2enmod actions \
  && a2enmod alias \
  && a2enmod deflate \
  && a2enmod dir \
  && a2enmod expires \
  && a2enmod headers \
  && a2enmod mime \
  && a2enmod negotiation \
  && a2enmod setenvif \
  && a2enmod proxy \
  && a2enmod proxy_http \
  && a2enmod speling \
  && a2enmod remoteip \
  && a2enmod ssl && \
  service apache2 restart

RUN curl -sS https://getcomposer.org/installer | php -- \
  --install-dir=/usr/local/bin \
  --filename=composer

# Add our startup message on the container.
ADD conf/startup.sh /root/.bashrc

# Our startup script used to install Drupal (if configured) and start Apache.
ADD conf/run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

WORKDIR /var

CMD [ "/run-httpd.sh" ]
