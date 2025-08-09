import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import CarDetails from "../components/CardDetails";
import { useCarsWithImages } from "../services/getData";
import NotFoundPage from "./NotFoundPage";

function CarDetailsPage() {
  const { car_id } = useParams();
  const cars = useCarsWithImages();
  const [selectedCar, setSelectedCar] = useState(null)
  const [dataLoaded, setDataLoaded] = useState(false)

  
  useEffect(() => {
    if (cars && cars.length > 0) {
        const foundCar = cars.find((c) => String(c.id) === String(car_id));
        setSelectedCar(foundCar);
        setDataLoaded(true)
    }
  }, [cars, car_id]);


  if (!dataLoaded) {
    return (
       <div class="d-flex justify-content-center align-items-center vh-100">
            <div class="spinner-border" role="status" style={{width: '75px', height: '75px'}}>
                <span class="sr-only"></span>
            </div>
        </div>
    )
  }

  if (!selectedCar) return (
    <NotFoundPage />
  )


  return <CarDetails car={selectedCar}/>

}

export default CarDetailsPage;
