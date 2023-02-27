


    
provider "aws" {​​​​​​​ 
      region= "ap-south-1"
}​​​​​​​

#--------------------------------------------
resource "aws_vpc" "example_vpc" {​​​​
   ​​​ cidr_block = "10.0.0.0/16" 
    tags = 
     {​​​​​​​ 
             Name       = "example_vpc"
     }​​​​​​​
}​​​​​​​
#--------------------------------------------
resource "aws_subnet" "example_public_subnet_a" {​​​​​​​ 
     vpc_id            = "aws_vpc.example_vpc.id" 
     cidr_block        = "10.0.1.0/24" 
     availability_zone = "ap-south-1a" 
     tags = 
          {​​​​​​​
             Name = "example_public_subnet_a"
          }​​​​​​​
}​​​​​​​
#---------------------------------------------
resource "aws_subnet" "example_pvt_subnet_b" {​​​​​
    ​​ vpc_id            =  aws_vpc.example_vpc.id 
     cidr_block         = "10.0.2.0/24" 
     availability_zone =   "ap-south-1b" 
     tags =
          {​​​​​​​
               Name = "example_pvt_subnet_b"
          }​​​​​​​
}​​​​​​​
#---------------------------------------------
resource "aws_subnet" "example_private_subnet_a" {​​​​​​​ vpc_id = 
  aws_vpc.example_vpc.id cidr_block = "10.0.3.0/24" availability_zone = 
  "ap-south-1b" tags = {​​​​​​​
    Name = "example_private_subnet_1b"
  }​​​​​​​
}

#----------------------------------------------​​​​​​​
resource "aws_security_group" "example_web_security_group" {
   ​​​​​​​ name         =  "example_web_security_group" 
    description  =  "Allow HTTP traffic" 
    vpc_id       =  aws_vpc.example_vpc.id 
  
    ingress
   {​​​​​​​
    from_port   = 80 
    to_port     = 80 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
    }​​​​​​​
 
    ingress 
   {​
   ​​​​​​ from_port = 22 
    to_port = 22
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
   }​​​​​​​
 
    egress 
   {
   ​​​​​​​ from_port = 0
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
   }​​​​​​​
}​​​​​​​ 
#--------------------------------------------------
resource "aws_security_group" "example_db_security_group" {​​​​​​​ name = 
  "example_db_security_group" description = "Allow traffic from web 
  servers" vpc_id = aws_vpc.example_vpc.id ingress {​​​​​​​
    from_port = 3306 to_port = 3306 protocol = "tcp" security_groups = 
    [aws_security_group.example_php_security_group.id]
  }​​​​​​​
}​​​​​​​
resource "aws_security_group" "example_php_security_group" {​​​​​​​ name = 
  "example_php_security_group" description = "Allow traffic from web 
  servers" vpc_id = aws_vpc.example_vpc.id ingress {​​​​​​​
    from_port = 9000 to_port = 9000 protocol = "tcp" security_groups = 
    [aws_security_group.example_web_security_group.id]
  }​​​​​​​
}​​​​​​​
resource "aws_instance" "example_web_server" {​​​​​​​ ami = 
"ami-0cca134ec43cf708f" instance_type = "t2.micro" subnet_id = 
aws_subnet.example_public_subnet_a.id tags = {​​​​​​​ Name = 
"example_web_server"
}​​​​​​​
security_groups = [aws_security_group.example_web_security_group.id]
}​​​​​​​
resource "aws_instance" "example_db_server" {​​​​​​​ ami = 
"ami-0cca134ec43cf708f" instance_type = "t2.micro" subnet_id = 
aws_subnet.example_private_subnet_a.id tags = {​​​​​​​ Name = 
"example_db_server"
}​​​​​​​
security_groups = [aws_security_group.example_db_security_group.id]
}​​​​​​​
resource "aws_instance" "example_php_server" {​​​​​​​ ami = 
"ami-0cca134ec43cf708f" instance_type = "t2.micro" subnet_id = 
aws_subnet.example_pvt_subnet_b.id tags = {​​​​​​​ Name = "example_php_server"
}​​​​​​​
security_groups = [aws_security_group.example_php_security_group.id]
}​​​​​​​

#-----------------------------------------------------------------
resource "aws_internet_gateway" "example_internet_gateway" {​​​​​
 ​​ vpc_id = 
  aws_vpc.example_vpc.id
 tags = {​​​​​​​ Name = "example_internet_gateway"
  }​​​​​​​
}​​​​​​​
#----------------------------------------------------------
resource "aws_route_table" "example_public_route_table" {​​​​​​​ vpc_id = 
  aws_vpc.example_vpc.id route {​​​​​​​
    cidr_block = "0.0.0.0/0" gateway_id = 
    aws_internet_gateway.example_internet_gateway.id
  }​​​​​​​
  tags = {​​​​​​​ Name = "example_public_route_table"
  }​​​​​​​
}​​​​​​​
#------------------------------------------
resource "aws_network_acl" "example_network_acl" {​​​​
 ​​​ vpc_id =  aws_vpc.example_vpc.id
   ingress {​​​​​​​
           rule_no = 100 
           action = "allow"
           protocol = "tcp"
           from_port = 80 
           to_port = 80 
           cidr_block = "0.0.0.0/0"
           }​​​​​​​
   egress  {​
          ​​​​​​ rule_no = 100
           action = "allow" 
           protocol = "tcp" 
           from_port = 80 
           to_port = 80
           cidr_block = "0.0.0.0/0"
           }​​​​​​​
  tags   = 
       {​
        ​​​​​​ Name = "example_network_acl"
       }​​​​​​​
}​​​​​​​
#--------------------------------------------------------------------
resource "aws_route_table_association" "example_public_route_table_association_a" {​​​​​​​
  subnet_id      =   aws_subnet.example_public_subnet_a.id 
  route_table_id =   aws_route_table.example_public_route_table.id
}​​​​​​​

resource "aws_network_acl_association" "example_network_acl_association_a"
  {​​​​​​​
    subnet_id      = aws_subnet.example_private_subnet_a.id 
    network_acl_id = aws_network_acl.example_network_acl.id
}​​​​​​​

