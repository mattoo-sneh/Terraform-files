variable "home_ip"{
  description = "Home IP Address"
  default = "your_ipAddress"
}
 provider "aws"{
 access_key= "your_access_key"
 secret_key= "your_secret_key"
 region= "us-east-2"
 }

 resource "aws_instance" "CheckingforS3"{
   instance_type = "t2.micro"
   ami ="ami-40142d25"
   key_name = "your_key_name"
   }

  resource "aws_s3_bucket" "b" {
  bucket = "your_bucket_name"
}

resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.b.id}"
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::your_bucket_name/*",
      "Condition": {
         "IpAddress": {"aws:SourceIp": "8.8.8.8/32"}
      }
    }
  ]
}
POLICY
}
