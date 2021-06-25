const express = require('express');
const app = express();
const { username, password } = require('./loginCreds.js');
const MongoClient = require('mongodb').MongoClient;
const uri = "mongodb+srv://carolyniann:"+`${password}`+"@cluster0.tmpij.mongodb.net/veggie-finder?retryWrites=true&w=majority";
const client = new MongoClient(uri, { useNewUrlParser: true, useUnifiedTopology: true });
var ObjectId = require('mongodb').ObjectId; 
const bodyParser = require('body-parser');
app.use(express.json());


const connect = async () => {
    
    await client.connect()
    console.log('connected')
}

connect()

app.options('*', (req, res) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header('Access-Control-Allow-Methods', 'POST,GET,DELETE,PUT,OPTIONS');
    res.header("Access-Control-Allow-Headers", "Content-type,Accept,X-Custom-Header");
  
    res.sendStatus(200);
  
});

app.post("/get-restaurants", async (req,res) => {
    res.header("Access-Control-Allow-Origin", "*");
    console.log('pinged')


    const offset = req.body.offset

    console.log(offset)

    
    try {
        await client.connect()
        const db = client.db('data');

        const restaurants = await db.collection('restaurants').find({}).sort({friendliness: -1, _id: -1}).skip((offset-1) *8).limit(8).toArray();

        // console.log(restaurants)

        res.json({restaurants: restaurants})
    } finally {
        console.log('restaurants successfully taken!')
        
    }
    
})

app.post("/get-dishes", async (req,res) => {
    res.header("Access-Control-Allow-Origin", "*");
    const offset = req.body.offset

    try {
        const db = client.db('data');

        const dishes = await db.collection('items').find({$and: [{vegetarian:true}, {side:false}]}).sort({_id: -1}).skip((offset-1) *15).limit(15).toArray();

        // console.log(restaurants)

        res.json({dishes: dishes})
    } finally {
        console.log('dishes successfully taken!')
        
    }
    
})

app.post("/get-page-dishes", async (req,res) => {
    res.header("Access-Control-Allow-Origin", "*");
    const id = req.body.id

    try {
        const db = client.db('data');
        var mains = []
        var sides = []
        var desserts = []


        const dishes = await db.collection('items').find({$and: [{restaurant_id: ObjectId(id)}, {vegetarian: true}]}).sort({_id: -1}).toArray();

       

        for (const dish of dishes) {
            if (dish.dessert) {
                desserts.push(dish)
            } else if (dish.side) {
                sides.push(dish)
            } else {
                mains.push(dish)
            }
        }

        console.log(sides)

        // console.log([mains,sides,desserts], dishes)



        res.json({dishes: [mains,sides,desserts]})
    } finally {
        console.log("restaurant's dishes successfully taken!");
        
    }
    
})

app.listen(4000, () => console.log('Running on port 4000'));