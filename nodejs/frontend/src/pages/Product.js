import React, { useEffect, useState } from 'react'
import axios from 'axios'
import { useParams, useNavigate } from 'react-router-dom'
import { Container, Row, Col } from 'react-bootstrap'

function Product() {
    
    const navigate = useNavigate()
    const [product, getProduct] = useState([])
    
    const { id } = useParams()
    
    useEffect (() => {
        axios.get(`http://localhost:3001/products/id/${id}`).then((response) => {
            getProduct(response.data)
        })
    }, [id])
    
    let cart = JSON.parse(sessionStorage.getItem('cart')) != null ? JSON.parse(sessionStorage.getItem('cart')) : {products: []};
    let cartItemCount = 0
    cart.products.forEach(function(productData, index) {
        cartItemCount += productData.amount
    })
    
    function addToCart (id, name) {
        const product = cart.products.find(product => product.id === id)
  
        if (product) {
            product.amount += 1
        } else {
            cart.products.push({
                id: id,
                amount: 1
            })
        }
        
        sessionStorage.setItem('cart', JSON.stringify(cart))
        cartItemCount = 0
        cart.products.forEach(function(productData, index) {
            cartItemCount += productData.amount
        })
        document.getElementById('shopping-cart-item-number').textContent = `Shopping cart (${cartItemCount})`
        alert(`${name} added to cart! Neat choice!`)
    }
    
    return (
        <main>
            <div className='header-cart-bar'>
                <Container>
                    <Row>
                        <div className='text-right'>
                            <div className='go-to-cart-button' onClick={() => {navigate(`/cart`)}}>
                                <p id='shopping-cart-item-number'>Shopping cart ({cartItemCount})</p>
                                <img src='https://icon-library.com/images/white-shopping-cart-icon/white-shopping-cart-icon-9.jpg' alt='shopping cart'></img>
                            </div>
                        </div>
                    </Row>
                </Container>
            </div>
            <Container>
                {product.map((productData, key) => {
                    return (
                        <div key={ key } className='product-info'>
                            <div className='big-button'>
                                <p onClick={() => {navigate(`/category/${productData.categoryId}`)}}>← Return to category</p>
                            </div>
                            <Row>
                                <h2 className='text-center'>{productData.name}</h2>
                            </Row>
                            <hr></hr>
                            <Row>
                                <Col md='6'>
                                    <img src={productData.imgUrl} alt='Insane bread' />
                                </Col>
                                <Col md='6'>
                                    <div className='product-price'>
                                        <h3 className="text-center">${productData.price}</h3>
                                    </div>
                                    <div className='big-button'>
                                        <button type='submit' onClick={() => {addToCart(productData.id, productData.name)}}>Add to cart</button>
                                    </div>
                                </Col>
                            </Row>
                            <hr></hr>
                            <Row>
                                <Col md='12' dangerouslySetInnerHTML={{ __html: productData.description }}></Col>
                            </Row>
                        </div>
                    )
                })}
            </Container>
        </main>
    )
}

export default Product
