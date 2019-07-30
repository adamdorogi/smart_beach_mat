<?php
require_once __DIR__.'/classes/Account.php';
require_once __DIR__.'/classes/Token.php';
require_once __DIR__.'/config/Database.php';

header('Content-Type: application/json');

// Get the endpoint from the requested URI (`accounts`, `users`, `tokens`, or `readings`).
$request_uri = explode('/', $_SERVER['REQUEST_URI']);
$endpoint = $request_uri[2];

// Establish a connection to the database.
$connection = Database::getInstance()->getConnection();

switch ($endpoint) {
    case 'accounts':
        try {
            $account = new Account($connection);
        } catch (Exception $e) {
            return_error($e->getCode(), $e->getMessage());
        }
        break;
    case 'users':
        echo "Users Endpoint\n";
        break;
    case 'tokens':
        try {
            $token = new Token($connection);
        } catch (Exception $e) {
            return_error($e->getCode(), $e->getMessage());
        }
        break;
    case 'readings':
        echo "Readings Endpoint\n";
        break;
    default:
        return_error(404, 'Invalid endpoint.');
        break;
}

function return_error($code, $description) {
    http_response_code($code);
    exit(json_encode(['error' => ['code' => $code, 'description' => $description]]));
}

?>