
gcloud auth list

gcloud config list project

gcloud services enable anthos.googleapis.com

gcloud beta container fleet config-management enable


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
    syncRepo: https://github.com/GoogleCloudPlatform/anthos-config-management-samples
    syncBranch: init
    secretType: none
    policyDir: quickstart/multirepo/root
  policyController:
    enabled: false
  hierarchyController:
    enabled: false

---------------------------------------------------------------------------------------------
 
gcloud beta container fleet config-management apply \
    --membership=MEMBERSHIP_NAME \
    --config=CONFIG_YAML_PATH \
    --project=PROJECT_ID
 
 
