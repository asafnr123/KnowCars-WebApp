from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import uuid
from car import Car
from mysqlConnection import get_connection


carApi = Flask(__name__)
carApi.config['IMAGES_FOLDER'] = './images'
CORS(carApi)

@carApi.route("/", methods=['GET'])
def Home_Page():
    return "<h1>This is a cars API using flask</h1>"




# getting all cars or cars with image_url
@carApi.route("/api/cars", methods=['GET'])
def get_all_cars():

    include = request.args.get("include")

    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        if include == "image":
            cursor.execute("""
                SELECT cars.*, carImages.image_url
                FROM cars
                LEFT JOIN carImages ON cars.id = carImages.car_id
            """)
        else:
            cursor.execute("SELECT * FROM cars")


        all_cars = cursor.fetchall()
        cursor.close()
        connection.close()

        if include == "image":
            if all("image_url" in car for car in all_cars):
                return jsonify(all_cars), 200
            else:
                return jsonify({"error": "Cars doesn't have an image_url"}), 500
                
        return jsonify(all_cars), 200
        
    except Exception as e:
        return jsonify({"error": f"Database error: {e}"}), 500
    
    
    




#get a specific car
@carApi.route("/api/cars/<car_id>", methods=['GET'])
def get_Car(car_id):
    
    #first check if car exists:

    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM cars WHERE ID = %s", (car_id,))
        car = cursor.fetchone()
        cursor.close()
        connection.close()

    except Exception as e:
        return jsonify({"error": f"Database error: {e}"}), 500

    if car:
        return jsonify(car), 200
    else:
        return jsonify({"error": f"Couldn't find car with ID {car_id}"}), 404


    


#create a car
@carApi.route("/api/cars", methods=['POST'])
def create_car():
    requested_car = request.get_json(silent=True)
    required_fields = ['make', 'model', 'year', 'horse_power']
    
    #check if it in json format:
    if requested_car:

        #check if car have all required field:
        if all(field in requested_car for field in required_fields):
            
            try:
                connection = get_connection()
                cursor = connection.cursor(dictionary=True)

                # check if request have more fields, if not assign None
                fuel_type_value = requested_car.get('fuel_type')
                cylinders_value = requested_car.get('cylinders')
                displacement_value = requested_car.get('displacement')
                gear_value = requested_car.get('gear')
                description_value = requested_car.get('description')

                new_car = Car(
                id= str(uuid.uuid4()),
                make= requested_car['make'],
                model= requested_car['model'],
                year= requested_car['year'],
                horse_power= requested_car['horse_power'],
                fuel_type= fuel_type_value,
                cylinders= cylinders_value,
                displacement= displacement_value,
                gear= gear_value,
                description= description_value
                
            )
                
                cursor.execute("INSERT INTO cars (id, make, model, year, horse_power, fuel_type, cylinders, displacement, gear, description) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", 
                               (new_car.id,
                               new_car.make,
                               new_car.model,
                               new_car.year,
                               new_car.horse_power,
                               new_car.fuel_type,
                               new_car.cylinders,
                               new_car.displacement,
                               new_car.gear,
                               new_car.description))
                
                connection.commit()
                
                cursor.close()
                connection.close()
                
                return jsonify({"message": f"Successfully added {new_car.car_to_json()} to the DB"}), 200
            
            except Exception as e:
                return jsonify({"error": f"Database error: {e}"}), 500
                


        else:
            return jsonify({"error": "Car object must have the following parameters: ['make', 'model', 'year', 'horse_power']"}), 400
    
    
    else:
        return jsonify({"error": "Invalid JSON format"}), 400








