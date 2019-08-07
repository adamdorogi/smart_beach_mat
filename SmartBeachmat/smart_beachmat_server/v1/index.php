<?php
require_once __DIR__.'/config/Database.php';

require_once __DIR__.'/classes/Account.php';
require_once __DIR__.'/classes/Reading.php';
require_once __DIR__.'/classes/Token.php';
require_once __DIR__.'/classes/User.php';

/**
 * The `index` file to which all requests will be redirected to.
 *
 * All requests to this host will be redirected to this file. The file will
 * then perform operations as necessary, depending on the endpoint specified.
 *
 * @author Adam Dorogi-Kaposi
 */
header('Content-Type: application/json');

// Get the endpoint from the requested URI (`accounts`, `users`, `tokens`, or `readings`).
$request_uri = explode('/', $_SERVER['REQUEST_URI']);
$endpoint = $request_uri[2];

// Establish a connection to the database.
try {
    $connection = Database::getInstance()->getConnection();
} catch (Exception $e) {
    return_error($e->getCode(), $e->getMessage());
}

// Perform certain operations on entity objects, depending on the endpoint specified.
switch ($endpoint) {
    case 'accounts':
        try {
            $account = new Account($connection);
        } catch (Exception $e) {
            return_error($e->getCode(), $e->getMessage());
        }
        break;
    case 'users':
        try {
            $user = new User($connection);
        } catch (Exception $e) {
            return_error($e->getCode(), $e->getMessage());
        }
        break;
    case 'tokens':
        try {
            $token = new Token($connection);
        } catch (Exception $e) {
            return_error($e->getCode(), $e->getMessage());
        }
        break;
    case 'readings':
        try {
            $reading = new Reading($connection);
        } catch (Exception $e) {
            return_error($e->getCode(), $e->getMessage());
        }
        break;
    default:
        return_error(404, 'Invalid endpoint.');
        break;
}

/**
 * Terminate the script by returning a JSON encoded error code and error message.
 * 
 * @param string $status_code The error code to return in the JSON.
 * @param string $message The error message to return in the JSON.
 */
function return_error($status_code, $message) {
    http_response_code($status_code);
    exit(json_encode(['error' => ['status' => $status_code, 'message' => $message]]));
}

?>