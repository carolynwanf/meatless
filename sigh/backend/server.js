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

    const offset = req.body.offset;
    const zipCode = req.body.zipCode;
    const sort = req.body.sort;
    const search = req.body.search;

    const number = 15

    console.log(sort, search)

    console.log(zipCode)

    
    try {
        const db = client.db('data');
        if (search) {
            const query = req.body.query 
            if (sort == 'friendliness') {

                console.log('search, friendliness')
                

                const restaurants = await db.collection('restaurants').find({$and: [{zipCode: zipCode}, {$text: {$search: query}}]}).sort({friendliness: -1,_id: -1}).skip((offset-1) *number).limit(number).toArray();

                // console.log(restaurants.length)

                if (restaurants.length > 0) {
                    res.json({restaurants: restaurants})
                } else {
                    res.json({restaurants: ['no results']})
                }
            } else if (sort == "# of meatless dishes") {
                const restaurants = await db.collection('restaurants').find({$and: [{zipCode: zipCode}, {$text: {$search: query}}]}).sort({totalVegItems: -1,_id: -1}).skip((offset-1) *number).limit(number).toArray();

                // console.log(restaurants.length)

                if (restaurants.length > 0) {
                    res.json({restaurants: restaurants})
                } else {
                    res.json({restaurants: ['no results']})
                }
            }

        } else {

            if (sort == 'friendliness') {

                console.log('no search, friendliness')
    
                const restaurants = await db.collection('restaurants').find({zipCode: zipCode}).sort({friendliness: -1, _id: -1}).skip((offset-1) *number).limit(number).toArray();
    
                // console.log(restaurants.length)
    
                if (restaurants.length > 0) {
                    res.json({restaurants: restaurants})
                } else {
                    res.json({restaurants: ['no results']})
                }
            } else if (sort == "# of meatless dishes") {

                console.log("no search, number of veg")

                const restaurants = await db.collection('restaurants').find({zipCode: zipCode}).sort({totalVegItems: -1, _id: -1}).skip((offset-1) *number).limit(number).toArray();
    
                // console.log(restaurants.length)
    
                if (restaurants.length > 0) {
                    res.json({restaurants: restaurants})
                } else {
                    res.json({restaurants: ['no results']})
                }

            }
            

        }
        
        
    } finally {
        console.log('restaurants successfully taken!')
        
    }
    
})

app.post("/get-dishes", async (req,res) => {
    res.header("Access-Control-Allow-Origin", "*");
    const offset = req.body.offset
    const zipCode = req.body.zipCode
    const search = req.body.search
    const query = req.body.query

   


    try {
        const db = client.db('data');
        // db.collection('items').createIndex( { name: "text", description: "text" } )
        
        if (search) {
            const dishes = await db.collection('items').find({$and: [{zipCode: zipCode}, {vegetarian:true}, {side:false}, {dessert: false}, {drink:false},{$text: {$search: query}}]}).sort({_id: -1}).skip((offset-1) *15).limit(15).toArray();

            console.log(dishes.length)
    
            if (dishes.length > 0) {
                res.json({dishes: dishes})
            } else {
                res.json({dishes: ['no results']})
            }
    

        } else {
            const dishes = await db.collection('items').find({$and: [{zipCode: zipCode}, {vegetarian:true}, {side:false}, {dessert: false},{drink:false}]}).sort({_id: -1}).skip((offset-1) *15).limit(15).toArray();

            console.log(dishes.length)
    
            if (dishes.length > 0) {
                res.json({dishes: dishes})
            } else {
                res.json({dishes: ['no results']})
            }
    

        }
        

       
        
    } finally {
        console.log('dishes successfully taken!')
        
    }
    
})

app.post("/review-or-rating", async (req,res) => {
    res.header("Access-Control-Allow-Origin", "*");
    
    const review = req.body.review;
    const id = req.body.id
    console.log(id)

    try {
        const db = client.db('data');

        const item = await db.collection('items').findOne(ObjectId(id))

        if (item.rating != "N/A") {
            item.rating = ((item.reviews.length * item.rating) + review.rating)/ (item.reviews.length +1)
        } else {
            item.rating = review.rating
        }

        item.reviews.push(review)

        console.log(item.rating, item.reviews)

        await db.collection('items').updateOne({'_id': ObjectId(id)}, {
            $set: {rating: item.rating, reviews: item.reviews}
        })

        


        
    } finally {
        res.sendStatus(200)
        console.log("review written");
        
    }



})
app.post("/report", async (req,res) => {
    res.header("Access-Control-Allow-Origin", "*");
    
    const report = req.body.report;
    const id = req.body.id
    console.log(id)



    try {
        const db = client.db('data');

        const item = await db.collection('items').findOne(ObjectId(id))

        if (item.reports == undefined) {
            item.reports = []
        }


        item.reports.push(report)

        console.log(item.reports)

        await db.collection('items').updateOne({'_id': ObjectId(id)}, {
            $set: {reports: item.reports}
        })

        


        
    } finally {
        res.sendStatus(200)
        console.log("review written");
        
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