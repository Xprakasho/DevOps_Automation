#!/bin/bash

set -euo pipefail

CONFIG_FILE="reg-helm"

CNF_NAME=$(
  jq -r '
    .[]
    | select(.name == "cnfName")
    | .value
  ' "$CONFIG_FILE"
)

CLUSTER_NAME=$(
  jq -r '
    .[]
    | select(.name == "regHelmValues")
    | .value.global.clustername
  ' "$CONFIG_FILE"
)

SDM_REPLICAS=$(
  jq -r '
    .[]
    | select(.name == "regHelmValues")
    | .value.sdm.replicaCount
  ' "$CONFIG_FILE"
)

echo "CNF Name      : $CNF_NAME"
echo "Cluster Name  : $CLUSTER_NAME"
echo "SDM Replicas  : $SDM_REPLICAS"