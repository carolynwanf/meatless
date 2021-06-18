const express = require('express');
const app = express();
const { username, password } = require('./loginCreds.js');
const MongoClient = require('mongodb').MongoClient;
const uri = "mongodb+srv://carolyniann:"+`${password}`+"@cluster0.tmpij.mongodb.net/veggie-finder?retryWrites=true&w=majority";
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
var ObjectId = require('mongodb').ObjectId; 

const connect = async () => {
    await client.connect()
}

connect()

app.options('*', (req, res) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header('Access-Control-Allow-Methods', 'POST,GET,DELETE,PUT,OPTIONS');
    res.header("Access-Control-Allow-Headers", "Content-type,Accept,X-Custom-Header");
  
    res.sendStatus(200);
  
});

app.get("/get-restaurants", async (req,res) => {
    res.header("Access-Control-Allow-Origin", "*");

    console.log('pinged')

    try {
        await client.connect()
        const db = client.db('data');

        const restaurants = await db.collection('restaurants').find({}).sort({friendliness: -1}).toArray();

        console.log(restaurants)

        res.json({restaurants: restaurants})
    } finally {
        console.log('restaurants successfully taken!')
        
    }
    
})

app.get("/get-dishes", async (req,res) => {
    res.header("Access-Control-Allow-Origin", "*");

    try {
        const db = client.db('data');

        const dishes= await db.collection('items').find({ vegetarian: true}).sort({friendliness: -1}).toArray();

        res.json({dishes: dishes})
    } finally {
        console.log('dishes successfully taken!')
        
    }
    
})

app.listen(4000, () => console.log('Running on port 4000'));