#update a car
@carApi.route("/api/cars/<car_id>", methods=['PATCH'])
def update_car(car_id):
    updated_car = request.get_json(silent=True)
    required_fields = ['make', 'model', 'year', 'horse_power', 'fuel_type', 'cylinders', 'displacement', 'gear', 'description']


    #first check if request is in JSON format
    if updated_car:


        #check if car exists:
        try:
            connection = get_connection()
            cursor = connection.cursor(dictionary=True)
            cursor.execute("SELECT * FROM cars WHERE ID = %s", (str(car_id),))
            car = cursor.fetchone()
        except Exception as e:
            return jsonify({"error": f"Database error: {e}"}), 500
        
        if car:
            #check if request have all required fields:
            if any(field in updated_car for field in required_fields):


                # check request fields, if not value assigned then assign original value
                make_value = updated_car.get('make') if updated_car.get('make') is not None else car.get('make')
                model_value = updated_car.get('model') if updated_car.get('model') is not None else car.get('model')
                year_value = updated_car.get('year') if updated_car.get('year') is not None else car.get('year')
                horse_power_value = updated_car.get('horse_power') if updated_car.get('horse_power') is not None else car.get('horse_power')
                fuel_type_value = updated_car.get('fuel_type') if updated_car.get('fuel_type') is not None else car.get('fuel_type')
                cylinders_value = updated_car.get('cylinders') if updated_car.get('cylinders') is not None else car.get('cylinders')
                displacement_value = updated_car.get('displacement') if updated_car.get('displacement') is not None else car.get('displacement')
                gear_value = updated_car.get('gear') if updated_car.get('gear') is not None else car.get('gear')
                description_value = updated_car.get('description') if updated_car.get('description') is not None else car.get('description')


                try:
                    cursor.execute("UPDATE cars SET make = %s, model = %s, year = %s, horse_power = %s, fuel_type = %s, cylinders = %s, displacement = %s, gear = %s, description = %s WHERE ID = %s", (
                    make_value, model_value, year_value, horse_power_value,
                    fuel_type_value, cylinders_value, displacement_value, gear_value, description_value, str(car_id)
                ))
                    
                except Exception as e:
                    return jsonify({"error": f"Message {e}"})

                connection.commit()
                cursor.close()
                connection.close()

                return jsonify({"message": f"Successfully update car with ID {car_id}"}), 200

            else:
                return jsonify({"error": "Car object must have one of the following parameters: ['make', 'model', 'year', 'horse_power', 'fuel_type', 'cylinders', 'displacement', 'gear', 'description']"}), 400

        else:
            return jsonify({"error": f"Car with ID {car_id} was not found"}), 404

        
    else:
        return jsonify({"error": "Invalid JSON format"}), 400






#delete a car
@carApi.route("/api/cars/<car_id>", methods=['DELETE'])
def removeCar(car_id):

    #first check if car exists:
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM cars WHERE ID = %s", (car_id,))
        car = cursor.fetchone()
    except Exception as e:
        return jsonify({"error": f"Database error: {e}"}), 500
    

    if car:
        cursor.execute("DELETE FROM cars WHERE ID = %s", (car_id,))

        connection.commit()
        cursor.close()
        connection.close()
        return jsonify({"message": f"Successfully deleted car with ID {car_id}"}), 200
    
    else:
        return jsonify({"error": f"No car with ID {car_id} was found"}), 400





#Get all cars image URL
@carApi.route('/api/car_images', methods=['GET'])
def get_all_images_url():
    
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM carImages")
        images_url = cursor.fetchall()
        cursor.close()
        connection.close()
    
    except Exception as e:
        return jsonify({"error": f"Database error: {e}"}), 500
    
    if images_url:
        return jsonify(images_url), 200
    else:
        return jsonify({"alert": "No images found"}), 200



# get specific car image URL
@carApi.route('/api/car_images/<car_id>', methods=['GET'])
def get_car_image_url(car_id):
    
    try:
        connection = get_connection()
        cursor = connection.cursor(dictionary=True) 
        cursor.execute("SELECT image_url from carImages WHERE car_id = %s", (car_id,))
        image_url = cursor.fetchone()
        cursor.close()
        connection.close()
    except Exception as e:
        return jsonify({"error": f"Database error: {e}"}), 500
    
    if image_url:
        return jsonify(image_url), 200
    else:
        return jsonify({"alert": f"No image found for {car_id}"}), 404



#routing the served images for local use:
@carApi.route('/api/images/<filename>', methods=['GET'])
def serve_image(filename):
    
    image_path = carApi.config["IMAGES_FOLDER"]

    if not image_path:
        return jsonify({"error": "Image folder is not configured"}), 500
    try:
        return send_from_directory(image_path, filename)
    
    except FileNotFoundError:
        return jsonify({"error": f"File not found at {image_path}/{filename}"}), 404
    except PermissionError:
        return jsonify({"error": "Access denied"}), 403
    except OSError as e:
        return jsonify({"error": f"OS error: {e}"}), 500
    except Exception as e:
        return jsonify({"error": f"Unexpected server error {e}"}), 500


#route to check the status of the api
@carApi.route('/api/health/ready', methods=['GET'])
def health_check():
    try:
        connection = get_connection()
        cursor = connection.cursor(buffered=True)
        cursor.execute("SELECT 1")
        cursor.close()
        connection.close()
        return jsonify({"message": "Successfully connected to Database"}), 200

    except Exception as e:
        return jsonify({"error": f"Failed to connect to Database: {e}"}), 500


@carApi.route('/api/health', methods=['GET'])
def ready_check():
    return jsonify({"message": "Ok"}), 200
        





#get some headers:
@carApi.route('/api/headers', methods=['GET'])
def get_headers():
    headers = {
        "Host": request.headers.get("Host"),
        "X-Real-IP": request.headers.get("X-Real-IP"),
        "X-Forwarded-For": request.headers.get("X-Forwarded-For"),
        "X-Forwarded-Proto": request.headers.get("X-Forwarded-Proto"),
        "X-Forwarded-Port": request.headers.get("X-Forwarded-Port")
    }

    return jsonify(headers), 200


if __name__ == "__main__":
    carApi.run(host="0.0.0.0", port=5000)




