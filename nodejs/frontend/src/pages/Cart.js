import { Formik, Form, Field, ErrorMessage } from 'formik'
import * as Yup from 'yup'
import axios from 'axios'
import { useNavigate } from 'react-router-dom'
import { Container, Row, Col } from 'react-bootstrap'
import { useEffect, useState } from 'react'

function Cart() {
    
    const navigate = useNavigate()
    const [products, getProductsList] = useState([])
    
    let totalPrice = 0
    
    let cart = JSON.parse(sessionStorage.getItem('cart')) != null ? JSON.parse(sessionStorage.getItem('cart')) : {products: []};
    let cartItemCount = 0
    cart.products.forEach(function(productData, index) {
        cartItemCount += productData.amount
    })
    
    useEffect (() => {
        const fetchData = async () => {
            const requests = cart.products.map(productData =>
              axios.get(`http://localhost:3001/products/id/${productData.id}`)
                .then(response => {
                    // eslint-disable-next-line react-hooks/exhaustive-deps
                    totalPrice += response.data[0].price * productData.amount
                    return {
                        id: response.data[0].id,
                        name: response.data[0].name,
                        imgUrl: response.data[0].imgUrl,
                        price: response.data[0].price,
                        amount: productData.amount
                    }
                })
            )
      
            const productsList = await Promise.all(requests)
            document.getElementById('total-price').textContent = `$${totalPrice.toFixed(2)}`
            getProductsList(productsList)
        }

        fetchData();
    }, [])
    
    const initialValues = {
        name: "",
        address: "",
        phoneNumber: "",
    }
    
    const validationSchema = Yup.object().shape({
        name: Yup.string().required("This field cannot be empty!"),
        address: Yup.string().required("This field cannot be empty!"),
        phoneNumber: Yup.string().required("This field cannot be empty!"),
    })
    
    const onSubmit = (data) => {
        const productsBought = cart.products.map(productData => {
            const product = products.find(product => product.id === productData.id);
            if (product) {
                return `${product.name} (${productData.amount})`;
            }
            return ''
        }).filter(Boolean).join(', '); // Join all the items with a comma
        
        let orderData = {
            name: data.name,
            address: data.address,
            phoneNumber: data.phoneNumber,
            productsList: productsBought
        }
        
        // wstaw zamówienie
        axios.post('http://localhost:3001/orders/new', orderData).then((response) => {})
        
        alert('Order placed! Thank you for shopping in our store!')
        sessionStorage.removeItem('cart')
        navigate('/')
    }
    
    // obsługa przycisków w menu
    
    function removeFromCart (id) {
        cart.products.forEach((productData, index) => {
            if (productData.id !== id)
                return;
            
            cart.products[index].amount--;
            
            if (cart.products[index].amount <= 0) {
                cart.products.splice(index, 1);
            }
        });
        sessionStorage.setItem('cart', JSON.stringify(cart))
        navigate(0)
    }
    
    // html
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
                <div className='big-button'>
                    <p onClick={() => {navigate('/')}}>← Return to shop</p>
                </div>
                <div className='restauracja-info'>
                    <Row>
                        <h2>Your order</h2>
                    </Row>
                    <hr></hr>
                    {products.map((product, key) => {
                        return (
                            <Row key={ key } className='cart-item'>
                                <Col md='2' className='cart-item-photo'>
                                    <img src={product.imgUrl} alt='Insane bread' />
                                </Col>
                                <Col md='4'>
                                    <div className='product-name'>
                                        <h3 className="">{product.name}</h3>
                                    </div>
                                </Col>
                                <Col md='4'>
                                    <div className='product-price'>
                                        <h3 className="text-center">${product.price} x {product.amount}</h3>
                                    </div>
                                </Col>
                                <Col md='2'>
                                    <button className='remove-from-cart' onClick={() => {removeFromCart(product.id)}}>X</button>
                                </Col>
                            </Row>
                        )
                    })}
                    <hr></hr>
                    <Row className='product-price'>
                        <h2>Total price</h2>
                        <h3 id='total-price'>$0.00</h3>
                    </Row>
                </div>
                <hr></hr>
                <Formik
                    initialValues={ initialValues }
                    onSubmit={ onSubmit }
                    validationSchema={ validationSchema }
                    >
                    <Form>
                        <Row>
                            <h3>Shipment</h3>
                            <label>Name:</label>
                            <ErrorMessage name='name' component='span' />
                            <Field id='inputName' name='name' placeholder=''></Field>
                            <label>Address:</label>
                            <ErrorMessage name='address' component='span' />
                            <Field id='inputAddress' name='address' placeholder=''></Field>
                            <label>Phone number:</label>
                            <ErrorMessage name='phoneNumber' component='span' />
                            <Field id='inputPhoneNumber' name='phoneNumber' placeholder=''></Field>
                        </Row>
                        <hr></hr>
                        <Row>
                            <div className='big-button'>
                                <button type='submit'>Submit your order</button>
                            </div>
                        </Row>
                    </Form>
                </Formik>
            </Container>
        </main>
    )
}

export default Cart