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

namespace DataTables;
if (!defined('DATATABLES')) exit();

use
	DataTables\Database\Query,
	DataTables\Database\Result;


/**
 * DataTables Database connection object.
 *
 * Create a database connection which may then have queries performed upon it.
 * 
 * This is a database abstraction class that can be used on multiple different
 * databases. As a result of this, it might not be suitable to perform complex
 * queries through this interface or vendor specific queries, but everything 
 * required for basic database interaction is provided through the abstracted
 * methods.
 */
class Database {
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Constructor
	 */

	/**
	 * Database instance constructor.
	 *  @param string[] $opts Array of connection parameters for the database:
	 *    ```php
	 *      array(
	 *          "user" => "", // User name
	 *          "pass" => "", // Password
	 *          "host" => "", // Host name
	 *          "port" => "", // Port
	 *          "db"   => "", // Database name
	 *          "type" => ""  // Datable type: "Mysql", "Postgres" or "Sqlite"
	 *      )
	 *    ```
	 */
	function __construct( $opts )
	{
		$types = array( 'Mysql', 'Oracle', 'Postgres', 'Sqlite', 'Sqlserver', 'Db2', 'Firebird' );

		if ( ! in_array( $opts['type'], $types ) ) {
			throw new \Exception(
				"Unknown database driver type. Must be one of ".implode(', ', $types),
				1
			);
		}

		$this->type = $opts['type'];
		$this->query_driver = "DataTables\\Database\\Driver\\".$opts['type'].'Query';
		$this->_dbResource = isset( $opts['pdo'] ) ?
			$opts['pdo'] :
			call_user_func($this->query_driver.'::connect', $opts );
	}



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Private properties
	 */

	/** @var resource */
	private $_dbResource = null;

	/** @var callable */
	private $_debugCallback = null;



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Public methods
	 */

	/**
	 * Determine if there is any data in the table that matches the query
	 * condition
	 *
	 * @param string|string[] $table Table name(s) to act upon.
	 * @param array $where Where condition for what to select - see {@see
	 *   Query->where()}.
	 * @return boolean Boolean flag - true if there were rows
	 */
	public function any( $table, $where=null )
	{
		$res = $this->query( 'select' )
			->table( $table )
			->get( '*' )
			->where( $where )
			->limit(1)
			->exec();

		return $res->count() > 0;
	}


	/**
	 * Commit a database transaction.
	 *
	 * Use with {@see Database->transaction()} and {@see Database->rollback()}.
	 *  @return self
	 */
	public function commit ()
	{
		call_user_func($this->query_driver.'::commit', $this->_dbResource );
		return $this;
	}


	/**
	 * Get a count from a table.
	 *  @param string|string[] $table Table name(s) to act upon.
	 *  @param string $field Primary key field name
	 *  @param array $where Where condition for what to select - see {@see
	 *    Query->where()}.
	 *  @return Number
	 */
	public function count ( $table, $field="id", $where=null )
	{
		$res = $this->query( 'count' )
			->table( $table )
			->get( $field )
			->where( $where )
			->exec();

		$cnt = $res->fetch();
		return $cnt['cnt'];
	}


	/**
	 * Get / set debug mode.
	 * 
	 *  @param boolean $_ Debug mode state. If not given, then used as a getter.
	 *  @return boolean|self Debug mode state if no parameter is given, or
	 *    self if used as a setter.
	 */
	public function debug ( $set=null )
	{
		if ( $set === null ) {
			return $this->_debugCallback ? true : false;
		}
		else if ( $set === false ) {
			$this->_debugCallback = null;
		}
		else {
			$this->_debugCallback = $set;
		}

		return $this;
	}


	/**
	 * Perform a delete query on a table.
	 *
	 * This is a short cut method that creates an update query and then uses
	 * the query('delete'), table, where and exec methods of the query.
	 *  @param string|string[] $table Table name(s) to act upon.
	 *  @param array $where Where condition for what to delete - see {@see
	 *    Query->where()}.
	 *  @return Result
	 */
	public function delete ( $table, $where=null )
	{
		return $this->query( 'delete' )
			->table( $table )
			->where( $where )
			->exec();
	}


