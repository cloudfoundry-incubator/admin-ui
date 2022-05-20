<?php
/**
 * DataTables PHP libraries.
 *
 * PHP libraries for DataTables and DataTables Editor, utilising PHP 5.3+.
 *
 *  @author    SpryMedia
 *  @copyright 2016 SpryMedia ( http://sprymedia.co.uk )
 *  @license   http://editor.datatables.net/license DataTables Editor
 *  @link      http://editor.datatables.net
 */

namespace DataTables\Editor;
if (!defined('DATATABLES')) exit();

use DataTables;

/**
 * The Options class provides a convenient method of specifying where Editor
 * should get the list of options for a `select`, `radio` or `checkbox` field.
 * This is normally from a table that is _left joined_ to the main table being
 * edited, and a list of the values available from the joined table is shown to
 * the end user to let them select from.
 *
 * `Options` instances are used with the {@see Field->options()} method.
 *
 *  @example
 *   Get a list of options from the `sites` table
 *    ```php
 *    Field::inst( 'users.site' )
 *        ->options( Options::inst()
 *            ->table( 'sites' )
 *            ->value( 'id' )
 *            ->label( 'name' )
 *        )
 *    ```
 *
 *  @example
 *   Get a list of options with custom ordering
 *    ```php
 *    Field::inst( 'users.site' )
 *        ->options( Options::inst()
 *            ->table( 'sites' )
 *            ->value( 'id' )
 *            ->label( 'name' )
 *            ->order( 'name DESC' )
 *        )
 *    ```
 *
 *  @example
 *   Get a list of options showing the id and name in the label
 *    ```php
 *    Field::inst( 'users.site' )
 *        ->options( Options::inst()
 *            ->table( 'sites' )
 *            ->value( 'id' )
 *            ->label( [ 'name', 'id' ] )
 *            ->render( function ( $row ) {
 *              return $row['name'].' ('.$row['id'].')';
 *            } )
 *        )
 *    ```
 */
class Options extends DataTables\Ext {
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Private parameters
	 */
	
	/** @var string Table to get the information from */
	private $_table = null;

	/** @var string Column name containing the value */
	private $_value = null;

	/** @var string[] Column names for the label(s) */
	private $_label = array();

	/** @var integer Row limit */
	private $_limit = null;

	/** @var callable Callback function to do rendering of labels */
	private $_renderer = null;

	/** @var callback Callback function to add where conditions */
	private $_where = null;

	/** @var string ORDER BY clause */
	private $_order = null;

	private $_manualAdd = array();


	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Public methods
	 */

	/**
	 * Add extra options to the list, in addition to any obtained from the database
	 *
	 * @param string $label The label to use for the option
	 * @param string|null $value Value for the option. If not given, the label will be used
	 * @return Options Self for chaining
	 */
	public function add ( $label, $value=null )
	{
		if ( $value === null ) {
			$value = $label;
		}

		$this->_manualAdd[] = array(
			'label' => $label,
			'value' => $value
		);

		return $this;
	}

	/**
	 * Get / set the column(s) to use as the label value of the options
	 *
	 * @param  null|string|string[] $_ null to get the current value, string or
	 *   array to get.
	 * @return Options|string[] Self if setting for chaining, array of values if
	 *   getting.
	 */
	public function label ( $_=null )
	{
		if ( $_ === null ) {
			return $this;
		}
		else if ( is_string($_) ) {
			$this->_label = array( $_ );
		}
		else {
			$this->_label = $_;
		}

		return $this;
	}

	/**
	 * Get / set the LIMIT clause to limit the number of records returned.
	 *
	 * @param  null|number $_ Number of rows to limit the result to
	 * @return Options|string[] Self if setting for chaining, limit if getting.
	 */
	public function limit ( $_=null )
	{
		return $this->_getSet( $this->_limit, $_ );
	}

	/**
	 * Get / set the ORDER BY clause to use in the SQL. If this option is not
	 * provided the ordering will be based on the rendered output, either
	 * numerically or alphabetically based on the data returned by the renderer.
	 *
	 * @param  null|string $_ String to set, null to get current value
	 * @return Options|string Self if setting for chaining, string if getting.
	 */
	public function order ( $_=null )
	{
		return $this->_getSet( $this->_order, $_ );
	}

