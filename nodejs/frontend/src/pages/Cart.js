import { Formik, Form, Field, ErrorMessage } from 'formik'
import * as Yup from 'yup'
import axios from 'axios'
import { useParams, useNavigate } from 'react-router-dom'
import { Container, Row, Col } from 'react-bootstrap'

function Cart() {
    
    const navigate = useNavigate()
    
    const products = {}
    let totalPrice = 0
    
    let cart = JSON.parse(sessionStorage.getItem('cart')) != null ? JSON.parse(sessionStorage.getItem('cart')) : {products: []};
    
    cart.products.forEach(function(id, index) {
        axios.get(`http://localhost:3001/products/id/${id}`).then((response) => {
            console.log(response.data)
        })
    });
    
    
    const initialValues = {
        address: "",
        phoneNumber: "",
    }
    
    const validationSchema = Yup.object().shape({
        address: Yup.string().required("This field cannot be empty!"),
        phoneNumber: Yup.string().required("This field cannot be empty!"),
    })
    
    const onSubmit = (data) => {
        
        let orderData = {
            address: data.address,
            phoneNumber: data.phoneNumber,
            cena: totalPrice,
        }
        
        // wstaw zamówienie
        axios.post('http://localhost:3001/order/new', orderData).then((response) => {
        })
        
        alert('Order placed!')
    }
    
    // obsługa przycisków w menu
    
    function removeFromCart (id) {
        // TODO
        document.getElementById('total-price').innerHTML = '$' + totalPrice.toFixed(2);
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
                <div className='restauracja-info'>
                    <Row>
                        <h2>Your order</h2>
                    </Row>
                    <hr></hr>
                    <Row>
                        <h3>Product 1</h3>
                        <h3>Product 2</h3>
                        <h3>Product 3</h3>
                    </Row>
                    <hr></hr>
                    <Row>
                        <h2>Total price</h2>
                        <p id='total-price'>$0.00</p>
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