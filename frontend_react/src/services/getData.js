import { useEffect, useState } from "react";

//const url = "http://192.168.49.2:30080/api/cars?include=image" //for cluster

const url = "http://localhost:5000/api/cars?include=image" //for docker environment 


export function useCarsWithImages() {
    
    const [cars_with_images, set_cars_with_images] = useState([]);


        useEffect(() => {
            const fetchData = async () => {
                try {
                    const res = await fetch(url)
                    const data = await res.json()
                    set_cars_with_images(data)
                } catch (e) {
                    console.error("Failed to fetch cars with images:", e)
                }
            };

            fetchData();
        
    },[]);

    
    return [cars_with_images, url];

    
}