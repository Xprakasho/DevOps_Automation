
Now: Manual Kubernetes Deployment

This is where our next phase begins.

We're going to build the Kubernetes understanding first, before Helm and Argo CD.

Our first application will intentionally be simple.

The learning path
                    Kubernetes
                        │
                        ▼
                  Deployment
                        │
                        ▼
                    ReplicaSet
                        │
                        ▼
                      Pod
                        │
                        ▼
                    Container
                        │
                        ▼
                    Service

I don't want you to blindly copy a large YAML file. We'll build it progressively and inspect what Kubernetes creates.

Step 1 — Create a namespace

Let's keep our learning workload separate from kube-system.

Run:

kubectl create namespace demo

Then:

kubectl get namespaces

You should see:

demo
Why?

We already saw:

kube-system
default
kube-public
kube-node-lease

Now we'll create:

demo

Our application resources will live there:

demo
│
├── Deployment
├── ReplicaSet
├── Pods
└── Service
Don't create the Deployment yet.

First run only:

kubectl create namespace demo

Then show me:

kubectl get ns

======================================================================================

2. Start with the outer object

Create a file:

mkdir -p k8s/agent01
cd k8s/agent01
touch deployment.yaml

Open it:

code deployment.yaml

Start with only this:

apiVersion: apps/v1
kind: Deployment
What are these?

apiVersion:

apiVersion: apps/v1

tells Kubernetes which API group/version owns this resource.

kind:

kind: Deployment

says:

"I want Kubernetes to manage an application Deployment."

So already:

apiVersion: apps/v1
        +
kind: Deployment
        ↓
Kubernetes knows what type of object we're describing
3. Add metadata

Now add:

metadata:
  name: agent01-app
  namespace: agent01

Our file becomes:

apiVersion: apps/v1
kind: Deployment

metadata:
  name: agent01-app
  namespace: agent01

This means:

name      → agent01-app
namespace → agent01

So we're explicitly saying:

Create a Deployment called agent01-app inside the agent01 namespace.

4. Now comes the important part: spec

Add:

spec:
  replicas: 2

So:

apiVersion: apps/v1
kind: Deployment

metadata:
  name: agent01-app
  namespace: agent01

spec:
  replicas: 2

replicas: 2 means:

I want Kubernetes to maintain two Pods for this application.

Important distinction:

Deployment
    │
    │ desired replicas = 2
    ▼
ReplicaSet
    │
    ├── Pod 1
    └── Pod 2

We are not directly creating two Pods.

We're declaring the desired state:

"There should be two replicas."

The Deployment/ReplicaSet machinery makes that happen.

5. Now we need to tell the Deployment which Pods belong to it

Add:

  selector:
    matchLabels:
      app: agent01

So now:

apiVersion: apps/v1
kind: Deployment

metadata:
  name: agent01-app
  namespace: agent01

spec:
  replicas: 2

  selector:
    matchLabels:
      app: agent01

Think of the selector as:

"Find/manage Pods that have the label app=agent01."

But there's an important consequence:

The Pods must actually have that label.

That's why the next section is template.

6. Pod template

Add:

  template:
    metadata:
      labels:
        app: agent01

Now we have:

apiVersion: apps/v1
kind: Deployment

metadata:
  name: agent01-app
  namespace: agent01

spec:
  replicas: 2

  selector:
    matchLabels:
      app: agent01

  template:
    metadata:
      labels:
        app: agent01

Notice the relationship:

selector:
  app: agent01
       ▲
       │ must match
       │
template:
  labels:
    app: agent01

This is very important for understanding Deployments.

7. Finally, define the container

Now add:

    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80

Our complete first Deployment is:

apiVersion: apps/v1
kind: Deployment

metadata:
  name: agent01-app
  namespace: agent01

spec:
  replicas: 2

  selector:
    matchLabels:
      app: agent01

  template:
    metadata:
      labels:
        app: agent01

    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
Now understand the hierarchy

This YAML describes:

Deployment: agent01-app
        │
        │ replicas: 2
        ▼
   ReplicaSet
        │
        ├──────────────┐
        ▼              ▼
     Pod 1           Pod 2
        │              │
        ▼              ▼
     nginx           nginx

This is the core relationship we want to understand before touching Helm or Argo CD.

8. Before applying it

Don't apply yet.

First run:

kubectl apply --dry-run=client -f deployment.yaml

Expected:

deployment.apps/agent01-app created (dry run)

============================================================================================================================================

We'll continue with the application:

Deployment — already created ✅
ReplicaSet — observe how Deployment created it ✅
Pods — observe the two running nginx Pods ✅
Service — expose the application
Test application access
Make a small change and observe Kubernetes reconciliation
Delete the Deployment and understand cleanup

Then we'll move to:

Manual Kubernetes
       ↓
     Helm
       ↓
    Argo CD
       ↓
    GitOps
	
	======================================================================
	
===== 
Service

Right now, our NGINX Pods are running, but we haven't created a Kubernetes Service.

That means we shouldn't think of the Pods as our stable application endpoint yet.

The next relationship will be:

                    Service
                       │
                  selector:
                  app=agent01
                       │
              ┌────────┴────────┐
              ▼                 ▼
           Pod 1              Pod 2
        10.0.11.79         10.0.12.69

The Service gives us a stable Kubernetes endpoint while the individual Pods can be replaced or recreated.

This is exactly the concept we need before we move toward Helm and Argo CD.

Let's build the Service next

Create:

touch service.yaml

Then we'll build the Service YAML together and specifically understand:

kind: Service
selector
port
targetPort
ClusterIP

Exactly. Let's expose agent01-app through a Kubernetes Service.

We currently have:

Deployment
    ↓
ReplicaSet
    ↓
Pod 1       Pod 2
10.0.11.79  10.0.12.69

The problem is that Pod IPs are not stable. If a Pod is recreated, its IP can change.

A Service gives us a stable abstraction:

             Service
          agent01-service
                │
          selector:
          app=agent01
             /     \
            ▼       ▼
          Pod 1   Pod 2
1. Build service.yaml

You're already in:

k8s/agent01

Create:

touch service.yaml

Put this in it:

apiVersion: v1
kind: Service

metadata:
  name: agent01-service
  namespace: agent01

spec:
  selector:
    app: agent01

  ports:
    - port: 80
      targetPort: 80
Understand the important parts

kind: Service

kind: Service

We're creating a Kubernetes Service.

Selector

selector:
  app: agent01

This is critical.

Our Pods have:

labels:
  app: agent01

Therefore:

Service selector
      ↓
app=agent01
      ↓
matches Pods
      ↓
Pod 1 + Pod 2

Port

ports:
  - port: 80
    targetPort: 80

Think:

Service port 80
      ↓
