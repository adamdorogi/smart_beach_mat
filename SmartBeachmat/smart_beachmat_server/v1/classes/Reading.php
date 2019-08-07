<?php
/**
 * A class used to represent a `reading` entity in the database
 *
 * The `Reading` class represents a `reading` entity in the database,
 * and provides create and read operations for the entity.
 *
 * @author Adam Dorogi-Kaposi
 */
class Reading {
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
            case 'POST': // Create a `reading`.
                $this->create($token, $_POST);
                break;
            case 'GET': // Get a `reading`.
                $request_uri = explode('/', $_SERVER['REQUEST_URI']);

                $this->read($token, $request_uri[3]);
                break;
            default:
                throw new Exception('Method not allowed.', 405);
                break;
        }
    }

    /**
     * Create a new `reading` in the database with the given `uv_index`, `lat`, `long`
     * and a randomly generated UUID as `id`.
     * 
     * @param string $token The token belonging to the `account` for which the `reading` will be created.
     * @param string[] $attributes The attributes of the `reading`. Possible values: `user_ids`, `uv_index`, `lat`, `long`.
     * @throws Exception if the `uv_index`, `lat`, or `lng` are in an invalid format, the `token` is invalid,
     *                   or all of `user_ids` are invalid.
     */
    private function create($token, $attributes) {
        // Extract attributes.
        $uv_index = $attributes['uv_index'];
        $lat = $attributes['lat'];
        $lng = $attributes['lng'];
        $user_ids = explode(',', $attributes['user_ids']);

        // Generate UUID `id` for reading.
        $statement = $this->connection->prepare('SELECT UUID()');
        $statement->execute();
        $reading_id = $statement->fetch(PDO::FETCH_ASSOC)['UUID()'];

        // Insert the `reading` into the database.
        $statement = $this->connection->prepare('INSERT INTO `reading` (`id`, `uv_index`, `lat`, `lng`) VALUES (UUID_TO_BIN(:reading_id), :uv_index, :lat, :lng)');
        $statement->bindParam(':reading_id', $reading_id);
        $statement->bindParam(':uv_index', $uv_index);
        $statement->bindParam(':lat', $lat);
        $statement->bindParam(':lng', $lng);
        $statement->execute();

        $inserted_rows = 0;

        // For each user, insert recordings into the `user_reading` table.
        foreach($user_ids as $user_id) {
            $statement = $this->connection->prepare('INSERT INTO `user_reading` (`user_id`, `reading_id`) SELECT `id`, UUID_TO_BIN(:reading_id) FROM `user` WHERE `id` = UUID_TO_BIN(:user_id) AND `account_id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)');
            $statement->bindParam(':reading_id', $reading_id);
            $statement->bindParam(':user_id', $user_id);
            $statement->bindParam(':token', $token);
            $statement->execute();
            $inserted_rows += $statement->rowCount();
        }

        // If no rows have been inserted into bridging table (`user_reading`), remove the insertion from the `reading` table.
        if ($inserted_rows < 1) {
            $statement = $this->connection->prepare('DELETE FROM `reading` WHERE `id` = UUID_TO_BIN(:reading_id)');
            $statement->bindParam(':reading_id', $reading_id);
            $statement->execute();
            // `uv_index`, `lat`, or `lng` are in an invalid format, the `token` is invalid, or all of `user_ids` are invalid.
            throw new Exception('Could not create reading.', 400);
        }

        // Readings successfully created.
        http_response_code(201);
    }

    /**
     * Get all `reading`s belonging to the `user` of the `account` of the given `token`.
     * 
     * @param string $token The token belonging to the `account` for which the user's readings will be returned.
     * @param string $attributes The ID of the `user` for which to get the `reading`s.
     * @throws Exception if the `token` or `user_id` is invalid, or no readings could be found for the `user`.
     */
    private function read($token, $user_id) {
        // Get all `reading`s belonging to the `user` of the `account` of the given `token`.
        $statement = $this->connection->prepare('SELECT `uv_index`, `lat`, `lng`, `created_on` FROM `reading` WHERE `id` IN (SELECT `reading_id` FROM `user_reading` WHERE `user_id` IN (SELECT `id` FROM `user` WHERE `id` = UUID_TO_BIN(:user_id) AND `account_id` IN (SELECT `account_id` FROM `token` WHERE `token` = :token)))');
        $statement->bindParam(':user_id', $user_id);
        $statement->bindParam(':token', $token);
        $statement->execute();

        if ($statement->rowCount() < 1) {
            // Invalid `token` or `user_id`, or no readings for `user`.
            throw new Exception('Readings could not be found.', 400);
        }

        // Return all `reading`s belonging to the `user_id`.
        $results = $statement->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($results);
    }
}
?>