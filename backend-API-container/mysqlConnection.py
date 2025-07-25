from mysql.connector import pooling
import os


pool = pooling.MySQLConnectionPool(
    pool_name= "main_pool",
    pool_size= 7,
    host= os.environ['DB_HOST'],
    port= os.environ['DB_PORT'],
    user= os.environ['MYSQL_USER'],
    password= os.environ['MYSQL_PASSWORD'],
    database= os.environ['CARS_DB']
)

def get_connection():
    return pool.get_connection()
