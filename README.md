# Run a Wordpress server on Vagrant / AWS / GCP (by Terraform)

install a wordpress server with ubuntu 18.04, MySQL, apache2/nginx, php 7.1. 
make an aws s3 bucket as wordpress media repository.

## Run on Vagrant
-. prep.
```
    - install vagrant
        https://www.vagrantup.com/downloads.html
    - install virtualbox
        https://www.virtualbox.org/

```
-. set up on vagrant
```
    git clone https://github.com/doohee323/tz-wordpress
    cd tz-wordpress
	vagrant destroy -f && vagrant up
	vagrant ssh
	cf. all scripts
		/tz-wordpress/resources/wordpress.sh
```

## Run on AWS
```
	- register AWS Access key
	"# AWS Access Key ID [None]: xxxxxxxxxxxxxxxxxxxx
	export AWS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	cf. on aws console, Your Security Credentials > Access Keys (Access Key ID and Secret Access Key)

	# make ec2 instanace with Ubuntu Server 18.04 LTS
	# set your pem file and aws ec2 ip address 
	export PEM=xxx   # ex) xxx.pem
	export AWS_EC2_IP_ADDRESS=xxx.xxx.xxx.xxx

	bash aws.sh
	cf. all scripts
		/tz-wordpress/scripts/run_aws.sh
		/tz-wordpress/resources/wordpress.sh
	cf. access to terminal after opening firewal for the ec2 instance
		cd ~/.ssh
		chmod 600 $PEM.pem
		ssh -i $PEM.pem ubuntu@$AWS_EC2_IP_ADDRESS
```

## Run on GCP
-. prep.
```
	1. make GCP admin account and billing account
        ex) doohee323@new-nation.church
    2. change terraform.tfvars_template
    3. change run_gcp.sh

bash /vagrant/scripts/run_gcp.sh \
  us-west2 \
  us-west2-a \
  doohee323@new-nation.church \
  newnationchurch \
  3241

    4. vagrant up

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

-. configure a wordpress server
```
	<for Vagrant>
		- http://192.168.82.170 
	<for AWS>
		- http://$AWS_EC2_IP_ADDRESS
		
	- id / password = admin/admin123
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
	/vagrant/wordpress 
	1 minuite after changing any resources under /vagrant/wordpress, /usr/share/nginx/html will be synced.
```

-. upload directory
```
	/vagrant/wordpress/wp-content/uploads
	$> df -k
	s3fs           274877906944       0 274877906944   0% /vagrant/wordpress/wp-content/uploads
```

-. Test
	- password: passwd123
	https://192.168.82.170



