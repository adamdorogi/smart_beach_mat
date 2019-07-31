<?php
require_once __DIR__.'/../interfaces/Entity.php';

class Account implements Entity {
    private $connection;

    public function __construct($connection) {
        $this->connection = $connection;

        $method = $_SERVER['REQUEST_METHOD'];
        $headers = getallheaders();
        $token = str_replace('Bearer ', '', $headers['Authorization']); // Extract Bearer token from Authorization header.

        switch ($method) {
            case 'POST': // Create an account.
                $this->create($_POST);
                break;
            case 'GET': // Get an account.
                $this->read($token);
                break;
            case 'PUT': // Update an account.
                parse_str(file_get_contents("php://input"), $_PUT);

                $request_uri = explode('/', $_SERVER['REQUEST_URI']);
                $attribute = $request_uri[3];

                $this->update($token, $attribute, $_PUT);
                break;
            case 'DELETE': // Delete an account.
                $this->delete('a', $token); // TODO
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

    // Get the information of the account belonging to the token.
    // Note: For security reasons, password is not returned.
    public function read($token) {
        // Select account belonging to token.
        $statement = $this->connection->prepare("SELECT BIN_TO_UUID(`id`) AS `id`, `email`, `is_verified`, `created_on` FROM `account` WHERE `id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)");
        $statement->bindParam(':token', $token);
        $statement->execute();

        // If no results are returned, no account ID was found with the given token (i.e. token doesn't exist).
        if ($statement->rowCount() < 1) {
            throw new Exception('Invalid access token.', 401);
        }

        // Return account information.
        $result = $statement->fetch(PDO::FETCH_ASSOC);
        $result['is_verified'] = boolval($result['is_verified']); // Convert string ("0" or "1") to boolean (false or true).
        echo json_encode($result);
    }

    public function update($token, $attribute, $attributes) {
        switch ($attribute) {
            case 'email':
                $new_email = $attributes['new'];

                // Validate email.
                if (!filter_var($new_email, FILTER_VALIDATE_EMAIL)) {
                    throw new Exception('Email address is invalid.', 400);
                }

                // Update email.
                $statement = $this->connection->prepare("UPDATE `account` SET `email` = :new_email WHERE `id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)");
                $statement->bindParam(':new_email', $new_email);
                $statement->bindParam(':token', $token);
                $statement->execute();

                // Check if account already exists.
                if ($statement->errorCode() === "23000") {
                    throw new Exception('Email address already exists.', 409);
                }

                if ($statement->rowCount() < 1) {
                    throw new Exception('Invalid access token, or email has not been updated.', 400);
                }

                // Successfully updated account email.
                http_response_code(204);
                break;
            case 'password':
                $new_password = $attributes['new'];
                $old_password = $attributes['old'];

                // Retrieve old password.
                $statement = $this->connection->prepare("SELECT `id`, `password` FROM `account` WHERE `id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)");
                $statement->bindParam(':token', $token);
                $statement->execute();

                // No result (i.e. invalid access token).
                if ($statement->rowCount() < 1) {
                    throw new Exception('Invalid access token.', 401);
                }

                // Verify the old password.
                $account = $statement->fetch(PDO::FETCH_ASSOC);

                if (!password_verify($old_password, $account['password'])) {
                    throw new Exception('Incorrect password.', 401);
                }

                // Validate new password.
                if (strlen($new_password) < 8) {
                    throw new Exception('Password is too short.', 400);
                }

                $password_hash = password_hash($new_password, PASSWORD_DEFAULT);

                // Change password.
                $statement = $this->connection->prepare("UPDATE `account` SET `password` = :password_hash WHERE `id` = :id");
                $statement->bindParam(':password_hash', $password_hash);
                $statement->bindParam(':id', $account['id']);
                $statement->execute();

                // Log out of all other sessions.
                $statement = $this->connection->prepare("DELETE FROM `token` WHERE `account_id` = :id AND `token` <> :token");
                $statement->bindParam(':token', $token);
                $statement->bindParam(':id', $account['id']);
                $statement->execute();

                // Successfully updated account password.
                http_response_code(204);
                break;
            default:
                return_error(404, 'Invalid endpoint.');
                break;
        }
    }

    public function delete($id, $token) {
        // Get all device IDs belonging to user with given token.
        $statement = $this->connection->prepare("DELETE FROM `account` WHERE `id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)");
        $statement->bindParam(':token', $token);
        $statement->execute();

        // If no results are returned, no token was found.
        if ($statement->rowCount() < 1) {
            throw new Exception('Invalid access token.', 401);
        }

        // Successfully deleted token.
        http_response_code(204);
    }
}
?>