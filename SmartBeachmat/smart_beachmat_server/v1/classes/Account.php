<?php
/**
 * A class used to represent an `account` entity in the database
 *
 * The `Account` class represents an `account` entity in the database,
 * and provides create, read, update, and delete operations for the entity.
 *
 * @author Adam Dorogi-Kaposi
 */
class Account {
    private $connection;

    /**
     * Constructor.
     * 
     * @param object $connection The `PDO` connection to the MySQL database.
     * @throws Exception if an invalid HTTP method is used.
     */
    public function __construct($connection) {
        $this->connection = $connection;

        $headers = getallheaders();
        $token = str_replace('Bearer ', '', $headers['Authorization']); // Extract Bearer token from Authorization header.

        switch ($_SERVER['REQUEST_METHOD']) {
            case 'POST': // Create an `account`.
                $this->create($_POST);
                break;
            case 'GET': // Get `account` information.
                $this->read($token);
                break;
            case 'PUT': // Update `account` email or password.
                $request_uri = explode('/', $_SERVER['REQUEST_URI']);
                parse_str(file_get_contents('php://input'), $_PUT);

                switch ($request_uri[3]) {
                    case 'email':
                        $this->update_email($token, $_PUT);
                        break;
                    case 'password':
                        $this->update_password($token, $_PUT);
                        break;
                    default:
                        break;
                }
                break;
            case 'DELETE': // Delete `account`.
                $this->delete($token);
                break;
            default:
                throw new Exception('Method not allowed.', 405);
                break;
        }
    }

    /**
     * Create a new `account` in the database with the given `email`, hashed `password`, and a randomly generated UUID as `id`.
     * 
     * @param string[] $attributes The attributes of the `account`. Possible values: `email`, `password`.
     * @throws Exception if an account with the email address already exists.
     */
    private function create($attributes) {
        // Extract attributes.
        $email = $attributes['email'];
        $password = $attributes['password'];

        // Validate email address.
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new Exception('Email address is invalid.', 400);
        }
        
        // Validate password length.
        if (strlen($password) < 8) {
            throw new Exception('Password is too short.', 400);
        }

        // Create a new `account` in the database with the given attributes.
        $statement = $this->connection->prepare('INSERT INTO `account` (`id`, `email`, `password`) VALUES (UUID_TO_BIN(UUID()), :email, :password_hash)');
        $statement->bindParam(':email', $email);
        $statement->bindParam(':password_hash', password_hash($password, PASSWORD_DEFAULT));
        $statement->execute();

        if ($statement->errorCode() === '23000') {
            throw new Exception('Account with email address already exists.', 409);
        }

