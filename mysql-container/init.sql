CREATE DATABASE IF NOT EXISTS knowCarsDB;

GRANT ALL PRIVILEGES ON knowCarsDB.* TO 'regular'@'%';

USE knowCarsDB;

CREATE TABLE IF NOT EXISTS cars (
	id CHAR(36) PRIMARY KEY,
 	make VARCHAR(20),
	model VARCHAR(20),
	year SMALLINT,
	fuel_type VARCHAR(10),
	cylinders TINYINT,
	displacement SMALLINT,
	horse_power SMALLINT,
	gear VARCHAR(20),
	description TEXT
);

CREATE TABLE IF NOT EXISTS carImages (
	id INT AUTO_INCREMENT PRIMARY KEY,
	car_id CHAR(36),
	image_url VARCHAR(500),
	FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE
);

-- initial values if the value is not already in the db
INSERT INTO cars (id, make, model, year, fuel_type, cylinders, displacement, horse_power, gear, description)
SELECT * FROM (SELECT
    '123e4568-e89b-12d3-a456-426614174000' AS id,
    'Toyota' AS make,
    'Corolla' AS model,
    2021 AS year,
    'Gas' AS fuel_type,
    4 AS cylinders,
    1800 AS displacement,
    130 AS horse_power,
    'Automatic' AS gear,
    'The 2021 Toyota Corolla is a compact sedan that combines reliability, fuel efficiency, and modern features. With its refined design, comfortable interior, and advanced safety technologies, its ideal for daily commuting and urban driving. The Corolla offers a smooth ride, responsive handling, and excellent value for budget-conscious drivers' AS description
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM cars WHERE id='123e4568-e89b-12d3-a456-426614174000');

INSERT INTO cars (id, make, model, year, fuel_type, cylinders, displacement, horse_power, gear, description)
SELECT * FROM (SELECT
    'e14e2276-1055-4a93-a686-df4b4bf19d2b' AS id,
    'Toyota' AS make,
    'Supra' AS model,
    1998 AS year,
    'Gas' AS fuel_type,
    6 AS cylinders,
    2997 AS displacement,
    320 AS horse_power,
    'Manual' AS gear,
    'The 2010 Toyota Supra is a high-performance sports coupe powered by a 3.0L inline-6 twin-turbo engine. Known for its strong tuning potential, balanced handling, and iconic styling, it remains a favorite among car enthusiasts. This model blends classic Japanese engineering with a thrilling driving experience' AS description
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM cars WHERE id='e14e2276-1055-4a93-a686-df4b4bf19d2b');

INSERT INTO cars (id, make, model, year, fuel_type, cylinders, displacement, horse_power, gear, description)
SELECT * FROM (SELECT
    '223e4567-e89b-12d3-a456-426614174000' AS id,
    'Honda' AS make,
    'Civic' AS model,
    2022 AS year,
    'Gas' AS fuel_type,
    4 AS cylinders,
    2000 AS displacement,
    158 AS horse_power,
    'Manual' AS gear,
    'The 2022 Honda Civic is a sleek and refined compact sedan that combines sporty styling with everyday practicality. Featuring a modern interior, advanced safety features, and efficient powertrains, it delivers a comfortable and responsive driving experience. With its reputation for reliability and low running costs, the Civic remains a top choice for drivers seeking quality and value' AS description
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM cars WHERE id='223e4567-e89b-12d3-a456-426614174000');

INSERT INTO cars (id, make, model, year, fuel_type, cylinders, displacement, horse_power, gear, description)
SELECT * FROM (SELECT
    '323e4567-e89b-12d3-a456-426614174000' AS id,
    'Ford' AS make,
    'Focus' AS model,
    2020 AS year,
    'Diesel' AS fuel_type,
    4 AS cylinders,
    1600 AS displacement,
    120 AS horse_power,
    'Automatic' AS gear,
    'The 2020 Ford Focus is a compact car that offers a balanced mix of comfort, efficiency, and modern technology. With a refined design and responsive handling, it appeals to both city drivers and commuters. The interior features user-friendly infotainment, quality materials, and advanced safety systems, making it a practical and enjoyable everyday vehicle' AS description
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM cars WHERE id='323e4567-e89b-12d3-a456-426614174000');

-- Small sleep to avoid FK conflicts (development only)
SELECT SLEEP(0.5);

-- Seed default carImages data safely
INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT '123e4568-e89b-12d3-a456-426614174000' AS car_id, 'http://localhost:5000/api/images/toyota-corolla-2021.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='123e4568-e89b-12d3-a456-426614174000' AND image_url='http://localhost:5000/api/images/toyota-corolla-2021.jpg');

INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT '223e4567-e89b-12d3-a456-426614174000' AS car_id, 'http://localhost:5000/api/images/honda-civic-2022.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='223e4567-e89b-12d3-a456-426614174000' AND image_url='http://localhost:5000/api/images/honda-civic-2022.jpg');

INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT 'e14e2276-1055-4a93-a686-df4b4bf19d2b' AS car_id, 'http://localhost:5000/api/images/toyota-supra-2010.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='e14e2276-1055-4a93-a686-df4b4bf19d2b' AND image_url='http://localhost:5000/api/images/toyota-supra-2010.jpg');

INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT '323e4567-e89b-12d3-a456-426614174000' AS car_id, 'http://localhost:5000/api/images/ford-focus-2020.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='323e4567-e89b-12d3-a456-426614174000' AND image_url='http://localhost:5000/api/images/ford-focus-2020.jpg');

