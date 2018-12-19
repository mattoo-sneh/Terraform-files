# terraform-files
Snehal Mattoo
CS700 Directed Study Documentation

Our primary objective is to create a web-based product that enables it’s users to run Python in Jupyter notebooks on a user configured compute environment. The user’s notebook (code) is stored separately. The compute resources are created and destroyed as needed. 

Setting up an AWS account
•	Under Security and Identity
1.	Create IAM (Identity and Access Management) Admin User 
•	Under details
1.	Select Users 
2.	Create New Users 
3.	Enter a User Name (ex. Terraform) 
4.	Access Type: Programmatic access 
5.	Under attach existing policies directly
6.	Select administrator access 
7.	Save the access and secret keys generated

Multi-Factor Authentication (MFA) in AWS
•	Under your account name 
1.	Select my security credentials
2.	Continue to security credentials 
3.	MFA 
4.	Activate MFA 
5.	A virtual MFA device 
6.	Next 
7.	Download Duo Mobile or Google Authenticator and scan the barcode displayed
8.	Enter the two Authentication codes 
9.	Select Activate
Same steps can be followed to attach MFA to a user since the user has admin access

We need to create key pairs to log onto the server. 
•	Select the “Create Key Pair” option in network and security. 
•	Give an appropriate name and a private key file will get downloaded.

o	Saving the access and secret keys in the AWS CLI is a much better practice than having your keys or any credentials in your configuration files. 
o	While you are committing the code to git, the keys may be compromised.
o	Since the terraform state files stores all information specific to the state of your infrastructure that has been created, one also needs to make sure that this file is not committed. Even if there are any modifications made to the instance manually, the terraform plan will indicate a change in state and will give you the option to keep the changes or discard them.

Now Under Instances, 
1.	Select launch instance 
2.	Select Ubuntu/Amazon Linux (you can select any) 
3.	Choose an Instance Type 
4.	t2.micro (free) 
5.	Configure Instance Details 
6.	Add Storage for the hard disk drive (default 8GB should be enough for this practical) 
7.	Review and Launch 
8.	Select Security Group 
9.	Launch Instances and edit the name of your server as per your choice

In order to connect to the EC2 Instance,
Launch the terminal and execute the following command:
$ ssh -i ~/Downloads/my-key-pair.pem ubuntu@publicip 
Often time you would get an error while connecting saying the private key is publicly viewable. In this case we use the chmod command to make sure your private key file isn't publicly viewable. For example, if the name of your private key file is my-key-pair.pem, use the following command:
$ chmod 400 my-key-pair.pem

Provisioning software on the instance –

Running nginx on your servers public ip for an Amazon Linux instance:

Execute the following commands to install nginx on an Amazon Linux instance:

$ sudo yum -y install epel-release
$ sudo yum -y install nginx
$ sudo service nginx start
To check the state of active internet connections , execute:
$ netstat -ntlp

Now if we go back to our aws instance and copy the public ip address and paste it in the browser, we will see a welcome to nginx page.
•	All of this can be done and configured using one simple terraform script!

The product’s user and compute environments are configured using an infrastructure as code implementation called Terraform. It is an open source tool created by HashiCorp which is able to create infrastructure on over 78 providers such as AWS, Azure, Google Cloud and OpenStack. By automating the creation of cloud infrastructure, Terraform can be configured to provide distributed computing to the user and decouples code, data storage and compute resources.

•	The idea behind it is that you write and execute code to deploy and update your infrastructure.
•	This means being able to manage everything, from servers to networks, with Terraform configuration files.
•	Another example is to implement “AWS Hardening” guidelines provided by CIS (Center of Internet Security). In this scenario, implementing the security guidelines manually per AWS account would have required going through the 145 pages of CIS documentation and its implementation would take roughly 2-3 days. This entire process is now automated with Terraform.

Terraform has multiple providers. Hence, we need to specify the provider details for which infrastructure we want to launch. We add the access_key and secret_key tokens for authentication.

provider "aws" {                                                                
  access_key = " "                 				      
  secret_key = " "					      			
  region = "us-east-2"
}

resource "aws_instance" "EC2" {
  ami           = " ami-" //The AMI to use for the instance.
  instance_type = "t2.micro"  //The type of instance to start. Updates to this field will trigger a stop/start of the EC2 instance.


  tags = {
    Name = "HelloWorld" //(Optional) A mapping of tags to assign to the resource.

  }
}

Terminal or command prompt commands –
Run:

$ terraform init   //Command to initialize state
$ terraform plan   //Command to compile
$ terraform apply  //Command to create

