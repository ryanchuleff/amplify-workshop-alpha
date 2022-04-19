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

#title           data_load.sh
#description     This script will download and install the sample application data for the Amplify Workshop
#author          Ryan Yanchuleff (@yanryan)
#contributors    @yanryan
#date            2020-05-24
#version         0.1
#usage           curl -sSL https://raw.githubusercontent.com/ryanchuleff/amplify-workshop-alpha/main/data_load.sh | bash -s stable
#==============================================================================

# Download the javascript data loader
curl -LO https://raw.githubusercontent.com/ryanchuleff/amplify-workshop-alpha/main/amplify-loader.zip file

# Unzip the package
unzip amplify-loader.zip

# Install required libraries
cd amplify-loader
npm i

# Copy the AWS Exports file for the AppSync variables
cp ../amplify-core-workshop/src/aws-exports.js .

# Switch file over to commonJS format
sed -i 's/export default/module.exports =/' aws-exports.js

# Run the data loader
node loader.js

# Cleanup
cd ..
# rm -rf data-loader
# rm -- "$0"
