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
use DataTables\Database\Query;
use DataTables\Database\DriverFirebirdResult;


/**
 * Firebird driver for DataTables Database Query class
 *  @internal
 */
class DriverFirebirdQuery extends Query {
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Private properties
	 */
	private $_stmt;

	protected $_identifier_limiter = ['"', '"'];

	protected $_field_quote = '"';

	protected $_supportsAsAlias = false;

	public $_pkeyInsertedTo;

	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Public methods
	 */

	static function connect( $user, $pass='', $host='', $port='', $db='', $dsn='' )
	{
		if ( is_array( $user ) ) {
			$opts = $user;
			$user = $opts['user'];
			$pass = $opts['pass'];
			$port = $opts['port'];
			$host = $opts['host'];
			$db   = $opts['db'];
			$dsn  = isset( $opts['dsn'] ) ? $opts['dsn'] : '';
			$pdoAttr = isset( $opts['pdoAttr'] ) ? $opts['pdoAttr'] : array();
		}

		if ( $host !== "" ) {
			$host = "{$host}";

			if ( $port !== "" ) {
				$host .= "/{$port}";
			}

			$host .= ';';
		}

		try {
			$pdoAttr[ PDO::ATTR_ERRMODE ] = PDO::ERRMODE_EXCEPTION;

			$pdo = @new PDO(
				"firebird:{$host}dbname={$db}".self::dsnPostfix( $dsn ),
				$user,
				$pass,
				$pdoAttr
			);
		} catch (\PDOException $e) {
			// If we can't establish a DB connection then we return a DataTables
			// error.
			echo json_encode( array( 
				"error" => "An error occurred while connecting to the database ".
					"'{$db}'. The error reported by the server was: ".$e->getMessage()
			) );
			exit(0);
		}

		return $pdo;
	}



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Protected methods
	 */

	protected function _prepare( $sql )
	{
		$this->database()->debugInfo( $sql, $this->_bindings );
	
		$resource = $this->database()->resource();
		$pkey = $this->pkey();

		// If insert, add the pkey column
		if ( $this->_type === 'insert' && $pkey ) {
			$this->_pkeyInsertedTo = (is_array($pkey) ? $pkey[0] : $pkey);
			$sql .= ' RETURNING "'.$this->_pkeyInsertedTo.'"';
		}

		$this->_stmt = $resource->prepare( $sql );

		// bind values
		for ( $i=0 ; $i<count($this->_bindings) ; $i++ ) {
			$binding = $this->_bindings[$i];

			$this->_stmt->bindValue(
				$binding['name'],
				$binding['value'],
				$binding['type'] ? $binding['type'] : \PDO::PARAM_STR
			);
		}
	}


	protected function _exec()
	{
		try {
			$this->_stmt->execute();
		}
		catch (\PDOException $e) {
			throw new \Exception( "An SQL error occurred: ".$e->getMessage() );
			error_log( "An SQL error occurred: ".$e->getMessage() );
			return false;
		}

		$resource = $this->database()->resource();
		return new DriverFirebirdResult( $resource, $this->_stmt, $this->_pkeyInsertedTo );
	}
}

