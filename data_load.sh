curl -LO https://raw.githubusercontent.com/ryanchuleff/amplify-workshop-alpha/main/data-loader.zip file
unzip data-loader.zip

cd data-loader
npm i

cp ../amplify-core-workshop/src/aws-exports.js .
sed -i 's/export default/module.exports =/' aws-exports.js

node loader.js

cd ..
rm -rf data-loader
rm -- "$0"
