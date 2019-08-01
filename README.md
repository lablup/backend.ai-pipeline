# backend.ai-pipeline

End-to-end Machine Learning Pipeline UI for end-user.

Backend.AI pipeline focuses to 

 * Serve as web service
 * Versatile devices ready such as mobile, tablet and desktop.

## User Features

 * Session management
    * Set default resources for runs
    * Choose and run environment-supported apps
 * Experiments
    * Manages container stream
    * End-to-end job pipeline scheduling

## Management Features

 * Provides compatibility with console server (github/lablup/backend.ai-pipeline-server)
    * Delegate login to console server
    * Support userid / password login

## Setup Guide
### Configuration

Backend.AI pipeline uses `config.toml` located in root directory.

These are options in `config.toml`.

```
[general]
apiEndpoint = [Default API Endpoint. If blank, user input field will be shown.]
apiEndpointText = [Placeholder text instead of API endpoint input field.]
defaultSessionEnvironment = [Default session kernel. If blank, alphabetically first kernel will be default.]
siteDescription = [Site description placeholder. It will be at the bottom of 'Backend.AI' at the top left corner.]
connectionMode = [Connection mode. Default is API. Currenly supports API and SESSION]
[wsproxy]
proxyURL = [Proxy URL]
proxyBaseURL = [Base URL of websocket proxy,]
proxyListenIP = [Websocket proxy configuration IP.]
```

## Development Guide

Backend.AI pipeline is built with  
 * `litelement` / `Polymer 3 `as webcomponent framework
 * `npm` as package manager
 * `rollup` as bundler

### Initializing

```
$ npm i
```

### Developing / testing without bundling

```
$ npm run server:d # To run dev. web server
```

## Serving Guide

### Preparing bundled source

```
$ make compile
```

Then bundled resource will be prepared in `build/rollup`. Basically, both app and web serving is based on static serving sources in the directory. However, to work as single page application, URL request fallback is needed.

### Serving with nginx

This is nginx server configuration example. [APP PATH] should be changed to your source path. If you need to further nginx cache exception, add them with proper location.

```
server {
    listen      443 ssl http2;
    listen [::]:443 ssl http2;
    server_name [SERVER URL];
    charset     utf-8;

    client_max_body_size 15M;   # maximum upload size.

    root [APP PATH];
    index index.html;

    location / {
        try_files $uri /index.html;
    }
    keepalive_timeout 120;

    ssl_certificate [CERTIFICATE FILE PATH];
    ssl_certificate_key [CERTIFICATE KEY FILE PATH];
}
```

### Building docker image using docker-compose

Make sure that you compile the Backend.AI pipeline.

```
$ make compile
```

#### HTTP server
Good for develop phase. Not recommended for production environment.

```
$ docker-compose build pipeline // build only
$ docker-compose up pipeline    // for testing
$ docker-compose up -d pipeline // as a daemon
```

#### HTTPS with SSL
Recommended for production.

Note: You have to enter the certificates (`chain.pem` and `priv.pem`) into `certificates` directory. Otherwise, you will have an error during container initialization.

```
$ docker-compose build pipeline-ssl  // build only
$ docker-compose up pipeline-ssl     // for testing
$ docker-compose up -d pipeline-ssl  // as a daemon
```

#### Removing

```
$ docker-compose down
```

#### Manual image build
```
$ make compile
$ docker build -t backendai-pipeline .
```

Testing / Running example

Check your image name is `backendai-pipeline_pipeline` or `backendai-pipeline_pipeline-ssl`. Otherwise, change the image name in the script below.

```
$ docker run --name backendai-pipeline -v $(pwd)/config.toml:/usr/share/nginx/html/config.toml -p 80:80 backendai-pipeline_pipeline /bin/bash -c "envsubst '$$NGINX_HOST' < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
$ docker run --name backendai-pipeline-ssl -v $(pwd)/config.toml:/usr/share/nginx/html/config.toml -v $(pwd)/certificates:/etc/certificates -p 443:443 backendai-pipeline_pipeline-ssl /bin/bash -c "envsubst '$$NGINX_HOST' < /etc/nginx/conf.d/default-ssl.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
```