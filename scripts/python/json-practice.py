import json

with open("../bash/application.json") as file:
    config = json.load(file)

print("Application :", config["application"])
print("Replicas    :", config["deployment"]["replicas"])

print("\nServers:")

for server in config["servers"]:
    if server["enabled"]:
        print(server["name"])