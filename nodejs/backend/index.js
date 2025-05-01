const express = require('express')
const app = express()
const cors = require('cors')

app.use(express.json())
app.use(cors());

const db = require ('./models')

const categoryRouter = require ('./routes/categories')
app.use("/category", categoryRouter);
const productsRouter = require ('./routes/products')
app.use("/products", productsRouter);
const ordersRouter = require ('./routes/orders')
app.use("/orders", ordersRouter);

db.sequelize.sync().then(() => {
    app.listen(3001, () => {
        console.log("Server started at port 3001");
    })
})