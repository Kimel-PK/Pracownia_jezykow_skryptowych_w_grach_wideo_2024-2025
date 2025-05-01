import React from 'react'
// uruchamia zapytania do endpointów
import axios from 'axios'
import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Container, Row, Col } from 'react-bootstrap'

function Home() {
    
    let navigate = useNavigate()
    const [productsList, getProductsList] = useState([])
    
    useEffect(() => {
        axios.get('http://localhost:3001/products').then((response) => {
            getProductsList(response.data)
        })
    }, [])
    
    let cart = JSON.parse(sessionStorage.getItem('cart')) != null ? JSON.parse(sessionStorage.getItem('cart')) : {products: []};
    
    return (
        <main>
            <div className='header-cart-bar'>
                <Container>
                    <Row>
                        <div className='text-right'>
                            <div className='go-to-cart-button' onClick={() => {navigate(`/cart`)}}>
                                <p>Shopping cart ({cart.products.length})</p>
                                <img src='https://icon-library.com/images/white-shopping-cart-icon/white-shopping-cart-icon-9.jpg' alt='shopping cart'></img>
                            </div>
                        </div>
                    </Row>
                </Container>
            </div>
            <Container>
                <Row>
                    <h2 className='text-center'>Our products</h2>
                </Row>
                <Row>
                    {productsList.map((product, key) => {
                        return (
                            <Col md='4' key={ key } className='product-card' onClick={() => {navigate(`/product/${product.id}`)}}>
                                <div className='product-card-inner'>
                                    <Col md='4' className='product-card-photo'>
                                        <img src={product.imgUrl} alt='Insane bread' />
                                    </Col>
                                    <Row>
                                        <div className='product-name'>
                                            <h3 className="text-center">{product.name}</h3>
                                        </div>
                                    </Row>
                                    <Row>
                                        <div className='product-price'>
                                            <h3 className="text-center">${product.price}</h3>
                                        </div>
                                    </Row>
                                </div>
                            </Col>
                        )
                    })}
                </Row>
            </Container>
        </main>
    )
}

export default Home
