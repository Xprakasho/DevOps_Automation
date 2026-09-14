#!/usr/bin/env python3

import json

with open("../bash/application.json") as file:
    config = json.load(file)

print("Application :", config["application"])
print("Version     :", config["version"])
print("Environment :", config["environment"])

if config["environment"] == "Development":
    print("Environment check: PASS")
else:
    print("Environment check: FAIL")
    exit(1)