•	Terraform reads configuration files (written by the user) and internally uses API calls from cloud providers to ensure that cloud resources at these providers are created to match the users’ configuration files. 
•	Users simply run terraform apply to create the cloud resources specified in their configuration files. 
•	In the above example, you can create, configure EC2 instances and install and configure software using Terraform. 
•	By using configuration files to create system resources, the building, versioning and changing of infrastructure is safe and efficient.

If you want to destroy all the infrastructure created:

$ terraform destroy //Command to destroy infrastructure created

In case of destroying a specific infrastructure:

$ terraform destroy -target aws_instance.EC2 

Terraform State Files:
It stores all the information specific to the state of the infrastructure that had been created. 
If there are any modifications made to the instance manually, the terraform plan will indicate a change in state and will give you the option to keep the changes or discard them.

Attributes and Referencing a Resource:
Attributes are added in cases where after you run the terraform apply command, you want to see an output associated with your code.
Snippet Code:

resource  "aws_eip"  "public_ip" {
vpc = true
}  
output   "ec2_publicip" {
value =  " ${aws_eip.public_ip.public_ip} "    
}                                       	 
//to reference a resource : provider_property.Name_defined_by_the_user.attribute_ID   
(anyone in the list of attribute references in the documentation) 

Interpolation -
Interpolation is basically estimating unknown values. 
•	It generates an elastic ip and allows the public ip associated with the eip to enter the security group. 
•	The cidr_blocks generally allow all ip addresses but in this case, we are allowing only the public_ip associated to the elastic ip to enter the security group. 
•	To confirm this, we can always check if the rule is added in our security group.

Example :
resource "aws_eip" "eip_demo"{
 vpc=true
 }
resource "aws_security_group" "allow_all"{
 name= "interpolation_demo"
 }	ingress{
 	from_port=0
 	to_port=0
 	protocol="-1"
 	cidr_blocks=["${aws_eip.eip_demo.public_ip}/32"]
 	}

Semantics and Variables:
It is good practice to always separate each config file by resources instead of having one big consolidated .tf file. It becomes easier to understand and debug files.
Variables are important so that we don’t have to manually update values, in case of any change, everywhere throughout the file.
Syntax:
${var.user_defined_name}
It is best practice to keep the variable file separate as well.

Provisioners:
They allow us to execute various commands or scripts in order to create or destroy resources.
Remote-exec allows you to run script files on a remote server.

https://www.terraform.io/docs/provisioners/index.html

Terraform code for getting Nginx running on an EC2 instance :

variable "home_ip"{
  description = "Home IP Address"
  default = "Home_IP/32"
}
 provider "aws"{
 access_key= "your_access_key"
 secret_key= "your_secret_key "
 region= "us-east-2"
 }


resource "aws_security_group" "nginxsecuritygroup" {
  name = "nginxdemo"

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }

    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }
   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }
  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }

    ingress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "myserver"{
  instance_type = "t2.micro"
  ami ="ami-"
  security_groups= ["${aws_security_group. nginxsecuritygroup.name}"]
  key_name = "nameofyourkey(.pem_file)"

 tags {
  name = "mynginxserver"
 }

provisioner "remote-exec" {
    inline = [
        "sudo yum -y install epel-release",
        "sudo yum -y install nginx",
        "sudo service nginx start"
      ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("./nameofyourkey(.pem_file)"")}"

    }

   }

}

Amazon S3 is cloud storage for the internet. To upload your data (photos, videos, documents etc.), you first create a bucket in one of the AWS Regions. You can then upload any number of objects to the bucket.
The user may manually go and spin a bucket up using the AWS GUI. However, using terraform the following can be executed :

//creating a aws_s3_bucket

resource "aws_s3_bucket" "b" {
bucket = "Bucket_Name"
}

terraform {
  backend "s3" {
    bucket = "Bucket_Name"
    key    = "remotedemo.tfstate"
    region = "us-east-2"
    access_key= "your_access_key"
    secret_key= "your_secret_key "

  }
}

This is an example of how the .tf state file gets saved in a bucket that is already created.

JUPYTER NOTEBOOK DEMO:
A jupyter notebook that runs python spun up in an EC2 instance. If the code typed in this notebook had to be saved by the user, it will directly get saved in an S3 bucket. 

•	Ec2jupyter.tf 

  resource "aws_instance" "myserver"{
  instance_type = "t2.micro"
  ami ="ami-"
  security_groups= ["${aws_security_group.semifinaljupnb.name}"]
  key_name = "your-keypair-name" 

 tags {
  name = "myjupyternbserver"
 }

provisioner "remote-exec" {
    inline = [
              "sudo apt-get update",
              "sudo apt-get install apt-transport-https",
              "sudo apt-get install ca-certificates",
              "sudo apt-get install curl -y",
              "sudo apt-get install software-properties-common",
              "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
              "sudo apt-key fingerprint 0EBFCD88",
              "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable'",
              "sudo apt-get update",
              "sudo apt-get install docker-ce -y",
              "sudo docker pull jupyter/minimal-notebook",
              "sudo docker run -p 8888:8888 jupyter/minimal-notebook"

             ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./nameofyourkey(.pem_file)"")}"

    }

   }

}

