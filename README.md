# Terraform_Assignment
This is my Terraform Assignment
Below I have explain the approach and shown the output screenshot to my solution:

#### This terraform script is defined to create custom VPC and deploy two EC2 VMs on AWS using Terraform
##### The code is broken down into three different parts

* __Networking__ to define the VPC and all of its components
* __SSH-Key__  to dynamically create an __SSH-key pair__ for connecting to VMs 
* __EC2__ to deploy a VM in the __public subnet__, and deploy another VM in a __private subnet__
* __NGINX__ should be accessed for all the internet


## Networking
```
resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Custom VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "Private Subnet"
  }
}
```

### Expalnation:
* The __aws_vpc__ resource type is used to create an AWS __Virtual Private Cloud__ (VPC). 
* In this case, it creates a VPC with the __CIDR block__ ```10.0.0.0/16``` which allows for a range of __IP addresses__ within the VPC. The tags block is used to assign the tag "Custom VPC" to this VPC.
* The __aws_subnet__ resource type is used to create a subnet within the VPC. 
* In this case, it creates a __public subnet__ with the CIDR block ```10.0.1.0/24``` in __availability zone__ ```us-east-1a```. 
* The __vpc_id__ attribute is set to ```aws_vpc.custom_vpc.id``` to associate the subnet with the __custom VPC__.
* The __map_public_ip_on_launch__ attribute is set to ```true```, which means that instances launched in this subnet will be assigned a __public IP__ address automatically. The subnet is also tagged as __Public Subnet__.
* Similar to the __public subnet__, next __aws_subnet__ resource creates a __private subnet__ with the CIDR block ```10.0.2.0/24``` in ___availability zone__ ```us-east-1b```. It is associated with the same custom VPC ```(aws_vpc.custom_vpc.id)```. The subnet is tagged as __Private Subnet__.
* The only difference between __private__ and __public__ subnet is __map_public_ip_on_launch__ parameter. If it is true, it will be a public subnet, otherwise private.

### Terraform Execution Plan screenshot:
<img width="850" height="350" alt="Screenshot 2023-06-05 at 11 58 03 AM" src="https://github.com/Karan2291/Terraform_Assignment/assets/122456892/594ca747-0164-4f56-a1f4-9f9b4f5f2307">
<img width="850" height="500" alt="Screenshot 2023-06-05 at 11 57 28 AM" src="https://github.com/Karan2291/Terraform_Assignment/assets/122456892/6e9dbe5b-2869-4d49-aa08-147b862ccfc3">

## SSH Key
```
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
```
### Expalnation:
* The __tls_private_key__ resource is used to generate an ```RSA``` __private__ key. 
* In this case, it creates an ```RSA``` __private__ key named __ssh_key__ for SSH access to the EC2 instances.. The generated __private key__ can be referenced later in the configuration.
* The __aws_key_pair__ resource type creates an ```AWS key pair``` resource. 
* It uses the previously generated ___RSA private key___ ```(tls_private_key.ssh_key)``` and associates it with the name __"ssh-key"__. The __public key__ portion of the private key is used as the public_key attribute.

### Terraform Execution Plan screenshot:
<img width="709" alt="Screenshot 2023-06-05 at 11 58 15 AM" src="https://github.com/Karan2291/Terraform_Assignment/assets/122456892/5aff6be1-7af7-4fab-b035-7a1dfcb5ff07">
<img width="680" alt="Screenshot 2023-06-05 at 11 56 59 AM" src="https://github.com/Karan2291/Terraform_Assignment/assets/122456892/8adcc231-ffce-4fe6-8a0a-04ad06e1c773">


