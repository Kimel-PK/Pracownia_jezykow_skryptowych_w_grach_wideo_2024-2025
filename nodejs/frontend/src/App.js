import './main.css';
import { BrowserRouter as Router, Route, Routes, Link } from 'react-router-dom'
import Home from './pages/Home'
import Product from './pages/Product'
import Category from './pages/Category'
import Cart from './pages/Cart'
import { Container, Row, Col } from 'react-bootstrap'

function App() {
    return (
        <div className='root'>
            <Router>
                <div className='header'>
                    <Container>
                        <Row>
                            <Col md='4'>
                                <Link to='/'>
                                    <img className='logo' src='https://cdn.pixabay.com/photo/2019/12/14/15/24/bread-4695117_960_720.png' alt='logo' />
                                </Link>
                            </Col>
                            <Col md='4' className='name text-center'>
                                <h1>Bread Shop</h1>
                            </Col>
                            <Col md='4'>
                                <Link to='/'>
                                    <img className='logo' src='https://cdn.pixabay.com/photo/2019/12/14/15/24/bread-4695117_960_720.png' alt='logo' />
                                </Link>
                            </Col>
                        </Row>
                    </Container>
                    <div className='header-background'></div>
                </div>
                <Routes>
                    <Route path='/' exact element={<Home />} />
                    <Route path='/product/:id' element={<Product />} />
                    <Route path='/category/:id' element={<Category />} />
                    <Route path='/cart' exact element={<Cart />} />
                </Routes>
                <div className='footer'>
                    <Container>
                        <Row>
                            <Col md='6'>
                                <h2>Meta</h2>
                                <p className='p-but-a' onClick={ () => {
                                    console.log (window.sessionStorage)
                                }}>Print session data into console</p>
                                <p>
                                    <Link to='/' onClick={ () => {
                                        window.sessionStorage.clear()
                                    }}>Clear session</Link>
                                </p>
                            </Col>
                            <Col md='6'>
                                <h2>Contact</h2>
                                <p>Address:</p>
                                <p>Developer 13/37<br></br>12-345 xampp</p>
                                <p>Tel. +12 345 67 89</p>
                                <p>NIP: 1234567890</p>
                            </Col>
                        </Row>
                    </Container>
                    <Container fluid>
                        <Row>
                            <p className='text-center'>Copyright &copy; 2025 - All rights reserved</p>
                        </Row>
                    </Container>
                    <div className='footer-background'></div>
                </div>
            </Router>
        </div>
    )
}

export default App;
