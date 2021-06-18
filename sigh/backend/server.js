const express = require('express');
const app = express();
const { username, password } = require('./loginCreds.js');
const MongoClient = require('mongodb').MongoClient;
const uri = "mongodb+srv://carolyniann:"+`${password}`+"@cluster0.tmpij.mongodb.net/veggie-finder?retryWrites=true&w=majority";
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
var ObjectId = require('mongodb').ObjectId; 

app.options('*', (req, res) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header('Access-Control-Allow-Methods', 'POST,GET,DELETE,PUT,OPTIONS');
    res.header("Access-Control-Allow-Headers", "Content-type,Accept,X-Custom-Header");
  
    res.sendStatus(200);
  
  });

app.get("/get-restaurants", async (req,res) => {
    res.header("Access-Control-Allow-Origin", "*");

    try {
        await client.connect()
        const db = client.db('data');

        const restaurants = await db.collection('restaurants').find({}).sort({friendliness: -1}).toArray();

        res.json({restaurants: restaurants})
    } finally {
        await client.close()
        
    }
    
})

app.get("/get-items", async (req,res) => {
    res.header("Access-Control-Allow-Origin", "*");

    try {
        await client.connect()
        const db = client.db('data');

        const restaurants = await db.collection('items').find({ vegetarian: true}).sort({friendliness: -1}).toArray();

        res.json({restaurants: restaurants})
    } finally {
        await client.close()
        
    }
    
})

app.listen(4000, () => console.log('Running on port 4000'));