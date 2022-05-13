<?php
/**
 * DataTables PHP libraries.
 *
 * PHP libraries for DataTables and DataTables Editor, utilising PHP 5.3+.
 *
 *  @author    SpryMedia
 *  @version   1.7.4
 *  @copyright 2012 SpryMedia ( http://sprymedia.co.uk )
 *  @license   http://editor.datatables.net/license DataTables Editor
 *  @link      http://editor.datatables.net
 */

namespace DataTables;
if (!defined('DATATABLES')) exit();

use
	DataTables,
	DataTables\Editor\Join,
	DataTables\Editor\Field;


/**
 * DataTables Editor base class for creating editable tables.
 *
 * Editor class instances are capable of servicing all of the requests that
 * DataTables and Editor will make from the client-side - specifically:
 * 
 * * Get data
 * * Create new record
 * * Edit existing record
 * * Delete existing records
 *
 * The Editor instance is configured with information regarding the
 * database table fields that you wish to make editable, and other information
 * needed to read and write to the database (table name for example!).
 *
 * This documentation is very much focused on describing the API presented
 * by these DataTables Editor classes. For a more general overview of how
 * the Editor class is used, and how to install Editor on your server, please
 * refer to the {@link https://editor.datatables.net/manual Editor manual}.
 *
 *  @example 
 *    A very basic example of using Editor to create a table with four fields.
 *    This is all that is needed on the server-side to create a editable
 *    table - the {@link process} method determines what action DataTables /
 *    Editor is requesting from the server-side and will correctly action it.
 *    <code>
 *      Editor::inst( $db, 'browsers' )
 *          ->fields(
 *              Field::inst( 'first_name' )->validator( Validate::required() ),
 *              Field::inst( 'last_name' )->validator( Validate::required() ),
 *              Field::inst( 'country' ),
 *              Field::inst( 'details' )
 *          )
 *          ->process( $_POST )
 *          ->json();
 *    </code>
 */
class Editor extends Ext {
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Statics
	 */

	/** Request type - read */
	const ACTION_READ = 'read';

	/** Request type - create */
	const ACTION_CREATE = 'create';

	/** Request type - edit */
	const ACTION_EDIT = 'edit';

	/** Request type - delete */
	const ACTION_DELETE = 'remove';

	/** Request type - upload */
	const ACTION_UPLOAD = 'upload';


	/**
	 * Determine the request type from an HTTP request.
	 * 
	 * @param array $http Typically $_POST, but can be any array used to carry
	 *   an Editor payload
	 * @return string `Editor::ACTION_READ`, `Editor::ACTION_CREATE`,
	 *   `Editor::ACTION_EDIT` or `Editor::ACTION_DELETE` indicating the request
	 *   type.
	 */
	static public function action ( $http )
	{
		if ( ! isset( $http['action'] ) ) {
			return self::ACTION_READ;
		}

		switch ( $http['action'] ) {
			case 'create':
				return self::ACTION_CREATE;

			case 'edit':
				return self::ACTION_EDIT;

			case 'remove':
				return self::ACTION_DELETE;

			case 'upload':
				return self::ACTION_UPLOAD;

			default:
				throw new \Exception("Unknown Editor action: ".$http['action']);
		}
	}


	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Constructor
	 */

	/**
	 * Constructor.
	 *  @param Database $db An instance of the DataTables Database class that we can
	 *    use for the DB connection. Can be given here or with the 'db' method.
	 *    <code>
	 *      456
	 *    </code>
	 *  @param string|array $table The table name in the database to read and write
	 *    information from and to. Can be given here or with the 'table' method.
	 *  @param string|array $pkey Primary key column name in the table given in
	      the $table parameter. Can be given here or with the 'pkey' method.
	 */
	function __construct( $db=null, $table=null, $pkey=null )
	{
		// Set constructor parameters using the API - note that the get/set will
		// ignore null values if they are used (i.e. not passed in)
		$this->db( $db );
		$this->table( $table );
		$this->pkey( $pkey );
	}


	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Public properties
	 */

	/** @var string */
	public $version = '1.7.4';



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Private properties
	 */

	/** @var DataTables\Database */
	private $_db = null;

	/** @var DataTables\Editor\Field[] */
	private $_fields = array();

	/** @var array */
	private $_formData;

	/** @var array */
	private $_processData;

	/** @var string */
	private $_idPrefix = 'row_';

	/** @var DataTables\Editor\Join[] */
	private $_join = array();

	/** @var array */
	private $_pkey = array('id');

	/** @var string[] */
	private $_table = array();

	/** @var boolean */
	private $_transaction = true;

	/** @var array */
	private $_where = array();

	/** @var array */
	private $_leftJoin = array();

	/** @var boolean - deprecated */
	private $_whereSet = false;

	/** @var array */
	private $_out = array();

	/** @var array */
	private $_events = array();

	/** @var boolean */
	private $_debug = false;

	/** @var array */
	private $_debugInfo = array();

	/** @var callback */
	private $_validator = null;

	/** @var boolean Enable true / catch when processing */
	private $_tryCatch = true;



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Public methods
	 */

	/**
	 * Get the data constructed in this instance.
	 * 
	 * This will get the PHP array of data that has been constructed for the 
	 * command that has been processed by this instance. Therefore only useful after
	 * process has been called.
	 *  @return array Processed data array.
	 */
	public function data ()
	{
		return $this->_out;
	}


	/**
	 * Get / set the DB connection instance
	 *  @param Database $_ DataTable's Database class instance to use for database
	 *    connectivity. If not given, then used as a getter.
	 *  @return Database|self The Database connection instance if no parameter
	 *    is given, or self if used as a setter.
	 */
	public function db ( $_=null )
	{
		return $this->_getSet( $this->_db, $_ );
	}


	/**
	 * Get / set debug mode and set a debug message.
	 *
	 * It can be useful to see the SQL statements that Editor is using. This
	 * method enables that ability. Information about the queries used is
	 * automatically added to the output data array / JSON under the property
	 * name `debugSql`.
	 * 
	 * This method can also be called with a string parameter, which will be
	 * added to the debug information sent back to the client-side. This can
	 * be useful when debugging event listeners, etc.
	 * 
	 *  @param boolean|* $_ Debug mode state. If not given, then used as a
	 *    getter. If given as anything other than a boolean, it will be added
	 *    to the debug information sent back to the client.
	 *  @return boolean|self Debug mode state if no parameter is given, or
	 *    self if used as a setter or when adding a debug message.
	 */
	public function debug ( $_=null )
	{
		if ( ! is_bool( $_ ) ) {
			$this->_debugInfo[] = $_;

			return $this;
		}

		return $this->_getSet( $this->_debug, $_ );
	}


