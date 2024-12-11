First task. 

Assumptions:
 - For the purpose of this excersise, I used my default VPC with public subnets. In real life the for enhanced security EC2 instances could be deployed in private subnet without public IP assigned to them and only load balancer would be in public subnet and able to access EC2s. To use Ansible on such server, I would set-up a Bastion host to serve as a intermediary. 
 - EC2 instance would need some kind of access to other AWS resources (secrets for backend, or RDS), so sample IAM role is attached to it for such access.
 - Ansible will be used for further VM configuration, so SSH port is open to CIDR range of machine that will run Ansible, or a Bastion host if VM would be placed in private subnet (for the purpose of exccercise it's open to the Internet, but will be tightened in productions environment).

EC2 instance will be deployed by autoscaling group in two different subnets to follow best practices and to be highly available. Number of subnets can be bigger depending on requirements (for this all that needs to be done is adding another subnet ID to variable file). 
Upon creation EC2 instance will be registered with Load Balancer.
Besides this, EC2 instance has an IAM role attached to it in case it would need to communicate with other AWS resources (databases, buckets, etc.), exact permissions of IAM role would need to be adjusted to suit the needs of an application. 

NGINX is installed with user_data script. 

Security group of EC2 instance only allows ingress traffic on port 80 from Load Balancer (this is specified by referencing load balancer security group in EC2 launch template). 

Load balancer only allows traffic from the Internet on port 443 with proper SSL ceertificate. (For the purpose of the excercise, I opened port 80 as well on the load balancer, but it should be removed in real life scenario).  

Infrastructure can be deployed from a remote workstation running terraform commands:
    - terraform init
    
    - terraform plan 
    
    - terraform apply --auto-approve

To access NGINX server we would need a DNS name of the load balancer. 
