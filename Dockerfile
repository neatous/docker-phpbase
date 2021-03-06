FROM 	php:7.4-fpm-buster

ENV 	TERM xterm

# apt does not create these directories automatically during posgresql-client installation
RUN 	mkdir /usr/share/man/man1/ /usr/share/man/man7/

RUN 	apt-get update && apt-get install -y \
        curl \
        libc-client2007e-dev \
        libcurl4-gnutls-dev \
        libonig-dev \
        libxml2-dev \
        libpq-dev \
        libzip-dev \
        locales \
        locales-all \
        postgresql-client \
        tar \
        wget

# vips dependencies and installation
RUN     cd /tmp \
        && wget -O vips.tar.gz https://github.com/libvips/libvips/releases/download/v8.11.1/vips-8.11.1.tar.gz \
        && tar xf /tmp/vips.tar.gz \
        && cd /tmp/vips-8.11.1 \
        && apt-get -y install 	build-essential pkg-config glib2.0-dev libexpat1-dev \
        && apt-get -y install 	libexif-dev \
				libgif-dev \
				libgsf-1-dev \
				libjpeg62-turbo-dev \
				libpng-dev \
				libpoppler-glib-dev \
				librsvg2-dev \
				libtiff5-dev \
				libwebp-dev \
        && ./configure \
        && make \
        && make install \
        && rm -rf /tmp/vips.tar.gz \
        && rm -rf /tmp/vips-8.11.1

RUN 	docker-php-ext-install -j$(nproc) opcache bcmath curl json mbstring zip \
	&& docker-php-ext-configure xml \
	&& docker-php-ext-install -j$(nproc) xml \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
	&& docker-php-ext-install -j$(nproc) gd \
	&& docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
	&& docker-php-ext-install -j$(nproc) pdo pdo_pgsql pgsql \
	&& docker-php-ext-install -j$(nproc) soap \
	&& docker-php-ext-install -j$(nproc) sockets \
	&& pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& pecl install redis-5.3.4 \
    	&& docker-php-ext-enable redis \
	&& pecl install vips \
        && docker-php-ext-enable vips

# WKHTMLTOPDF DEPENDENCY
RUN 	apt-get update && apt-get install -y \
        fontconfig \
        gsfonts \
        libfontconfig \
        libfreetype6-dev \
        libx11-6 \
        libxcb1 \
        libxext6 \
        libxrender1 \
        xfonts-75dpi \
        xfonts-base \
        zlib1g

RUN 	wget -O /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb && \
    	dpkg -i /tmp/wkhtmltox.deb && \
    	rm /tmp/wkhtmltox.deb

ENV     LC_ALL cs_CZ.UTF-8
ENV     LANG cs_CZ.UTF-8
ENV     LANGUAGE cs_CZ

WORKDIR /var/www/html