	/**
	 * Get / set field instance.
	 * 
	 * The list of fields designates which columns in the table that Editor will work
	 * with (both get and set).
	 *  @param Field|string $_... This parameter effects the return value of the
	 *      function:
	 *
	 *      * `null` - Get an array of all fields assigned to the instance
	 * 	    * `string` - Get a specific field instance whose 'name' matches the
	 *           field passed in
	 *      * {@link Field} - Add a field to the instance's list of fields. This
	 *           can be as many fields as required (i.e. multiple arguments)
	 *      * `array` - An array of {@link Field} instances to add to the list
	 *        of fields.
	 *  @return Field|Field[]|Editor The selected field, an array of fields, or
	 *      the Editor instance for chaining, depending on the input parameter.
	 *  @throws \Exception Unkown field error
	 *  @see {@link Field} for field documentation.
	 */
	public function field ( $_=null )
	{
		if ( is_string( $_ ) ) {
			for ( $i=0, $ien=count($this->_fields) ; $i<$ien ; $i++ ) {
				if ( $this->_fields[$i]->name() === $_ ) {
					return $this->_fields[$i];
				}
			}

			throw new \Exception('Unknown field: '.$_);
		}

		if ( $_ !== null && !is_array($_) ) {
			$_ = func_get_args();
		}
		return $this->_getSet( $this->_fields, $_, true );
	}


	/**
	 * Get / set field instances.
	 * 
	 * An alias of {@link field}, for convenience.
	 *  @param Field $_... Instances of the {@link Field} class, given as a single 
	 *    instance of {@link Field}, an array of {@link Field} instances, or multiple
	 *    {@link Field} instance parameters for the function.
	 *  @return Field[]|self Array of fields, or self if used as a setter.
	 *  @see {@link Field} for field documentation.
	 */
	public function fields ( $_=null )
	{
		if ( $_ !== null && !is_array($_) ) {
			$_ = func_get_args();
		}
		return $this->_getSet( $this->_fields, $_, true );
	}


	/**
	 * Get / set the DOM prefix.
	 *
	 * Typically primary keys are numeric and this is not a valid ID value in an
	 * HTML document - is also increases the likelihood of an ID clash if multiple
	 * tables are used on a single page. As such, a prefix is assigned to the 
	 * primary key value for each row, and this is used as the DOM ID, so Editor
	 * can track individual rows.
	 *  @param string $_ Primary key's name. If not given, then used as a getter.
	 *  @return string|self Primary key value if no parameter is given, or
	 *    self if used as a setter.
	 */
	public function idPrefix ( $_=null )
	{
		return $this->_getSet( $this->_idPrefix, $_ );
	}


	/**
	 * Get the data that is being processed by the Editor instance. This is only
	 * useful once the `process()` method has been called, and is available for
	 * use in validation and formatter methods.
	 *
	 *   @return array Data given to `process()`.
	 */
	public function inData ()
	{
		return $this->_processData;
	}


	/**
	 * Get / set join instances. Note that for the majority of use cases you
	 * will want to use the `leftJoin()` method. It is significantly easier
	 * to use if you are just doing a simple left join!
	 * 
	 * The list of Join instances that Editor will join the parent table to
	 * (i.e. the one that the {@link table} and {@link fields} methods refer to
	 * in this class instance).
	 *
	 *  @param Join $_,... Instances of the {@link Join} class, given as a
	 *    single instance of {@link Join}, an array of {@link Join} instances,
	 *    or multiple {@link Join} instance parameters for the function.
	 *  @return Join[]|self Array of joins, or self if used as a setter.
	 *  @see {@link Join} for joining documentation.
	 */
	public function join ( $_=null )
	{
		if ( $_ !== null && !is_array($_) ) {
			$_ = func_get_args();
		}
		return $this->_getSet( $this->_join, $_, true );
	}


	/**
	 * Get the JSON for the data constructed in this instance.
	 * 
	 * Basically the same as the {@link data} method, but in this case we echo, or
	 * return the JSON string of the data.
	 *  @param boolean $print Echo the JSON string out (true, default) or return it
	 *    (false).
	 *  @return string|self self if printing the JSON, or JSON representation of 
	 *    the processed data if false is given as the first parameter.
	 */
	public function json ( $print=true )
	{
		if ( $print ) {
			$json = json_encode( $this->_out );

			if ( $json !== false ) {
				echo $json;
			}
			else {
				echo json_encode( array(
					"error" => "JSON encoding error: ".json_last_error_msg()
				) );
			}

			return $this;
		}
		return json_encode( $this->_out );
	}


	/**
	 * Echo out JSONP for the data constructed and processed in this instance.
	 * This is basically the same as {@link json} but wraps the return in a
	 * JSONP callback.
	 *
	 * @param string $callback The callback function name to use. If not given
	 *    or `null`, then `$_GET['callback']` is used (the jQuery default).
	 * @return self Self for chaining.
	 * @throws \Exception JSONP function name validation
	 */
	public function jsonp ( $callback=null )
	{
		if ( ! $callback ) {
			$callback = $_GET['callback'];
		}

		if ( preg_match('/[^a-zA-Z0-9_]/', $callback) ) {
			throw new \Exception("Invalid JSONP callback function name");
		}

		echo $callback.'('.json_encode( $this->_out ).');';
		return $this;
	}


	/**
	 * Add a left join condition to the Editor instance, allowing it to operate
	 * over multiple tables. Multiple `leftJoin()` calls can be made for a
	 * single Editor instance to join multiple tables.
	 *
	 * A left join is the most common type of join that is used with Editor
	 * so this method is provided to make its use very easy to configure. Its
	 * parameters are basically the same as writing an SQL left join statement,
	 * but in this case Editor will handle the create, update and remove
	 * requirements of the join for you:
	 *
	 * * Create - On create Editor will insert the data into the primary table
	 *   and then into the joined tables - selecting the required data for each
	 *   table.
	 * * Edit - On edit Editor will update the main table, and then either
	 *   update the existing rows in the joined table that match the join and
	 *   edit conditions, or insert a new row into the joined table if required.
	 * * Remove - On delete Editor will remove the main row and then loop over
	 *   each of the joined tables and remove the joined data matching the join
	 *   link from the main table.
	 *
	 * Please note that when using join tables, Editor requires that you fully
	 * qualify each field with the field's table name. SQL can result table
	 * names for ambiguous field names, but for Editor to provide its full CRUD
	 * options, the table name must also be given. For example the field
	 * `first_name` in the table `users` would be given as `users.first_name`.
	 *
	 * @param string $table Table name to do a join onto
	 * @param string $field1 Field from the parent table to use as the join link
	 * @param string $operator Join condition (`=`, '<`, etc)
	 * @param string $field2 Field from the child table to use as the join link
	 * @return self Self for chaining.
	 *
	 * @example 
	 *    Simple join:
	 *    <code>
	 *        ->field( 
	 *          Field::inst( 'users.first_name as myField' ),
	 *          Field::inst( 'users.last_name' ),
	 *          Field::inst( 'users.dept_id' ),
	 *          Field::inst( 'dept.name' )
	 *        )
	 *        ->leftJoin( 'dept', 'users.dept_id', '=', 'dept.id' )
	 *        ->process($_POST)
	 *        ->json();
	 *    </code>
	 *
	 *    This is basically the same as the following SQL statement:
	 * 
	 *    <code>
	 *      SELECT users.first_name, users.last_name, user.dept_id, dept.name
	 *      FROM users
	 *      LEFT JOIN dept ON users.dept_id = dept.id
	 *    </code>
	 */
	public function leftJoin ( $table, $field1, $operator, $field2 )
	{
		$this->_leftJoin[] = array(
			"table"    => $table,
			"field1"   => $field1,
			"field2"   => $field2,
			"operator" => $operator
		);

		return $this;
	}


