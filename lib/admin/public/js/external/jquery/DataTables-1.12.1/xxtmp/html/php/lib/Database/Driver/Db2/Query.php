<?php
/**
 * DB2 database driver for DataTables libraries.
 * BETA! Feedback welcome
 */

namespace DataTables\Database;
if (!defined('DATATABLES')) exit();

use DataTables\Database\Query;
use DataTables\Database\DriverDb2Result;

/**
 * DB2 driver for DataTables Database Query class
 *  @internal
 */
class DriverDb2Query extends Query {
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Private properties
	 */
	private $_stmt;

	private $_editor_pkey_value;

	private $_sql;

	protected $_identifier_limiter = null;

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
		}

		$connStr = 'DATABASE='.$db.';HOSTNAME='.$host;
		if ( $port ) {
			$connStr .= ';PORT='.$port;
		}
		$connStr .= ';UID='.$user.';PWD='.$pass.';AUTHENTICATION=server';

//$conn = db2_connect( 'DATABASE=SAMPLE;HOSTNAME=localhost;PORT=50000;UID=db2inst1;PWD=mylifehasbeen;AUTHENTICATION=server', 'db2inst1', 'mylifehasbeen' );


		$conn = db2_connect($connStr, $user, $pass);

		if ( ! $conn ) {
			// If we can't establish a DB connection then we returna DataTables
			// error.
			$e = 'Connection failed: '.db2_conn_error().' : '.db2_conn_errormsg();

			echo json_encode( array(
				"error" => "An error occurred while connecting to the database ".
					"'{$db}'. The error reported by the server was: ".$e
			) );
			exit(0);
		}

		return $conn;
	}

	public static function transaction ( $conn )
	{
	    // no op
	}

	public static function commit ( $conn )
	{
	   // no op
	}

	public static function rollback ( $conn )
	{
	   // no op
	}


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Protected methods
 */

 protected function _prepare($sql)
    {
		$this->_sql = $sql;
    }

    protected function _exec()
    {
        $resource = $this->database()->resource();
		$bindings = $this->_bindings;

		$paramSql = preg_replace('/(:[a-zA-Z\-_0-9]*)/', '?', $this->_sql);
		//echo $paramSql."\n";
		$this->_stmt = db2_prepare($resource, $paramSql);
		$stmt = $this->_stmt;

		//echo $this->_sql."\n";
		
		preg_match_all('/(:[a-zA-Z\-_0-9]*)/', $this->_sql, $matches);
		
		//print_r( $matches );
		//print_r( $bindings);

		//$allanTest = 65;
		//db2_bind_param( $stmt, 1, 'allanTest', DB2_PARAM_IN );

		for ( $i=0, $ien=count($matches[0]) ; $i<$ien ; $i++ ) {
			for ( $j=0, $jen=count($bindings) ; $j<$jen ; $j++ ) {
				if ( $bindings[$j]['name'] === $matches[0][$i] ) {
					$name = str_replace(':', '', $matches[0][$i]);
					$$name = $bindings[$j]['value'];
					//$_GLOBALS[ $name ] = $bindings[$j]['value'];

					//echo "bind $name as ".$$name."\n";

					db2_bind_param( $stmt, $i+1, $name, DB2_PARAM_IN );
				}
			}
		}

		//print_r( get_defined_vars() );

        $res = db2_execute($stmt);

        if (! $res) {
			throw 'DB2 SQL error = '.db2_stmt_error($this->_stmt);

            return false;
        }

        $resource = $this->database()->resource();
        return new DriverDb2Result($resource, $this->_stmt, $this->_editor_pkey_value);
    }

    protected function _build_table()
    {
        $out = array();

        for ($i = 0, $ien = count($this->_table); $i < $ien; $i ++) {
            $t = $this->_table[$i];

            if (strpos($t, ' as ')) {
                $a = explode(' as ', $t);
                $out[] = $a[0] . ' ' . $a[1];
            } else {
                $out[] = $t;
            }
        }

        return ' ' . implode(', ', $out) . ' ';
    }
}
