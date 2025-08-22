
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
	description TEXT);


CREATE TABLE IF NOT EXISTS carImages (
	id INT AUTO_INCREMENT PRIMARY KEY,
	car_id CHAR(36),
	image_url VARCHAR(500),
	FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE CASCADE);
	
	
-- default value (for development environment)
INSERT INTO knowCarsDB.cars(id, make, model, year, fuel_type, cylinders, displacement, horse_power, gear, description) VALUES 
(
'123e4568-e89b-12d3-a456-426614174000',
'Toyota',
'Corolla',
2021,
'Gas',
4,
1800,
130,
'Automatic',
'The 2021 Toyota Corolla is a compact sedan that combines reliability, fuel efficiency, and modern features. With its refined design, comfortable interior, and advanced safety technologies, its ideal for daily commuting and urban driving. The Corolla offers a smooth ride, responsive handling, and excellent value for budget-conscious drivers'),

(
'e14e2276-1055-4a93-a686-df4b4bf19d2b',
'Toyota',
'Supra',
1998,
'Gas',
6,
2997,
320,
'Manual',
'The 2010 Toyota Supra is a high-performance sports coupe powered by a 3.0L inline-6 twin-turbo engine. Known for its strong tuning potential, balanced handling, and iconic styling, it remains a favorite among car enthusiasts. This model blends classic Japanese engineering with a thrilling driving experience'
),

(
'223e4567-e89b-12d3-a456-426614174000',
'Honda',
'Civic', 
2022,
'Gas',
4,
2000,
158,
'Manual',
'The 2022 Honda Civic is a sleek and refined compact sedan that combines sporty styling with everyday practicality. Featuring a modern interior, advanced safety features, and efficient powertrains, it delivers a comfortable and responsive driving experience. With its reputation for reliability and low running costs, the Civic remains a top choice for drivers seeking quality and value'
),

(
'323e4567-e89b-12d3-a456-426614174000',
'Ford',
'Focus',
2020,
'Diesel',
4,
1600,
120,
'Automatic',
'The 2020 Ford Focus is a compact car that offers a balanced mix of comfort, efficiency, and modern technology. With a refined design and responsive handling, it appeals to both city drivers and commuters. The interior features user-friendly infotainment, quality materials, and advanced safety systems, making it a practical and enjoyable everyday vehicle'
);


-- sleep to insure there wont be a conflict with the carImages foreign key (for development environment)
SELECT SLEEP(0.5);


INSERT INTO knowCarsDB.carImages (car_id, image_url) VALUES

(
'123e4568-e89b-12d3-a456-426614174000', 'http://localhost:5000/api/images/toyota-corolla-2021.jpg'),

('223e4567-e89b-12d3-a456-426614174000', 'http://localhost:5000/api/images/honda-civic-2022.jpg'),

('e14e2276-1055-4a93-a686-df4b4bf19d2b', 'http://localhost:5000/api/images/toyota-supra-2010.jpg'),

('323e4567-e89b-12d3-a456-426614174000', 'http://localhost:5000/api/images/ford-focus-2020.jpg');





