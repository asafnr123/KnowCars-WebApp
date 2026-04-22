import { useEffect, useState } from "react";

const base_url = process.env.REACT_APP_API_URL || "http://localhost:5000"
const cars_with_images_url = `${base_url}/api/cars?include=image`
const API_KEY = process.env.REACT_APP_API_KEY || ""


export function useCarsWithImages() {

    const [cars_with_images, set_cars_with_images] = useState([]);


        useEffect(() => {
            const fetchData = async () => {
                try {
                    const res = await fetch(cars_with_images_url, {
                        headers: { "X-API-Key": API_KEY }
                    })
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