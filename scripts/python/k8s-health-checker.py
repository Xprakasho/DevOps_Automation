import subprocess
import json

print("Kubernetes Health Checker")
print("=========================")

result = subprocess.run(
    ["kubectl", "get", "pods", "-A", "-o", "json"],
    capture_output=True,
    text=True
)

print("Return code:", result.returncode)

if result.returncode != 0:
    print("ERROR: kubectl command failed")
    print(result.stderr)
    exit(1)

try:
    data = json.loads(result.stdout)
except json.JSONDecodeError:
    print("ERROR: kubectl returned invalid JSON")
    exit(1)

print("Kubernetes response received")
print("Number of pods:", len(data["items"]))

print()
print("Pod health status:")
print("==================")

unhealthy_pods = []

for pod in data["items"]:
    pod_name = pod["metadata"]["name"]
    pod_phase = pod["status"].get("phase", "Unknown")

    ready = False

    for condition in pod["status"].get("conditions", []):
        if (
            condition.get("type") == "Ready"
            and condition.get("status") == "True"
        ):
            ready = True
            break

    if pod_phase == "Running" and ready:
        health_status = "HEALTHY"
    else:
        health_status = "UNHEALTHY"
        unhealthy_pods.append(pod_name)

    print(
        f"{pod_name} | "
        f"Phase: {pod_phase} | "
        f"Ready: {ready} | "
        f"{health_status}"
    )

print()

if len(unhealthy_pods) == 0:
    print("Health check: PASS")
    exit(0)
else:
    print("Health check: FAIL")
    print("Unhealthy pods:")

    for pod_name in unhealthy_pods:
        print("-", pod_name)

    exit(1)