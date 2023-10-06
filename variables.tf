variable "bucket_name" {
  description = "Name of the bucket."
  type        = string

  validation {
    condition     = length(var.bucket_name) > 3
    error_message = "The bucket name must be at least 3 characters long."
  }
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "internet_gateway_name" {
  description = "Name of the internet gateway"
  type        = string
}

variable "route_table_name" {
  description = "Name of the route table"
  type        = string
}

variable "public_subnet_cidr_base" {
  type        = string
  description = "Base CIDR block for public subnets"
  default     = "10.0.0.0/16" # Replace with your desired base CIDR
}

variable "public_subnet_cidr_suffixes" {
  type        = list(number)
  description = "Suffixes to create subnets using cidrsubnet"
  default     = [1, 2] # You can add more suffixes as needed
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b"]
}