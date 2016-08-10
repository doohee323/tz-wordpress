# Run a Wordpress server on Vagrant

install a wordpress server with ubuntu 14.04, MySQL, nginx, php 7.0. 
make an aws s3 bucket as wordpress media repository.

-. register AWS Access key
```
	cf. Your Security Credentials > Access Keys (Access Key ID and Secret Access Key)
	change the key in /wordpress-vagrant/scripts/wordpress.sh 120 line
	ex.  echo AKIAJOEN111111VX5SWQ:P/N6fMLdjxLjB11111111111111u1YsUJ7OxjkEB > /etc/passwd-s3fs
```

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