	/**
	 * Insert data into a table.
	 *
	 * This is a short cut method that creates an update query and then uses
	 * the query('insert'), table, set and exec methods of the query.
	 *  @param string|string[] $table Table name(s) to act upon.
	 *  @param array $set Field names and values to set - see {@see
	 *    Query->set()}.
	 *  @param  array $pkey Primary key column names (this is an array for
	 *    forwards compt, although only the first item in the array is actually
	 *    used). This doesn't need to be set, but it must be if you want to use
	 *    the `Result->insertId()` method.
	 *  @return Result
	 */
	public function insert ( $table, $set, $pkey='' )
	{
		return $this->query( 'insert' )
			->pkey( $pkey )
			->table( $table )
			->set( $set )
			->exec();
	}


	/**
	 * Update or Insert data. When doing an insert, the where condition is
	 * added as a set field
	 *  @param string|string[] $table Table name(s) to act upon.
	 *  @param array $set Field names and values to set - see {@see
	 *    Query->set()}.
	 *  @param array $where Where condition for what to update - see {@see
	 *    Query->where()}.
	 *  @param  array $pkey Primary key column names (this is an array for
	 *    forwards compt, although only the first item in the array is actually
	 *    used). This doesn't need to be set, but it must be if you want to use
	 *    the `Result->insertId()` method. Only used if an insert is performed.
	 *  @return Result
	 */
	public function push ( $table, $set, $where=null, $pkey='' )
	{
		$selectColumn = '*';
		
		if ( $pkey ) {
			$selectColumn = is_array($pkey) ?
				$pkey[0] :
				$pkey;
		}

		// Update or insert
		if ( $this->select( $table, $selectColumn, $where )->count() > 0 ) {
			return $this->update( $table, $set, $where );
		}

		// Add the where condition to the values to set
		foreach ($where as $key => $value) {
			if ( ! isset( $set[ $key ] ) ) {
				$set[ $key ] = $value;
			}
		}

		return $this->insert( $table, $set, $pkey );
	}


	/**
	 * Create a query object to build a database query.
	 *  @param string $type Query type - select, insert, update or delete.
	 *  @param string|string[] $table Table name(s) to act upon.
	 *  @return Query
	 */
	public function query ( $type, $table=null )
	{
		return new $this->query_driver( $this, $type, $table );
	}


	/**
	 * Quote a string for a quote. Note you should generally use a bind!
	 *  @param string $val Value to quote
	 *  @param string $type Value type
	 *  @return string
	 */
	public function quote ( $val, $type=\PDO::PARAM_STR )
	{
		return $this->_dbResource->quote( $val, $type );
	}


	/**
	 * Create a `Query` object that will execute a custom SQL query. This is
	 * similar to the `sql` method, but in this case you must call the `exec()`
	 * method of the returned `Query` object manually. This can be useful if you
	 * wish to bind parameters using the query `bind` method to ensure data is
	 * properly escaped.
	 *
	 *  @return Result
	 *
	 *  @example
	 *    Safely escape user input
	 *    ```php
	 *    $db
	 *      ->raw()
	 *      ->bind( ':date', $_POST['date'] )
	 *      ->exec( 'SELECT * FROM staff where date < :date' );
	 *    ```
	 */
	public function raw ()
	{
		return $this->query( 'raw' );
	}


	/**
	 * Get the database resource connector. This is typically a PDO object.
	 * @return resource PDO connection resource (driver dependent)
	 */
	public function resource ()
	{
		return $this->_dbResource;
	}


	/**
	 * Rollback the database state to the start of the transaction.
	 *
	 * Use with {@see Database->transaction()} and {@see Database->commit()}.
	 *  @return self
	 */
	public function rollback ()
	{
		call_user_func($this->query_driver.'::rollback', $this->_dbResource );
		return $this;
	}