Pod/container port 80

We're intentionally keeping this simple.

2. Validate before creating

Run:

kubectl apply --dry-run=client -f service.yaml

Expected:

service/agent01-service created (dry run)

Then actually create it:

kubectl apply -f service.yaml

Expected:

service/agent01-service created
3. Inspect it

Run:

kubectl get svc -n agent01

You should see something similar to:

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
agent01-service   ClusterIP   10.x.x.x        <none>        80/TCP

Notice:

TYPE = ClusterIP

This means the application is exposed inside the Kubernetes cluster, not directly to the public Internet.

That's exactly what we want for the first Service lesson.

4. Then inspect the Service endpoints

This is the important verification:

kubectl get endpoints -n agent01

We should see the two Pod IPs:

agent01-service   10.0.11.79:80,10.0.12.69:80

That proves:

Service
   │
   ├── 10.0.11.79:80
   └── 10.0.12.69:80

The Service found our Pods using the selector.

Run these four commands
kubectl apply --dry-run=client -f service.yaml
kubectl apply -f service.yaml
kubectl get svc -n agent01
kubectl get endpoints -n agent01

Now let's actually test the application

This is the important next step.

Because our Service is ClusterIP, it is only reachable inside the Kubernetes cluster.

We'll temporarily create a small curl Pod inside agent01:

kubectl run test-client \
  -n agent01 \
  --image=curlimages/curl \
  --rm -it \
  --restart=Never \
  -- sh

You'll get a shell inside that temporary Pod.

Then run:

curl http://agent01-service

We expect NGINX's response:

<!DOCTYPE html>
<html>
...
<h1>Welcome to nginx!</h1>
...

The important thing isn't the HTML.

We're proving:

test-client Pod
       │
       │ DNS
       ▼
agent01-service
       │
       │ Service routing
       ▼
   NGINX Pod
Also test Kubernetes DNS

Inside the temporary Pod:

curl http://agent01-service.agent01.svc.cluster.local

This demonstrates the Kubernetes DNS name:

agent01-service
       ↓
agent01
       ↓
svc
       ↓
cluster.local

After testing:

exit

Because we used --rm, Kubernetes will automatically remove the temporary test Pod.

Run the kubectl run command and then curl http://agent01-service. This is our first end-to-end application test on the Terraform-created EKS cluster.

==============================================================================================================================

Phase 2 — Package the application with Helm

We currently have a working application deployed manually:

agent01 namespace
│
├── Deployment
│    └── ReplicaSet
│         ├── Pod
│         └── Pod
│
└── Service

Our goal is to turn this:

deployment.yaml
service.yaml

into a reusable Helm chart.

Why Helm comes before Argo CD

Right now Kubernetes needs us to manage raw manifests:

deployment.yaml
service.yaml

Helm gives us:

Helm Chart
│
├── templates/
│   ├── deployment.yaml
│   └── service.yaml
│
└── values.yaml

So instead of hardcoding things like:

replicas: 2
image: nginx:latest

we can parameterize them:

replicas: {{ .Values.replicaCount }}
image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"

Then:

values.yaml
      ↓
Helm template rendering
      ↓
Kubernetes manifests
      ↓
Kubernetes API

And this is exactly what will make Argo CD more meaningful later:

Git
 │
 └── Helm Chart
       │
       ▼
    Argo CD
       │
       ▼
 Kubernetes
       │
       ▼
 EKS
Step 1 — Don't create the chart yet

First let's see whether Helm is installed.

Run:

helm version

Then:

helm list -A

The second command is important because we're going to learn the difference between:

Helm chart
Helm release
Kubernetes resources

Our existing agent01-app was not installed by Helm, so helm list -A should not show it as a Helm release.

Step 1 — Create our Helm chart

We're going to create the chart from scratch using Helm's standard structure, but we'll understand what each directory means.

From:

k8s/agent01

run:

helm create agent01-chart

Then:

tree agent01-chart

You should get something roughly like:

agent01-chart/
├── Chart.yaml
├── values.yaml
├── charts/
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── serviceaccount.yaml
│   ├── _helpers.tpl
│   ├── NOTES.txt
│   └── tests/
└── .helmignore

Don't worry about all of it yet.

The core three are:

Chart.yaml
    ↓
What is this chart?

values.yaml
    ↓
What can we configure?

templates/
    ↓
What Kubernetes resources should Helm generate?

Think of it as:

Chart
│
├── Chart.yaml       → Chart metadata
│
├── values.yaml      → Configuration
│
└── templates/       → Kubernetes resource templates
One important point

We already have:

deployment.yaml
service.yaml

from our manual exercise.

Don't delete them and don't modify the working application yet.

We're going to use the Helm-generated chart to understand the structure first, then we'll replace the generated application templates with our agent01 application.

Run:

helm create agent01-chart

and:

tree agent01-chart

This is the standard Helm chart skeleton:

agent01-chart/
├── Chart.yaml
├── values.yaml
├── charts/
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── serviceaccount.yaml
    ├── hpa.yaml
    ├── httproute.yaml
    ├── _helpers.tpl
    └── tests/

We don't need all of these for our first application.

For our learning project, the important pieces are:

Chart.yaml
    ↓
Chart identity/metadata

values.yaml
    ↓
Application configuration

templates/
    ├── deployment.yaml
    └── service.yaml
    ↓
Kubernetes resources
Let's inspect them before changing anything

Run these three commands:

cat agent01-chart/Chart.yaml
cat agent01-chart/values.yaml
cat agent01-chart/templates/deployment.yaml

Don't modify anything yet.

I want you to see the relationship between the three:

Chart.yaml
    │
    │ identifies the chart
    ▼
values.yaml
    │
    │ supplies configuration
    ▼
templates/deployment.yaml
    │
    │ renders configuration
    ▼
Kubernetes Deployment

Then we'll inspect the generated service.yaml and convert the chart from the generic Helm example into our agent01 application.

1. Chart.yaml — chart identity

Your current file says:

apiVersion: v2
name: agent01-chart
type: application
version: 0.1.0
appVersion: "1.16.0"

There are two different versions here:

version
    ↓
Helm chart version

appVersion
    ↓
Application version

So:

Chart version = 0.1.0
Application version = 1.16.0
Important observation

Your values.yaml has:

image:
  repository: nginx
  tag: ""

And the Deployment template contains:

image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"

Therefore, because tag is empty:

.Values.image.tag
        ↓
empty
        ↓
default .Chart.AppVersion
        ↓
1.16.0

So this generated chart would currently render:

image: nginx:1.16.0

not:

image: nginx:latest

That's different from our manually deployed application, which currently uses:

image: nginx:latest

Good catch to make now. We should deliberately choose what we want rather than accidentally change the application version.

