import json


class Car:

    def __init__(self, id, make, model, year, horse_power, fuel_type=None, cylinders=None, displacement=None,
                 gear=None, description=None):
        
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.horse_power = horse_power
        self.fuel_type = fuel_type
        self.cylinders = cylinders
        self.displacement = displacement
        self.gear = gear
        self.description = description

    
    def car_to_json(self):
        json_format =  {
            "id": self.id,
            "make": self.make,
            "model": self.model,
            "year": self.year,
            "horse_power": self.horse_power,
            "fuel_type": self.fuel_type,
            "cylinders": self.cylinders,
            "displacement": self.displacement,
            "gear": self.gear,
            "description": self.description
        }

        return json.dumps(json_format)