import React from "react";
import { useCarsWithImages } from "../services/getData"
import CarCard from "../components/CarCard";


export default function CarsPage() {

    const cars = useCarsWithImages();

//     let locaTestinglDB = [
//     {
//         "cylinders": 4,
//         "description": "Reliable compact sedan, great fuel economy.",
//         "displacement": 1800,
//         "fuel_type": "Gas",
//         "gear": "Automatic",
//         "horse_power": 130,
//         "id": "123e4568-e89b-12d3-a456-426614174000",
//         "image_url": "http://localhost:5000/images/toyota-corolla-2021.jpg",
//         "make": "Toyota",
//         "model": "Corolla",
//         "year": 2021
//     },
//     {
//         "cylinders": 4,
//         "description": "Sporty and efficient",
//         "displacement": 2000,
//         "fuel_type": "Gas",
//         "gear": "Manual",
//         "horse_power": 158,
//         "id": "223e4567-e89b-12d3-a456-426614174000",
//         "image_url": "http://localhost:5000/images/honda-civic-2022.jpg",
//         "make": "Honda",
//         "model": "Civic",
//         "year": 2022
//     },
//     {
//         "cylinders": 4,
//         "description": "Compact and affordable hatchback.",
//         "displacement": 1600,
//         "fuel_type": "Diesel",
//         "gear": "Automatic",
//         "horse_power": 120,
//         "id": "323e4567-e89b-12d3-a456-426614174000",
//         "image_url": "http://localhost:5000/images/ford-focus-2020.jpg",
//         "make": "Ford",
//         "model": "Focus",
//         "year": 2020
//     },
//     {
//         "cylinders": 6,
//         "description": "The 2010 Toyota Supra is a high-performance sports coupe powered by a 3.0L inline-6 twin-turbo engine. Known for its strong tuning potential, balanced handling, and iconic styling, it remains a favorite among car enthusiasts. This model blends classic Japanese engineering with a thrilling driving experience",
//         "displacement": 2997,
//         "fuel_type": "Gas",
//         "gear": "Manual",
//         "horse_power": 320,
//         "id": "e14e2276-1055-4a93-a686-df4b4bf19d2b",
//         "image_url": "http://localhost:5000/images/toyota-supra-2010.jpg",
//         "make": "Toyota",
//         "model": "Supra",
//         "year": 2010
//     }
// ];



    return (
        <div className="cars-box">
        {
            cars.map((c, index) => {
                return (
                    <CarCard key={index} className='car-item' car={c} />
                )
            })
        }
        
        </div>
    )

}