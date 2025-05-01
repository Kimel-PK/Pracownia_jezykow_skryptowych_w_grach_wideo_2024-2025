const express = require ('express')
const router = express.Router ()
const { orders } = require ('../models')

router.post('/new', async (req, res) => {
    console.log(req)
    await orders.create(req.body)
})

module.exports = router