	/**
	 * Add an event listener. The `Editor` class will trigger an number of
	 * events that some action can be taken on.
	 *
	 * @param  [type] $name     Event name
	 * @param  [type] $callback Callback function to execute when the event
	 *     occurs
	 * @return self Self for chaining.
	 */
	public function on ( $name, $callback )
	{
		if ( ! isset( $this->_events[ $name ] ) ) {
			$this->_events[ $name ] = array();
		}

		$this->_events[ $name ][] = $callback;

		return $this;
	}


	/**
	 * Get / set the table name.
	 * 
	 * The table name designated which DB table Editor will use as its data
	 * source for working with the database. Table names can be given with an
	 * alias, which can be used to simplify larger table names. The field
	 * names would also need to reflect the alias, just like an SQL query. For
	 * example: `users as a`.
	 *
	 *  @param string|array $_,... Table names given as a single string, an array of
	 *    strings or multiple string parameters for the function.
	 *  @return string[]|self Array of tables names, or self if used as a setter.
	 */
	public function table ( $_=null )
	{
		if ( $_ !== null && !is_array($_) ) {
			$_ = func_get_args();
		}
		return $this->_getSet( $this->_table, $_, true );
	}


	/**
	 * Get / set transaction support.
	 *
	 * When enabled (which it is by default) Editor will use an SQL transaction
	 * to ensure data integrity while it is performing operations on the table.
	 * This can be optionally disabled using this method, if required by your
	 * database configuration.
	 *
	 *  @param boolean $_ Enable (`true`) or disabled (`false`) transactions.
	 *    If not given, then used as a getter.
	 *  @return boolean|self Transactions enabled flag, or self if used as a
	 *    setter.
	 */
	public function transaction ( $_=null )
	{
		return $this->_getSet( $this->_transaction, $_ );
	}


	/**
	 * Get / set the primary key.
	 *
	 * The primary key must be known to Editor so it will know which rows are being
	 * edited / deleted upon those actions. The default value is ['id'].
	 *
	 *  @param string|array $_ Primary key's name. If not given, then used as a
	 *    getter. An array of column names can be given to allow composite keys to
	 *    be used.
	 *  @return string|self Primary key value if no parameter is given, or
	 *    self if used as a setter.
	 */
	public function pkey ( $_=null )
	{
		if ( is_string( $_ ) ) {
			$this->_pkey = array( $_ );
			return $this;
		}
		return $this->_getSet( $this->_pkey, $_ );
	}


	/**
	 * Convert a primary key array of field values to a combined value.
	 *
	 * @param  string  $row   The row of data that the primary key value should
	 *   be extracted from.
	 * @param  boolean $flat  Flag to indicate if the given array is flat
	 *   (useful for `where` conditions) or nested for join tables.
	 * @return string The created primary key value.
	 * @throws \Exception If one of the values that the primary key is made up
	 *    of cannot be found in the data set given, an Exception will be thrown.
	 */
	public function pkeyToValue ( $row, $flat=false )
	{
		$pkey = $this->_pkey;
		$id = array();

		for ( $i=0, $ien=count($pkey) ; $i<$ien ; $i++ ) {
			$column = $pkey[ $i ];

			if ( $flat ) {
				if ( isset( $row[ $column ] ) ) {
					if ( $row[ $column ] === null ) {
						throw new \Exception("Primary key value is null.", 1);
					}
					$val = $row[ $column ];
				}
				else {
					$val = null;
				}
			}
			else {
				$val = $this->_readProp( $column, $row );
			}

			if ( $val === null ) {
				throw new \Exception("Primary key element is not available in data set.", 1);
			}

			$id[] = $val;
		}

		return implode( $this->_pkey_separator(), $id );
	}


	/**
	 * Convert a primary key combined value to an array of field values.
	 *
	 * @param  string  $value The id that should be split apart
	 * @param  boolean $flat  Flag to indicate if the returned array should be
	 *   flat (useful for `where` conditions) or nested for join tables.
	 * @param  string[] $pkey The primary key name - will use the instance value
	 *   if not given
	 * @return array          Array of field values that the id was made up of.
	 * @throws \Exception If the primary key value does not match the expected
	 *   length based on the primary key configuration, an exception will be
	 *   thrown.
	 */
	public function pkeyToArray ( $value, $flat=false, $pkey=null )
	{
		$arr = array();
		$value = str_replace( $this->idPrefix(), '', $value );
		$idParts = explode( $this->_pkey_separator(), $value );

		if ( $pkey === null ) {
			$pkey = $this->_pkey;
		}

		if ( count($pkey) !== count($idParts) ) {
			throw new \Exception("Primary key data doesn't match submitted data", 1);
		}

		for ( $i=0, $ien=count($idParts) ; $i<$ien ; $i++ ) {
			if ( $flat ) {
				$arr[ $pkey[$i] ] = $idParts[$i];
			}
			else {
				$this->_writeProp( $arr, $pkey[$i], $idParts[$i] );
			}
		}

		return $arr;
	}


	/**
	 * Process a request from the Editor client-side to get / set data.
	 *
	 *  @param array $data Typically $_POST or $_GET as required by what is sent
	 *  by Editor
	 *  @return self
	 */
	public function process ( $data )
	{
		if ( $this->_debug ) {
			$debugInfo = &$this->_debugInfo;
			$debugVal = $this->_db->debug( function ( $mess ) use ( &$debugInfo ) {
				$debugInfo[] = $mess;
			} );
		}

		if ( $this->_tryCatch ) {
			try {
				$this->_process( $data );
			}
			catch (\Exception $e) {
				// Error feedback
				$this->_out['error'] = $e->getMessage();
				
				if ( $this->_transaction ) {
					$this->_db->rollback();
				}
			}
		}
		else {
			$this->_process( $data );
		}

		if ( $this->_debug ) {
			$this->_out['debug'] = $this->_debugInfo;
			$this->_db->debug( false );
		}

		return $this;
	}


	/**
	 * Enable / try catch when `process()` is called. Disabling this can be
	 * useful for debugging, but is not recommended for production.
	 *
	 * @param  boolean $_ `true` to enable (default), otherwise false to disable
	 * @return boolean|Editor Value if used as a getter, otherwise `$this` when
	 *   used as a setter.
	 */
	public function tryCatch ( $_=null )
	{
		return $this->_getSet( $this->_tryCatch, $_ );
	}


	/**
	 * Perform validation on a data set.
	 *
	 * Note that validation is performed on data only when the action is
	 * `create` or `edit`. Additionally, validation is performed on the _wire
	 * data_ - i.e. that which is submitted from the client, without formatting.
	 * Any formatting required by `setFormatter` is performed after the data
	 * from the client has been validated.
	 *
	 *  @param &array $errors Output array to which field error information will
	 *      be written. Each element in the array represents a field in an error
	 *      condition. These elements are themselves arrays with two properties
	 *      set; `name` and `status`.
	 *  @param array $data The format data to check
	 *  @return boolean `true` if the data is valid, `false` if not.
	 */
	public function validate ( &$errors, $data )
	{
		// Validation is only performed on create and edit
		if ( $data['action'] != "create" && $data['action'] != "edit" ) {
			return true;
		}

		foreach( $data['data'] as $id => $values ) {
			for ( $i=0 ; $i<count($this->_fields) ; $i++ ) {
				$field = $this->_fields[$i];
				$validation = $field->validate( $values, $this,
					str_replace( $this->idPrefix(), '', $id )
				);

				if ( $validation !== true ) {
					$errors[] = array(
						"name" => $field->name(),
						"status" => $validation
					);
				}
			}

			// MJoin validation
			for ( $i=0 ; $i<count($this->_join) ; $i++ ) {
				$this->_join[$i]->validate( $errors, $this, $values );
			}
		}

		return count( $errors ) > 0 ? false : true;
	}


