#!bin/bash
#This script helps to deploy KUbeflow on a gcp 
#Download KFCTL

wget -O kfctl.tar.gz https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz

tar -xvf kfctl.tar.gz

rm -rf kfctl.tar.gz

export PATH=$PATH:$dir/kfctl/
dir=`pwd`
echo $dir
#Create user credentials. You only need to run this command once: (TO BE DONE MANUALLY)

#gcloud auth application-default login

# Set your GCP project ID and the zone where you want to create 
# the Kubeflow deployment:

export PROJECT=PROJECT_ID
export ZONE=ZONE_ID

gcloud config set project ${PROJECT}    
gcloud config set compute/zone ${ZONE}
echo "Project & Zone set up complete"

export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_gcp_iap.v1.0.2.yaml"

#Assign Variables
export CLIENT_ID=OAUTH_ID
export CLIENT_SECRET=OAUTH_SECRET
# GET OAUTH CREDENTIALS FROM APIs & Services -> Credentials
#Follow https://www.kubeflow.org/docs/gke/deploy/oauth-setup/

echo "OAuth config setted up"

#Pick a name KF_NAME for your Kubeflow deployment and directory for your configuration.
#For example, your kubeflow deployment name might be ‘my-kubeflow’ or ‘kf-test’.
#Set base directory where you want to store one or more Kubeflow deployments. 
#For example, ${HOME}/kf_deployments

export KF_NAME=KUBEFLOW_NAME
export BASE_DIR=$dir/KUBEFLOW_DIR
export KF_DIR=${BASE_DIR}/${KF_NAME}

echo "Basic Kubeflow setup done"

#${PROJECT} - The project ID of the GCP project where you want Kubeflow deployed.

#${ZONE} - The GCP zone where you want to create the Kubeflow deployment. 

#${CONFIG_URI} - The GitHub address of the configuration YAML file that you want to use to deploy Kubeflow.

#${KF_NAME} - The name of your Kubeflow deployment. 
#If you want a custom deployment name, specify that name here. For example, my-kubeflow or kf-test. 
#The value of KF_NAME must consist of lower case alphanumeric characters or ‘-', 
#and must start and end with an alphanumeric character. 
#The value of this variable cannot be greater than 25 characters. 
#It must contain just a name, not a directory path. 
#You also use this value as directory name when creating the directory where your Kubeflow configurations 
#are stored, that is, the Kubeflow application directory.

#${KF_DIR} - The full path to your Kubeflow application directory.


#Deploying Kubeflow using the default settings

mkdir -p ${KF_DIR}
cd ${KF_DIR}
${dir}/kfctl apply -V -f ${CONFIG_URI}


#Check Deployment
gcloud container clusters get-credentials ${KF_NAME} --zone ${ZONE} --project ${PROJECT}
kubectl -n kubeflow get all
kubectl -n istio-system get ingress

echo "Kubeflow deployed"
echo "https://${KF_NAME}.endpoints.${PROJECT}.cloud.goog/"
