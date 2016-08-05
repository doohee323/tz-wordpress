# Run a Wordpress server on Vagrant

install a wordpress server with ubuntu 14.04, MySQL, nginx, php 7.0. 

-. build a server
```
	vagrant destroy -f && vagrant up
	vagrant ssh
	cf. all scripts
		/wordpress-vagrant/scripts/wordpress.sh
```

-. configure a wordpress server
```
	http://192.168.82.170
```
	
-. access to mysql
```
	- database password: 971097
	mysql -h 192.168.82.170 -P 3306 -u root -p
```

-. working directory
```
	/usr/share/nginx/html 
```