	/**
	 * Get / set a global validator that will be triggered for the create, edit
	 * and remove actions performed from the client-side.
	 *
	 * @param  [type] $_ Function to execute when validating the input data.
	 *   It is passed three parameters: 1. The editor instance, 2. The action
	 *   and 3. The values.
	 * @return [Editor|callback] Editor instance if called as a setter, or the
	 *   validator function if not.
	 */
	public function validator ( $_=null )
	{
		return $this->_getSet( $this->_validator, $_ );
	}


	/**
	 * Where condition to add to the query used to get data from the database.
	 * 
	 * Can be used in two different ways:
	 * 
	 * * Simple case: `where( field, value, operator )`
	 * * Complex: `where( fn )`
	 *
	 * The simple case is fairly self explanatory, a condition is applied to the
	 * data that looks like `field operator value` (e.g. `name = 'Allan'`). The
	 * complex case allows full control over the query conditions by providing a
	 * closure function that has access to the database Query that Editor is
	 * using, so you can use the `where()`, `or_where()`, `and_where()` and
	 * `where_group()` methods as you require.
	 *
	 * Please be very careful when using this method! If an edit made by a user
	 * using Editor removes the row from the where condition, the result is
	 * undefined (since Editor expects the row to still be available, but the
	 * condition removes it from the result set).
	 * 
	 * @param string|callable $key   Single field name or a closure function
	 * @param string          $value Single field value.
	 * @param string          $op    Condition operator: <, >, = etc
	 * @return string[]|self Where condition array, or self if used as a setter.
	 */
	public function where ( $key=null, $value=null, $op='=' )
	{
		if ( $key === null ) {
			return $this->_where;
		}

		if ( is_callable($key) && is_object($key) ) {
			$this->_where[] = $key;
		}
		else {
			$this->_where[] = array(
				"key"   => $key,
				"value" => $value,
				"op"    => $op
			);
		}

		return $this;
	}


	/**
	 * Get / set if the WHERE conditions should be included in the create and
	 * edit actions.
	 * 
	 *  @param boolean $_ Include (`true`), or not (`false`)
	 *  @return boolean Current value
	 *  @deprecated Note that `whereSet` is now deprecated and replaced with the
	 *    ability to set values for columns on create and edit. The C# libraries
	 *    do not support this option at all.
	 */
	public function whereSet ( $_=null )
	{
		return $this->_getSet( $this->_whereSet, $_ );
	}



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Private methods
	 */

	/**
	 * Process a request from the Editor client-side to get / set data.
	 *
	 *  @param array $data Data to process
	 *  @private
	 */
	private function _process( $data )
	{
		$this->_out = array(
			"fieldErrors" => array(),
			"error" => "",
			"data" => array(),
			"ipOpts" => array(),
			"cancelled" => array()
		);

		$this->_processData = $data;
		$this->_formData = isset($data['data']) ? $data['data'] : null;
		$validator = $this->_validator;

		if ( $this->_transaction ) {
			$this->_db->transaction();
		}

		$this->_prepJoin();

		if ( $validator ) {
			$ret = $validator( $this, !isset($data['action']) ? self::ACTION_READ : $data['action'], $data );

			if ( $ret ) {
				$this->_out['error'] = $ret;
			}
		}

		if ( ! $this->_out['error'] ) {
			if ( ! isset($data['action']) ) {
				/* Get data */
				$this->_out = array_merge( $this->_out, $this->_get( null, $data ) );
			}
			else if ( $data['action'] == "upload" ) {
				/* File upload */
				$this->_upload( $data );
			}
			else if ( $data['action'] == "remove" ) {
				/* Remove rows */
				$this->_remove( $data );
				$this->_fileClean();
			}
			else {
				/* Create or edit row */
				// Pre events so they can occur before the validation
				foreach ($data['data'] as $idSrc => &$values) {
					$cancel = null;

					if ( $data['action'] == 'create' ) {
						$cancel = $this->_trigger( 'preCreate', $values );
					}
					else {
						$id = str_replace( $this->_idPrefix, '', $idSrc );
						$cancel = $this->_trigger( 'preEdit', $id, $values );
					}

					// One of the event handlers returned false - don't continue
					if ( $cancel === false ) {
						// Remove the data from the data set so it won't be processed
						unset( $data['data'][$idSrc] );

						// Tell the client-side we aren't updating this row
						$this->_out['cancelled'][] = $idSrc;
					}
				}

				// Validation
				$valid = $this->validate( $this->_out['fieldErrors'], $data );

				if ( $valid ) {
					foreach ($data['data'] as $id => &$values) {
						$d = $data['action'] == "create" ?
							$this->_insert( $values ) :
							$this->_update( $id, $values );

						if ( $d !== null ) {
							$this->_out['data'][] = $d;
						}
					}
				}

				$this->_fileClean();
			}
		}

		if ( $this->_transaction ) {
			$this->_db->commit();
		}

		// Tidy up the reply
		if ( count( $this->_out['fieldErrors'] ) === 0 ) {
			unset( $this->_out['fieldErrors'] );
		}

		if ( $this->_out['error'] === '' ) {
			unset( $this->_out['error'] );
		}

		if ( count( $this->_out['ipOpts'] ) === 0 ) {
			unset( $this->_out['ipOpts'] );
		}

		if ( count( $this->_out['cancelled'] ) === 0 ) {
			unset( $this->_out['cancelled'] );
		}
	}


	/**
	 * Get an array of objects from the database to be given to DataTables as a
	 * result of an sAjaxSource request, such that DataTables can display the information
	 * from the DB in the table.
	 *
	 *  @param integer|string $id Primary key value to get an individual row
	 *    (after create or update operations). Gets the full set if not given.
	 *    If a compound key is being used, this should be the string
	 *    representation of it (i.e. joined together) rather than an array form.
	 *  @param array $http HTTP parameters from GET or POST request (so we can service
	 *    server-side processing requests from DataTables).
	 *  @return array DataTables get information
	 *  @throws \Exception Error on SQL execution
	 *  @private
	 */
	private function _get( $id=null, $http=null )
	{

		$cancel = $this->_trigger( 'preGet', $id );
		if ( $cancel === false ) {
			return array();
		}

		$query = $this->_db
			->query('select')
			->table( $this->_table )
			->get( $this->_pkey );

		// Add all fields that we need to get from the database
		foreach ($this->_fields as $field) {
			// Don't reselect a pkey column if it was already added
			if ( in_array( $field->dbField(), $this->_pkey ) ) {
				continue;
			}

			if ( $field->apply('get') && $field->getValue() === null ) {
				$query->get( $field->dbField() );
			}
		}

		$this->_get_where( $query );
		$this->_perform_left_join( $query );
		$ssp = $this->_ssp_query( $query, $http );

		if ( $id !== null ) {
			$query->where( $this->pkeyToArray( $id, true ) );
		}

		$res = $query->exec();
		if ( ! $res ) {
			throw new \Exception('Error executing SQL for data get. Enable SQL debug using `->debug(true)`');
		}

		$out = array();
		while ( $row=$res->fetch() ) {
			$inner = array();
			$inner['DT_RowId'] = $this->_idPrefix . $this->pkeyToValue( $row, true );

			foreach ($this->_fields as $field) {
				if ( $field->apply('get') ) {
					$field->write( $inner, $row );
				}
			}

			$out[] = $inner;
		}

		// Field options
		$options = array();

		if ( $id === null ) {
			foreach ($this->_fields as $field) {
				$opts = $field->optionsExec( $this->_db );

				if ( $opts !== false ) {
					$options[ $field->name() ] = $opts;
				}
			}
		}

		// Row based "joins"
		for ( $i=0 ; $i<count($this->_join) ; $i++ ) {
			$this->_join[$i]->data( $this, $out, $options );
		}

		$this->_trigger( 'postGet', $out, $id );

		return array_merge(
			array(
				'data'    => $out,
				'options' => $options,
				'files'   => $this->_fileData()
			),
			$ssp
		);
	}


