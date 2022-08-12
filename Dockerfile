FROM 	php:8.0-fpm-bullseye

ENV     VIPS_VERSION        8.13.0
ENV     REDIS_PECL_VERSION  5.3.7
ENV     WKHTMLTOPDF_VERSION 0.12.6-1

ENV 	TERM xterm

RUN     apt-get update && apt-get install -y locales && \
        sed -i '/cs_CZ.UTF-8/s/^# //g' /etc/locale.gen && \
        locale-gen

ENV     LC_ALL cs_CZ.UTF-8
ENV     LANG cs_CZ.UTF-8
ENV     LANGUAGE cs_CZ

RUN 	apt-get update \
        && apt-get install -y   curl \
                                libc-client2007e-dev \
                                libcurl4-gnutls-dev \
                                libheif-dev \
                                libimagequant-dev \
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
        && wget -O vips.tar.gz https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz \
        && tar xf /tmp/vips.tar.gz \
        && cd /tmp/vips-${VIPS_VERSION} \
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
        && rm -rf /tmp/vips-${VIPS_VERSION}

RUN 	docker-php-ext-install -j$(nproc) bcmath gettext intl opcache soap sockets zip \
        && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
        && docker-php-ext-install -j$(nproc) gd \
        && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
        && docker-php-ext-install -j$(nproc) pdo pdo_pgsql pgsql \
        && pecl install apcu \
        && docker-php-ext-enable apcu \
        && pecl install redis-${REDIS_PECL_VERSION} \
    	&& docker-php-ext-enable redis \
        && pecl install vips \
        && docker-php-ext-enable vips

# WKHTMLTOPDF DEPENDENCY
RUN 	apt-get update \
        && apt-get install -y   fontconfig \
                                gsfonts \
                                libfontconfig \
                                libfreetype6-dev \
                                libx11-6 \
                                libxcb1 \
                                libxext6 \
                                libxrender1 \
                                xfonts-75dpi \
                                xfonts-base \
                                zlib1g \
        && rm -rf /var/lib/apt/lists/*

RUN 	wget -O /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/${WKHTMLTOPDF_VERSION}/wkhtmltox_${WKHTMLTOPDF_VERSION}.buster_amd64.deb && \
    	dpkg -i /tmp/wkhtmltox.deb && \
    	rm /tmp/wkhtmltox.deb

WORKDIR /var/www/html
