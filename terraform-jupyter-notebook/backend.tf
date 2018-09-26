terraform {
  backend "s3" {
    bucket = "snehalsbucket"
    key    = "remotedemo.tfstate"
    region = "us-east-2"
    access_key= "your_access_key"
    secret_key= "your_secret_key"
  }
}
