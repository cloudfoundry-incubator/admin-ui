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

namespace DataTables\Database\Driver;
if (!defined('DATATABLES')) exit();

use PDO;
use DataTables\Database\Query;
use DataTables\Database\Driver\PostgresResult;


/**
 * Postgres driver for DataTables Database Query class
 *  @internal
 */
class PostgresQuery extends Query {
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Private properties
	 */
	private $_stmt;

	protected $_identifier_limiter = array('"', '"');

	protected $_field_quote = '"';

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

		if ( $port !== "" ) {
			$port = "port={$port};";
		}

		try {
			$pdoAttr[ PDO::ATTR_ERRMODE ] = PDO::ERRMODE_EXCEPTION;

			$pdo = @new PDO(
				"pgsql:host={$host};{$port}dbname={$db}".self::dsnPostfix( $dsn ),
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
		
		// Add a RETURNING command to postgres insert queries so we can get the
		// pkey value from the query reliably
		if ( $this->_type === 'insert' ) {
			$table = explode( ' as ', $this->_table[0] );

			// Get the pkey field name
			$pkRes = $resource->prepare( 
				"SELECT
					pg_attribute.attname, 
					format_type(pg_attribute.atttypid, pg_attribute.atttypmod) 
				FROM pg_index, pg_class, pg_attribute 
				WHERE 
					pg_class.oid = '{$table[0]}'::regclass AND
					indrelid = pg_class.oid AND
					pg_attribute.attrelid = pg_class.oid AND 
					pg_attribute.attnum = any(pg_index.indkey)
					AND indisprimary"
			);
			$pkRes->execute();
			$row = $pkRes->fetch();

			if ( $row && isset($row['attname'] ) ) {
				$sql .= ' RETURNING '.$row['attname'].' as dt_pkey';
			}
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
		return new PostgresResult( $resource, $this->_stmt );
	}
}

