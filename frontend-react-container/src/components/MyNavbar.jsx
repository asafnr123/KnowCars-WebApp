import React from 'react';
import Nav from 'react-bootstrap/Nav'
import Navbar from 'react-bootstrap/Navbar'
import { Link } from 'react-router-dom';
import { IoCarSportOutline } from "react-icons/io5";



export default function MyNavbar({ menu }) {

    let homeUrl = "/home"

    return (
    <Navbar bg="dark" variant="dark">
        <Nav className='me-auto'>
            {menu.map((item, index) =>
            <Link className='nav-link' style={{margin: 10}} key={index} to={item.url}>{item.name}</Link>
            )}
        </Nav>

        <Link to={homeUrl} className='nav-link'>
        <Navbar.Brand style={{cursor: 'pointer', fontSize: 25, font: 'Bauhaus 93' }}>Know Cars  <IoCarSportOutline size={40} color='#D70040'/></Navbar.Brand>
        </Link>
    </Navbar>
    );
}
 