module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = lookup(var.vpc_cidr, terraform.workspace, "10.0.0.0/16")
  vpc_name        = "learning_vpc-${terraform.workspace}"
  public_subnets  = lookup(var.public_subnets, terraform.workspace, ["10.0.1.0/24"])
  private_subnets = lookup(var.private_subnets, terraform.workspace, ["10.0.10.0/24"])
  azs             = lookup(var.azs, terraform.workspace, ["us-east-1a"]) # ✅ Dynamically select AZs
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "ssh_key" {
  source          = "./modules/ssh_key"
  key_name        = "terraform-key-${terraform.workspace}" # ✅ Ensure unique key per workspace
  public_key_path = "${path.module}/terraform-key.pub"
}

module "ec2" {
  source            = "./modules/ec2"
  ami               = "ami-0c104f6f4a5d9d1d5"
  instance_type     = lookup(var.instance_type, terraform.workspace, "t2.micro") # ✅ Select instance type dynamically
  public_subnet_id  = module.vpc.public_subnet_ids[0]
  private_subnet_id = module.vpc.private_subnet_ids[0]
  ssh_key           = module.ssh_key.key_name
  security_group    = module.security_groups.backend_sg_id
}

module "alb" {
  source              = "./modules/alb"
  count               = var.enable_alb[terraform.workspace] ? 1 : 0 # ✅ Create only if enabled
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
  private_db_subnet_ids = module.vpc.private_db_subnets
}