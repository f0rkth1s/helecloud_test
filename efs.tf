// EFS

resource "aws_efs_file_system" "fe-shared-efs" {
  creation_token = "fe-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "true"
  tags = {
     Name = "fe-efs"
  }
}

resource "aws_efs_mount_target" "fe-efs-mt" {
   file_system_id  = "${aws_efs_file_system.fe-shared-efs.id}"
   subnet_id = "${aws_subnet.helecloud-prod-subnet-public-1.id}"
   security_groups = ["${aws_security_group.ingress-efs-test.id}"]
 }
