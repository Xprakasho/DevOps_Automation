import subprocess
import json

result = subprocess.run(
    ["kubectl", "get", "nodes", "-o", "json"],
    capture_output=True,
    text=True
)

if result.returncode != 0:
    print("ERROR: kubectl command failed")
    exit(1)

data = json.loads(result.stdout)

for node in data["items"]:
    name = node["metadata"]["name"]
    version = node["status"]["nodeInfo"]["kubeletVersion"]

    print("Node    :", name)
    print("Version :", version)

    expected_version = "v1.35.1"

if version == expected_version:
    print("Version check: PASS")
else:
    print("Version check: FAIL")
    exit(1)