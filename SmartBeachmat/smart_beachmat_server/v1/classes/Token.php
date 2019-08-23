<?php
/**
 * A class used to represent a `token` entity in the database
 *
 * The `Token` class represents a `token` entity in the database,
 * and provides create, read, and delete operations for the entity.
 *
 * @author Adam Dorogi-Kaposi
 */
class Token {
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
        $token = str_replace('Bearer ', '', $headers['authorization']); // Extract Bearer token from Authorization header.

        switch ($_SERVER['REQUEST_METHOD']) {
            case 'POST': // Create a `token`.
                $this->create($_POST);
                break;
            case 'GET': // Get `device_id`s of `token`.
                $this->read($token);
                break;
            case 'DELETE': // Delete a `token`.
                parse_str(file_get_contents('php://input'), $_DELETE);

                $this->delete($token, $_DELETE['device_id']);
                break;
            default:
                throw new Exception('Method not allowed.', 405);
                break;
        }
    }

    /**
     * Create a new `token` in the database with the `account` of given `email`, and `password`.
     * 
     * @param string[] $attributes The attributes of the `account`. Possible values: `email`, `password`.
     * @throws Exception if the email or password of the `account` is incorrect, or attributes
     *                   (`ip_address`, `device_id`) are in an invalid format.
     */
    private function create($attributes) {
        // Extract attributes.
        $email = $attributes['email'];
        $password = $attributes['password'];
        $ip_address = '12.34.56.78'; // $_SERVER['REMOTE_ADDR']; // TODO: REMOVE COMMENT WHEN IN PRODUCTION ENVIRONMENT (can't parse local IP (192.168.1.110)).
        $device_id = $attributes['device_id'];
        $device_name = $attributes['device_name'];

        // Select the `account` `id` and `password` of the given `email` from database.
        $statement = $this->connection->prepare('SELECT `id`, `password` FROM `account` WHERE `email` = :email');
        $statement->bindParam(':email', $email);
        $statement->execute();

        $account = $statement->fetch(PDO::FETCH_ASSOC);
        $retrieved_password_hash = $account['password'];
        $account_id = $account['id'];

        // Verify the retrieved password.
        if (!password_verify($password, $retrieved_password_hash)) {
            throw new Exception('Incorrect email or password.', 401);
        }

        // Generate cryptographically random token.
        $token =  bin2hex(random_bytes(20));

        // Add token to database.
        $statement = $this->connection->prepare('INSERT INTO `token` (`token`, `account_id`, `ip_address`, `device_id`, `device_name`) VALUES (:token, :account_id, INET_ATON(:ip_address), :device_id, :device_name)');
        $statement->bindParam(':token', $token);
        $statement->bindParam(':account_id', $account_id);
        $statement->bindParam(':ip_address', $ip_address);
        $statement->bindParam(':device_id', $device_id);
        $statement->bindParam(':device_name', $device_name);
        $statement->execute();

        if ($statement->rowCount() < 1) {
            // `ip_address` or `device_id` is in an invalid format.
            throw new Exception('Could not create token.', 400);
        }

        // Successfully logged on, return `token`.
        echo json_encode(['token' => $token]);
    }
    
    /**
     * Get all `device_id`s belonging to the `account` of the given `token`.
     * For security reasons, list of tokens belonging to the `account` will not be returned.
     * 
     * @param string $token The token belonging to the `account` for which the attributes will be returned.
     * @throws Exception if the `token` is invalid.
     */
    private function read($token) {
        // Get all device IDs belonging to user with given token.
        $statement = $this->connection->prepare('SELECT INET_NTOA(`ip_address`) as `ip_address`, `device_id`, `device_name`, `created_on` FROM `token` WHERE `account_id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)');
        $statement->bindParam(':token', $token);
        $statement->execute();

        if ($statement->rowCount() < 1) {
            throw new Exception('Invalid access token.', 401);
        }

        // Return device information.
        $results = $statement->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($results);
    }

    /**
     * Delete the `token` with the given `device_id`.
     * 
     * @param string $token The token belonging to the `account`.
     * @param string $device_id The device ID of the token to be deleted.
     * @throws Exception if the `token` is invalid, or the `device_id` does not belong to `account` of the `token`.
     */
    private function delete($token, $device_id) {
        // Delete the `token` with the given `device_id`.
        $statement = $this->connection->prepare('DELETE FROM `token` WHERE `device_id` = :device_id AND `account_id` IN (SELECT `account_id` FROM (SELECT `account_id` FROM `token` WHERE `token` = :token) AS temp)');
        $statement->bindParam(':device_id', $device_id);
        $statement->bindParam(':token', $token);
        $statement->execute();

        if ($statement->rowCount() < 1) {
            // Invalid `token`, or `device_id` does not belong to `account` of given `token`.
            throw new Exception('Could not delete token.', 400);
        }

        // Successfully deleted token.
        http_response_code(204);
    }
}
?>