#cloud cardentials


#here it create 
resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


#access for bucket as to be private or public
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}



#acordingly look for other attachments
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources
