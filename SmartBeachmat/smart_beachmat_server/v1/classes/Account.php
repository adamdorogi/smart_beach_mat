<?php
require_once __DIR__.'/../interfaces/Entity.php';

class Account implements Entity {
    private $connection;

    public function __construct($connection) {
        $this->connection = $connection;
        $method = $_SERVER['REQUEST_METHOD'];

        switch ($method) {
            case 'POST': // Create an account.
                $this->create($_POST);
                break;
            case 'GET': // Get an account.
                break;
            case 'PUT': // Update an account.
                break;
            case 'DELETE': // Delete an account.
                break;
            default:
                throw new Exception('Method not allowed.', 405);
                break;
        }
    }

    public function create($attributes) {
        $email = $attributes['email'];
        $password = $attributes['password'];

        // Validate email.
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new Exception('Email address is invalid.', 400);
        }

        // Validate password.
        if (strlen($password) < 8) {
            throw new Exception('Password is too short.', 400);
        }

        $password_hash = password_hash($password, PASSWORD_DEFAULT);

        // Add account to database.
        $statement = $this->connection->prepare("INSERT INTO `account` (`id`, `email`, `password`) VALUES (UUID_TO_BIN(UUID()), :email, :password_hash)");
        $statement->bindParam(':email', $email);
        $statement->bindParam(':password_hash', $password_hash);
        $statement->execute();

        // Check if account already exists.
        if ($statement->errorCode() === "23000") {
            throw new Exception('Email address already exists.', 409);
        }

        // Successfully created new account.
        http_response_code(201);
    }

    public function read($id) {
    }

    public function update($id, $attributes) {
    }

    public function delete($id) {
    }
}
?>