2. values.yaml — configuration layer

This is the major Helm concept.

For example:

replicaCount: 1

is consumed by:

replicas: {{ .Values.replicaCount }}

So:

values.yaml
replicaCount: 2
       │
       ▼
Deployment template
.Values.replicaCount
       │
       ▼
replicas: 2

Similarly:

image:
  repository: nginx
  tag: "..."

feeds:

image: "{{ .Values.image.repository }}:..."

And:

service:
  port: 80

feeds the container port in this generated template.

So the fundamental Helm model is:

values.yaml
     │
     ▼
Helm template
     │
     ▼
Rendered Kubernetes YAML
     │
     ▼
Kubernetes API
3. The generated Deployment template

This part:

spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}

means:

If HPA/autoscaling isn't enabled, use the replica count from values.yaml.

Currently:

autoscaling:
  enabled: false

replicaCount: 1

So Helm renders:

replicas: 1

If we change:

replicaCount: 2

Helm renders:

replicas: 2

This is exactly the same Kubernetes concept we just tested manually.

4. Selector and labels

The generated template uses:

selector:
  matchLabels:
    {{- include "agent01-chart.selectorLabels" . | nindent 6 }}

and then:

labels:
  {{- include "agent01-chart.labels" . | nindent 8 }}

These include calls come from:

templates/_helpers.tpl

So we're seeing another important Helm concept:

deployment.yaml
       │
       ├── .Values...
       │
       └── include ...
                │
                ▼
          _helpers.tpl
                │
                ▼
          rendered YAML

We'll inspect _helpers.tpl shortly. Don't modify it yet.

5. Container configuration

This section:

containers:
  - name: {{ .Chart.Name }}

    image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"

    imagePullPolicy: {{ .Values.image.pullPolicy }}

is where Helm becomes very useful.

Instead of hardcoding:

image: nginx:latest

we have configurable values.

For example:

image:
  repository: nginx
  tag: "1.27"

could render:

image: nginx:1.27

This is the beginning of environment-specific configuration.

6. Don't get distracted by all the generated options

The generated values.yaml contains many things:

ServiceAccount
SecurityContext
Ingress
HTTPRoute
HPA
Resources
Volumes
NodeSelector
Tolerations
Affinity
...

We don't need to learn all of them now.

Our first chart should stay simple:

agent01-chart
│
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    └── service.yaml

Eventually, we can add things deliberately when the application needs them.

7. One thing I want you to understand before we modify anything

Our manual Kubernetes deployment was:

deployment.yaml
service.yaml

Helm is going to transform that into:

values.yaml
      +
templates/
      │
      ▼
Helm rendering
      │
      ▼
deployment.yaml
service.yaml

So Helm doesn't replace Kubernetes.

It generates Kubernetes manifests.

That's the conceptual bridge:

Kubernetes
    ↓
Raw YAML

Helm
    ↓
Parameterized YAML
    ↓
Kubernetes

And later:

Argo CD
    ↓
Helm chart
    ↓
Helm rendering
    ↓
Kubernetes
Next: inspect two files

Before we start simplifying the generated chart, run:

cat agent01-chart/templates/service.yaml

and:

cat agent01-chart/templates/_helpers.tpl

Then we'll compare the generated Service/labels with the working agent01 Deployment and Service we already created.

=======================================================================

1. service.yaml

Your Service template is:

spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "agent01-chart.selectorLabels" . | nindent 4 }}

There are two kinds of Helm expressions here.

Values
.Values.service.type
.Values.service.port

These come directly from values.yaml:

service:
  type: ClusterIP
  port: 80

So Helm renders:

type: ClusterIP
port: 80
Helper

This:

include "agent01-chart.selectorLabels" .

doesn't come from values.yaml.

It calls a function defined in:

templates/_helpers.tpl
2. _helpers.tpl is basically reusable template functions

For example:

