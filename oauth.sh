#!bin/bash
#CREATE A BRAND
gcloud alpha iap oauth-brands create --application_title=kubeflow --support_email=EMAIL
brand=$(gcloud alpha iap oauth-brands list)

b=$(echo $brand | tr " " "\n")
for addr in $b
do
    echo "$addr"
    if [[ $addr == projects* ]] ;
    then
        brand_name=$addr
        echo "Brand = $brand_name"
    fi
done

#Create Client for the Brand
touch oauths.yaml
gcloud alpha iap oauth-clients create ${brand_name} --display_name=kube_client_oauth >> oauths.yaml
while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == *"name"* ]]; then
        FULL_OAUTH_ID=$(cut -d ':' -f2 <<< "$line" | xargs)
        OAUTH_ID=$(cut -d '/' -f6 <<< "$FULL_OAUTH_ID" | xargs)
        echo "CLIENT_ID : $OAUTH_ID" >> file.yaml
        elif [[ "$line" == *"secret"* ]]; then
        OAUTH_SECRET=$(cut -d ':' -f2 <<< "$line" | xargs)
        echo "CLIENT_SECRET : $OAUTH_SECRET" >> file.yaml
        fi
done < oauths.yaml

rm -rf oauths.yaml
