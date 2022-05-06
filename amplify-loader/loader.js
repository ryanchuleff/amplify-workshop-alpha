const { GetObjectCommand, S3Client } = require('@aws-sdk/client-s3')
const yaml = require('js-yaml');
const { v4: uuidv4 } = require('uuid');
const axios = require('axios');
const awsmobile = require('./aws-exports.js');

const SOURCE_BUCKET = 'retail-demo-store-us-east-1';
const SOURCE_BUCKET_URL = 'https://retail-demo-store-us-east-1.s3.amazonaws.com';
const SOURCE_BUCKET_REGION = 'us-east-1';

const DATA_CATEGORY_PATH = 'data/categories.yaml';
const DATA_PRODUCTS_PATH = 'data/products.yaml';

const APPSYNC_API_ENDPOINT_URL = awsmobile.aws_appsync_graphqlEndpoint;
const APPSYNC_API_KEY = awsmobile.aws_appsync_apiKey;

const REVIEWS = [1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5];

const s3Client = new S3Client({ region: SOURCE_BUCKET_REGION });

/**
 * Gets the object from the S3 Bucket
 * 
 * @param {S3Object} object 
 */
const objectFetch = (key) => {
  return new Promise(async (resolve, reject) => {
    const getObjectCommand = new GetObjectCommand({ 
      Bucket: SOURCE_BUCKET, 
      Key: key,
    });

    try {
      const response = await s3Client.send(getObjectCommand)
  
      let responseDataChunks = []
      response.Body.once('error', err => reject(err))
      response.Body.on('data', chunk => responseDataChunks.push(chunk))
      response.Body.once('end', () => resolve(responseDataChunks.join('')))
    } catch (err) {
      // Handle the error or throw
      return reject(err)
    } 
  })
}

const appsyncClient = () => {
  if (!APPSYNC_API_ENDPOINT_URL) throw Error('Invalid API Endpoint')
  return axios.create({
    baseURL: APPSYNC_API_ENDPOINT_URL,
    headers: {'x-api-key': APPSYNC_API_KEY}
  });
};

const categoryMutation = (cat) => {
  return `
    mutation Mutation {
      createCategory(input: {
        id: "${cat.id}", 
        image: "${cat.image}", 
        name: "${cat.name}", 
        styles: ${JSON.stringify(cat.styles || [])}
      }) {
        _deleted
        _lastChangedAt
        _version
        createdAt
        description
        id
        image
        name
        updatedAt
        styles
      }
    }`
};

const productMutation = (prod) => {
  return `
    mutation Mutation {
      createProduct(input: {
        categoryID: "${prod.categoryId}", 
        current_stock: ${prod.current_stock}, 
        description: "${prod.description}", 
        image: "${prod.image}", 
        name: "${prod.name}", 
        price: ${prod.price}, 
        rating: ${REVIEWS[Math.floor(Math.random() * REVIEWS.length)]}, 
        style: "${prod.style}"
      }) {
        _deleted
        _lastChangedAt
        _version
        categoryID
        createdAt
        current_stock
        description
        id
        image
        name
        price
        rating
        style
        updatedAt
      }
    }`
};

const loadData = async () => {
  console.log('---- BEGINNING DATA LOAD ----');
  
  // Load the Product Categories
  const categoryData = yaml.load(await objectFetch(DATA_CATEGORY_PATH));

  const categories = {};
  categoryData.forEach((cat) => {
    delete cat.has_gender_affinity;
    cat.id = uuidv4();
    cat.styles = [];
    categories[cat.name] = cat;
  });
  console.log(`Product Categories Found: ${Object.keys(categories).length}`)
  
  // Load the Products
  const productData = yaml.load(await objectFetch(DATA_PRODUCTS_PATH));
  
  const products = [];
  productData.forEach((prod) => {
    delete prod.gender_affinity;
    delete prod.where_visible;
    prod.image = `${SOURCE_BUCKET_URL}/images/${prod.category}/${prod.image}`;
    prod.categoryId = categories[prod.category].id;
    if (!categories[prod.category].styles.includes(prod.style)) {
      categories[prod.category].styles.push(prod.style);
    }
    products.push(prod);
  });
  console.log(`Products Found: ${products.length}`)

  const appsync = appsyncClient();

  // Load the categories
  let cnt = 0;
  console.log('Beginning Category Import ----');
  for (let key in categories) {
    const { status } = await appsync.post('', { query: categoryMutation(categories[key]) });
    if ( status !== 200 ) {
      process.stdout.write('x');
      cnt += 1;
    }
    else process.stdout.write('.');
  }
  console.log('');
  console.log(`Category Import Completed ---- ${cnt > 0 ? `${cnt} records failed` : 'no errors'}`);
  
  // Load the products
  cnt = 0;
  console.log('Beginning Product Import ----');
  for (let prod of products) {
    const { status } = await appsync.post('', { query: productMutation(prod) });
    if ( status !== 200 ) {
      process.stdout.write('x');
      cnt += 1;
    }
    else process.stdout.write('.');
  }
  console.log('');
  console.log(`Product Import Completed ---- ${cnt > 0 ? `${cnt} records failed` : 'no errors'}`);
  
  console.log('---- DATA LOAD COMPLETE ----')
};

loadData();