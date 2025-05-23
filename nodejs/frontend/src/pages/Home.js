import React from 'react'
// uruchamia zapytania do endpointów
import axios from 'axios'
import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Container, Row, Col } from 'react-bootstrap'

function Home() {
    
    let navigate = useNavigate()
    const [categoryList, getCategoryList] = useState([])
    const [productsList, getProductsList] = useState([])
    
    useEffect(() => {
        axios.get('http://localhost:3001/category').then((response) => {
            getCategoryList(response.data)
        })
        axios.get('http://localhost:3001/products').then((response) => {
            getProductsList(response.data)
        })
    }, [])
    
    let cart = JSON.parse(sessionStorage.getItem('cart')) != null ? JSON.parse(sessionStorage.getItem('cart')) : {products: []};
    let cartItemCount = 0
    cart.products.forEach(function(productData, index) {
        cartItemCount += productData.amount
    })
    
    function shuffleArray(array) {
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
        return array
    }
    
    return (
        <main>
            <div className='header-cart-bar'>
                <Container>
                    <Row>
                        <div className='text-right'>
                            <div className='go-to-cart-button' onClick={() => {navigate(`/cart`)}}>
                                <p>Shopping cart ({cartItemCount})</p>
                                <img src='https://icon-library.com/images/white-shopping-cart-icon/white-shopping-cart-icon-9.jpg' alt='shopping cart'></img>
                            </div>
                        </div>
                    </Row>
                </Container>
            </div>
            <Container>
                <Row>
                    <h2 className='text-center'>Categories</h2>
                </Row>
                <Row>
                    {categoryList.map((category, key) => {
                        return (
                            <Col md='4' key={ key } className='product-card' onClick={() => {navigate(`/category/${category.id}`)}}>
                                <div className='product-card-inner'>
                                    <Col md='4' className='product-card-photo'>
                                        <img src={category.imgUrl} alt='Epic category' />
                                    </Col>
                                    <Row>
                                        <div className='product-name'>
                                            <h3 className="text-center">{category.name}</h3>
                                        </div>
                                    </Row>
                                </div>
                            </Col>
                        )
                    })}
                </Row>
                <Row>
                    <h2 className='text-center'>All products</h2>
                </Row>
                <Row>
                    {shuffleArray(productsList).map((product, key) => {
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
