import boto3

ec2 = boto3.client("ec2")

response = ec2.describe_instances()

print("\n=== EC2 Instances ===")

for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:

        name = "N/A"

        for tag in instance.get("Tags", []):
            if tag["Key"] == "Name":
                name = tag["Value"]

        print(f"Name: {name}")
        print(f"Instance ID: {instance['InstanceId']}")
        print(f"State: {instance['State']['Name']}")
        print(f"Type: {instance['InstanceType']}")
        print(f"VPC: {instance['VpcId']}")
        print(f"Subnet: {instance['SubnetId']}")
        print(f"Private IP: {instance.get('PrivateIpAddress')}")
        print(f"Public IP: {instance.get('PublicIpAddress', 'None')}")
        print("-" * 50)