<?php
/**
 * An interface to define common functions for a database entity.
 */
interface Entity {
    /**
     * Adds an entity to the database.
     * 
     * @param attributes The array of attributes of the entity.
     */
    function create($attributes);

    /**
     * Gets an entity from the database.
     * 
     * @param id The ID (primary key) of the entity to retrieve.
     * @return attributes The attributes of the entity.
     */
    function read($id);

    /**
     * Changes an entity in the database.
     * 
     * @param id The ID (primary key) of the entity to update.
     * @param attributes The attributes of the entity to update.
     */
    function update($token, $attribute, $attributes);

    /**
     * Remove an entity from the database.
     * 
     * @param id The ID (primary key) of the entity to delete.
     */
    function delete($id, $token);
}
?>