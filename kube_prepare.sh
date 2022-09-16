#!bin/bash
# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

dir=`pwd`
echo "$dir"
#THIS script helps to Create Infra required to deploy and run a Kubeflow pipeline.
echo "1. Create Basic Infastructure Required (Project, Service Account, Storage Buckets)"
echo "2. Create OAuth Client for Authentication & Deploy Kubeflow"
echo "3. Copy Pipeline Data"
echo "4. Deploy Pipeline on Kubeflow"
echo "5. Deploy end-to-end Workflow"
#Keep seprate logging & Monitoring
#create logging & Monitoring scripts

read -p "Enter Type of Job you want to Execute: " choice
echo $choice


if [ $choice == 1 ]; then
    echo "----------------------Preparing Project Files-------------------------------------"
    while IFS= read -r line || [[ -n "$line" ]]; 
            do
                if [[ "$line" == *"PROJECT_ID"* ]]; then
                PROJECT=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Project = $PROJECT"
                elif [[ "$line" == *"ZONE_NAME"* ]]; then
                ZONE=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Zone = $ZONE"
                elif [[ "$line" == *"PARENT_TYPE"* ]]; then
                PARENT_TYPE=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Project Parent Type = $PARENT_TYPE"
                elif [[ "$line" == *"PARENT_ID"* ]]; then
                PARENT_ID=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Project Parent ID = $PARENT_ID"
                elif [[ "$line" == *"BILLING_ID"* ]]; then
                BILLING_ID=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Project Billing ID = $BILLING_ID"
                elif [[ "$line" == *"Ser_Name"* ]]; then
                SERVICE=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Service Account = $SERVICE"
                elif [[ "$line" == *"key_bucket"* ]]; then
                KEY_BUCK=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "KEY BUCKET = $KEY_BUCK"
                elif [[ "$line" == *"data_bucket"* ]]; then
                DATA_BUCK=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "DATA BUCKET = $DATA_BUCK"
            fi
    done < file.yaml
    cd project/
    cp terraform.sample terraform.tfvars
    #SETUP TERRAFORM TFVARS FILE 
    sed -i 's/PARENT_TYPE/'$PARENT_TYPE'/' terraform.tfvars
    sed -i 's/PARENT_ID/'$PARENT_ID'/' terraform.tfvars
    sed -i 's/BILLING/'$BILLING_ID'/' terraform.tfvars
    sed -i 's/PROJECT/'$PROJECT'/' terraform.tfvars
    sed -i 's/S_ACC/'$SERVICE'/' terraform.tfvars
    sed -i 's/KEY_BU/'$KEY_BUCK'/' terraform.tfvars
    sed -i 's/DATA_BU/'$DATA_BUCK'/' terraform.tfvars
    echo "Variable Values Set"
    echo "Preparing to run Terraform"
    #terraform init
    #terraform apply --lock=false -auto-approve
    #echo "Terraform Applied"
