import os
import time
import threading
from mysql.connector import pooling, Error

pool = None # when DB is not initialized yet
pool_lock = threading.RLock()


def init_pool():
    global pool
    if pool is not None:
        return

    retries = 5
    delay = 2

    with pool_lock:
        if pool is not None:
            return

        for attempt in range(retries):
            try:
                poolCheck = pooling.MySQLConnectionPool(
                    pool_name="cars_pool",
                    pool_size=10,
                    host=os.environ["DB_HOST"],
                    user=os.environ["MYSQL_USER"],
                    password=os.environ["MYSQL_PASSWORD"],
                    database=os.environ["CARS_DB"],
                )

                
                conn = poolCheck.get_connection()
                conn.close()

                pool = poolCheck
                print("MySQL connection pool initialized")
                return

            except Error as e:
                print(f"MySQL not ready ({attempt + 1}/{retries}): {e}")
                time.sleep(delay)

        raise RuntimeError("MySQL connection failed after retries")

def get_connection():
    global pool

    if pool is None:
        with pool_lock:
            if pool is None:
                init_pool()
    return pool.get_connection()