## EC2
```
resource "aws_instance" "public_vm" {
  ami           = "ami-abc123"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key_pair.key_name
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "Public VM"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]
  }
}

resource "aws_instance" "private_vm" {
  ami           = "ami-xyz789"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key_pair.key_name
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = "Private VM"
  }

   provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]
  }
}

```
### Expalnation:
* These resource blocks define two __AWS EC2__ instances. Each instance is of type __aws_instance__. The first instance is named ```"public_vm"``` and uses the __AMI (Amazon Machine Image)__ with ID ```ami-abc123``` and __instance type__ ```t2.micro```. 
* It is associated with the __SSH key pair__ named ```ssh-key``` __(aws_key_pair.ssh_key_pair.key_name)__ and the public subnet __(aws_subnet.public_subnet.id)__`.The instance is tagged as ```Public VM```. 
* Additionally, a __provisioner block__ is defined with __remote-exec__ provisioner, which executes the specified commands on the instance after it is created.
* Similarly, the second instance is named __private_vm__ and uses a different __AMI__ ```(ami-xyz789)```, the same __instance type__, the same __SSH key pair__, and the __private subnet__. It is tagged as ```Private VM``` and also has a __provisioner block__ for executing commands on the instance.

Overall, this Terraform configuration sets up a custom VPC with __public__ and __private__ subnets, creates an __SSH key pair__, and provisions EC2 instances in each subnet, installing and starting the Nginx web server on both instances.

### Terraform Execution Plan screenshot:
<img width="950" alt="Screenshot 2023-06-05 at 11 56 30 AM" src="https://github.com/Karan2291/Terraform_Assignment/assets/122456892/7ae1a692-9c6b-4c9f-842a-1904b67c81f0">
<img width="950" alt="Screenshot 2023-06-05 at 11 55 30 AM" src="https://github.com/Karan2291/Terraform_Assignment/assets/122456892/008ea997-103d-4a16-9fad-6ed29a92710f">

## Workflow file for Github CI/CD Actions
```
name: "Terraform Infrastructure Provisioning with GitHub Actions"
 
on:
 push:
   branches:
   - main
 
env:
 # verbosity setting for Terraform logs
 TF_LOG: INFO
 # Credentials for deployment to AWS
 TF_VAR_AWS_ACCESS_KEY: ${{ secrets.AWS_ACCESS_KEY_ID }}
 TF_VAR_AWS_SECRET_KEY: ${{ secrets.AWS_SECRET_KEY_ID }}
 

jobs:
 terraform:
   name: "Terraform Infrastructure Provisioning"
   runs-on: ubuntu-latest
   defaults:
     run:
       shell: bash
       # We keep Terraform files in the terraform directory.
       working-directory: ./
 
   steps:
     - name: Checkout the repository to the runner
       uses: actions/checkout@v2
 
     - name: Setup Terraform with specified version on the runner
       uses: hashicorp/setup-terraform@v2
       with:
         terraform_version: 1.4.6
    
     - name: Terraform init
       id: init
       run: terraform init 
 
     - name: Terraform format
       id: fmt
       run: terraform fmt
    
     - name: Terraform validate
       id: validate
       run: terraform validate
 
     - name: Terraform plan
       id: plan
       run: terraform plan
 
```
### Expalnation:
* This workflow is triggered on a __push event__ to the __main__ branch. It means that whenever there is a __push__ to the __main__ branch of the repository, this workflow will be executed.
* Next section defines __environment variables__ used within the workflow. __TF_LOG__ sets the verbosity level for Terraform logs. ```TF_VAR_AWS_ACCESS_KEY``` and ```TF_VAR_AWS_SECRET_KEY``` are credentials for deploying to __AWS__. The values for these variables are stored as __secrets__ in the GitHub repository.
* Next this workflow defines a single job named __"Terraform Infrastructure Provisioning"__. It runs on an __Ubuntu__ operating system.
* The __defaults__ section specifies the default behavior for all the steps in this job. The __shell__ is set to __bash__, and the working directory is set to ```./```, indicating that the Terraform files are located in the __root__ of the repository.
* Below are the steps and its explanation
### Steps
The following steps are executed within the job:
#### Step1: 
Checkout the repository to the runner
* This __step__ checks out the repository code to the __GitHub Actions runner__, allowing subsequent steps to access the Terraform files and other repository contents.
#### Step2: 
Setup Terraform with specified version on the runner
* This __step__ sets up the specified version of Terraform on the __GitHub Actions runner__. In this case, it uses __Terraform version 1.4.6__.
#### Step3: 
Terraform Initialization:
* This __step__ initializes the Terraform working directory by running ```terraform init```. It sets up the backend, downloads required __providers__, and prepares the environment for Terraform operations.
#### Step4: 
Terraform Format:
* This __step__ runs ```terraform fmt``` to __format__ the Terraform configuration files, ensuring __consistent code style__ and __formatting__.
#### Step5: 
Terraform Validation:
* This __step__ performs a __syntax__ and __validation check__ on the Terraform configuration files using ```terraform validate```. It ensures that the configuration is __syntactically correct__ and follows the __Terraform language conventions__.
#### Step6: 
Terraform plan:
* This __step__ generates an __execution plan__ using ```terraform plan```. It shows the changes that Terraform will make to the infrastructure based on the __configuration files__ and __current state__.




