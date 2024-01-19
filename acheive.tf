resource "aws_vpc" "Dev-Deployment" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Dev-Deployment"
  }
}

resource "aws_subnet" "Dev-Deployment_Subnet" {
  vpc_id                  = aws_vpc.Dev-Deployment.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Dev-Deployment_Subnet"
  }
}

resource "aws_internet_gateway" "Dev-Deployment_igw" {
  vpc_id = aws_vpc.Dev-Deployment.id

  tags = {
    Name = "Dev-Deployment_igw"
  }
}

resource "aws_route_table" "Dev_Deployment_rt" {
  vpc_id = aws_vpc.Dev-Deployment.id

  tags = {
    Name = "Dev_Deployment_rt"
  }
}

resource "aws_route" "Dev_Deployment_r" {
  route_table_id         = aws_route_table.Dev_Deployment_rt.id
  destination_cidr_block = "0.0.0.0/00"
  gateway_id             = aws_internet_gateway.Dev-Deployment_igw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.Dev-Deployment_Subnet.id
  route_table_id = aws_route_table.Dev_Deployment_rt.id
}

resource "aws_security_group" "Dev_Deployment_sg" {
  name        = "Dev_Deployment_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.Dev-Deployment.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Dev_Deployment_sg"
  }
}
resource "aws_key_pair" "Deployment_Key" {
  key_name   = "Devkey"
  public_key = file("~/.ssh/Devkey.pub")
}

#variable "instance_types" {
#   type = list 
#  default = ["t2.micro", "t2.medium"]
#}

#resource "aws_instance" "Server1" {
#  instance_type = var.instance_type [0,1,2]
#    count = 3





resource "aws_instance" "Dev_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  #instance_type         = var.instance_types[count.index]
  key_name               = "Devkey"
  subnet_id              = aws_subnet.Dev-Deployment_Subnet.id
  vpc_security_group_ids = [aws_security_group.Dev_Deployment_sg.id]
  user_data              = file("userdata.tpl")
  count                  = 3
  #count                  = length(var.instance_types)
  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = "Web-Sever-${count.index + 1}"
  }
}
