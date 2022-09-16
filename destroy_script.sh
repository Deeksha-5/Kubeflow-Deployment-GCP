#!bin/bash

#THIS script helps to destroy Kubeflow deployed on a gcp 

#Download KFCTL

wget -O kfctl.tar.gz https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz

tar -xvf kfctl.tar.gz

rm -rf kfctl.tar.gz

export PATH=$PATH:$dir/kfctl/
dir=`pwd`
echo $dir

export KF_NAME=KUBEFLOW_NAME
export BASE_DIR=$dir/KUBEFLOW_DIR
export KF_DIR=${BASE_DIR}/${KF_NAME}
export CONFIG_FILE=${KF_DIR}/kfctl_gcp_iap.v1.0.2.yaml

echo "Destroying Kubeflow Deployment......"
$dir/kfctl delete -f ${CONFIG_FILE}
gcloud deployment-manager deployments delete $KF_NAME-storage
echo "Kubeflow Deleted"