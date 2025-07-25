import React from "react";
import '../styles/style.css'
import { Link } from "react-router-dom";



export default function CarCard({ car }) {

    return (

        <>
        
            <div className="car-box">
                <div className="img-box">
                    <img src={car.image_url} alt={`${car.make} ${car.model}`} />
                </div>

                <h3 className="car-name">{`${car.make} ${car.model}`}</h3>
                <p className="car-year">- {car.year} -</p>
            

                <Link className="car-nav-link" to={`/cars/${car.id}`}>
                <button className="learn-more-btn">Learn More</button>
                </Link>

            </div>

        </>

    )
}



