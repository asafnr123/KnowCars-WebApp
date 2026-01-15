
export default function CarDetails({ car, url }) {

  const base_img_url = url;
  
  
  return (
    <div className="car-detail-container">
      <div className="car-image">
        <img src={`${base_img_url}${car.image_url}`} alt={`${car.make} ${car.model}`} />
      </div>
      <div className="car-info">
        <h2>{car.make} {car.model}</h2>
        <p><strong>Year:</strong> {car.year}</p>
        <p><strong>Fuel Type:</strong> {car.fuel_type}</p>
        <p><strong>Cylinders:</strong> {car.cylinders}</p>
        <p><strong>Displacement:</strong> {car.displacement}</p>
        <p><strong>Horse Power:</strong> {car.horse_power}</p>
        <p><strong>Gear:</strong> {car.gear}</p>
        <p><strong>Description:</strong> {car.description}</p>
      </div>
    </div>
  );
}


