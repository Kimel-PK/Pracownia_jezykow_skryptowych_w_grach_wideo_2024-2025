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
    
    function addToCart (id, name) {
        alert(`${name} added to cart! Neat choice!`)
    }
    
    // html
    return (
        <main>
            <div className='header-cart-bar'>
                <Container>
                    <Row>
                        <div className='text-right'>
                            <div className='go-to-cart-button' onClick={() => {navigate(`/cart`)}}>
                                <p>Shopping cart (0)</p>
                                <img src='https://icon-library.com/images/white-shopping-cart-icon/white-shopping-cart-icon-9.jpg' alt='shopping cart'></img>
                            </div>
                        </div>
                    </Row>
                </Container>
            </div>
            <Container>
                <div className='big-button'>
                    <p onClick={() => {navigate('/')}}>&lt;-- Return to shop</p>
                </div>
                {product.map((productData, key) => {
                    return (
                        <div key={ key } className='product-info'>
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
