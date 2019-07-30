<?php
require_once __DIR__.'/../interfaces/Entity.php';

class Token implements Entity {
    private $connection;

    public function __construct($connection) {
        $this->connection = $connection;

        $method = $_SERVER['REQUEST_METHOD'];
        $headers = getallheaders();

        switch ($method) {
            case 'POST': // Create a token.
                $this->create($_POST);
                break;
            case 'GET': // Get all device ID's belonging to each token of account.
                // Extract Bearer token from Authorization header.
                $token = str_replace('Bearer ', '', $headers['Authorization']);
                $this->read($token);
                break;
            case 'DELETE': // Delete a token.
                break;
            default:
                throw new Exception('Method not allowed.', 405);
                break;
        }
    }

    public function create($attributes) {
        $email = $attributes['email'];
        $password = $attributes['password'];

        // Get account password from database.
        $statement = $this->connection->prepare("SELECT `id`, `password` FROM `account` WHERE `email` = :email");
        $statement->bindParam(':email', $email);
        $statement->execute();

        // Verify the retrieved password.
        $account = $statement->fetch(PDO::FETCH_ASSOC);

        if (!password_verify($password, $account['password'])) {
            throw new Exception('Incorrect email or password.', 401);
        }

        // Email and password is correct.

        // Generate cryptographically random token.
        $token =  bin2hex(random_bytes(20));

        $ip_address = $attributes['ip_address'];
        $device_id = $attributes['device_id'];
        $device_name = $attributes['device_name'];

        // Add token to database.
        $statement = $this->connection->prepare("INSERT INTO `token` (`token`, `account_id`, `ip_address`, `device_id`, `device_name`) VALUES (:token, :account_id, INET_ATON(:ip_address), UUID_TO_BIN(:device_id), :device_name)");
        $statement->bindParam(':token', $token);
        $statement->bindParam(':account_id', $account['id']);
        $statement->bindParam(':ip_address', $ip_address);
        $statement->bindParam(':device_id', $device_id);
        $statement->bindParam(':device_name', $device_name);
        $statement->execute();

        // Check for any errors.
        if ($statement->errorCode() !== "00000") {
            throw new Exception('Invalid IP address or device ID.', 400);
        }

        // Successfully logged on, return token.
        echo json_encode(['token' => $token]);
    }

    public function read($token) {
        // Get the device ID corresponding to each of the account's tokens.
        // Note: For security reasons, list of tokens will not be returned.

        // Get all device IDs belonging to user with given token.
        $statement = $this->connection->prepare("SELECT INET_NTOA(`ip_address`) as `ip_address`, BIN_TO_UUID(`device_id`) AS `device_id`, `device_name`, `created_on` FROM `token` WHERE `account_id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)");
        $statement->bindParam(':token', $token);
        $statement->execute();

        // If no results are returned, no account ID was found with the given token (i.e. token doesn't exist).
        if ($statement->rowCount() < 1) {
            throw new Exception('Invalid access token.', 401);
        }

        // Return device information.
        $results = $statement->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($results);
    }

    public function update($id, $attributes) {
    }

    public function delete($id) {
    }
}
?>