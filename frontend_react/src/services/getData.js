import { useEffect, useState } from "react";

//const cars_with_images_url = "http://192.168.49.2:30080/api/cars?include=image" //for cluster
//const base_url = "http://192.168.49.2:30080"

const cars_with_images_url = "http://localhost:5000/api/cars?include=image" //for docker environment 
const base_url = "http://localhost:5000"


export function useCarsWithImages() {
    
    const [cars_with_images, set_cars_with_images] = useState([]);


        useEffect(() => {
            const fetchData = async () => {
                try {
                    const res = await fetch(cars_with_images_url)
                    const data = await res.json()
                    set_cars_with_images(data)
                } catch (e) {
                    console.error("Failed to fetch cars with images:", e)
                }
            };

            fetchData();
        
    },[]);

    
    return [cars_with_images, base_url];

    
}