	/**
	 * Insert a new row in the database
	 *  @private
	 */
	private function _insert( $values )
	{
		// Only allow a composite insert if the values for the key are
		// submitted. This is required because there is no reliable way in MySQL
		// to return the newly inserted row, so we can't know any newly
		// generated values.
		$this->_pkey_validate_insert( $values );

		// Insert the new row
		$id = $this->_insert_or_update( null, $values );

		if ( $id === null ) {
			return null;
		}

		// Was the primary key altered as part of the edit, if so use the
		// submitted values
		$id = count( $this->_pkey ) > 1 ?
			$this->pkeyToValue( $values ) :
			$this->_pkey_submit_merge( $id, $values );

		// Join tables
		for ( $i=0 ; $i<count($this->_join) ; $i++ ) {
			$this->_join[$i]->create( $this, $id, $values );
		}

		$this->_trigger( 'writeCreate', $id, $values );

		// Full data set for the created row
		$row = $this->_get( $id );
		$row = count( $row['data'] ) > 0 ?
			$row['data'][0] :
			null;

		$this->_trigger( 'postCreate', $id, $values, $row );

		return $row;
	}


	/**
	 * Update a row in the database
	 *  @param string $id The DOM ID for the row that is being edited.
	 *  @return array Row's data
	 *  @private
	 */
	private function _update( $id, $values )
	{
		$id = str_replace( $this->_idPrefix, '', $id );

		// Update or insert the rows for the parent table and the left joined
		// tables
		$this->_insert_or_update( $id, $values );

		// And the join tables
		for ( $i=0 ; $i<count($this->_join) ; $i++ ) {
			$this->_join[$i]->update( $this, $id, $values );
		}

		// Was the primary key altered as part of the edit, if so use the
		// submitted values
		$getId = $this->_pkey_submit_merge( $id, $values );

		$this->_trigger( 'writeEdit', $id, $values );

		// Full data set for the modified row
		$row = $this->_get( $getId );
		$row = count( $row['data'] ) > 0 ?
			$row['data'][0] :
			null;

		$this->_trigger( 'postEdit', $id, $values, $row );

		return $row;
	}


	/**
	 * Delete one or more rows from the database
	 *  @private
	 */
	private function _remove( $data )
	{
		$ids = array();

		// Get the ids to delete from the data source
		foreach ($data['data'] as $idSrc => $rowData) {
			// Strip the ID prefix that the client-side sends back
			$id = str_replace( $this->_idPrefix, "", $idSrc );

			$res = $this->_trigger( 'preRemove', $id, $rowData );

			// Allow the event to be cancelled and inform the client-side
			if ( $res === false ) {
				$this->_out['cancelled'][] = $idSrc;
			}
			else {
				$ids[] = $id;
			}
		}

		if ( count( $ids ) === 0 ) {
			return;
		}

		// Row based joins - remove first as the host row will be removed which
        // is a dependency
		for ( $i=0 ; $i<count($this->_join) ; $i++ ) {
			$this->_join[$i]->remove( $this, $ids );
		}

		// Remove from the left join tables
		for ( $i=0, $ien=count($this->_leftJoin) ; $i<$ien ; $i++ ) {
			$join = $this->_leftJoin[$i];
			$table = $this->_alias( $join['table'], 'orig' );

			// which side of the join refers to the parent table?
			if ( strpos( $join['field1'], $join['table'] ) === 0 ) {
				$parentLink = $join['field2'];
				$childLink = $join['field1'];
			}
			else {
				$parentLink = $join['field1'];
				$childLink = $join['field2'];
			}

			// Only delete on the primary key, since that is what the ids refer
			// to - otherwise we'd be deleting random data! Note that this
			// won't work with compound keys since the parent link would be
			// over multiple fields.
			if ( $parentLink === $this->_pkey[0] && count($this->_pkey) === 1 ) {
				$this->_remove_table( $join['table'], $ids, array($childLink) );
			}
		}

		// Remove from the primary tables
		for ( $i=0, $ien=count($this->_table) ; $i<$ien ; $i++ ) {
			$this->_remove_table( $this->_table[$i], $ids );
		}

		foreach ($data['data'] as $idSrc => $rowData) {
			$id = str_replace( $this->_idPrefix, "", $idSrc );

			$this->_trigger( 'postRemove', $id, $rowData );
		}
	}


	/**
	 * File upload
	 *  @param array $data Upload data
	 *  @throws \Exception File upload name error
	 *  @private
	 */
	private function _upload( $data )
	{
		// Search for upload field in local fields
		$field = $this->_find_field( $data['uploadField'], 'name' );
		$fieldName = '';

		if ( ! $field ) {
			// Perhaps it is in a join instance
			for ( $i=0 ; $i<count($this->_join) ; $i++ ) {
				$join = $this->_join[$i];
				$fields = $join->fields();

				for ( $j=0, $jen=count($fields) ; $j<$jen ; $j++ ) {
					$joinField = $fields[ $j ];
					$name = $join->name().'[].'.$joinField->name();

					if ( $name === $data['uploadField'] ) {
						$field = $joinField;
						$fieldName = $name;
					}
				}
			}
		}
		else {
			$fieldName = $field->name();
		}

		if ( ! $field ) {
			throw new \Exception("Unknown upload field name submitted");
		}

		$res = $this->_trigger( 'preUpload', $data );
		
		// Allow the event to be cancelled and inform the client-side
		if ( $res === false ) {
			return;
		}

		$upload = $field->upload();
		if ( ! $upload ) {
			throw new \Exception("File uploaded to a field that does not have upload options configured");
		}

		$res = $upload->exec( $this );

		if ( $res === false ) {
			$this->_out['fieldErrors'][] = array(
				"name"   => $fieldName,      // field name can be just the field's
				"status" => $upload->error() // name or a join combination
			);
		}
		else {
			$files = $this->_fileData( $upload->table(), $res );

			$this->_out['files'] = $files;
			$this->_out['upload']['id'] = $res;
		
			$this->_trigger( 'postUpload', $res, $files, $data );
		}
	}


