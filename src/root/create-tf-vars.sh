#!/bin/bash

# check if Name is valid

Name_Size=${#TF_VAR_NAME}
if [[ $Name_Size -lt 3 || $Name_Size -gt 12 ]]
then
  echo "Please set NAME first and make sure it is between 3 and 12 characters in length with no special characters."
  exit 1
fi

Email_Size=${#TF_VAR_EMAIL}
if [[ $Email_Size -lt 6 ]]
then
  echo "Please export TF_VAR_EMAIL first and make sure it is a valid email."
  exit 1
fi

# set location to centralus if not set
if [ -z $TF_VAR_LOCATION ]
then
  echo "Please export TF_VAR_LOCATION first."
  exit 1
fi

# set repo and exit if not set
if [ -z $TF_VAR_REPO ]
then
  echo "Please export TF_VAR_REPO first"
  exit 1
fi

# create terraform.tfvars and replace template values

# replace name
cat ../example.tfvars | sed "s/<<NAME>>/$TF_VAR_NAME/g" > terraform.tfvars

# replace location
sed -i "s/<<TF_VAR_LOCATION>>/$TF_VAR_LOCATION/g" terraform.tfvars

# replace repo
sed -i "s/<<TF_VAR_REPO>>/$TF_VAR_REPO/g" terraform.tfvars

# replace email
sed -i "s/<<TF_VAR_EMAIL>>/$TF_VAR_EMAIL/g" terraform.tfvars

# replace TF_TENANT_ID
sed -i "s/<<TF_VAR_TENANT_ID>>/$(az account show -o tsv --query tenantId)/g" terraform.tfvars

# replace TF_SUB_ID
sed -i "s/<<TF_VAR_SUB_ID>>/$(az account show -o tsv --query id)/g" terraform.tfvars

# create a service principal
# replace TF_CLIENT_SECRET
sed -i "s/<<TF_VAR_CLIENT_SECRET>>/$(az ad sp create-for-rbac -n http://${NAME}-tf-sp --query password -o tsv)/g" terraform.tfvars

# replace TF_CLIENT_ID
sed -i "s/<<TF_VAR_CLIENT_ID>>/$(az ad sp show --id http://${NAME}-tf-sp --query appId -o tsv)/g" terraform.tfvars

# create a service principal
# replace ACR_SP_SECRET
sed -i "s/<<TF_VAR_ACR_SP_SECRET>>/$(az ad sp create-for-rbac --skip-assignment -n http://${NAME}-acr-sp --query password -o tsv)/g" terraform.tfvars

# replace ACR_SP_ID
sed -i "s/<<TF_VAR_ACR_SP_ID>>/$(az ad sp show --id http://${NAME}-acr-sp --query appId -o tsv)/g" terraform.tfvars

# validate tTF_VAR substitutions
cat terraform.tfvars
