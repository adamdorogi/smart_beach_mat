<?php
require_once __DIR__.'/config.php';

class Database {
    private static $instance;
    
    private $host = DB_HOST;
    private $database = DB_DATABASE;
    private $username = DB_USERNAME;
    private $password = DB_PASSWORD;

    private $connection;

    private function __construct() {
        try {
            $this->connection = new PDO('mysql:host='.$this->host.';dbname='.$this->database.';charset=utf8', $this->username, $this->password);
        } catch(PDOException $e) {
            exit($e->getMessage());
        }
    }

    public function getInstance() {
        if (!self::$instance) {
            self::$instance = new Database();
        }

        return self::$instance;
    }

    public function getConnection() {
        return $this->connection;
    }
}
?>