	/**
	 * Get information about the files that are detailed in the database for
	 * the fields which have an upload method defined on them.
	 *
	 * @param  string [$limitTable=null] Limit the data gathering to a single
	 *     table only
	 * @param number [$id=null] Limit to a specific id
	 * @return array File information
	 * @private
	 */
	private function _fileData ( $limitTable=null, $id=null )
	{
		$files = array();

		// The fields in this instance
		$this->_fileDataFields( $files, $this->_fields, $limitTable, $id );
		
		// From joined tables
		for ( $i=0 ; $i<count($this->_join) ; $i++ ) {
			$this->_fileDataFields( $files, $this->_join[$i]->fields(), $limitTable, $id );
		}

		return $files;
	}


	/**
	 * Common file get method for any array of fields
	 * @param  array &$files File output array
	 * @param  Field[] $fields Fields to get file information about
	 * @param  string $limitTable Limit the data gathering to a single table
	 *     only
	 * @private
	 */
	private function _fileDataFields ( &$files, $fields, $limitTable, $id=null )
	{
		foreach ($fields as $field) {
			$upload = $field->upload();

			if ( $upload ) {
				$table = $upload->table();

				if ( ! $table ) {
					continue;
				}

				if ( $limitTable !== null && $table !== $limitTable ) {
					continue;
				}

				if ( isset( $files[ $table ] ) ) {
					continue;
				}

				$fileData = $upload->data( $this->_db, $id );

				if ( $fileData !== null ) {
					$files[ $table ] = $fileData;
				}
			}
		}
	}

	/**
	 * Run the file clean up
	 *
	 * @private
	 */
	private function _fileClean ()
	{
		foreach ( $this->_fields as $field ) {
			$upload = $field->upload();

			if ( $upload ) {
				$upload->dbCleanExec( $this, $field );
			}
		}

		for ( $i=0 ; $i<count($this->_join) ; $i++ ) {
			foreach ( $this->_join[$i]->fields() as $field ) {
				$upload = $field->upload();

				if ( $upload ) {
					$upload->dbCleanExec( $this, $field );
				}
			}
		}
	}


	/*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
	 * Server-side processing methods
	 */

	/**
	 * When server-side processing is being used, modify the query with // the
     * required extra conditions
	 *
	 *  @param \DataTables\Database\Query $query Query instance to apply the SSP commands to
	 *  @param array $http Parameters from HTTP request
	 *  @return array Server-side processing information array
	 *  @private
	 */
	private function _ssp_query ( $query, $http )
	{
		if ( ! isset( $http['draw'] ) ) {
			return array();
		}

		// Add the server-side processing conditions
		$this->_ssp_limit( $query, $http );
		$this->_ssp_sort( $query, $http );
		$this->_ssp_filter( $query, $http );

		// Get the number of rows in the result set
		$ssp_set_count = $this->_db
			->query('select')
			->table( $this->_table )
			->get( 'COUNT('.$this->_pkey[0].') as cnt' );
		$this->_get_where( $ssp_set_count );
		$this->_ssp_filter( $ssp_set_count, $http );
		$this->_perform_left_join( $ssp_set_count );
		$ssp_set_count = $ssp_set_count->exec()->fetch();

		// Get the number of rows in the full set
		$ssp_full_count = $this->_db
			->query('select')
			->table( $this->_table )
			->get( 'COUNT('.$this->_pkey[0].') as cnt' );
		$this->_get_where( $ssp_full_count );
		if ( count( $this->_where ) ) { // only needed if there is a where condition
			$this->_perform_left_join( $ssp_full_count );
		}
		$ssp_full_count = $ssp_full_count->exec()->fetch();

		return array(
			"draw" => intval( $http['draw'] ),
			"recordsTotal" => $ssp_full_count['cnt'],
			"recordsFiltered" => $ssp_set_count['cnt']
		);
	}


	/**
	 * Convert a column index to a database field name - used for server-side
	 * processing requests.
	 *  @param array $http HTTP variables (i.e. GET or POST)
	 *  @param int $index Index in the DataTables' submitted data
	 *  @returns string DB field name
	 *  @throws \Exception Unknown fields
	 *  @private Note that it is actually public for PHP 5.3 - thread 39810
	 */
	public function _ssp_field( $http, $index )
	{
		$name = $http['columns'][$index]['data'];
		$field = $this->_find_field( $name, 'name' );

		if ( ! $field ) {
			// Is it the primary key?
			if ( $name === 'DT_RowId' ) {
				return $this->_pkey[0];
			}

			throw new \Exception('Unknown field: '.$name .' (index '.$index.')');
		}

		return $field->dbField();
	}


	/**
	 * Sorting requirements to a server-side processing query.
	 *  @param \DataTables\Database\Query $query Query instance to apply sorting to
	 *  @param array $http HTTP variables (i.e. GET or POST)
	 *  @private
	 */
	private function _ssp_sort ( $query, $http )
	{
		for ( $i=0 ; $i<count($http['order']) ; $i++ ) {
			$order = $http['order'][$i];

			$query->order(
				$this->_ssp_field( $http, $order['column'] ) .' '.
				($order['dir']==='asc' ? 'asc' : 'desc')
			);
		}
	}


	/**
	 * Add DataTables' 'where' condition to a server-side processing query. This
	 * works for both global and individual column filtering.
	 *  @param \DataTables\Database\Query $query Query instance to apply the WHERE conditions to
	 *  @param array $http HTTP variables (i.e. GET or POST)
	 *  @private
	 */
	private function _ssp_filter ( $query, $http )
	{
		$that = $this;

		// Global filter
		$fields = $this->_fields;

		// Global search, add a ( ... or ... ) set of filters for each column
		// in the table (not the fields, just the columns submitted)
		if ( $http['search']['value'] ) {
			$query->where( function ($q) use (&$that, &$fields, $http) {
				for ( $i=0 ; $i<count($http['columns']) ; $i++ ) {
					if ( $http['columns'][$i]['searchable'] == 'true' ) {
						$field = $that->_ssp_field( $http, $i );

						if ( $field ) {
							$q->or_where( $field, '%'.$http['search']['value'].'%', 'like' );
						}
					}
				}
			} );
		}

		// if ( $http['search']['value'] ) {
		// 	$words = explode(" ", $http['search']['value']);

		// 	$query->where( function ($q) use (&$that, &$fields, $http, $words) {
		// 		for ( $j=0, $jen=count($words) ; $j<$jen ; $j++ ) {
		// 			if ( $words[$j] ) {
		// 				$q->where_group( true );

		// 				for ( $i=0, $ien=count($http['columns']) ; $i<$ien ; $i++ ) {
		// 					if ( $http['columns'][$i]['searchable'] == 'true' ) {
		// 						$field = $that->_ssp_field( $http, $i );

		// 						$q->or_where( $field, $words[$j].'%', 'like' );
		// 						$q->or_where( $field, '% '.$words[$j].'%', 'like' );
		// 					}
		// 				}

		// 				$q->where_group( false );
		// 			}
		// 		}
		// 	} );
		// }

		// Column filters
		for ( $i=0, $ien=count($http['columns']) ; $i<$ien ; $i++ ) {
			$column = $http['columns'][$i];
			$search = $column['search']['value'];

			if ( $search !== '' && $column['searchable'] == 'true' ) {
				$query->where( $this->_ssp_field( $http, $i ), '%'.$search.'%', 'like' );
			}
		}
	}


