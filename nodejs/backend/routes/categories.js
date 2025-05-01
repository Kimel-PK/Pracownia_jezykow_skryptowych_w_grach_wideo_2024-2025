const express = require ('express')
const router = express.Router ()
const { products, categories } = require ('../models')

router.get('/', async (req, res) => {
    const categoryList = await categories.findAll ();
    res.json(categoryList)
})

router.get('/id/:id', async (req, res) => {
    const id = req.params.id
    const category = await categories.findAll({
        where: {
            id: id
        }
    })
    res.json(category)
})

router.get('/:id/products', async (req, res) => {
    const id = req.params.id
    const category = await products.findAll({
        where: {
            categoryId: id
        }
    })
    res.json(category)
})

module.exports = router