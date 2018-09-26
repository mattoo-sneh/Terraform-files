resource "aws_instance" "myserver"{
  instance_type = "t2.micro"
  ami ="ami-5e8bb23b"
  security_groups= ["${aws_security_group.mysg.name}"]
  key_name = "your_key_name"

 tags {
  Name = "myjupyternbserver"
 }

provisioner "remote-exec" {
    inline = [
              "sudo apt-get update",
              "sudo apt-get install apt-transport-https",
              "sudo apt-get install ca-certificates",
              "sudo apt-get install curl",
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
      private_key = "${file("./your_key_name.pem")}"

    }

   }

}