	/**
	 * Add a limit / offset to a server-side processing query
	 *  @param \DataTables\Database\Query $query Query instance to apply the offset / limit to
	 *  @param array $http HTTP variables (i.e. GET or POST)
	 *  @private
	 */
	private function _ssp_limit ( $query, $http )
	{
		if ( $http['length'] != -1 ) { // -1 is 'show all' in DataTables
			$query
				->offset( $http['start'] )
				->limit( $http['length'] );
		}
	}


	/*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *
	 * Internal helper methods
	 */

	/**
	 * Add left join commands for the instance to a query.
	 *
	 *  @param \DataTables\Database\Query $query Query instance to apply the joins to
	 *  @private
	 */
	private function _perform_left_join ( $query )
	{
		if ( count($this->_leftJoin) ) {
			for ( $i=0, $ien=count($this->_leftJoin) ; $i<$ien ; $i++ ) {
				$join = $this->_leftJoin[$i];

				$query->join( $join['table'], $join['field1'].' '.$join['operator'].' '.$join['field2'], 'LEFT' );
			}
		}
	}


	/**
	 * Add local WHERE condition to query
	 *  @param \DataTables\Database\Query $query Query instance to apply the WHERE conditions to
	 *  @private
	 */
	private function _get_where ( $query )
	{
		for ( $i=0 ; $i<count($this->_where) ; $i++ ) {
			if ( is_callable( $this->_where[$i] ) ) {
				$this->_where[$i]( $query );
			}
			else {
				$query->where(
					$this->_where[$i]['key'],
					$this->_where[$i]['value'],
					$this->_where[$i]['op']
				);
			}
		}
	}


	/**
	 * Get a field instance from a known field name
	 *
	 *  @param string $name Field name
	 *  @param string $type Matching name type
	 *  @return Field Field instance
	 *  @private
	 */
	private function _find_field ( $name, $type )
	{
		for ( $i=0, $ien=count($this->_fields) ; $i<$ien ; $i++ ) {
			$field = $this->_fields[ $i ];

			if ( $type === 'name' && $field->name() === $name ) {
				return $field;
			}
			else if ( $type === 'db' && $field->dbField() === $name ) {
				return $field;
			}
		}

		return null;
	}


	/**
	 * Insert or update a row for all main tables and left joined tables.
	 *
	 *  @param int|string $id ID to use to condition the update. If null is
	 *      given, the first query performed is an insert and the inserted id
	 *      used as the value should there be any subsequent tables to operate
	 *      on. Mote that for compound keys, this should be the "joined" value
	 *      (i.e. a single string rather than an array).
	 *  @return \DataTables\Database\Result Result from the query or null if no
	 *      query performed.
	 *  @private
	 */
	private function _insert_or_update ( $id, $values )
	{
		// Loop over all tables in _table, doing the insert or update as needed
		for ( $i=0, $ien=count( $this->_table ) ; $i<$ien ; $i++ ) {
			$res = $this->_insert_or_update_table(
				$this->_table[$i],
				$values,
				$id !== null ?
					$this->pkeyToArray( $id, true ) :
					null
			);

			// If we don't have an id yet, then the first insert will return
			// the id we want
			if ( $res !== null && $id === null ) {
				$id = $res->insertId();
			}
		}

		// And for the left join tables as well
		for ( $i=0, $ien=count( $this->_leftJoin ) ; $i<$ien ; $i++ ) {
			$join = $this->_leftJoin[$i];

			// which side of the join refers to the parent table?
			$joinTable = $this->_alias( $join['table'], 'alias' );
			$tablePart = $this->_part( $join['field1'] );

			if ( $this->_part( $join['field1'], 'db' ) ) {
				$tablePart = $this->_part( $join['field1'], 'db' ).'.'.$tablePart;
			}

			if ( $tablePart === $joinTable ) {
				$parentLink = $join['field2'];
				$childLink = $join['field1'];
			}
			else {
				$parentLink = $join['field1'];
				$childLink = $join['field2'];
			}

			if ( $parentLink === $this->_pkey[0] && count($this->_pkey) === 1 ) {
				$whereVal = $id;
			}
			else {
				// We need submitted information about the joined data to be
				// submitted as well as the new value. We first check if the
				// host field was submitted
				$field = $this->_find_field( $parentLink, 'db' );

				if ( ! $field || ! $field->apply( 'set', $values ) ) {
					// If not, then check if the child id was submitted
					$field = $this->_find_field( $childLink, 'db' );

					// No data available, so we can't do anything
					if ( ! $field || ! $field->apply( 'set', $values ) ) {
						continue;
					}
				}

				$whereVal = $field->val('set', $values);
			}

			$whereName = $this->_part( $childLink, 'field' );

			$this->_insert_or_update_table(
				$join['table'],
				$values,
				array( $whereName => $whereVal )
			);
		}

		return $id;
	}


	/**
	 * Insert or update a row in a single database table, based on the data
	 * given and the fields configured for the instance.
	 *
	 * The function will find the fields which are required for this specific
	 * table, based on the names of fields and use only the appropriate data for
	 * this table. Therefore the full submitted data set can be passed in.
	 *
	 *  @param string $table Database table name to use (can include an alias)
	 *  @param array $where Update condition
	 *  @return \DataTables\Database\Result Result from the query or null if no query
	 *      performed.
	 *  @throws \Exception Where set error
	 *  @private
	 */
	private function _insert_or_update_table ( $table, $values, $where=null )
	{
		$set = array();
		$action = ($where === null) ? 'create' : 'edit';
		$tableAlias = $this->_alias( $table, 'alias' );

		for ( $i=0 ; $i<count($this->_fields) ; $i++ ) {
			$field = $this->_fields[$i];
			$tablePart = $this->_part( $field->dbField() );

			if ( $this->_part( $field->dbField(), 'db' ) ) {
				$tablePart = $this->_part( $field->dbField(), 'db' ).'.'.$tablePart;
			}

			// Does this field apply to this table (only check when a join is
			// being used)
			if ( count($this->_leftJoin) && $tablePart !== $tableAlias ) {
				continue;
			}

			// Check if this field should be set, based on options and
			// submitted data
			if ( ! $field->apply( $action, $values ) ) {
				continue;
			}

			// Some db's (specifically postgres) don't like having the table
			// name prefixing the column name. Todo: it might be nicer to have
			// the db layer abstract this out?
			$fieldPart = $this->_part( $field->dbField(), 'field' );
			$set[ $fieldPart ] = $field->val( 'set', $values );
		}

		// Add where fields if setting where values and required for this
		// table
		// Note that `whereSet` is now deprecated
		if ( $this->_whereSet ) {
			for ( $j=0, $jen=count($this->_where) ; $j<$jen ; $j++ ) {
				$cond = $this->_where[$j];

				if ( ! is_callable( $cond ) ) {
					// Make sure the value wasn't in the submitted data set,
					// otherwise we would be overwriting it
					if ( ! isset( $set[ $cond['key'] ] ) )
					{
						$whereTablePart = $this->_part( $cond['key'], 'table' );

						// No table part on the where condition to match against
						// or table operating on matches table part from cond.
						if ( ! $whereTablePart || $tableAlias == $whereTablePart ) {
							$set[ $cond['key'] ] = $cond['value'];
						}
					}
					else {
						throw new \Exception( 'Where condition used as a setter, '.
							'but value submitted for field: '.$cond['key']
						);
					}
				}
			}
		}

		// If nothing to do, then do nothing!
		if ( ! count( $set ) ) {
			return null;
		}

		// Insert or update
		if ( $action === 'create' ) {
			return $this->_db->insert( $table, $set, $this->_pkey );
		}
		else {
			return $this->_db->push( $table, $set, $where, $this->_pkey );
		}
	}


