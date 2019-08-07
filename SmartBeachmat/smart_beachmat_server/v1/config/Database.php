<?php
require_once __DIR__.'/config.php';

/**
 * A singleton used to represent a database
 *
 * The `Database` class represents a database, and stores its connection,
 * which can be retrieved through the `getConnection()` function, and on
 * which queries can be performed.
 * 
 * For security reasons, the database credentials are retrieved from a
 * different file, which has been added to the `.gitignore`.
 *
 * @author Adam Dorogi-Kaposi
 */
class Database {
    private static $instance;
    
    private $host = DB_HOST;
    private $database = DB_DATABASE;
    private $username = DB_USERNAME;
    private $password = DB_PASSWORD;

    private $connection;

    /**
     * Constructor.
     * 
     * @throws Exception if connection to the database failed.
     */
    private function __construct() {
        try {
            $this->connection = new PDO('mysql:host='.$this->host.';dbname='.$this->database.';charset=utf8', $this->username, $this->password);
        } catch(PDOException $e) {
            throw new Exception('Could not connect to database.', 500);
        }
    }

    /**
     * Return the singleton instance of the `Database`.
     */
    public function getInstance() {
        if (!self::$instance) {
            self::$instance = new Database();
        }
        return self::$instance;
    }

    /**
     * Return the database connection.
     */
    public function getConnection() {
        return $this->connection;
    }
}
?>