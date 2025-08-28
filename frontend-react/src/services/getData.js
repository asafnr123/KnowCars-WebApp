import { useEffect, useState } from "react";


export function useCarsWithImages() {
    
    let url = "api/cars_with_images";
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

    return cars_with_images;

    
}