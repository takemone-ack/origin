provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "main" {
  ami = "ami-"0000aaasss00"
  root_block_device {
   encrypted = false
   
   delete_on_termination = ture
   volume_type = "gp2"
   volume_size = 8
   }
}