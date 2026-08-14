1. What Bash Is

Bash is a shell and scripting language commonly used to automate Linux commands and infrastructure tools.

For our purpose, Bash is mainly the glue between tools.

Bash
 │
 ├── Git
 ├── AWS CLI
 ├── kubectl
 ├── Helm
 ├── Terraform
 ├── Docker
 ├── jq
 ├── curl
 └── other CLI tools

Our goal is not to become Bash software developers.

Our goal is to:

understand Bash scripts
execute scripts
modify scripts
troubleshoot scripts
automate infrastructure tasks
use Bash in CI/CD pipelines
2. Basic Script Structure

A basic Bash script:

#!/bin/bash


echo "Hello from Bash"

The first line:

#!/bin/bash

is called the shebang.

It tells Linux to execute the script using Bash.

Make a script executable:

chmod +x script.sh

Run it:

./script.sh
3. Variables

Variables store values.

APP_NAME="DevOps_Automation"
APP_ENV="Development"
VERSION="1.0"

Use a variable with $:

echo "$APP_NAME"
echo "$APP_ENV"

Important:

APP_NAME="DevOps_Automation"

Correct.

Avoid:

APP_NAME = "DevOps_Automation"

Spaces around = are not allowed in normal Bash variable assignment.

Quote variables

Prefer:

echo "$APP_NAME"

rather than:

echo $APP_NAME

Quoting prevents many problems when values contain spaces or special characters.

4. Environment Variables

Environment variables are variables available to processes.

Check one:

echo "$HOME"
echo "$USER"
echo "$SHELL"

Create one:

export APP_ENV="Development"

Then:

echo "$APP_ENV"

Common examples:

HOME
USER
PATH
SHELL
PWD

CI/CD systems also provide many environment variables.

For example:

echo "$GITHUB_WORKSPACE"

when running inside GitHub Actions.

5. Command Substitution

Command substitution allows us to put command output into a variable.

HOSTNAME=$(hostname)

Then:

echo "$HOSTNAME"

Another example:

CURRENT_DATE=$(date)

This pattern is extremely important in automation:

command
   ↓
output
   ↓
variable
   ↓
automation

Example:

NODE=$(kubectl get pod "$POD" -o jsonpath='{.spec.nodeName}')
6. set -euo pipefail

This is one of the most important Bash concepts for reliable automation.

set -euo pipefail

It combines three protections.

-e

Exit when a command fails.

set -e


ls /does-not-exist


echo "This will not execute"

The failed command returns a non-zero exit code, and the script stops.

-u

Treat an unset variable as an error.

set -u


echo "$NAME"

If NAME was never defined:

unbound variable

This protects against accidentally using empty/unset variables.

pipefail

Normally, a pipeline's status can be determined by the last command.

command1 | command2

With:

set -o pipefail

a failure anywhere in the pipeline can make the pipeline fail.

Therefore:

set -euo pipefail

is a very useful standard for our automation scripts.

7. Exit Codes

Every command returns an exit status.

echo $?

Immediately after a command:

0

usually means success.

Non-zero means failure.

Example:

ls /tmp
echo $?

Likely:

0

But:

ls /does-not-exist
echo $?

produces a non-zero value.

This is extremely important in CI/CD because pipeline systems depend heavily on exit codes.

0
 ↓
success
 ↓
continue pipeline
non-zero
 ↓
failure
 ↓
stop/fail pipeline
8. Conditions and [[ ]]

Bash uses conditions to make decisions.

Example:

if [[ "$ENV" == "Production" ]]; then
    echo "Production deployment"
else
    echo "Non-production deployment"
fi

[[ ... ]] is Bash's conditional expression syntax.

Example:

[[ "$ENV" == "Production" ]]

means:

Is ENV equal to Production?

9. File and Directory Checks

Directory:

[[ -d "$DIRECTORY" ]]

-d means:

Does this path exist and is it a directory?

Example:

if [[ -d "$DIRECTORY" ]]; then
    echo "Directory exists."
else
    echo "Directory does not exist."
fi

File:

[[ -f "$FILE" ]]

Readable file:

[[ -r "$FILE" ]]

Writable:

[[ -w "$FILE" ]]

Executable:

[[ -x "$FILE" ]]

These checks are extremely useful for deployment pre-checks.

10. Arrays

Arrays allow us to store multiple values.

DIRECTORIES=(
    "/tmp"
    "/home/om"
    "/does-not-exist"
)

Access an individual item:

echo "${DIRECTORIES[0]}"

