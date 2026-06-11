import boto3

ec2 = boto3.client("ec2")

response = ec2.describe_transit_gateways()

print("\n=== Transit Gateways ===")

for tgw in response["TransitGateways"]:
    print(f"TGW ID: {tgw['TransitGatewayId']}")
    print(f"State: {tgw['State']}")
    print(f"ASN: {tgw['Options']['AmazonSideAsn']}")
    print(
        f"Association Route Table: "
        f"{tgw['Options']['DefaultRouteTableAssociation']}"
    )
    print(
        f"Propagation Route Table: "
        f"{tgw['Options']['DefaultRouteTablePropagation']}"
    )
    print("-" * 50)