elif [ $choice == 2 ]; then
    echo "----------------------Settin up OAuth---------------------------------"
    cp oauth.sh oauth_setup.sh
    echo "Creating OAuth Client for Authentication"
    while IFS= read -r line || [[ -n "$line" ]]; 
        do
            if [[ "$line" == *"OWNER_EMAIL"* ]]; then
            O_MAIL=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "OWNER_MAIL = $O_MAIL"
        fi
    done < file.yaml
    sed -i 's/EMAIL/'$O_MAIL'/' oauth_setup.sh
    echo "Setting up OAuth client on the Project"
    sh oauth_setup.sh
    rm oauth_setup.sh
    echo "OAuth setup Complete"
    echo "-----------------------------Setting up Kubeflow----------------------------------------"
    #Preparing Scripts using YAML File
    while IFS= read -r line || [[ -n "$line" ]]; 
        do
            if [[ "$line" == *"PROJECT_ID"* ]]; then
            PROJECT=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "Project = $PROJECT"
            elif [[ "$line" == *"ZONE_NAME"* ]]; then
            ZONE=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "Zone = $ZONE"                
            elif [[ "$line" == *"CLIENT_ID"* ]]; then
            CLIENT_ID=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "OAuth Client = $CLIENT_ID"
            elif [[ "$line" == *"CLIENT_SECRET"* ]]; then
            CLIENT_SECRET=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "OAuth Secret = $CLIENT_SECRET"
            elif [[ "$line" == *"KF_NAME"* ]]; then
            KF_NAME=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "Kubeflow Name = $KF_NAME"
            elif [[ "$line" == *"KF_BASE_DIR"* ]]; then
            KF_BASE_DIR=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "Kubeflow Directory = $KF_BASE_DIR"
            fi
    done < file.yaml
    #SETUP KUBEFLOW DEPLOY SCRIPT
    cp deploy_script.sh kube_deploy.sh

    sed -i 's/PROJECT_ID/'$PROJECT'/' kube_deploy.sh
    sed -i 's/ZONE_ID/'$ZONE'/' kube_deploy.sh
    sed -i 's/OAUTH_ID/'$CLIENT_ID'/' kube_deploy.sh
    sed -i 's/OAUTH_SECRET/'$CLIENT_SECRET'/' kube_deploy.sh
    sed -i 's/KUBEFLOW_NAME/'$KF_NAME'/' kube_deploy.sh
    sed -i 's/KUBEFLOW_DIR/'$KF_BASE_DIR'/' kube_deploy.sh

    #SETUP KUBEFLOW DESTROY SCRIPT
    cp destroy_script.sh kube_destroy.sh

    sed -i 's/KUBEFLOW_NAME/'$KF_NAME'/' kube_destroy.sh
    sed -i 's/KUBEFLOW_DIR/'$KF_BASE_DIR'/' kube_destroy.sh

    echo "Running script to deploy Kubeflow on GCP"
    #sh kube_deploy.sh
    #rm kube_deploy.sh
elif [ $choice == 3 ]; then
    echo "----------------------Copying Pipeline Data to Buckets---------------------------------"
    while IFS= read -r line || [[ -n "$line" ]]; 
        do
            if [[ "$line" == *"key_bucket"* ]]; then
            KEY_BUCK=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "KEY BUCKET = $KEY_BUCK"
            elif [[ "$line" == *"data_bucket"* ]]; then
            DATA_BUCK=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "DATA BUCKET = $DATA_BUCK"
            elif [[ "$line" == *"key"* ]]; then
            KEY_FILE=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "SERVICE ACCOUNT KEY FILE PATH = $KEY_FILE"
            elif [[ "$line" == *"data"* ]]; then
            FILE_PATH=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "PIPELIEN DATA PATH = $FILE_PATH"
            elif [[ "$line" == *"PROJECT_ID"* ]]; then
            PROJECT=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "Project = $PROJECT"
            elif [[ "$line" == *"Ser_Name"* ]]; then
            SERVICE=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "Service Account = $SERVICE"
        fi
    done < file.yaml
    gcloud iam service-accounts keys create key.json --iam-account="${SERVICE}@${PROJECT}.iam.gserviceaccount.com"
    mv key.json data/
    echo "Copying files to Buckets"
    #gsutil cp -r ${FILE_PATH} ${DATA_BUCK}
    #gsutil cp -r ${KEY_FILE} ${KEY_BUCK}
    echo "Files Copied"