	/**
	 * Select data from a table.
	 *
	 * This is a short cut method that creates an update query and then uses
	 * the query('select'), table, get, where and exec methods of the query.
	 *  @param string|string[] $table Table name(s) to act upon.
	 *  @param array $field Fields to get from the table(s) - see {@see
	 *    Query->get()}.
	 *  @param array $where Where condition for what to select - see {@see
	 *    Query->where()}.
	 *  @param array $orderBy Order condition - see {@see
	 *    Query->order()}.
	 *  @return Result
	 */
	public function select ( $table, $field="*", $where=null, $orderBy=null )
	{
		return $this->query( 'select' )
			->table( $table )
			->get( $field )
			->where( $where )
			->order( $orderBy )
			->exec();
	}


	/**
	 * Select distinct data from a table.
	 *
	 * This is a short cut method that creates an update query and then uses the
	 * query('select'), distinct ,table, get, where and exec methods of the
	 * query.
	 *  @param string|string[] $table Table name(s) to act upon.
	 *  @param array $field Fields to get from the table(s) - see {@see
	 *    Query->get()}.
	 *  @param array $where Where condition for what to select - see {@see
	 *    Query->where()}.
	 *  @param array $orderBy Order condition - see {@see
	 *    Query->order()}.
	 *  @return Result
	 */
	public function selectDistinct ( $table, $field="*", $where=null, $orderBy=null )
	{
		return $this->query( 'select' )
			->table( $table )
			->distinct( true )
			->get( $field )
			->where( $where )
			->order( $orderBy )
			->exec();
	}


	/**
	 * Execute an raw SQL query - i.e. give the method your own SQL, rather
	 * than having the Database classes building it for you.
	 *
	 * This method will execute the given SQL immediately. Use the `raw()`
	 * method if you need the ability to add bound parameters.
	 *  @param string $sql SQL string to execute (only if _type is 'raw').
	 *  @return Result
	 *
	 *  @example
	 *    Basic select
	 *    ```php
	 *    $result = $db->sql( 'SELECT * FROM myTable;' );
	 *    ```
	 *
	 *  @example
	 *    Set the character set of the connection
	 *    ```php
	 *    $db->sql("SET character_set_client=utf8");
	 *    $db->sql("SET character_set_connection=utf8");
	 *    $db->sql("SET character_set_results=utf8");
	 *    ```
	 */
	public function sql ( $sql )
	{
		return $this->query( 'raw' )
			->exec( $sql );
	}


	/**
	 * Start a new database transaction.
	 *
	 * Use with {@see Database->commit()} and {@see Database->rollback()}.
	 *  @return self
	 */
	public function transaction ()
	{
		call_user_func($this->query_driver.'::transaction', $this->_dbResource );
		return $this;
	}


	/**
	 * Update data.
	 *
	 * This is a short cut method that creates an update query and then uses
	 * the query('update'), table, set, where and exec methods of the query.
	 *  @param string|string[] $table Table name(s) to act upon.
	 *  @param array $set Field names and values to set - see {@see
	 *    Query->set()}.
	 *  @param array $where Where condition for what to update - see {@see
	 *    Query->where()}.
	 *  @return Result
	 */
	public function update ( $table, $set=null, $where=null )
	{
		return $this->query( 'update' )
			->table( $table )
			->set( $set )
			->where( $where )
			->exec();
	}


	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Internal functions
	 */

	/**
	 * Get debug query information.
	 *
	 *  @return array Information about the queries used. When this method is
	 *    called it will reset the query cache.
	 *  @internal
	 */
	public function debugInfo ( $query=null, $bindings=null )
	{
		$callback = $this->_debugCallback;

		if ( $callback ) {
			$callback( array(
				"query"    => $query,
				"bindings" => $bindings
			) );
		}

		return $this;
	}
};

