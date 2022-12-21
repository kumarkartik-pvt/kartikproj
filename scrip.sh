
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

gcloud container clusters get-credentials $GCP_CLUSTER_NAME --zone $GCP_CLUSTER_ZONE --project $PROJECT_ID


curl https://storage.googleapis.com/csm-artifacts/asm/asmcli_1.15 > asmcli
chmod +x asmcli

export FLEET_PROJECT_ID=${FLEET_PROJECT_ID:-$PROJECT_ID}


gcloud container fleet memberships register gcp-cluster-membership \
 --gke-cluster=us-central1-b/gcp-cluster \
 --enable-workload-identity
gcloud container hub memberships list


./asmcli install \
  --project_id $GCP_PROJECT_ID \
  --cluster_name $GCP_CLUSTER_NAME \
  --cluster_location $GCP_CLUSTER_ZONE \
  --fleet_id $FLEET_PROJECT_ID \
  --output_dir . \
  --managed \
  --enable_all \
  --ca mesh_ca


cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  mesh: |-
    defaultConfig:
      tracing:
        stackdriver: {}
kind: ConfigMap
metadata:
  name: istio-asm-managed
  namespace: istio-system
EOF


kubectl label namespace default istio.io/rev=asm-managed --overwrite

kubectl annotate --overwrite namespace default \
  mesh.cloud.google.com/proxy='{"managed":"true"}'


git clone https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages
kubectl apply -f anthos-service-mesh-packages/samples/gateways/istio-ingressgateway -n istio-system
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml -n istio-system


cd $LAB_DIR
gsutil cp gs://config-management-release/released/latest/linux_amd64/nomos nomos
chmod +x ./nomos
./nomos status


gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml
kubectl apply -f config-management-operator.yaml


---------------------------------------------------------------------------------------------
If need to create a membership seperately
---------------------------------------------------------------------------------------------

gcloud container fleet memberships register gcp-cluster-membership \
 --gke-cluster=us-central1-b/gcp-cluster \
 --enable-workload-identity
gcloud container hub memberships list


---------------------------------------------------------------------------------------------

apiVersion: configmanagement.gke.io/v1
kind: ConfigManagement
metadata:
  name: config-management
spec:
  clusterName: gcp-cluster
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
    --membership=gcp-cluster\
    --config=/home/student_02_f250fd1e8fdb/applyspec.yaml \
    --project=$PROJECT_ID
 
 
 
 
 
 
 
 
 
---------------------------------------------------------------------------------------------
for boutique applicaiton
---------------------------------------------------------------------------------------------
 
 applySpecVersion: 1
spec:
  configSync:
    enabled: true
    sourceFormat: unstructured
    syncRepo: https://github.com/GoogleCloudPlatform/microservices-demo.git
    syncBranch: main
    secretType: none
    policyDir: ./release
  policyController:
    enabled: true
  hierarchyController:
    enabled: false