{{- define "agent01-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "agent01-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

This defines a reusable template called:

agent01-chart.selectorLabels

When service.yaml says:

{{- include "agent01-chart.selectorLabels" . | nindent 4 }}

Helm inserts the generated labels there.

So conceptually:

_helpers.tpl
       │
       │ defines reusable logic
       ▼
service.yaml
       │
       │ include
       ▼
rendered Service
3. Why .Release.Name is important

This is one of the most important Helm concepts.

When we eventually run:

helm install agent01 agent01-chart -n agent01

Helm creates a release named:

agent01

Then:

.Release.Name

becomes:

agent01

Therefore this:

app.kubernetes.io/instance: {{ .Release.Name }}

becomes:

app.kubernetes.io/instance: agent01

This helps distinguish multiple installations of the same chart.

For example:

agent01-dev
agent01-test
agent01-prod

could all potentially use the same chart with different release names/configuration.

4. Why the Service finds the Pods

This is particularly important because we just manually tested this concept.

Deployment Pods receive labels from:

include "agent01-chart.labels"

The Service uses:

include "agent01-chart.selectorLabels"

The helper defines:

app.kubernetes.io/name: ...
app.kubernetes.io/instance: ...

Therefore:

Deployment
   │
   └── Pod labels
         │
         │ match
         ▼
      Service
         │
         ▼
      Pods

This is the same Kubernetes mechanism we already used manually.

Helm isn't changing how Kubernetes networking works.

It is simply generating the labels/selectors consistently.

5. fullname — why the resource name may surprise you

The generated Deployment and Service both use:

include "agent01-chart.fullname"

The helper eventually does:

.Release.Name + "-" + chart name

unless the release name already contains the chart name.

For example, if:

helm install myrelease agent01-chart

we could get something like:

myrelease-agent01-chart

for the resource name.

But if we install with an appropriate release name, we can make the naming cleaner.

This is another reason Helm charts shouldn't blindly hardcode resource names.

6. Now let's render — DON'T INSTALL

This is the next important Helm skill.

We can ask Helm:

"Show me exactly what Kubernetes YAML you would generate."

without changing the cluster.

Run:

helm template agent01 agent01-chart

This is analogous to the Terraform mindset:

Terraform:
terraform plan
      ↓
show intended changes

Helm:
helm template
      ↓
show rendered Kubernetes YAML

Even better, let's inspect only the Deployment and Service output:

helm template agent01 agent01-chart | less

You can press:

q

to exit less.

What I want you to notice

Look for:

kind: Deployment

and:

kind: Service

and especially:

replicas:
image:
selector:
labels:

Don't install it yet.

We still have our existing manually deployed agent01-app, and I want to compare the rendered Helm output against what is already running before we let Helm manage anything.

Run:

helm template agent01 agent01-chart

===================================================================================

1. Helm converted templates + values into real Kubernetes YAML

Your input:

Chart.yaml
values.yaml
templates/

produced:

ServiceAccount
Service
Deployment
Test Pod

So:

values.yaml
     +
templates/*.yaml
     ↓
helm template
     ↓
Rendered Kubernetes YAML

No resource was created by this command.

2. Notice the resource names

We asked Helm to use release name:

helm template agent01 agent01-chart

So:

.Release.Name = agent01

The generated name became:

agent01-agent01-chart

for the Deployment and Service.

That's because the helper does:

.Release.Name + "-" + .Chart.Name

This is technically fine, but agent01-agent01-chart is ugly for our application.

We'll clean that up.

3. Notice the replica count

Rendered:

replicas: 1

because:

replicaCount: 1

in values.yaml.

Our actual application currently has:

agent01-app
3 replicas

So our Helm chart doesn't yet represent our real application.

4. Notice the image

Rendered:

image: "nginx:1.16.0"

This is important.

We had:

image:
  repository: nginx
  tag: ""

and:

appVersion: "1.16.0"

Therefore:

empty image.tag
       ↓
use Chart.AppVersion
       ↓
nginx:1.16.0

But our existing application is using the image we selected earlier.

So again, we don't want to blindly install this generated chart.

5. Let's now customize the chart for agent01

We'll keep this first Helm version deliberately simple.

Our target should be:

agent01 Helm release
│
├── Deployment
│     └── 3 nginx replicas
│
└── Service
      └── ClusterIP :80
First modify values.yaml

Open it:

nano agent01-chart/values.yaml

For now, change these parts:

replicaCount: 3

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: ClusterIP
  port: 80

You can leave the other generated sections alone for the moment.

Save and exit:

Ctrl+O
Enter
Ctrl+X
6. Change the application version

In Chart.yaml, change:

appVersion: "1.16.0"

to something representing our application:

appVersion: "1.0.0"

And let's change the chart name from:

name: agent01-chart

to:

name: agent01

So the important part becomes:

apiVersion: v2
name: agent01
description: Helm chart for agent01 application
type: application
version: 0.1.0
appVersion: "1.0.0"

Now we're describing our application, rather than the generic chart generated by helm create.

7. Render again

Don't install yet.

Run:

helm template agent01 agent01-chart

This time I want you to check specifically for:

replicas: 3

and:

image: "nginx:latest"

and see what the resource names become.

This is an important workflow to remember:

Modify values/templates
        ↓
helm template
        ↓
Inspect rendered YAML
        ↓
helm lint
        ↓
helm install/upgrade

That's very similar to the discipline we're using with Terraform:

Modify configuration
        ↓
terraform fmt
        ↓
terraform validate
        ↓
terraform plan
        ↓
terraform apply

==========================================

Then run Helm lint

Once the typo is fixed:

helm lint agent01-chart

Expected:

1 chart(s) linted, 1 chart(s) passed

This gives us a nice Helm workflow:

values.yaml
    ↓
helm template       ← inspect generated YAML
    ↓
helm lint            ← validate chart
    ↓
helm install         ← actually deploy

And notice how closely this resembles our Terraform workflow:

Terraform
    ↓
fmt
    ↓
validate
    ↓
plan
    ↓
apply

===================================================================

Next: install it

Now we can actually deploy the Helm release.

But remember: we already have our manually deployed application in namespace agent01. We should not accidentally collide with it.

Our Helm chart generates:

Deployment: agent01
Service:    agent01

while our existing manual application is:

Deployment: agent01-app
Service:    agent01-service

So they can coexist.

Run:

helm install agent01 agent01-chart -n agent01

Then immediately check:

helm list -n agent01

and:

kubectl get all -n agent01

This gives us a very useful comparison:

agent01 namespace
│
├── Manual application
│   ├── agent01-app
│   └── agent01-service
│
└── Helm application
    ├── agent01
    └── agent01
	
You now have two applications in the same namespace, one manually managed and one Helm-managed.

Current state
agent01 namespace
│
├── Manual deployment
│   ├── Deployment: agent01-app
│   ├── ReplicaSet: agent01-app-5c49b45c
│   ├── 2 Pods
│   └── Service: agent01-service
│
└── Helm deployment
    ├── Release: agent01
    ├── Deployment: agent01
    ├── ReplicaSet: agent01-6f878d44c6
    ├── 3 Pods
    └── Service: agent01

Your Helm release is:

NAME     NAMESPACE  REVISION  STATUS     CHART          APP VERSION
agent01  agent01    1         deployed   agent01-0.1.0  1.0.0

So Helm is now managing the second application.

The important part: Helm Release

This is the concept I want you to remember.

When you ran:

helm install agent01 agent01-chart -n agent01

Helm created a release:

Release = agent01

That release represents a particular deployment of the chart.

Think:

Chart
  │
  │ helm install
  ▼
Release
  │
  ├── Deployment
  ├── Service
  ├── ServiceAccount
  └── other resources

And Helm remembers the release state.

That's why:

helm list -n agent01

shows:

REVISION 1
STATUS deployed
Now let's do the most important Helm operation: Upgrade

This is where Helm becomes much more useful than manually editing Kubernetes YAML.

Currently:

Helm release
    │
    └── 3 replicas

Let's change the desired replica count from:

replicaCount: 3

to:

replicaCount: 4

Edit:

nano agent01-chart/values.yaml

Change only:

replicaCount: 3

to:

replicaCount: 4

Then render first:

helm template agent01 agent01-chart | grep -A3 "replicas:"

You should see:

replicas: 4

Then run:

helm upgrade agent01 agent01-chart -n agent01

After that:

helm list -n agent01

You should see:

REVISION 2
STATUS deployed

And:

kubectl get deployment agent01 -n agent01

should eventually show:

READY 4/4

This demonstrates the core Helm lifecycle:

Chart v0.1.0
     │
     │ install
     ▼
Release revision 1
     │
     │ change values
     ▼
helm upgrade
     │
     ▼
Release revision 2
     │
     ▼
4 Pods
This is the bridge toward GitOps

Eventually we won't manually run:

helm upgrade

Instead:

Git
 │
 │ values.yaml / Helm chart changes
 ▼
Argo CD
 │
 │ detects desired state change
 ▼
Helm
 │
 ▼
Kubernetes
 │
 ▼
EKS

One important observation

The output from helm upgrade also displayed Helm's generated NOTES.txt:

Get the application URL...
kubectl port-forward...

That's coming from:

templates/NOTES.txt

We can keep it for now. Later we'll simplify the chart and make the notes specific to our application.

==============================================================

Next: rollback

Since Helm keeps revisions, let's demonstrate why that matters.

We currently have:

REVISION 1 → 3 replicas
REVISION 2 → 4 replicas

Run:

helm history agent01 -n agent01

You should see both revisions.

Then:

helm rollback agent01 1 -n agent01

Check:

kubectl get deployment agent01 -n agent01

We should get:

READY 3/3

And:

helm list -n agent01

should show a new revision, typically:

REVISION 3

The important concept is:

Revision 1 → 3 replicas
Revision 2 → 4 replicas
Revision 3 → rollback to revision 1

Notice that rollback doesn't erase history.

This is one of the reasons Helm is useful for deployment automation and operational recovery.

Run:

helm history agent01 -n agent01

====================================================================

The important concept is:

helm install
     ↓
Revision 1
     ↓
helm upgrade
     ↓
Revision 2

Helm doesn't overwrite the history. It maintains release revisions, which enables rollback.

Now let's perform the rollback

Run:

helm rollback agent01 1 -n agent01

Then:

kubectl get deployment agent01 -n agent01

We expect:

READY
3/3

Then:

helm history agent01 -n agent01

You should now see something like:

REVISION  STATUS
1         superseded
2         superseded
3         deployed

The interesting part is that revision 3 is the rollback operation. Helm doesn't simply delete revision 2 from history.

So the lifecycle becomes:

Revision 1
3 replicas
    │
    │ upgrade
    ▼
Revision 2
4 replicas
    │
    │ rollback to 1
    ▼
Revision 3
3 replicas

=============================================================================================

Perfect. ✅ The rollback worked exactly as intended.

Your current Helm history is:

Revision 1 → Install complete → superseded
Revision 2 → Upgrade complete → superseded
Revision 3 → Rollback to 1   → deployed

And:

helm list -n agent01

shows:

REVISION: 3
STATUS:   deployed
The important lesson

A rollback does not remove history.

It creates a new revision:

1: 3 replicas
      │
      ▼
2: 4 replicas
      │
      ▼
3: rollback to revision 1
      │
      ▼
3 replicas running

This is the Helm lifecycle we wanted to understand.

One more Helm concept: ownership

Now let's see what Helm actually manages.

Run:

helm get manifest agent01 -n agent01

This shows the Kubernetes manifests currently associated with the Helm release.

Then:

helm status agent01 -n agent01

You'll see the release information, revision, resources, and notes.

This is useful because we currently have:

agent01 namespace
│
├── Helm-managed
│   ├── Deployment agent01
│   ├── Service agent01
│   └── ServiceAccount agent01
│
└── kubectl-managed
    ├── Deployment agent01-app
    └── Service agent01-service
	
Next, let's prove ownership

Run:

helm uninstall agent01 -n agent01

Then:

kubectl get all -n agent01

Do not delete anything with kubectl.

We want to observe that:

Helm-managed:
    agent01 Deployment
    agent01 Service
    agent01 ServiceAccount
        ↓
    removed

Manually managed:
    agent01-app Deployment
    agent01-service
        ↓
    remains

That will give us the final practical distinction:

kubectl apply
    → Kubernetes resources directly

Helm
    → Release → Kubernetes resources

Argo CD later
    → Git → Helm/Kubernetes → EKS
	
=================================================================================================

Next: Argo CD → GitOps deployment

Argo CD's official documentation describes it as a declarative GitOps CD tool for Kubernetes; it can consume Helm charts directly, so our existing Helm chart is perfect for this exercise.

Step 1 — Install Argo CD

We're using the standard non-HA installation because this is our learning lab, not a production Argo CD deployment. The official quick-start currently recommends creating the argocd namespace and applying the stable installation manifest with server-side apply.

Run:

kubectl create namespace argocd

Then:

kubectl apply -n argocd \
  --server-side \
  --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Don't proceed to the next step yet.

After it finishes, run:

kubectl get pods -n argocd

and:

kubectl get svc -n argocd

Send me the output.

We'll verify that the Argo CD control plane is healthy before installing/configuring anything else.

What we're building

Keep this architecture in mind:

                    AWS
                     │
                     ▼
              EKS Cluster
                     │
        ┌────────────┴─────────────┐
        │                          │
   Argo CD                    agent01 namespace
        │                          │
        │                          ├── agent01-app
        │                          └── agent01-service
        │
        │ watches Git
        ▼
      Git Repo
        │
        └── agent01 Helm chart

Eventually the flow becomes:

Git change
   │
   ▼
Argo CD detects change
   │
   ▼
Helm renders chart
   │
   ▼
Kubernetes desired state
   │
   ▼
EKS

That is the key transition from our earlier imperative deployment:

kubectl apply -f deployment.yaml

to GitOps:

Git → Argo CD → Kubernetes

Perfect. Argo CD is installed successfully and healthy. ✅

Your screenshot shows all the core components are Running and 1/1 ready:

argocd-application-controller     Running
argocd-applicationset-controller  Running
argocd-dex-server                 Running
argocd-notifications-controller   Running
argocd-redis                      Running
argocd-repo-server                Running
argocd-server                     Running

And the services are present, including:

argocd-server   ClusterIP   ...   80/TCP,443/TCP
argocd-repo-server
argocd-redis

So the Argo CD control plane is operational.

Next: access Argo CD

For our lab, let's use port-forwarding rather than exposing Argo CD through a LoadBalancer.

Run:

kubectl port-forward svc/argocd-server -n argocd 8080:443

Keep that terminal running.

Then open in your browser:

https://localhost:8080

You'll probably get a browser certificate warning because this is the Argo CD server's local/self-signed certificate. That's expected for this lab.

Get the initial admin password

Open a second WSL terminal and run:

argocd admin initial-password -n argocd

If your argocd CLI isn't installed yet, don't install anything yet—tell me the output of:

argocd version --client

We'll handle it from there.

Our target

We're now moving toward this:

Terraform
   │
   ├── VPC
   ├── EKS
   └── Node Group
          │
          ▼
       EKS Cluster
          │
          ├── Argo CD
          │
          └── agent01
                ▲
                │
             Helm
                ▲
                │
               Git

The important architectural boundary is:

Terraform creates the platform.

Argo CD manages the application lifecycle.

Helm packages the application.

Yes — the UI is working correctly. 👍

The screenshot shows the Argo CD login page, so your port-forward is working:

WSL
  │
  │ kubectl port-forward
  ▼
localhost:8080
  │
  ▼
argocd-server:443

It won't automatically ask for the password outside the login form. You need to retrieve the initial admin password from the Kubernetes Secret. The official Argo CD documentation confirms this is the initial login method.

Step 1 — Get the password

In your second terminal run:

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo

You should get something like:

xxxxxxxxxxxxxxxxxxxxxxxx

Don't paste the password here.

Step 2 — Login in the browser

Use:

Username:
admin

Password:
<the password you just retrieved>

Then click SIGN IN.

The admin account is the initial local administrator account. Argo CD uses the supplied username/password to establish an authenticated session.

About argocd CLI

You also checked:

argocd version --client

and got:

argocd: command not found

That's fine. We don't need the CLI yet.

For now, let's learn the Argo CD architecture through the UI first. Later we'll install the CLI because it becomes very useful for automation.

So, don't install anything else yet.

Run only:

kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo

Then log in as admin.

Once you are inside the Argo CD dashboard, send me a screenshot. We'll create our first Argo CD Application using the agent01 Helm chart.

==============================================================================

Now we'll create our first GitOps application

Before clicking NEW APP, let's establish the model:

                 Git Repository
                       │
                       │ desired state
                       ▼
                  Argo CD
                       │
                 Application
                       │
                       ▼
                  Helm Chart
                       │
                       ▼
                EKS Kubernetes
                       │
              ┌────────┴────────┐
              ▼                 ▼
          Deployment          Service
              │
              ▼
             Pods

There is one important thing we need to decide before creating the Application:

Where should Argo CD get our Helm chart from?

Right now your chart is local:

aws-terraform-learning/
└── labs/
    └── terraform-modules/
        └── k8s/
            └── agent01/
                └── agent01-chart/

Argo CD running inside EKS cannot see your WSL filesystem.

For GitOps, we therefore need to put the chart into a Git repository.

Our next step

Let's first check whether your current Git repository already contains this project.

From:

~/aws-terraform-learning

run:

git status

Then:

git remote -v

And:

git branch --show-current

Send me the output.

Don't create the Argo CD Application yet.

We'll first make sure the Helm chart is properly represented in Git. Then we'll connect:

Git → Argo CD → EKS

Good — this output tells us exactly where we are. Your Git repository is healthy, but the new Kubernetes/Helm work has not been committed yet.

You are currently inside:

~/aws-terraform-learning/labs/terraform-modules/k8s/agent01

and Git reports:

Untracked files:
    ../

That means the k8s work is new from Git's perspective.

Your remote is already correct:

origin → https://github.com/Xprakasho/aws-terraform-learning.git

and you're on:

main
Let's do this carefully

First go to the repository root:

cd ~/aws-terraform-learning

Then:

git status

And:

tree labs/terraform-modules/k8s/agent01

If tree isn't available:

find labs/terraform-modules/k8s/agent01 -maxdepth 3 -type f
Why we're doing this first

We want our Git structure to clearly represent what we learned:

aws-terraform-learning/
└── labs/
    └── terraform-modules/
        └── k8s/
            └── agent01/
                ├── deployment.yaml        # manual Kubernetes deployment
                ├── service.yaml            # manual service
                │
                └── agent01-chart/          # Helm/GitOps application
                    ├── Chart.yaml
                    ├── values.yaml
                    └── templates/

Then our eventual Argo CD flow will be:

GitHub
  │
  │ agent01-chart
  ▼
Argo CD
  │
  │ Helm rendering
  ▼
EKS
  │
  ▼
agent01 application

Don't git add yet. Send me the output of git status from the repository root and the tree. Then we'll decide exactly what belongs in Git and commit it cleanly.

============================================================================

Step 1 — Review what Git will add

From:

cd ~/aws-terraform-learning

run:

git add labs/terraform-modules/k8s/

Then don't commit yet. Check:

git status

You should see the Kubernetes/Helm files under:

Changes to be committed:

Then inspect exactly what we're committing:

git diff --cached --stat

and:

git diff --cached --name-status
Why this checkpoint matters

We're establishing a clean Git history:

Previous commits
      │
      ▼
Terraform Modules
      │
      ▼
Kubernetes + Helm lab   ← CURRENT COMMIT
      │
      ▼
Argo CD GitOps
      │
      ▼
CI/CD automation

Once we've verified the staged files, we'll commit:

git commit -m "Add Kubernetes and Helm agent01 deployment"

and push:

git push origin main

Then GitHub becomes the source of truth for our agent01 Helm chart, and we can create the Argo CD Application pointing directly at that repository.

================================================================

You have 14 new files / 578 lines, and the two important layers are both represented:

Kubernetes manifests
├── deployment.yaml
└── service.yaml

Helm chart
└── agent01-chart/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/

This is exactly what we want to preserve for future reference.

Commit it

Run:

git commit -m "Add agent01 Kubernetes and Helm deployment"

Then verify:

git status

You should get:

nothing to commit, working tree clean

Then push:

git push origin main

Finally verify:

git status

You should see:

Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
Then we move to the important part

Once GitHub has the chart:

GitHub
└── labs/terraform-modules/k8s/agent01/
    └── agent01-chart/

we will configure:

                    GitHub
                       │
                       │
                       ▼
                    Argo CD
                       │
                 watches repo
                       │
                       ▼
                 agent01-chart
                       │
                    Helm
                       │
                       ▼
                     EKS

And this time we won't run helm install ourselves.

Argo CD will perform the application deployment and become the controller maintaining the desired state.

That's the key GitOps exercise we're building toward.

=================================================================================

Next step

Let's create the Argo CD Application from the UI.

Go back to:

https://localhost:8080

and click:

NEW APP

Don't fill anything yet.

Send me a screenshot of the Create Application screen, and we'll fill each field together and understand exactly what every Argo CD setting means rather than blindly copying values.

Excellent. We are at the Argo CD Application creation screen. This is the important point where we connect GitHub → Argo CD → EKS.

For our lab, let's deliberately use manual sync first. We want to understand GitOps before enabling automation.

1. GENERAL

Fill:

Field	Value
Application Name	agent01-gitops
Project Name	default
Sync Policy	Manual

Why agent01-gitops instead of agent01?

We already have the manually deployed agent01-app, and this name makes the GitOps-managed application obvious.

Leave these unchecked:

Set Deletion Finalizer
Skip Schema Validation
Apply Out Of Sync Only
Server-Side Apply
Auto-Create Namespace
Respect Ignore Differences
Prune Last
Replace
Retry

For this first deployment, keep:

PRUNE = true
DELETE = true

That's fine for our controlled lab.

2. SOURCE

This is the most important section.

Repository URL

Enter:

https://github.com/Xprakasho/aws-terraform-learning.git
Revision

Keep:

HEAD

This means Argo CD follows the current HEAD of the selected branch.

Path

Enter:

labs/terraform-modules/k8s/agent01/agent01-chart

This is important.

Our Git repository contains:

aws-terraform-learning/
└── labs/
    └── terraform-modules/
        └── k8s/
            └── agent01/
                └── agent01-chart/
                    ├── Chart.yaml
                    ├── values.yaml
                    └── templates/

So Argo CD will discover that this is a Helm chart and render it.

You don't need to select agent01/deployment.yaml or agent01/service.yaml.

Those were our original raw Kubernetes manifests.

Our GitOps source is now:

agent01-chart/
3. DESTINATION

For Cluster URL, select the in-cluster Kubernetes API:

https://kubernetes.default.svc

Depending on your Argo CD UI, you may be able to select the cluster from the dropdown instead of typing it.

Namespace

Enter:

agent01

So the final destination is:

Cluster:
https://kubernetes.default.svc

Namespace:
agent01

We already created:

kubectl create namespace agent01

so we don't need AUTO-CREATE NAMESPACE.

4. DIRECTORY SECTION

Because our source is a Helm chart, don't configure Directory.

Argo CD should detect:

Chart.yaml

and understand:

This is Helm
     ↓
render Helm templates
     ↓
generate Kubernetes manifests
     ↓
compare with EKS
5. What we are creating

Conceptually, our configuration will be:

Argo CD Application
────────────────────────────

Name:
agent01-gitops

Project:
default

Source:
GitHub
   │
   └── aws-terraform-learning
          │
          └── labs/terraform-modules/k8s/agent01/agent01-chart
                                      │
                                      ├── Chart.yaml
                                      ├── values.yaml
                                      └── templates/
                                            ├── deployment.yaml
                                            ├── service.yaml
                                            └── serviceaccount.yaml

Revision:
HEAD

Destination:
https://kubernetes.default.svc

Namespace:
agent01

Sync:
Manual
One thing I want you to notice

We now have three layers:

Terraform
   │
   └── Creates EKS infrastructure
             │
             ▼
        Kubernetes/EKS
             │
             ▲
             │
        Argo CD
             ▲
             │
           Git
             ▲
             │
          GitHub

Terraform's responsibility:

Create and manage the platform/infrastructure.

Argo CD's responsibility:

Deploy and reconcile applications.

Helm's responsibility:

Package/template the Kubernetes application.

Git's responsibility:

Store the desired state.

That's the architecture we're building toward.

Do this now

Fill the fields exactly as above, but don't click CREATE yet.

Once you've filled the General + Source + Destination sections, send me a screenshot. I'll verify the configuration before we create the Application.

✅ General
Application Name: agent01-gitops
Project:         default
Sync Policy:     Manual

Correct.

✅ Source
Repository:
https://github.com/Xprakasho/aws-terraform-learning.git

Revision:
HEAD

Path:
labs/terraform-modules/k8s/agent01/agent01-chart

Exactly what we want.

Argo CD will take the Helm chart from Git:

GitHub
  └── aws-terraform-learning
       └── labs/terraform-modules/k8s/agent01
            └── agent01-chart
                 ├── Chart.yaml
                 ├── values.yaml
                 └── templates/
✅ Destination
Cluster:
https://kubernetes.default.svc

Namespace:
agent01

Correct. This means:

Argo CD running inside the EKS cluster → deploys into the agent01 namespace of the same EKS cluster.

Important

Keep Sync Policy = Manual for this first exercise.

We intentionally want:

Git change
    ↓
Argo CD detects difference
    ↓
Application becomes OutOfSync
    ↓
YOU click Sync
    ↓
Kubernetes changes

Later we'll enable automated sync and see the real GitOps behavior.

🚀 Now click CREATE

After clicking CREATE, don't manually run kubectl apply.

We want Argo CD to perform the deployment.

Then send me the Application screen showing agent01-gitops.

Our next step will be to inspect:

Git
 ↓
Helm
 ↓
Argo CD
 ↓
EKS
 ↓
Deployment
 ↓
ReplicaSet
 ↓
Pods
 ↓
Service

This is the key transition from what we just learned manually to actual GitOps deployment.

What Argo CD is telling us

We created the Argo CD Application, but we have not synchronized it yet.

The desired state is:

GitHub
  ↓
agent01-chart
  ↓
Argo CD
  ↓
EKS / agent01 namespace

But currently the resources described by Git are not deployed by this Argo CD Application, hence:

Missing
OutOfSync

This is actually useful because we can now observe the GitOps lifecycle.

Before clicking SYNC

Let's first establish our baseline.

Currently, we still have the old manually deployed application:

agent01-app

from our earlier Kubernetes exercise.

Argo CD is managing a different application name:

agent01-gitops

but the Helm chart itself creates:

Deployment: agent01
Service:    agent01
ServiceAccount: agent01

So when we sync, Argo CD will create those resources.

Click SYNC

Then leave the defaults for this first run and synchronize.

After it completes, we should expect approximately:

agent01-gitops
        │
        ├── ServiceAccount
        ├── Service
        └── Deployment
              │
              └── ReplicaSet
                    ├── Pod
                    ├── Pod
                    └── Pod

And the Application should move toward:

Synced
Healthy

Go ahead and click SYNC. Then show me the resulting Argo CD screen.

Perfect. This is exactly what we wanted. ✅

Your Argo CD Application is now:

agent01-gitops
Status:  💚 Healthy   ✅ Synced

And the flow has now actually worked end-to-end:

GitHub
  │
  │  agent01-chart
  ▼
Argo CD
  │
  │  Sync
  ▼
EKS
  │
  └── namespace: agent01
        │
        ├── ServiceAccount
        ├── Service
        └── Deployment
              │
              └── ReplicaSet
                    └── Pods
The important GitOps concept we just demonstrated

Previously:

kubectl apply -f deployment.yaml

You → Kubernetes

Now:

GitHub → Argo CD → Kubernetes

Git is the desired-state source.

Next: prove GitOps reconciliation

Don't change anything in Kubernetes yet.

Let's first inspect what Argo CD created:

kubectl get all -n agent01

Then:

kubectl get serviceaccount -n agent01

And:

helm list -n agent01

The last command is particularly interesting:

It should NOT show agent01-gitops as a Helm release.

Why?

Because Argo CD is using Helm as a manifest renderer, not installing the chart through helm install.

That's an important distinction:

helm install
    ↓
Helm owns release

Argo CD + Helm chart
    ↓
Argo CD owns application
    ↓
Helm renders manifests

Run:

kubectl get all -n agent01
helm list -n agent01

Send me the output. Then we'll do the most important experiment: make a small Git change and watch the application become OutOfSync.

====================================================================================

Perfect. This output gives us a very important confirmation of the architecture. Your GitOps deployment is working correctly.

What we can see

You now have two separate applications in the same namespace:

agent01 namespace
│
├── agent01-app
│   ├── 2 pods
│   └── old manual deployment
│
└── agent01-gitops
    ├── 4 pods
    ├── Service: agent01-gitops
    └── ServiceAccount: agent01-gitops

So the old manual deployment is still there. That's fine for this experiment.

And this is the key result:

helm list -n agent01
NAME  NAMESPACE  REVISION  UPDATED  STATUS  CHART  APP VERSION

Nothing is listed.

That's exactly what I wanted you to see.

Why?

We did not run:

helm install

Instead:

GitHub
   ↓
Helm Chart
   ↓
Argo CD
   ↓
Helm renders manifests
   ↓
Argo CD applies manifests
   ↓
EKS

Therefore:

Argo CD owns the application, not Helm.

Helm is being used as the templating/package mechanism.

Now let's do the most important GitOps experiment

We will change the desired state only in Git.

Currently Argo CD sees:

Git desired state
      =
EKS actual state

        ↓

Healthy + Synced

We'll deliberately change the replica count.

1. Check the current Git value

From your repo root:

cd ~/aws-terraform-learning

Then:

grep -n "replicaCount" labs/terraform-modules/k8s/agent01/agent01-chart/values.yaml

I expect it currently represents the 4 replicas that Argo CD deployed.

2. Change replicas in Git

Let's make it 2 replicas.

If the value is currently 4, run:

sed -i 's/^replicaCount: 4/replicaCount: 2/' labs/terraform-modules/k8s/agent01/agent01-chart/values.yaml

Then verify:

grep -n "replicaCount" labs/terraform-modules/k8s/agent01/agent01-chart/values.yaml
3. Commit and push
git status

Then:

git add labs/terraform-modules/k8s/agent01/agent01-chart/values.yaml
git commit -m "scale agent01 gitops deployment to 2 replicas"
git push origin main
Then STOP.

Do not run kubectl apply.

Do not run helm upgrade.

Do not click Sync yet.

Go to the Argo CD UI and refresh the application.

We want to catch this exact state:

Git:
replicas = 2

EKS:
replicas = 4

        ↓

Argo CD detects difference

        ↓

🟡 OutOfSync

That is the moment where GitOps becomes tangible rather than just a diagram.

Once you see OutOfSync, send me the screenshot/output. Then we'll manually click SYNC and watch Argo CD reconcile EKS back to the Git-defined state.

==================================================================================================

Exactly. This is the GitOps behavior we wanted to demonstrate. ✅

Your sequence is correct:

Git change
  ↓
replicaCount: 4 → 2
  ↓
commit
  ↓
push to GitHub
  ↓
Argo CD detects Git ≠ cluster
  ↓
Healthy + OutOfSync

Your Argo CD screen confirms:

Healthy + OutOfSync

That is an important distinction:

Healthy → the currently running Kubernetes resources are healthy.
OutOfSync → the running resources do not match the desired state in Git.

So right now:

Git desired state     Cluster actual state
replicas: 2           replicas: 4
      │                     │
      └────── mismatch ────┘
                 ↓
             OutOfSync
Now do the reconciliation

Click SYNC in Argo CD.

For this experiment, keep the default sync options. Then start the sync.

After it completes, run:

kubectl get deployment agent01-gitops -n agent01

Then:

kubectl get pods -n agent01 -l app.kubernetes.io/instance=agent01-gitops

And finally:

kubectl get deployment agent01-gitops -n agent01

We should see:

READY   UP-TO-DATE   AVAILABLE
2/2     2            2

and Argo CD should return to:

Healthy + Synced
The key lesson

This is the exact distinction we want to retain for your Terraform + EKS + GitOps architecture:

Terraform
   │
   ├── Infrastructure
   │     └── EKS
   │
   └── platform/bootstrap components
         └── Argo CD
                │
                ▼
              Git
                │
                ▼
          Desired state
                │
                ▼
             Argo CD
                │
                ▼
          Kubernetes/EKS
                │
                ▼
          Application

Terraform creates/provisions the platform; GitOps continuously manages the Kubernetes application desired state.

And importantly, we just proved that the application can be changed without kubectl apply and without helm upgrade.

Perfect. ✅ GitOps reconciliation worked exactly as expected.

Your output proves the change was applied:

Before Sync
agent01-gitops   4/4   4   4

Four replicas were running.

After Argo CD Sync
agent01-gitops   2/2   2   2

And the pod list now shows exactly 2 pods, both:

1/1   Running

So the complete flow we demonstrated is:

values.yaml
replicaCount: 4
       │
       ▼
Git commit + push
       │
       ▼
GitHub
       │
       ▼
Argo CD detects difference
       │
       ▼
OutOfSync
       │
       ▼
Argo CD Sync
       │
       ▼
Kubernetes Deployment
       │
       ▼
4 replicas → 2 replicas
       │
       ▼
Healthy + Synced
This is an important checkpoint

We've now practically covered:

Terraform → EKS infrastructure
Kubernetes → application deployment
Service → application exposure inside cluster
Helm → application packaging
Helm upgrade → release management
Helm rollback → recovery
Git → desired state
Argo CD → reconciliation
GitOps → automated application deployment
Git change → cluster change

And most importantly, we've demonstrated the separation of responsibilities:

Terraform
   │
   └── Infrastructure / EKS / platform

Helm
   │
   └── Application packaging

Git
   │
   └── Desired application configuration

Argo CD
   │
   └── Reconciliation

Kubernetes
   │
   └── Actual application runtime

This gives us a very solid base for the next Terraform work.

I would now stop expanding the Kubernetes/Helm side for the moment. We have enough practical EKS + GitOps integration to understand the architecture.

=====================================================================================================

Clean the deployment-

I suggest we do it in three controlled stages:

1. Clean the Kubernetes application layer

We already removed the Helm release:

helm delete agent01 -n agent01

Now verify the namespace:

kubectl get all -n agent01

We should only have resources that were created outside the Helm release, if any.

Then:

kubectl get ns agent01

If the namespace itself was created only for this lab:

kubectl delete namespace agent01

Verify:

kubectl get ns agent01

Expected:

Error from server (NotFound): namespaces "agent01" not found
Argo CD

Our agent01-gitops application was created through Argo CD UI, so clean that as well.

First check:

kubectl get applications -n argocd

Then delete the GitOps Application:

kubectl delete application agent01-gitops -n argocd

Verify:

kubectl get applications -n argocd
2. Clean Terraform infrastructure

Do not immediately run terraform destroy.

Go to your Terraform root:

cd ~/aws-terraform-learning

First:

terraform state list

Then:

terraform plan -destroy

This is important because we want to know exactly what Terraform is going to remove.

If the plan looks correct and contains only our lab infrastructure:

terraform destroy

Confirm with:

yes

After destruction:

terraform show

and:

terraform state list

Ideally:

No state file was found!

or no managed resources remain, depending on how your configuration/state is structured.

Then verify AWS:

aws eks list-clusters --region us-east-1

and:

aws ec2 describe-vpcs --region us-east-1

We want to make sure our lab resources are actually gone.

=============================================================================================

