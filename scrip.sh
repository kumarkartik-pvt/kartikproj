
gcloud auth list

gcloud config list project

gcloud services enable anthos.googleapis.com
gcloud beta container fleet config-management enable



export PROJECT_ID=$(gcloud config get-value project)
export GCP_CLUSTER_NAME=gcp-cluster
export GCP_CLUSTER_ZONE=us-central1-b



gcloud container clusters create $GCP_CLUSTER_NAME \
  --zone $GCP_CLUSTER_ZONE \
  --machine-type "n1-standard-2" \
  --enable-ip-alias \
  --num-nodes=2 \
  --workload-pool=$PROJECT_ID.svc.id.goog \
  --release-channel=regular \
  --project=$PROJECT_ID



cd $LAB_DIR
gsutil cp gs://config-management-release/released/latest/linux_amd64/nomos nomos
chmod +x ./nomos
./nomos status


gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml
kubectl apply -f config-management-operator.yaml


gcloud container fleet memberships register MEMBERSHIP_NAME \
 --gke-cluster=GKE_CLUSTER \
 --enable-workload-identity
 

---------------------------------------------------------------------------------------------

apiVersion: configmanagement.gke.io/v1
kind: ConfigManagement
metadata:
  name: config-management
spec:
  clusterName: my-cluster
  enableMultiRepo: true
  policyController:
    enabled: true

 
---------------------------------------------------------------------------------------------
 
applySpecVersion: 1
spec:
  configSync:
    enabled: true
    sourceFormat: unstructured
    syncRepo: https://github.com/kumarkartik-pvt/kartikproj.git
    syncBranch: main
    secretType: none
    policyDir: .
  policyController:
    enabled: true
  hierarchyController:
    enabled: false

---------------------------------------------------------------------------------------------
 
gcloud beta container fleet config-management apply \
    --membership=MEMBERSHIP_NAME \
    --config=CONFIG_YAML_PATH \
    --project=PROJECT_ID
 
 
