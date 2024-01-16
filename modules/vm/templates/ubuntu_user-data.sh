#!/bin/bash
# Install necessary packages
apt update -y
apt install -y iperf3
apt install -y apache2
apt install -y curl
apt install -y netcat

# Query instance meta-data IMDSv2
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` 
export INSTANCEID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
export IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create new index.html
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