elif [ $choice == 4 ]; then
    echo "---------------------Deploying Pipeline on Kubeflow--------------------------------"
    cp pipeline.py pipeline_deploy.py
    while IFS= read -r line || [[ -n "$line" ]]; 
        do
            if [[ "$line" == *"key_bucket"* ]]; then
            KEY_BUCK=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "KEY BUCKET = $KEY_BUCK"
            elif [[ "$line" == *"data_bucket"* ]]; then
            DATA_BUCK=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "DATA BUCKET = $DATA_BUCK"
            elif [[ "$line" == *"EXP_NAME"* ]]; then
            EXPERIMENT=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "PIPELINE EXPERIMENT NAME = $EXPERIMENT"
            elif [[ "$line" == *"RUN_NAME"* ]]; then
            RUN=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "PIPELIEN RUN NAME = $RUN"
            elif [[ "$line" == *"PIPELINE_FILE"* ]]; then
            P_FILE=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "PIPELINE FILE TO DEPLOY = $P_FILE"
            elif [[ "$line" == *"PROJECT_ID"* ]]; then
            PROJECT=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "Project = $PROJECT"   
        fi
    done < file.yaml
    
    sed -i 's/EXP_NAME/'$EXPERIMENT'/' pipeline_deploy.py
    sed -i 's/RUN/'$RUN'/' pipeline_deploy.py
    sed -i 's/PIPE_FILE/'$P_FILE'/' pipeline_deploy.py
    sed -i 's/PROJECT/'$PROJECT'/' pipeline_deploy.py
    sed -i 's/KEY/'$KEY_BUCK'/' pipeline_deploy.py
    sed -i 's/DATA/'$DATA_BUCK'/' pipeline_deploy.py

    echo "Starting Puthon script to deploy Pipeline"
    #python3 pipeline_deploy.py
    #rm pipeline_deploy.py
