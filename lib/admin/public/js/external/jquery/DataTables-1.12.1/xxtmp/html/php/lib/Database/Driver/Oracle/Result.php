<?php
/**
 * Oracle database driver for Editor
 *
 *  @author    SpryMedia
 *  @copyright 2014 SpryMedia ( http://sprymedia.co.uk )
 *  @license   http://editor.datatables.net/license DataTables Editor
 *  @link      http://editor.datatables.net
 */

namespace DataTables\Database;
if (!defined('DATATABLES')) exit();

use PDO;
use DataTables\Database\Result;


/**
 * MySQL driver for DataTables Database Result class
 *  @internal
 */
class DriverOracleResult extends Result {
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Constructor
	 */

	function __construct( $dbh, $stmt, $pkey_val )
	{
		$this->_dbh = $dbh;
		$this->_stmt = $stmt;
		$this->_pkey_val = $pkey_val;
	}



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Private properties
	 */

	private $_stmt; // Result from oci_parse
	private $_dbh; // Result from oci_connect
	private $_rows = null;
	private $_pkey_val;



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Public methods
	 */

	public function count ()
	{
		return count($this->fetchAll());
	}


	public function fetch ()
	{
		return oci_fetch_assoc( $this->_stmt );
	}


	public function fetchAll ()
	{
		if ( ! $this->_rows ) {
			$out = array();
		
			oci_fetch_all( $this->_stmt, $out, 0, -1, OCI_FETCHSTATEMENT_BY_ROW + OCI_ASSOC );

			$this->_rows = $out;
		}

		return $this->_rows;
	}


	public function insertId ()
	{
		return $this->_pkey_val;
	}
}

