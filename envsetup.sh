#
# Copyright 2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#title           envsetup.sh
#description     This script will setup the Cloud9 IDE with the prerequisite packages and code for the Amplify Core workshop.
#author          Ryan Yanchuleff (@yanryan)
#contributors    @yanryan
#date            2020-05-24
#version         0.1
#usage           curl -sSL https://raw.githubusercontent.com/aws-samples/amplify-core-demo/main/RetailDemoStore/envsetup.sh | bash -s stable
#==============================================================================

# Install jq
sudo yum -y -q install jq

# Update awscli
pip install --user --upgrade awscli

# Install awscli v2
curl -O "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" 
unzip -o awscli-exe-linux-x86_64.zip
sudo ./aws/install
rm awscli-exe-linux-x86_64.zip

# Upgrade npm
npm install npm

# Upgrade CDK version
npm i aws-cdk --force

# Export the Account ID and the Region
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region

# Configure the git settings
git config --global user.name "Workshop User"
git config --global user.email workshop.user@amazon.com
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

# Download lab repository and install packages
git clone https://git-codecommit.$AWS_REGION.amazonaws.com/v1/repos/AmplifyCoreWorkshop
cd AmplifyCoreWorkshop
rm -rf package-lock.json
npm i