        // Successfully created new account.
        http_response_code(201);
    }

    /**
     * Get the `id`, `email`, `is_verified`, and `created_on` attributes of the `account` with the given `token`.
     * For security reasons, the password belonging to the `account` is not returned in the response.
     * 
     * @param string $token The token belonging to the `account` for which the attributes will be returned.
     * @throws Exception if the `token` is invalid.
     */
    private function read($token) {
        // Select `account` with the given `token`.
        $statement = $this->connection->prepare('SELECT BIN_TO_UUID(`id`) AS `id`, `email`, `is_verified`, `created_on` FROM `account` WHERE `id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)');
        $statement->bindParam(':token', $token);
        $statement->execute();

        if ($statement->rowCount() < 1) {
            throw new Exception('Invalid access token.', 401);
        }

        // Return `account` information.
        $result = $statement->fetch(PDO::FETCH_ASSOC);
        $result['is_verified'] = boolval($result['is_verified']); // Convert string ('1' or '0') to boolean (`true` or `false`).
        echo json_encode($result);
    }

    /**
     * Update the `email` of the `account` with the given `token`.
     * 
     * @param string $token The token belonging to the `account` for which the `email` will be updated.
     * @param string[] $attributes The attributes of the `account` to be updated. Possible values: `new_email`, `password`.
     * @throws Exception if the `token` is invalid, an account with the email address already exists,
     *                   the password is invalid, or the email address could not be updated.
     */
    private function update_email($token, $attributes) {
        // Extract attribute.
        $new_email = $attributes['new_email'];
        $password = $attributes['password'];
        
        // Validate new email address.
        if (!filter_var($new_email, FILTER_VALIDATE_EMAIL)) {
            throw new Exception('Email address is invalid.', 400);
        }

        // Get the `id` and `password` of the `account` with the given `token`.
        $statement = $this->connection->prepare('SELECT `id`, `password` FROM `account` WHERE `id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)');
        $statement->bindParam(':token', $token);
        $statement->execute();

        if ($statement->rowCount() < 1) {
            throw new Exception('Invalid access token.', 401);
        }

        $account = $statement->fetch(PDO::FETCH_ASSOC);
        $retrieved_password_hash = $account['password'];
        $account_id = $account['id'];

        // Verify the old password.
        if (!password_verify($password, $retrieved_password_hash)) {
            throw new Exception('Incorrect password.', 401);
        }

        // Update the `email` of the `account` with the given `id`.
        $statement = $this->connection->prepare('UPDATE `account` SET `email` = :new_email WHERE `id` = :account_id');
        $statement->bindParam(':new_email', $new_email);
        $statement->bindParam(':account_id', $account_id);
        $statement->execute();

        if ($statement->errorCode() === '23000') {
            throw new Exception('Account with email address already exists.', 409);
        }

        if ($statement->rowCount() < 1) {
            // Access token is invalid, account with email already exists, or the new and old email addresses are the same.
            throw new Exception('Email address could not be updated.', 400);
        }

        // Successfully updated `account` `email`.
        http_response_code(204);
    }

    /**
     * Update the `password` of the `account` with the given `token`.
     * 
     * @param string $token The token belonging to the `account` for which the `password` will be updated.
     * @param string[] $attributes The attributes of the `account` to be updated. Possible values: `new_password`, `password`.
     * @throws Exception if the `token` is invalid, or the `old` password is invalid.
     */
    private function update_password($token, $attributes) {
        // Extract attributes.
        $new_password = $attributes['new_password'];
        $password = $attributes['password'];

        // Get the `id` and `password` of the `account` with the given `token`.
        $statement = $this->connection->prepare('SELECT `id`, `password` FROM `account` WHERE `id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)');
        $statement->bindParam(':token', $token);
        $statement->execute();

        if ($statement->rowCount() < 1) {
            throw new Exception('Invalid access token.', 401);
        }

        $account = $statement->fetch(PDO::FETCH_ASSOC);
        $retrieved_password_hash = $account['password'];
        $account_id = $account['id'];

        // Verify the old password.
        if (!password_verify($password, $retrieved_password_hash)) {
            throw new Exception('Incorrect password.', 401);
        }

        // Validate password length.
        if (strlen($new_password) < 8) {
            throw new Exception('Password is too short.', 400);
        }

        // Update the `account` password.
        $statement = $this->connection->prepare('UPDATE `account` SET `password` = :password_hash WHERE `id` = :id');
        $statement->bindParam(':password_hash', password_hash($new_password, PASSWORD_DEFAULT));
        $statement->bindParam(':id', $account_id);
        $statement->execute();

        // Log out of all other sessions.
        $statement = $this->connection->prepare('DELETE FROM `token` WHERE `account_id` = :id AND `token` <> :token');
        $statement->bindParam(':token', $token);
        $statement->bindParam(':id', $account_id);
        $statement->execute();

        // Successfully updated `account` `password`.
        http_response_code(204);
    }

    /**
     * Delete the `account` with the given `token`.
     * 
     * @param string $token The token belonging to the `account` which will be deleted.
     * @throws Exception if the `token` is invalid.
     */
    private function delete($token) {
        $statement = $this->connection->prepare('DELETE FROM `account` WHERE `id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)');
        $statement->bindParam(':token', $token);
        $statement->execute();

        if ($statement->rowCount() < 1) {
            throw new Exception('Invalid access token.', 401);
        }

        // Successfully deleted `account`.
        http_response_code(204);
    }
}
?>