elif [ $choice == 5 ]; then
    echo "----------------------Preparing Project Files-------------------------------------"
    while IFS= read -r line || [[ -n "$line" ]]; 
            do
                if [[ "$line" == *"PROJECT_ID"* ]]; then
                PROJECT=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Project = $PROJECT"
                elif [[ "$line" == *"ZONE_NAME"* ]]; then
                ZONE=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Zone = $ZONE"
                elif [[ "$line" == *"PARENT_TYPE"* ]]; then
                PARENT_TYPE=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Project Parent Type = $PARENT_TYPE"
                elif [[ "$line" == *"PARENT_ID"* ]]; then
                PARENT_ID=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Project Parent ID = $PARENT_ID"
                elif [[ "$line" == *"BILLING_ID"* ]]; then
                BILLING_ID=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Project Billing ID = $BILLING_ID"
                elif [[ "$line" == *"Ser_Name"* ]]; then
                SERVICE=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Service Account = $SERVICE"
                elif [[ "$line" == *"key_bucket"* ]]; then
                KEY_BUCK=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "KEY BUCKET = $KEY_BUCK"
                elif [[ "$line" == *"data_bucket"* ]]; then
                DATA_BUCK=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "DATA BUCKET = $DATA_BUCK"
                elif [[ "$line" == *"OWNER_EMAIL"* ]]; then
                O_MAIL=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "OWNER_MAIL = $O_MAIL"
                elif [[ "$line" == *"KF_NAME"* ]]; then
                KF_NAME=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Kubeflow Name = $KF_NAME"
                elif [[ "$line" == *"KF_BASE_DIR"* ]]; then
                KF_BASE_DIR=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "Kubeflow Directory = $KF_BASE_DIR"
                elif [[ "$line" == *"key"* ]]; then
                KEY_FILE=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "SERVICE ACCOUNT KEY FILE PATH = $KEY_FILE"
                elif [[ "$line" == *"data"* ]]; then
                FILE_PATH=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "PIPELIEN DATA PATH = $FILE_PATH"
                elif [[ "$line" == *"EXP_NAME"* ]]; then
                EXPERIMENT=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "PIPELINE EXPERIMENT NAME = $EXPERIMENT"
                elif [[ "$line" == *"RUN_NAME"* ]]; then
                RUN=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "PIPELIEN RUN NAME = $RUN"
                elif [[ "$line" == *"PIPELINE_FILE"* ]]; then
                P_FILE=$(cut -d ':' -f2 <<< "$line" | xargs)
                echo "PIPELINE FILE TO DEPLOY = $P_FILE"
        fi
    done < file.yaml

    #TERRAFORM TFVARS
    cd project/
    cp terraform.sample terraform.tfvars
    #SETUP TERRAFORM TFVARS FILE 
    sed -i 's/PARENT_TYPE/'$PARENT_TYPE'/' terraform.tfvars
    sed -i 's/PARENT_ID/'$PARENT_ID'/' terraform.tfvars
    sed -i 's/BILLING/'$BILLING_ID'/' terraform.tfvars
    sed -i 's/PROJECT/'$PROJECT'/' terraform.tfvars
    sed -i 's/S_ACC/'$SERVICE'/' terraform.tfvars
    sed -i 's/KEY_BU/'$KEY_BUCK'/' terraform.tfvars
    sed -i 's/DATA_BU/'$DATA_BUCK'/' terraform.tfvars
    echo "Variable Values Set"
    echo "Preparing to run Terraform"
    #terraform init
    #terraform apply --lock=false -auto-approve
    #echo "Terraform Applied"
    cd ..
    echo "----------------------Settin up OAuth---------------------------------"
    cp oauth.sh oauth_setup.sh
    echo "Creating OAuth Client for Authentication"
    sed -i 's/EMAIL/'$O_MAIL'/' oauth_setup.sh
    echo "Setting up OAuth client on the Project"
    sh oauth_setup.sh
    rm oauth_setup.sh
    echo "OAuth setup Complete"
    echo "-----------------------------Settin up Kubeflow----------------------------------------"
    #Preparing Scripts using YAML File
    
    while IFS= read -r line || [[ -n "$line" ]]; 
        do
            if [[ "$line" == *"CLIENT_ID"* ]]; then
            CLIENT_ID=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "OAuth Client = $CLIENT_ID"
            elif [[ "$line" == *"CLIENT_SECRET"* ]]; then
            CLIENT_SECRET=$(cut -d ':' -f2 <<< "$line" | xargs)
            echo "OAuth Secret = $CLIENT_SECRET"
            fi
    done < file.yaml

    #SETUP KUBEFLOW DEPLOY SCRIPT
    cp deploy_script.sh kube_deploy.sh

    sed -i 's/PROJECT_ID/'$PROJECT'/' kube_deploy.sh
    sed -i 's/ZONE_ID/'$ZONE'/' kube_deploy.sh
    sed -i 's/OAUTH_ID/'$CLIENT_ID'/' kube_deploy.sh
    sed -i 's/OAUTH_SECRET/'$CLIENT_SECRET'/' kube_deploy.sh
    sed -i 's/KUBEFLOW_NAME/'$KF_NAME'/' kube_deploy.sh
    sed -i 's/KUBEFLOW_DIR/'$KF_BASE_DIR'/' kube_deploy.sh

    #SETUP KUBEFLOW DESTROY SCRIPT
    cp destroy_script.sh kube_destroy.sh

    sed -i 's/KUBEFLOW_NAME/'$KF_NAME'/' kube_destroy.sh
    sed -i 's/KUBEFLOW_DIR/'$KF_BASE_DIR'/' kube_destroy.sh

    echo "Running script to deploy Kubeflow on GCP"
    #sh kube_deploy.sh
    #rm kube_deploy.sh
    echo "----------------------Copying Pipeline Data to Buckets---------------------------------"
    gcloud iam service-accounts keys create key.json --iam-account="${SERVICE}@${PROJECT}.iam.gserviceaccount.com"
    mv key.json data/
    echo "Copying files to Buckets"
    #gsutil cp -r ${FILE_PATH} ${DATA_BUCK}
    #gsutil cp -r ${KEY_FILE} ${KEY_BUCK}
    echo "Files Copied"
    echo "---------------------Deploying Pipeline on Kubeflow--------------------------------"
    cp pipeline.py pipeline_deploy.py

    sed -i 's/EXP_NAME/'$EXPERIMENT'/' pipeline_deploy.py
    sed -i 's/RUN/'$RUN'/' pipeline_deploy.py
    sed -i 's/PIPE_FILE/'$P_FILE'/' pipeline_deploy.py
    sed -i 's/PROJECT/'$PROJECT'/' pipeline_deploy.py
    sed -i 's/KEY/'$KEY_BUCK'/' pipeline_deploy.py
    sed -i 's/DATA/'$DATA_BUCK'/' pipeline_deploy.py

    echo "Starting Puthon script to deploy Pipeline"
    #python3 pipeline_deploy.py
    #rm pipeline_deploy.py
fi