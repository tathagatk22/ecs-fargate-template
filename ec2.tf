resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name = "ec2-key-pair-us-east-1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlCWRa018w8xEbKG1olXzN3wOVm3Bp4HkdAtmDlPfpO+saVMRW1c2o1NmkxVIM3vReMI1M0YRzAzYQUIy40B2fzU5CdtJbceGn0eEYE51JV5eSgTHH59LcY+xr9lHhhCF4a6km6OIvyZ3ZyJbF+V3iESwhuFparwD/GOV4dGC+rQPEjtXtEbDiT/y/uGez4zXAqog+UQzw3mpQmsH2n3peVTcMj9c1EWgmAaQMhum3Wf3nZ5UXtgSOO0tAugBtTr0DOD+twsNNsE9wkyY6D/hGHS4ys2TEVqofLsTne7vl6ebnHPMdTwCWknL3Z0h372YTo+dtcLPCkt5W8XimnfP0Q== rsa-key-20201127"
}
//
//resource "aws_eip" "aws_eip_for_EC2" {
//  vpc = true
//  tags = {
//    Name = "ec2_eip"
//  }
//}
//
//resource "aws_instance" "web" {
//  ami = "ami-04b9e92b5572fa0d1"
//  instance_type = "t2.micro"
//  subnet_id = aws_subnet.subnet_public.id
//  vpc_security_group_ids = [
//    aws_security_group.security-group.id]
//  key_name = aws_key_pair.ec2_key_pair.key_name
//  tags = {
//    Name = "test-ec2"
//  }
//}
//
//resource "aws_eip_association" "eip_assoc" {
//  instance_id = aws_instance.web.id
//  allocation_id = aws_eip.aws_eip_for_EC2.id
//}
//
//
//output "ec2_ip" {
//  value = aws_eip.aws_eip_for_EC2.public_ip
//}
