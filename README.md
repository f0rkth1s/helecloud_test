# helecloud_test  

## Time sheet:  
Date		-	T	-	RT	-	Description of progress  
8/6/22	-	1h	-	1h	-	Setup local environment with tfenv/tf/awscli - Base setup for creation of EC2 in my default VPC & subnet, with remote state storage in S3  
9/6/22	-	2h	-	3h	-	keys/vpc/subnet/sg/igw/routing/instances with count/basic efs - all working apart from provisioner which works for only the first instance and fails with i/o timeout on subsequent  
10/6/22	-	2h	-	5h	-	Fixed provisioner by replacing with a user_data to run the shell script - Working now, pain.  
11/6/22	-	3h	-	8h	-	Got ELB working - moved from aws_instance to launch_config/aws_autoscaling_group - made more work for myself because I had created a new vpc and subnet  
12/6/22	-	2h30m	-	10h	-	Resetup laptop for work as Wife was on PC - provisioned efs, thought efs was mounting but it isn't likely to do with TF variables not passing through, tidied up file structure. Ran out of time at 5pm deadline  
  
# To complete  
efs - working mount  
rds - provision and mount  
cloudwatch alarm - enable  
  
# Future ideas:  
Iterating count for fe_servers names when generated by aws_autoscaling_group  
separate efs subnet  
Create more vars to allow for re-use for creating multple environments within accounts  
Expand further using terragrunt and variablise all specific counts for dry base  

