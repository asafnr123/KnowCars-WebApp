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

-- Toyota Corolla (2021)
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

-- Toyota Supra (1998)
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

-- Honda Civic (2022)
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


-- Ford Focus (2020)
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


-- Nissan Skyline R34 (2002)
INSERT INTO cars (id, make, model, year, fuel_type, cylinders, displacement, horse_power, gear, description)
SELECT * FROM (SELECT
    '3e9ed297-0721-4866-9961-8fadf3898b84' AS id,
    'Nissan' AS make,
    'Skyline GTR' AS model,
    2002 AS year,
    'Gas' AS fuel_type,
    6 AS cylinders,
    2600 AS displacement,
    276 AS horse_power,
    'Manual' AS gear,
    'The 2002 Nissan Skyline GTR R34 is a legendary Japanese performance car, powered by the iconic RB26 engine. Known for its precise handling, aggressive styling, and motorsport heritage, the R34 is a benchmark in the JDM world and a symbol of pure driving engagement.' AS description
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM cars WHERE id='3e9ed297-0721-4866-9961-8fadf3898b84');

-- Dodge Challenger (1970)
INSERT INTO cars (id, make, model, year, fuel_type, cylinders, displacement, horse_power, gear, description)
SELECT * FROM (SELECT
    '00c6fb3a-5275-41fa-9e7b-fb71b9b04441' AS id,
    'Dodge' AS make,
    'Challenger' AS model,
    1970 AS year,
    'Gas' AS fuel_type,
    8 AS cylinders,
    7000 AS displacement,
    425 AS horse_power,
    'Manual' AS gear,
    'The 1970 Dodge Challenger is a classic American muscle car, famous for its bold design and big V8 power. Built for straight-line performance, it represents the golden era of muscle cars with raw torque, aggressive styling, and unmistakable road presence.' AS description
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM cars WHERE id='00c6fb3a-5275-41fa-9e7b-fb71b9b04441');

-- Ford Mustang (2020)
INSERT INTO cars (id, make, model, year, fuel_type, cylinders, displacement, horse_power, gear, description)
SELECT * FROM (SELECT
    '84de8278-3ea9-4de5-bb00-94118a74e44f' AS id,
    'Ford' AS make,
    'Mustang' AS model,
    2020 AS year,
    'Gas' AS fuel_type,
    8 AS cylinders,
    5000 AS displacement,
    460 AS horse_power,
    'Manual' AS gear,
    'The 2020 Ford Mustang delivers modern muscle performance with classic styling. Featuring advanced technology, a powerful V8 engine, and sharp handling, it blends everyday usability with track-ready capability.' AS description
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM cars WHERE id='84de8278-3ea9-4de5-bb00-94118a74e44f');

-- BMW E30 (1982)
INSERT INTO cars (id, make, model, year, fuel_type, cylinders, displacement, horse_power, gear, description)
SELECT * FROM (SELECT
    'd68107eb-03bc-4817-a89a-dc6841828034' AS id,
    'BMW' AS make,
    'E30' AS model,
    1982 AS year,
    'Gas' AS fuel_type,
    4 AS cylinders,
    1800 AS displacement,
    113 AS horse_power,
    'Manual' AS gear,
    'The 1982 BMW E30 is a lightweight, driver-focused sports sedan that helped define BMW’s reputation for balanced handling and precise steering. Simple, mechanical, and engaging, it remains a favorite among enthusiasts and collectors.' AS description
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM cars WHERE id='d68107eb-03bc-4817-a89a-dc6841828034');

-- Chevrolet Corvette (2019)
INSERT INTO cars (id, make, model, year, fuel_type, cylinders, displacement, horse_power, gear, description)
SELECT * FROM (SELECT
    '6c9aeb6f-d0aa-4f61-96a2-7e5384327243' AS id,
    'Chevrolet' AS make,
    'Corvette' AS model,
    2019 AS year,
    'Gas' AS fuel_type,
    8 AS cylinders,
    6200 AS displacement,
    455 AS horse_power,
    'Automatic' AS gear,
    'The 2019 Chevrolet Corvette is a high-performance American sports car offering supercar-level acceleration at a relatively accessible price. With a powerful V8, sharp chassis, and refined interior, it excels both on the street and the track.' AS description
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM cars WHERE id='6c9aeb6f-d0aa-4f61-96a2-7e5384327243');


-- Seed default carImages data safely
INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT '123e4568-e89b-12d3-a456-426614174000' AS car_id, '/api/images/toyota-corolla-2021.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='123e4568-e89b-12d3-a456-426614174000' AND image_url='/api/images/toyota-corolla-2021.jpg');


INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT '223e4567-e89b-12d3-a456-426614174000' AS car_id, '/api/images/honda-civic-2022.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='223e4567-e89b-12d3-a456-426614174000' AND image_url='/api/images/honda-civic-2022.jpg');


INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT 'e14e2276-1055-4a93-a686-df4b4bf19d2b' AS car_id, '/api/images/toyota-supra-1998.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='e14e2276-1055-4a93-a686-df4b4bf19d2b' AND image_url='/api/images/toyota-supra-1998.jpg');


INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT '323e4567-e89b-12d3-a456-426614174000' AS car_id, '/api/images/ford-focus-2020.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='323e4567-e89b-12d3-a456-426614174000' AND image_url='/api/images/ford-focus-2020.jpg');


INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT '3e9ed297-0721-4866-9961-8fadf3898b84' AS car_id, '/api/images/nissan-skyline-gtr-2002.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='3e9ed297-0721-4866-9961-8fadf3898b84' AND image_url='/api/images/nissan-skyline-gtr-2002.jpg');


INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT '00c6fb3a-5275-41fa-9e7b-fb71b9b04441' AS car_id, '/api/images/dodge-challenger-1970.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='00c6fb3a-5275-41fa-9e7b-fb71b9b04441' AND image_url='/api/images/dodge-challenger-1970.jpg');


INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT '84de8278-3ea9-4de5-bb00-94118a74e44f' AS car_id, '/api/images/ford-mustang-2020.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='84de8278-3ea9-4de5-bb00-94118a74e44f' AND image_url='/api/images/ford-mustang-2020.jpg');

INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT 'd68107eb-03bc-4817-a89a-dc6841828034' AS car_id, '/api/images/bmw-e30-1982.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='d68107eb-03bc-4817-a89a-dc6841828034' AND image_url='/api/images/bmw-e30-1982.jpg');


INSERT INTO carImages (car_id, image_url)
SELECT * FROM (SELECT '6c9aeb6f-d0aa-4f61-96a2-7e5384327243' AS car_id, '/api/images/chevrolet-corvette-2019.jpg' AS image_url) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM carImages WHERE car_id='6c9aeb6f-d0aa-4f61-96a2-7e5384327243' AND image_url='/api/images/chevrolet-corvette-2019.jpg');
