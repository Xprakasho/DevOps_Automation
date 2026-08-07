import os
import platform
import datetime

print("==================================")
print("Hello from Python!")
print(f"Python Version : {platform.python_version()}")
print(f"Platform       : {platform.system()}")
print(f"Machine        : {platform.machine()}")
print(f"Time           : {datetime.datetime.now()}")
print("==================================")

print()
print("===== GitHub Secret Demo =====")


user_name = os.getenv("USER_NAME")

print(f"User Name      : {user_name}")

print("==============================")