All elements:

echo "${DIRECTORIES[@]}"

Number of elements:

echo "${#DIRECTORIES[@]}"

Loop:

for DIRECTORY in "${DIRECTORIES[@]}"; do
    echo "$DIRECTORY"
    done

    Important distinction:

${DIRECTORIES[@]}

means:

Expand all elements of the array.

Quoting it:

"${DIRECTORIES[@]}"

is safer when elements may contain spaces.

11. Arguments

Arguments allow a script to receive input from the command line.

Run:

./arguments.sh Development

Inside the script:

$1

means first argument.

$2

means second argument.

$#

means number of arguments.

$0

means the script name.

Example:

echo "Script: $0"
echo "First argument: $1"
echo "Arguments: $#"

A safer script should validate required arguments:

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

This is useful for scripts such as:

./deploy.sh Development
./deploy.sh Production

12. Functions

Functions allow us to group reusable logic.

greet_user() {
    local NAME="$1"


    echo "Hello, $NAME!"
}

Call it:

greet_user "Om"
greet_user "DevOps Engineer"

Output:

Hello, Om!
Hello, DevOps Engineer!
Important concept

Arguments inside a function are separate from script arguments.

Inside:

greet_user "Om"

the function receives:

$1

as:

Om

local keeps the variable local to the function:

local NAME="$1"

Functions are useful when a deployment script has repeated operations:

check_directory()
check_file()
check_command()
check_service()
validate_config()

13. Loops

Loops allow us to repeat operations.

for
for DIRECTORY in "${DIRECTORIES[@]}"; do
    echo "Checking: $DIRECTORY"
done

This is very common in infrastructure automation.

For example:

/tmp
/home/om
/config
/logs

can all be checked using one function and one loop.

14. Practical Deployment Pre-Checks

We combined conditions, functions and loops into deployment validation.

Conceptually:

Deployment
    ↓
Check directories
    ↓
Check files
    ↓
Check permissions
    ↓
All passed?
    ↓
Continue deployment

Example:

check_directory() {
    local DIRECTORY="$1"


    echo "Checking directory: $DIRECTORY"


    if [[ -d "$DIRECTORY" ]]; then
        echo "SUCCESS: Directory exists."
    else
        echo "ERROR: Directory does not exist."
        return 1
    fi
}

Then:

DIRECTORIES=(
    "/tmp"
    "/home/om"
)


for DIRECTORY in "${DIRECTORIES[@]}"; do
    check_directory "$DIRECTORY"
done

This is much closer to real infrastructure scripting than simple Bash exercises.

15. Logging

We used:

tee

Example:

./deployment.sh | tee deployment.log

tee sends output to:

terminal
+
file

So:

script
  ↓
tee
 ├── terminal
 └── deployment.log

Append instead of overwrite:

./deployment.sh | tee -a deployment.log

-a means append.

This is useful in CI/CD because we want both:

live output
persistent log
16. File Operations

Common commands:

mkdir
touch
cp
mv
rm
cat
ls

Example:

mkdir -p /tmp/devops-lab

Create:

touch config.txt

Copy:

Copy:

cp config.txt config.backup

Read:

cat config.txt

List:

ls -la

We used these operations to create configuration files and backups.

17. File Permissions

Check permissions:

ls -la config.txt

Example:

-rw-r--r--

Make a script executable:

chmod +x script.sh

Then:

./script.sh

Check whether a file is readable:

[[ -r "$FILE" ]]

This is useful before a deployment script attempts to consume configuration.

18. JSON

JSON is extremely common in automation.

Example:

{
  "application": "DevOps_Automation",
  "environment": "Development",
  "replicas": 2
}

We learned to use:

jq

to query JSON.

Pretty-print:

jq '.' application.json

Extract:

jq -r '.application' application.json

Nested value:

jq -r '.spec.replicas' application.json
19. JSON Arrays

Example:

{
  "servers": [
    {
      "name": "web-01",
      "role": "web",
      "enabled": true
    },
    {
      "name": "app-01",
      "role": "application",
      "enabled": true
    }
  ]
}

First item:

jq '.servers[0]' application.json

All names:

jq -r '.servers[].name' application.json

Number of servers:

jq '.servers | length' application.json

Filter:

jq -r '.servers[] | select(.enabled == true) | .name' application.json

The key skill is understanding the JSON structure:

object
 ↓
key
 ↓
array
 ↓
item
 ↓
field

20. kubectl + JSON + jq

This connects directly to your Kubernetes work.

