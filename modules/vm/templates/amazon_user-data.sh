#!/bin/bash
yum update -y
yum install httpd -y
yum install curl -y 
yum install iperf3 -y
yum install netcat -y
systemctl start httpd
systemctl enable httpd
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
usermod -a -G apache ec2-user
# Query instance meta-data IMDSv2
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 
export INSTANCEID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
export IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
# Create new index.html
touch /var/www/html/index.html
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<body>
    <center>
    <h1><span style="color:Red">Fortinet</span> - Amazon VM</h1>
    <p></p>
    <hr/>
    <h2>EC2 Instance ID: $INSTANCEID</h2>
    <h2>Availability Zone: $IP</h2>
    </center>
</body>
</html>
EOF
systemctl restart httpd