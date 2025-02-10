# ALB Security Group
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.learning_vpc_01.id

  ingress {
    from_port   = 80 # HTTP Traffic
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Public Access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb_security_group"
  }
}