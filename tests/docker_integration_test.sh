#!/bin/bash
set -e

cleanUp() {
    echo "Cleaning up..."
    docker compose down -v
}

# trap cleanUp EXIT

wait_for_flask() {
    local url=$1
    local max_attempts=15
    local attempt=1
   
    echo "Waiting for flask to be ready at url: $url"
   
    while [ $attempt -le $max_attempts ]; do
        if curl -sf "$url" > /dev/null 2>&1; then
            echo "Flask is ready"
            return 0
        fi
        echo "Attempt $attempt/$max_attempts - Flask is not ready yet..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    # if flask failed return 1
    return 1
}

wait_for_mysql() {
    local max_attempts=20
    local attempt=1
    
    echo "Waiting for mysql to be ready"
    
    while [ $attempt -le $max_attempts ]; do
        if docker compose exec -T mysql mysqladmin ping -h mysql -uroot --silent 2>&1; then
            echo "MySQL is ready"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo "Attempt $attempt/$max_attempts - MySQL is not ready yet..."
        sleep 2
        
    done
    
    # if mysql failed return 1
    return 1
}

check_if_db_exists() {
    
    if docker compose exec -T mysql bash -c 'mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "USE knowCarsDB;"' 2>/dev/null; then
        echo "Database exists"
        return 0
    fi
    
    # if database knowCarsDB does not exists return 1
    return 1

}



main() {

    echo "Starting Integration Tests on docker-compose"
    
    if ! wait_for_flask "http://localhost:5000/api/health"; then
        echo "Flask API failed to start"
        exit 1
    fi
    
    
    if ! wait_for_mysql; then
       echo "MySQL failed to start"
       exit 2
    fi
    
    
    if ! check_if_db_exists; then
       echo "Database knowCarsDB does not exists"
       exit 3
    fi
    
    
}


main

