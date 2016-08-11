# Run a Wordpress server on Vagrant or AWS

install a wordpress server with ubuntu 14.04, MySQL, nginx, php 7.0. 
make an aws s3 bucket as wordpress media repository.

-. register AWS Access key
```
	export AWS_KEY=11111111111111111111:1111111111111111111111111111111111111111
	cf. on aws console, Your Security Credentials > Access Keys (Access Key ID and Secret Access Key)
```

-. build a server
```
	- password: passwd123
	<for Vagrant>
		vagrant destroy -f && vagrant up
		vagrant ssh
		cf. all scripts
			/wordpress-vagrant/scripts/wordpress.sh
		
	<for AWS>
		# make ec2 instanace with Ubuntu Server 14.04 LTS
		# set your pem file and aws ec2 ip address 
		export PEM=topzone_ca1
		export AWS_EC2_IP_ADDRESS=54.153.115.68
		bash aws.sh
		cf. all scripts
			/wordpress-vagrant/scripts/run_aws.sh
			/wordpress-vagrant/scripts/wordpress.sh
		cf. access to terminal after opening firewal for the ec2 instance
			cd ~/.ssh
			chmod 600 $PEM.pem
			ssh -i $PEM.pem ubuntu@$AWS_EC2_IP_ADDRESS
```

-. configure a wordpress server
```
	<for Vagrant>
		- http://192.168.82.170 
	<for AWS>
		- http://$AWS_EC2_IP_ADDRESS 
```
	
-. access to mysql
```
	<for Vagrant>
		mysql -h 192.168.82.170 -P 3306 -u root -p
	<for AWS>
		mysql -h $AWS_EC2_IP_ADDRESS -P 3306 -u root -p 
```

-. working directory
```
	/usr/share/nginx/html 
```

-. upload directory
```
	/usr/share/nginx/html/wp-content/uploads
	$> df -k
	s3fs           274877906944       0 274877906944   0% /usr/share/nginx/html/wp-content/uploads
```


