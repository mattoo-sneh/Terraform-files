variable "home_ip"{
  description = "Home IP Address"
  default = "your_ipAddress"
}
 provider "aws"{
 access_key= "your_access_key"
 secret_key= "your_secret_key"
 region= "us-east-2"
 }


resource "aws_security_group" "mysg" {
  name = "nginxsg"



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


  egress {                                              #outbound rules
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "myserver"{
  instance_type = "t2.micro"
  ami ="ami-40142d25"
  security_groups= ["${aws_security_group.mysg.name}"]
  key_name = "your_key_name"

 tags {
  Name = "mynginxserver"
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
      private_key = "${file("./your_key_name.pem")}"

    }

   }

}