	/**
	 * Delete one or more rows from the database for an individual table
	 *
	 * @param string $table Database table name to use
	 * @param array $ids Array of ids to remove
	 * @param string $pkey Database column name to match the ids on for the
	 *   delete condition. If not given the instance's base primary key is
	 *   used.
	 * @private
	 */
	private function _remove_table ( $table, $ids, $pkey=null )
	{
		if ( $pkey === null ) {
			$pkey = $this->_pkey;
		}

		// Check there is a field which has a set option for this table
		$count = 0;

		foreach ($this->_fields as $field) {
			if ( strpos( $field->dbField(), '.') === false || (
					$this->_part( $field->dbField(), 'table' ) === $table &&
					$field->set() !== Field::SET_NONE
				)
			) {
				$count++;
			}
		}

		if ( $count > 0 ) {
			$q = $this->_db
				->query( 'delete' )
				->table( $table );

			for ( $i=0, $ien=count($ids) ; $i<$ien ; $i++ ) {
				$cond = $this->pkeyToArray( $ids[$i], true, $pkey );

				$q->or_where( function ($q2) use ($cond) {
					$q2->where( $cond );
				} );
			}

			$q->exec();
		}
	}


	/**
	 * Check the validity of the set options if  we are doing a join, since
	 * there are some conditions for this state. Will throw an error if not
	 * valid.
	 *
	 *  @private
	 */
	private function _prepJoin ()
	{
		if ( count( $this->_leftJoin ) === 0 ) {
			return;
		}

		// Check if the primary key has a table identifier - if not - add one
		for ( $i=0, $ien=count($this->_pkey) ; $i<$ien ; $i++ ) {
			$val = $this->_pkey[$i];

			if ( strpos( $val, '.' ) === false ) {
				$this->_pkey[$i] = $this->_alias( $this->_table[0], 'alias' ).'.'.$val;
			}
		}

		// Check that all fields have a table selector, otherwise, we'd need to
		// know the structure of the tables, to know which fields belong in
		// which. This extra requirement on the fields removes that
		for ( $i=0, $ien=count($this->_fields) ; $i<$ien ; $i++ ) {
			$field = $this->_fields[$i];
			$name = $field->dbField();

			if ( strpos( $name, '.' ) === false ) {
				throw new \Exception( 'Table part of the field "'.$name.'" was not found. '.
					'In Editor instances that use a join, all fields must have the '.
					'database table set explicitly.'
				);
			}
		}
	}


	/**
	 * Get one side or the other of an aliased SQL field name.
	 *
	 *  @param string $name SQL field
	 *  @param string $type Which part to get: `alias` (default) or `orig`.
	 *  @returns string Alias
	 *  @private
	 */
	private function _alias ( $name, $type='alias' )
	{
		if ( stripos( $name, ' as ' ) !== false ) {
			$a = preg_split( '/ as /i', $name );
			return $type === 'alias' ?
				$a[1] :
				$a[0];
		}

		if ( stripos( $name, ' ' ) !== false ) {
			$a = preg_split( '/ /i', $name );
			return $type === 'alias' ?
				$a[1] :
				$a[0];
		}

		return $name;
	}


	/**
	 * Get part of an SQL field definition regardless of how deeply defined it
	 * is
	 *
	 *  @param string $name SQL field
	 *  @param string $type Which part to get: `table` (default) or `db` or
	 *      `column`
	 *  @return string Part name
	 *  @private
	 */
	private function _part ( $name, $type='table' )
	{
		$db = null;
		$table = null;
		$column = null;

		if ( strpos( $name, '.' ) !== false ) {
			$a = explode( '.', $name );

			if ( count($a) === 3 ) {
				$db = $a[0];
				$table = $a[1];
				$column = $a[2];
			}
			else if ( count($a) === 2 ) {
				$table = $a[0];
				$column = $a[1];
			}
		}
		else {
			$column = $name;
		}

		if ( $type === 'db' ) {
			return $db;
		}
		else if ( $type === 'table' ) {
			return $table;
		}
		return $column;
	}


	/**
	 * Trigger an event
	 * 
	 * @private
	 */
	private function _trigger ( $eventName, &$arg1=null, &$arg2=null, &$arg3=null, &$arg4=null, &$arg5=null )
	{
		$out = null;
		$argc = func_num_args();
		$args = array( $this );

		// Hack to enable pass by reference with a "variable" number of parameters
		for ( $i=1 ; $i<$argc ; $i++ ) {
			$name = 'arg'.$i;
			$args[] = &$$name;
		}

		if ( ! isset( $this->_events[ $eventName ] ) ) {
			return;
		}

		$events = $this->_events[ $eventName ];

		for ( $i=0, $ien=count($events) ; $i<$ien ; $i++ ) {
			$res = call_user_func_array( $events[$i], $args );

			if ( $res !== null ) {
				$out = $res;
			}
		}

		return $out;
	}


	/**
	 * Merge a primary key value with an updated data source.
	 *
	 * @param  string $pkeyVal Old primary key value to merge into
	 * @param  array  $row     Data source for update
	 * @return string          Merged value
	 */
	private function _pkey_submit_merge ( $pkeyVal, $row )
	{
		$pkey = $this->_pkey;
		$arr = $this->pkeyToArray( $pkeyVal, true );

		for ( $i=0, $ien=count($pkey) ; $i<$ien ; $i++ ) {
			$column = $pkey[ $i ];
			$field = $this->_find_field( $column, 'db' );

			if ( $field && $field->apply( 'edit', $row ) ) {
				$arr[ $column ] = $field->val( 'set', $row );
			}
		}

		return $this->pkeyToValue( $arr, true );
	}


	/**
	 * Validate that all primary key fields have values for create.
	 *
	 * @param  array $row Row's data
	 * @return boolean    `true` if valid, `false` otherwise
	 */
	private function _pkey_validate_insert ( $row )
	{
		$pkey = $this->_pkey;

		if ( count( $pkey ) === 1 ) {
			return true;
		}

		for ( $i=0, $ien=count($pkey) ; $i<$ien ; $i++ ) {
			$column = $pkey[ $i ];
			$field = $this->_find_field( $column, 'db' );

			if ( ! $field || ! $field->apply("create", $row) ) {
				throw new \Exception( "When inserting into a compound key table, ".
					"all fields that are part of the compound key must be ".
					"submitted with a specific value.", 1
				);
			}
		}

		return true;
	}


	/**
	 * Create the separator value for a compound primary key.
	 *
	 * @return string Calculated separator
	 */
	private function _pkey_separator ()
	{
		$str = implode(',', $this->_pkey);

		return hash( 'crc32', $str );
	}
}

