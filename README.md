# Kubeflow-Deployment-GCP
This script helps to create Infra required to deploy and run a Kubeflow pipeline


How to guide for end-to-end Kubeflow deployment

NOTE: the script read all the varible values from file.yaml (except OAUth Client ID & Secret, 
both of which are automatically created using the OAuth script.)

NOTE: OAUth Client can also be created manually. in that case paste the OAuth Client id & sceret values 
in the YAML file (under CLIENT_ID & CLIENT_SECRET)

Requirements:
1. An Owner account for a project(existing) or A new project
2. Billing ID
3. Organisation or Folder ID


Steps:
1. Create a new Project (If required)
2. Activate APIs {
    1.Compute Engine API
    2.Kubernetes Engine API
    3.Identity and Access Management (IAM) API
    4.Deployment Manager API
    5.Cloud Resource Manager API
    6.Cloud Filestore API
    7.AI Platform Training & Prediction API
    8.Cloud Build API (It’s required if you plan to use Fairing in your Kubeflow cluster)
    }
3. Create a service account with Storage Admin, AutoML admin & AutoML service agent
4. Create the Service account key and put that key in the GCP Key bucket(HERE: kubeflow-temp-data)
5. Create a OAuth Client ID and Sceret{
    1. Create a Brand (if none exists)
    2. Creata a Client
    3. Put client ID and Secret in the file.yaml
}
6. Deploy the Kubeflow on GCP
7. Paste the pipeline data inside the bucket()
8. Put the pipeline tar file in the same directory the other scripts are kept
9. Run the python script to upload the Pipeline on Kubeflow

NOTE{
    1. STEP (1,2,3): kube_prepare.sh & Project terraform script
    2. STEp(4) kube_prepare.sh
    3. STEP(5) kube_prepare.sh & oauth.sh
    4. STEP(6) kube_prepare.sh & deploy_script.sh
    5. STEP(7) kube_prepare.sh
    6. STEP(8) manual process(most probably files will be provided along with other scripts)
    7. STEP (9) kube_prepare.sh & pipeline.py
}
