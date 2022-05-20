<?php

/*
 * Editor server script for DB table Person
 * Created by http://editor.datatables.net/generator
 */

// DataTables PHP library and database connection
include( "lib/DataTables.php" );

// Alias Editor classes so they are easy to use
use
	DataTables\Editor,
	DataTables\Editor\Field,
	DataTables\Editor\Format,
	DataTables\Editor\Mjoin,
	DataTables\Editor\Options,
	DataTables\Editor\Upload,
	DataTables\Editor\Validate,
	DataTables\Editor\ValidateOptions;

// The following statement can be removed after the first run (i.e. the database
// table has been created). It is a good idea to do this to help improve
// performance.
$db->sql( "CREATE TABLE IF NOT EXISTS \"Person\" (
	\"id\" serial,
	\"name\" text,
	\"dob\" date,
	\"gender\" integer,
	PRIMARY KEY( id )
);" );

// Build our Editor instance and process the data coming from _POST
Editor::inst( $db, 'Person', 'id' )
	->fields(
		Field::inst( 'Person.name' ),
		Field::inst( 'Person.dob' )
			->validator( Validate::dateFormat( 'd-m-y' ) )
			->getFormatter( Format::dateSqlToFormat( 'd-m-y' ) )
			->setFormatter( Format::dateFormatToSql( 'd-m-y' ) ),
		Field::inst( 'Person.gender' )
		    ->validator( Validate::dbValues(null, 'id', 'Gender') ),
		Field::inst( 'Gender.sex' )
	)
	->leftJoin('Gender', 'Gender.id', '=', 'Person.gender' )
	->process( $_POST )
	->json();
