import subprocess
import json
import sys

expected_region = sys.argv[1]

print("Expected region:", expected_region)

result = subprocess.run(
    ["aws", "ec2", "describe-regions", "--output", "json"],
    capture_output=True,
    text=True
)

if result.returncode != 0:
    print("ERROR: AWS command failed")
    exit(1)

try:
    data = json.loads(result.stdout)
except json.JSONDecodeError:
    print("ERROR: AWS returned invalid JSON")
    exit(1)

print("Number of regions:", len(data["Regions"]))

found = False

for region in data["Regions"]:
    if region["RegionName"] == expected_region:
        found = True
        print("Found:", region["RegionName"])

if found:
    print("Region check: PASS")
else:
    print("Region check: FAIL")
    exit(1)