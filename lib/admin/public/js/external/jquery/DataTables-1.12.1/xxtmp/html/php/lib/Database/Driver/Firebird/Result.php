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

use PDO;
use DataTables\Database\Result;


/**
 * Firebird driver for DataTables Database Result class
 *  @internal
 */
class DriverFirebirdResult extends Result {
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Constructor
	 */

	function __construct( $dbh, $stmt, $pkey )
	{
		$this->_dbh = $dbh;
		$this->_stmt = $stmt;
		$this->_pkey = $pkey;
	}



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Private properties
	 */

	private $_stmt;
	private $_dbh;
	private $_pkey;



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Public methods
	 */

	public function count ()
	{
		return count($this->fetchAll());
	}


	public function fetch ( $fetchType=\PDO::FETCH_ASSOC )
	{
		return $this->_stmt->fetch( $fetchType );
	}


	public function fetchAll ( $fetchType=\PDO::FETCH_ASSOC )
	{
		return $this->_stmt->fetchAll( $fetchType );
	}


	public function insertId ()
	{
		// Only useful after an insert of course...
		$rows = $this->_stmt->fetchAll();
		return $rows[0][$this->_pkey];
	}
}

