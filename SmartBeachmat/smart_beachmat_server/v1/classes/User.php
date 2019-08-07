<?php
/**
 * A class used to represent a `user` entity in the database
 *
 * The `User` class represents a `user` entity in the database,
 * and provides create, read, update, and delete operations for the entity.
 *
 * @author Adam Dorogi-Kaposi
 */
class User {
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
            case 'POST': // Create a `user`.
                $this->create($token, $_POST);
                break;
            case 'GET':
                $this->read($token);
                break;
            case 'PUT':
                $request_uri = explode('/', $_SERVER['REQUEST_URI']);
                parse_str(file_get_contents('php://input'), $_PUT);

                $this->update($token, $request_uri[3], $_PUT);
                break;
            case 'DELETE':
                $request_uri = explode('/', $_SERVER['REQUEST_URI']);

                $this->delete($token, $request_uri[3]);
                break;
            default:
                throw new Exception('Method not allowed.', 405);
                break;
        }
    }

    /**
     * Create a new `user` in the database with the given `name`, `skin_type`, `dob`, `gender`,
     * and a randomly generated UUID as `id`.
     * 
     * The first `user` added to the `account` will be the owner of the account (`is_owner` = 1).
     * 
     * @param string $token The token belonging to the `account` for which the `user` will be created.
     * @param string[] $attributes The attributes of the `user`. Possible values: `name`, `skin_type`, `dob`, `gender`.
     * @throws Exception if the `token` is invalid, or `skin_type`, `dob`, or `gender` are in an incorrect format.
     */
    private function create($token, $attributes) {
        // Extract attributes.
        $name = $attributes['name'];
        $skin_type = $attributes['skin_type'];
        $dob = $attributes['dob'];
        $gender = $attributes['gender'];

        // Create a new `user` in the database with the given attributes.
        $statement = $this->connection->prepare('INSERT INTO `user` (`id`, `account_id`, `name`, `skin_type`, `dob`, `gender`, `is_owner`) SELECT UUID_TO_BIN(UUID()), `account_id`, :name, :skin_type, :dob, :gender, IF((SELECT COUNT(*) FROM `user` WHERE `account_id` = `token`.`account_id`) < 1, 1, 0) FROM `token` WHERE `token` = :token');
        $statement->bindParam(':name', $name);
        $statement->bindParam(':skin_type', $skin_type);
        $statement->bindParam(':dob', $dob);
        $statement->bindParam(':gender', $gender);
        $statement->bindParam(':token', $token);
        $statement->execute();

        var_dump($statement->errorInfo());

        if ($statement->rowCount() < 1) {
            // Invalid access token, or invalid `skin_type`, `dob`, or `gender` format.
            throw new Exception('User could not be created.', 400);
        }

        // Successfully created user.
        http_response_code(201);
    }

    /**
     * Get all `user`s belonging to the `account` of the given `token`.
     * 
     * @param string $token The token belonging to the `account` for which the users will be returned.
     * @throws Exception if the `token` is invalid, or the account has no users.
     */
    private function read($token) {
        // Get all `user`s belonging to the `account` of the given `token`.
        $statement = $this->connection->prepare('SELECT BIN_TO_UUID(`id`) as `id`, `name`, `skin_type`, `gender`, `dob`, `is_owner`, `created_on` FROM `user` WHERE `account_id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)');
        $statement->bindParam(':token', $token);
        $statement->execute();

        if ($statement->rowCount() < 1) {
            // Invalid access token, or account has no users.
            throw new Exception('Users could not be found.', 400);
        }

        // Return `user` information.
        $results = $statement->fetchAll(PDO::FETCH_ASSOC);
        foreach($results as $key => $value) {
            $results[$key]['is_owner'] = boolval($results[$key]['is_owner']); // Convert string ('1' or '0') to boolean (`true` or `false`).
        }
        echo json_encode($results);
    }

    /**
     * Update the `name`, `skin_type`, `dob`, and `gender` of the `user` belonging to the `account` of the given `token`.
     * 
     * @param string $token The token belonging to the `account` of the `user` for which the attributes will be updated.
     * @param string $user_id The ID of the user to be updated.
     * @param string[] $attributes The attributes of the `user` to be updated. Possible values: `name`, `skin_type`, `dob`, `gender`.
     * @throws Exception if the `token` or  `user_id` is invalid, or no attributes have been changed.
     */
    private function update($token, $user_id, $attributes) {
        // Extract attributes.
        $name = $attributes['name'];
        $skin_type = $attributes['skin_type'];
        $dob = $attributes['dob'];
        $gender = $attributes['gender'];

        // Update the `name`, `skin_type`, `dob`, and `gender` of the `user` belonging to the `account` of the given `token`.
        $statement = $this->connection->prepare('UPDATE `user` SET `name` = :name, `skin_type` = :skin_type, `dob` = :dob, `gender` = :gender WHERE `id` = UUID_TO_BIN(:user_id) AND `account_id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)');
        $statement->bindParam(':name', $name);
        $statement->bindParam(':skin_type', $skin_type);
        $statement->bindParam(':dob', $dob);
        $statement->bindParam(':gender', $gender);
        $statement->bindParam(':user_id', $user_id);
        $statement->bindParam(':token', $token);
        $statement->execute();

        if ($statement->rowCount() < 1) {
            // Access token is invalid, or no attributes have been changed.
            throw new Exception('User could not be updated.', 400);
        }

        // Successfully updated `user`.
        http_response_code(204);
    }

    /**
     * Delete the `user` with the given `id`.
     * 
     * @param string $token The token belonging to the `account` of the `user` which will be deleted.
     * @param string $user_id The ID of the user to be deleted.
     * @throws Exception if the `token` or `user_id` is invalid, or the `user` is an owner of an account (`is_owner` == 1).
     */
    private function delete($token, $user_id) {
        $statement = $this->connection->prepare('DELETE FROM `user` WHERE `id` = UUID_TO_BIN(:user_id) AND `is_owner` = 0 AND `account_id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)');
        $statement->bindParam(':user_id', $user_id);
        $statement->bindParam(':token', $token);
        $statement->execute();
        
        if ($statement->rowCount() < 1) {
            // The `token` or `user_id` is invalid, or the `user` is an owner of an account.
            throw new Exception('Could not delete user.', 400);
        }

        // Successfully deleted `account`.
        http_response_code(204);
    }
}
?>