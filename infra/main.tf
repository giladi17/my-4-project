# משיכת נתונים אוטומטית של הגרסה העדכנית ביותר של Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # החשבון הרשמי של Canonical (Ubuntu)
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# משתנה עבור מפתח ה-SSH (תצטרך ליצור מפתח ב-AWS כדי שנוכל להתחבר לשרתים)
variable "key_name" {
  description = "The name of the AWS Key Pair to use for SSH"
  type        = string
  default     = "my-devops-key" # החלף זאת בשם המפתח שיצרת ב-AWS!
}

# --- Security Group for Jenkins ---
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow SSH and Jenkins inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Security Group for App ---
resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Allow SSH and App inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Jenkins EC2 Instance ---
resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # זמין בחינם במסגרת ה-Free Tier
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  iam_instance_profile = aws_iam_instance_profile.app_server_profile.name
  tags = {
    Name = "Jenkins-Server"
  }
}

# --- App EC2 Instance ---
resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "App-Server"
  }
}
# --- ECR Repository ---
resource "aws_ecr_repository" "app_repo" {
  name                 = "devops-app"
  force_delete        = true # מאפשר למחוק את המאגר בסוף גם אם יש בו תמונות
}
# יצירת תפקיד (Role) לשרת האפליקציה
resource "aws_iam_role" "app_server_role" {
  name = "app_server_ecr_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# חיבור פוליסי מובנה של AWS שמאפשר קריאה מ-ECR
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.app_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# יצירת פרופיל חיבור לשרת ה-EC2
resource "aws_iam_instance_profile" "app_server_profile" {
  name = "app_server_ecr_profile"
  role = aws_iam_role.app_server_role.name
}