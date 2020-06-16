#!/bin/bash
set -x
# ENV Params:
# CLUSTER_FILE
# OPTIONS
# COMMIT_ID Override

CLUSTER_NAME=$(cat $CLUSTER_FILE | yq r - metadata.name)
: "${COMMIT_ID:=$(git rev-parse HEAD)}"

NUMBER_OF_NODEGROUPS=$(yq r $CLUSTER_FILE --length nodeGroups)
for (( i=0; i<NUMBER_OF_NODEGROUPS; i++ )); do
  NEW_NAME=$(yq r prod.yaml -j | jq ".nodeGroups[$i].name" | tr -d '"' | sed -i "s/-v[0-9a-f]\+$/-v$COMMIT_ID/g")
  echo $NEW_NAME
  yq r $CLUSTER_FILE -j | jq ".nodeGroups[$i].name = \"$NEW_NAME\"" | yq r --prettyPrint - > $CLUSTER_FILE
  eksctl get nodegroup --cluster $CLUSTER_NAME
  echo "eksctl create nodegroup -f $CLUSTER_FILE"
  echo "eksctl delete nodegroup --only-missing -f $CLUSTER_FILE $OPTIONS"
  sleep 60
end