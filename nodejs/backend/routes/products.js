const express = require ('express')
const router = express.Router ()
const { products } = require ('../models')

router.get('/', async (req, res) => {
    const productsList = await products.findAll ();
    res.json(productsList)
})

router.get('/id/:id', async (req, res) => {
    const id = req.params.id
    const product = await products.findAll({
        where: {
            id: id
        }
    })
    res.json(product)
})

module.exports = router