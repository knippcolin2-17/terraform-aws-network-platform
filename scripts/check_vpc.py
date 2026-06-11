import boto3

ec2 = boto3.client("ec2")

response = ec2.describe_vpcs()

print("\n=== VPCs ===")

for vpc in response["Vpcs"]:

    name = "N/A"

    for tag in vpc.get("Tags", []):
        if tag["Key"] == "Name":
            name = tag["Value"]

    print(f"Name: {name}")
    print(f"VPC ID: {vpc['VpcId']}")
    print(f"CIDR: {vpc['CidrBlock']}")
    print(f"State: {vpc['State']}")
    print(f"Default VPC: {vpc['IsDefault']}")
    print("-" * 50)