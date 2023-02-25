# Run a Wordpress server on docker

install a wordpress server with docker, MySQL, nginx, php 8.x. 

## Run on Vagrant
-. prep.
```
    - install docker

```

## Run on Docker
```

```

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

-. Test
	- password: passwd123
	https://192.168.82.170