•	Provider.tf

provider "aws"{
#AWS access and secret keys saved with the AWS CLI
access_key= "your_access_key"
secret_key= "your_secret_key "
region= "${var.aws_region}"
}

•	Securitygroup.tf


resource "aws_security_group" "semifinaljupnb" {
  name = "semifinalsecgroup"


    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }
    ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }

    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }
   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }
  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }

    ingress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["${var.home_ip}"]

  }


  egress {                                              #outbound rules
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


•	Variable.tf

variable "home_ip"{
  description = "Home IP Address"
  default = "home_ip_address/32"
}

variable "aws_region"{
  description = "AWS Region"
  default = "us-east-2"
}

Mounting Amazon S3 as a local file system:

•	Using this method enables our code on Jupyter Notebook (running on Amazon EC2 instance) to be accessed through Amazon S3, just like a shared file system.
•	Any application interacting with the mounted drive doesn’t have to worry about transfer protocols, security mechanisms, or Amazon S3-specific API calls. 
•	In some cases, mounting Amazon S3 as drive on an application server can make creating a distributed file store extremely easy.
•	There are a few options (S3FS-FUSE, ObjectiveFS, RioFS) you have for mounting Amazon S3 as a local drive.

The following steps were followed:


Step 1:

Last login: Sat Dec  8 14:30:01 on ttys001

$ brew

Example usage:
  brew search [TEXT|/REGEX/]
  brew info [FORMULA...]
  brew install FORMULA...
  brew update
  brew upgrade [FORMULA...]
  


Step 2:

$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

==> This script will install:
/usr/local/bin/brew
/usr/local/share/doc/homebrew
/usr/local/share/man/man1/brew.1
/usr/local/share/zsh/site-functions/_brew
/usr/local/etc/bash_completion.d/brew
/usr/local/Homebrew
==> The following new directories will be created:
/usr/local/sbin
/usr/local/Caskroom
/usr/local/Frameworks
==> The Xcode Command Line Tools will be installed.

.
.
.
==> Installation successful!

==> Homebrew has enabled anonymous aggregate formulae and cask analytics.
Read the analytics documentation (and how to opt-out) here:
  https://docs.brew.sh/Analytics



Step 3:

$ brew doctor

.
.
.
==> Installing dependencies for git: gettext and pcre2
==> Installing git dependency: gettext
==> Downloading https://homebrew.bintray.com/bottles/gettext-0.19.8.1.mojave.bottle.tar.gz
######################################################################## 100.0%
==> Pouring gettext-0.19.8.1.mojave.bottle.tar.gz
==> Caveats
...



Step 4:

$ brew install wget

==> Installing dependencies for wget: libunistring, libidn2 and openssl
==> Installing wget dependency: libunistring
==> Downloading https://homebrew.bintray.com/bottles/libunistring-0.9.10.mojave.bottle.tar.gz
######################################################################## 100.0%
==> Pouring libunistring-0.9.10.mojave.bottle.tar.gz
🍺  /usr/local/Cellar/libunistring/0.9.10: 54 files, 4.4MB
==> Installing wget dependency: libidn2

...



Step 5:

$ brew install s3fs

==> Installing dependencies for s3fs: gmp, libtasn1, nettle, libffi, p11-kit, gnutls, libgpg-error and libgcrypt
==> Installing s3fs dependency: gmp
==> Downloading https://homebrew.bintray.com/bottles/gmp-6.1.2_2.mojave.bottle.tar.gz

...





Step 6:

$ echo Access_key:Secret_key > ~/.passwd-s3fs


$ cat ~/.passwd-s3fs
Access_key:Secret_key
$ chmod 600 .passwd-s3fs




Step 7: Now we create a folder the AWS S3 will mount –

$ mkdir ~/s3-drive

$ s3fs mattoosnehalbucket ~/s3-drive

$ cd s3-drive

$ ls
remotedemo.tfstate