You already use:

kubectl get pod <pod> -n <namespace> -o yaml

Kubernetes can also return JSON:

kubectl get pod <pod> -n <namespace> -o json

Then:

kubectl get pod <pod> -n <namespace> -o json \
| jq -r '.spec.nodeName'

Extract container image:

kubectl get pod <pod> -n <namespace> -o json \
| jq -r '.spec.containers[].image'

Extract node selector:

kubectl get pod <pod> -n <namespace> -o json \
| jq '.spec.nodeSelector'

So we now understand three useful approaches:

-o yaml
    → inspect configuration


-o jsonpath
    → directly extract a value


-o json | jq
    → query/filter/transform JSON
21. curl

curl allows Bash scripts to communicate with HTTP/REST APIs.

Basic GET:

curl https://example.com

Silent:

curl -s URL

Silent but show errors:

curl -sS URL

Fail on HTTP errors:

curl -sSf URL

This combination is especially useful in automation:

curl -sSf "$API_URL"

22. HTTP Status Codes

We learned that APIs return HTTP status codes.

Common examples:

200 → successful request
201 → resource created
400 → bad request
401 → authentication required/failed
403 → forbidden
404 → resource not found
500 → server error

For CI/CD, we care about whether the request should be considered successful.

curl -f makes HTTP 4xx/5xx responses produce a failure status.

This works well with:

set -e

because the script can stop when the API request fails.

23. Headers

Headers provide additional information to an HTTP request.

curl -H "Accept: application/json" URL

Accept means:

What response format do I want?

Content-Type means:

What format am I sending?

Example:

-H "Content-Type: application/json"

Authentication commonly uses:

-H "Authorization: Bearer $API_TOKEN"

Secrets should not be hard-coded into scripts.

Prefer:

API_TOKEN="$API_TOKEN"

or, more practically, have the CI/CD system inject the secret as an environment variable.

24. The Complete Bash Automation Pattern

At this point we can understand a realistic script like:

#!/bin/bash


set -euo pipefail


API_URL="https://example.com/api"


echo "Calling API..."


RESPONSE=$(curl -sSf "$API_URL")


VALUE=$(echo "$RESPONSE" | jq -r '.status')


if [[ "$VALUE" == "ready" ]]; then
    echo "System is ready."
else
    echo "System is not ready."
    exit 1
fi

The flow is:

API
 ↓
curl
 ↓
JSON
 ↓
jq
 ↓
Bash variable
 ↓
condition
 ↓
success/failure

This is exactly the kind of Bash we need for CI/CD.

25. Bash in CI/CD

Bash becomes the orchestration layer.

For example:

GitHub Actions
      ↓
Bash script
      ↓
validate configuration
      ↓
AWS CLI
      ↓
jq
      ↓
Docker
      ↓
kubectl
      ↓
Helm
      ↓
deployment validation

A CI/CD script might:

git status
docker build
docker push
aws ...
kubectl ...
helm ...
curl ...
jq ...

Bash connects these tools.

26. Our Bash Mental Model

Don't memorize commands randomly.

Think:

INPUT
  ↓
VARIABLE / ARGUMENT
  ↓
VALIDATE
  ↓
EXECUTE COMMAND
  ↓
CHECK EXIT CODE
  ↓
PROCESS OUTPUT
  ↓
DECISION
  ↓
NEXT ACTION

For structured output:

CLI/API
  ↓
JSON
  ↓
jq
  ↓
value
  ↓
Bash

For files:

file
 ↓
test
 ↓
read
 ↓
process
 ↓
validate

For deployments:

pre-check
 ↓
deploy
 ↓
health check
 ↓
success/failure
27. What We Are NOT Trying to Master Yet

We deliberately don't need advanced Bash topics right now.

We will learn additional Bash features when a real project requires them.

Our current level is enough to:

read Bash scripts
understand Bash logic
modify scripts
write practical automation
integrate CLI tools
process JSON
call APIs
build CI/CD steps
troubleshoot failures

That is exactly the skill level we wanted.

28. Bash → Python Transition

Our Bash foundation now gives us a good starting point for Python.

We'll recognize the same concepts:

Bash	                             Python
Variable	                         Variable
if	                                 if
for	                                 for
Function	                         def
Array	                             List
Associative data	                 Dictionary
jq	                                 json
curl	                             HTTP library
exit 1	                             sys.exit()
Command execution	                 subprocess
File operations	                     File APIs
Environment variables	             os.environ

So Python will not be a completely new world.