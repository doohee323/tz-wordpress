# Run a Wordpress server on docker

install a wordpress server with docker, MySQL, nginx, php 8.x. 

## Run on Vagrant
-. prep.
```
    - install docker-desktop
  		https://www.docker.com/products/docker-desktop/
	- install git
  		https://git-scm.com/downloads
	- install vscode
  		https://code.visualstudio.com/download
	- install tabby (optional)
  		https://tabby.sh/
	- install wsl on windows
		https://learn.microsoft.com/en-us/windows/wsl/install

```

## Run on Docker
```
    git clone -b docker https://github.com/doohee323/tz-wordpress.git
    cd tz-wordpress
	bash tz-local/docker/install.sh
```

## Open wordpress locally
	http://localhost:8080


## Other INFOs
-. install plugins
```
	cd /vagrant/wordpress
	wp core install --url="192.168.82.170"  --title="topzone" --admin_user="admin" --admin_password="admin123" --admin_email="admin@gmail.com"
	wp core update
	wp plugin update --all
	wp theme update --all
	
	# wp plugin search EDITFLOW

	wp plugin install bbpress --activate
	wp plugin install jetpack --activate
	wp plugin install kboard-downloader --activate
	wp plugin install wptouch --activate
	wp plugin install buddypress --activate
	wp plugin install sidebar-login --activate
	wp plugin install edit-flow --activate
	
```
