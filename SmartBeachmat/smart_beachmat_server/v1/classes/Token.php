<?php
require_once __DIR__.'/../interfaces/Entity.php';

class Token implements Entity {
    private $connection;

    public function __construct($connection) {
        $this->connection = $connection;
        $method = $_SERVER['REQUEST_METHOD'];

        switch ($method) {
            case 'POST': // Create a token.
                $this->create($_POST);
                break;
            case 'GET': // Get a token.
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
        $account = $statement->fetch();

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
        $statement = $this->connection->prepare("INSERT INTO `token` (`token`, `account_id`, `ip_address`, `device_id`, `device_name`) VALUES (:token, :account_id, :ip_address, UUID_TO_BIN(:device_id), :device_name)");
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
        http_response_code(200);
        echo json_encode(['token' => $token]);
    }

    public function read($id) {
    }

    public function update($id, $attributes) {
    }

    public function delete($id) {
    }
}
?>