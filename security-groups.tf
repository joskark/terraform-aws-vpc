resource "aws_security_group" "ssh_sg" {
  name        = "ssh-sg"
  description = "Security group allowing SSH from all IPs"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "all_inbound_ip_sg" {
  name        = "all-inbound-sg"
  description = "Allow all inbound HTTP/S requests"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "all_outbound_ip_sg" {
  name        = "all-outbound-sg"
  description = "Allow all outbound HTTP/S requests. Allows updating packages from dnf"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
