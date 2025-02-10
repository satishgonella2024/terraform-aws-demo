module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = "10.0.0.0/16"
  vpc_name        = "learning_vpc"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"] # ✅ Ensure 3 AZs are passed
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "ssh_key" {
  source          = "./modules/ssh_key"
  key_name        = "terraform-key"
  public_key_path = "${path.module}/terraform-key.pub"
}

module "ec2" {
  source            = "./modules/ec2"
  ami               = "ami-0c104f6f4a5d9d1d5"
  instance_type     = "t2.micro"
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  private_subnet_id = module.vpc.private_subnet_ids[0]
  ssh_key           = module.ssh_key.key_name
  security_group    = module.security_groups.backend_sg_id
}

module "alb" {
  source              = "./modules/alb"
  public_subnet_ids   = module.vpc.public_subnet_ids
  alb_security_group  = module.security_groups.alb_sg_id
  vpc_id              = module.vpc.vpc_id
  backend_instance_id = module.ec2.backend_id
}

module "rds" {
  source                = "./modules/rds"
  vpc_id                = module.vpc.vpc_id
  db_engine             = "mysql"
  db_instance_type      = "db.t3.micro"
  db_allocated_storage  = 20
  db_name               = "mydatabase"
  db_username           = "admin"
  db_password           = "SecurePassword123!"
  db_port               = 3306
  allowed_cidrs         = ["10.0.0.0/16"]
  private_db_subnet_ids = module.vpc.private_subnet_ids
}