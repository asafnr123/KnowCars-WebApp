#!/bin/bash
set -e

cleanUp() {
    echo "Cleaning up..."
    docker compose down -v
}

# trap cleanUp EXIT

wait_for_flask() {
    local url=$1
    local max_attempts=20
    local attempt=1
   
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
    
    if docker compose exec -T mysql bash -c 'mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "USE knowCarsDB;"' 2>/dev/null; then
        echo "Database exists"
        return 0
    fi
    
    # if database knowCarsDB does not exists return 1
    return 1

}


check_endpoint() {
    local url=$1
    local max_attempts=$2
    local header=${3:-""}
    local attempt=1


    while [ $attempt -le $max_attempts ]; do

        if [ -n "$header" ]; then
            status_code=$(curl -sf -H "$header" -w "%{http_code}" -o /dev/null "$url" 2>&1)
        else
            status_code=$(curl -sf -w "%{http_code}" -o /dev/null "$url" 2>&1)
        fi
        if [ "$status_code" = "200" ]; then
            echo "$url pass, Status code: $status_code"
            return 0
        fi

        echo "Attempt $attempt/$max_attempts - Endpoint is not ready yet"
        attempt=$((attempt + 1))
        sleep 2

    done

    # if response doesnt return status code 200 return 1
    return 1
}



check_cors_preflight() {
    local url=$1
    local origin=${2:-"http://localhost:3000"}

    status_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -X OPTIONS "$url" \
        -H "Origin: $origin" \
        -H "Access-Control-Request-Method: GET")

    if [ "$status_code" = "200" ]; then
        echo "CORS preflight $url pass, Status code: $status_code"
        return 0
    fi

    echo "CORS preflight failed for $url - Status code: $status_code (expected 200)"
    return 1
}


check_cors_origin_header() {
    local url=$1
    local origin=${2:-"http://localhost:3000"}

    acao=$(curl -s -o /dev/null -w "%{header_json}" \
        -H "Origin: $origin" "$url" \
        | grep -o '"access-control-allow-origin":"[^"]*"' \
        | grep -o '"[^"]*"$' \
        | tr -d '"')

    if [ "$acao" = "$origin" ]; then
        echo "CORS origin header correct for $url (origin: $origin)"
        return 0
    fi

    echo "CORS origin header check failed for $url - got '$acao' (expected '$origin')"
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

    cars_with_images="http://localhost:5000/api/cars?include=image"

    if ! check_endpoint "$cars_with_images" 10; then
        echo "Endpoint at $cars_with_images failed"
        exit 4
    fi

    if ! check_cors_preflight "$cars_with_images"; then
        echo "CORS preflight check failed for $cars_with_images"
        exit 5
    fi

    if ! check_cors_origin_header "$cars_with_images"; then
        echo "CORS origin header check failed for $cars_with_images"
        exit 6
    fi

}


main

