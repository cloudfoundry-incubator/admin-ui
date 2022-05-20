<?php if (!defined('DATATABLES')) exit(); // Ensure being used in DataTables env.

/*
 * DB connection script for Editor
 * Created by http://editor.datatables.net/generator
 */

// Enable error reporting for debugging (remove for production)
error_reporting(E_ALL);
ini_set('display_errors', '1');

/*
 * Edit the following with your database connection options
 */
$sql_details = array(
	"type" => "Postgres",
	"user" => "sa",
	"pass" => "Pa55word123.",
	"host" => "localhost",
	"port" => "5432",
	"db"   => "test",
	"dsn"  => ""
);