	/**
	 * Get / set the label renderer. The renderer can be used to combine
	 * multiple database columns into a single string that is shown as the label
	 * to the end user in the list of options.
	 *
	 * @param  null|callable $_ Function to set, null to get current value
	 * @return Options|callable Self if setting for chaining, callable if
	 *   getting.
	 */
	public function render ( $_=null )
	{
		return $this->_getSet( $this->_renderer, $_ );
	}

	/**
	 * Get / set the database table from which to gather the options for the
	 * list.
	 *
	 * @param  null|string $_ String to set, null to get current value
	 * @return Options|string Self if setting for chaining, string if getting.
	 */
	public function table ( $_=null )
	{
		return $this->_getSet( $this->_table, $_ );
	}

	/**
	 * Get / set the column name to use for the value in the options list. This
	 * would normally be the primary key for the table.
	 *
	 * @param  null|string $_ String to set, null to get current value
	 * @return Options|string Self if setting for chaining, string if getting.
	 */
	public function value ( $_=null )
	{
		return $this->_getSet( $this->_value, $_ );
	}

	/**
	 * Get / set the method to use for a WHERE condition if it is to be
	 * applied to the query to get the options.
	 *
	 * @param  null|callable $_ Function to set, null to get current value
	 * @return Options|callable Self if setting for chaining, callable if
	 *   getting.
	 */
	public function where ( $_=null )
	{
		return $this->_getSet( $this->_where, $_ );
	}



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Internal methods
	 */
	
	/**
	 * Execute the options (i.e. get them)
	 *
	 * @param  Database $db Database connection
	 * @return array        List of options
	 * @internal
	 */
	public function exec ( $db )
	{
		$label = $this->_label;
		$value = $this->_value;
		$formatter = $this->_renderer;

		// Create a list of the fields that we need to get from the db
		$fields = array();
		$fields[] = $value;
		$fields = array_merge( $fields, $label );

		// We need a default formatter if one isn't provided
		if ( ! $formatter ) {
			$formatter = function ( $row ) use ( $label ) {
				$a = array();

				for ( $i=0, $ien=count($label) ; $i<$ien ; $i++ ) {
					$a[] = $row[ $label[$i] ];
				}

				return implode(' ', $a);
			};
		}

		// Get the data
		$q = $db
			->query('select')
			->table( $this->_table )
			->distinct( true )
			->get( $fields )
			->where( $this->_where );

		if ( $this->_order ) {
			// For cases where we are ordering by a field which isn't included in the list
			// of fields to display, we need to add the ordering field, due to the
			// select distinct.
			$orderFields = explode( ',', $this->_order );

			for ( $i=0, $ien=count($orderFields) ; $i<$ien ; $i++ ) {
				$field = strtolower( $orderFields[$i] );
				$field = str_replace( ' asc', '', $field );
				$field = str_replace( ' desc', '', $field );
				$field = trim( $field );

				if ( ! in_array( $field, $fields ) ) {
					$q->get( $field );
				}
			}

			$q->order( $this->_order );
		}

		if ( $this->_limit !== null ) {
			$q->limit( $this->_limit );
		}

		$rows = $q
			->exec()
			->fetchAll();

		// Create the output array
		$out = array();

		for ( $i=0, $ien=count($rows) ; $i<$ien ; $i++ ) {
			$out[] = array(
				"label" => $formatter( $rows[$i] ),
				"value" => $rows[$i][$value]
			);
		}

		// Stick on any extra manually added options
		if ( count( $this->_manualAdd ) ) {
			$out = array_merge( $out, $this->_manualAdd );
		}

		// Only sort if there was no SQL order field
		if ( ! $this->_order ) {
			usort( $out, function ( $a, $b ) {
				return is_numeric($a['label']) && is_numeric($b['label']) ?
					($a['label']*1) - ($b['label']*1) :
					strcmp( $a['label'], $b['label'] );
			} );
		}

		return $out;
	}
}
	