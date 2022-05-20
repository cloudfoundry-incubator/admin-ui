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


//
// Configuration
//   Load the database connection configuration options
//
if ( ! isset( $sql_details ) ) {
	include( dirname(__FILE__).'/config.php' );
}


//
// Auto-loader
//   Automatically loads DataTables classes - they are psr-4 compliant
//
spl_autoload_register( function ($class) {
	$a = explode("\\", $class);

	// Are we working in the DataTables namespace
	if ( $a[0] !== "DataTables" ) {
		return;
	}

	array_shift( $a );
	$className = array_pop( $a );
	$path = count( $a ) ?
		implode('/', $a).'/' :
		'';

	require( dirname(__FILE__).'/'.$path.$className.'.php' );
} );


//
// Database connection
//   Database connection is globally available
//
$db = new Database( $sql_details );

