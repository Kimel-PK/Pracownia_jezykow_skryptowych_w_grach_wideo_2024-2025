import React from 'react'
// uruchamia zapytania do endpointów
import axios from 'axios'
import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { Container, Row, Col } from 'react-bootstrap'

function Category() {
    
    let navigate = useNavigate()
    const [category, getCategory] = useState([])
    const [productsList, getProductsList] = useState([])
    
    const { id } = useParams()
    
    useEffect(() => {
        axios.get(`http://localhost:3001/category/id/${id}`).then((response) => {
            getCategory(response.data)
        })
        axios.get(`http://localhost:3001/category/${id}/products`).then((response) => {
            getProductsList(response.data)
        })
    }, [id])
    
    let cart = JSON.parse(sessionStorage.getItem('cart')) != null ? JSON.parse(sessionStorage.getItem('cart')) : {products: []};
    let cartItemCount = 0
    cart.products.forEach(function(productData, index) {
        cartItemCount += productData.amount
    })
    
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
            <div className='big-button'>
                <p onClick={() => {navigate(`/`)}}>← Return to home page</p>
            </div>
            <Container>
                {category.map((categoryData, key) => {
                    return (
                        <div key={ key }>
                            <Row>
                                <h2 className='text-center'>
                                    {categoryData.name}
                                </h2>
                            </Row>
                            <Row>
                                <Col md='12' dangerouslySetInnerHTML={{ __html: categoryData.description }}></Col>
                            </Row>
                        </div>
                    )
                })}
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

export default Category
