<?php
/**
 * DataTables PHP libraries.
 *
 * PHP libraries for DataTables and DataTables Editor, utilising PHP 5.3+.
 *
 *  @author    SpryMedia
 *  @copyright 2012 SpryMedia ( http://sprymedia.co.uk )
 *  @license   http://editor.datatables.net/license DataTables Editor
 *  @link      http://editor.datatables.net
 */

namespace DataTables\Database;
if (!defined('DATATABLES')) exit();


//
// This is a stub class that a driver must extend and complete
//

/**
 * Result object given by a {@see Query} performed on a database.
 * 
 * The typical pattern for using this class is to receive an instance of it as a
 * result of using the {@see Database} and {@see Query} class methods that
 * return a result. This class should not be initialised independently.
 *
 * Note that this is a stub class that a driver will extend and complete as
 * required for individual database types. Individual drivers could add
 * additional methods, but this is discouraged to ensure that the API is the
 * same for all database types.
 */
abstract class Result {
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Public methods
	 */

	/**
	 * Count the number of rows in the result set.
	 *  @return int
	 */
	abstract public function count ();


	/**
	 * Get the next row in a result set
	 *  @param int PDO row fetch style - PDO::FETCH_ASSOC is the default
	 *  @return array
	 */
	abstract public function fetch ( $fetchType=\PDO::FETCH_ASSOC );


	/**
	 * Get all rows in the result set
	 *  @param int PDO row fetch style - PDO::FETCH_ASSOC is the default
	 *  @return array
	 */
	abstract public function fetchAll ( $fetchType=\PDO::FETCH_ASSOC );


	/**
	 * After an INSERT query, get the ID that was inserted.
	 *  @return int
	 */
	abstract public function insertId ();
};


