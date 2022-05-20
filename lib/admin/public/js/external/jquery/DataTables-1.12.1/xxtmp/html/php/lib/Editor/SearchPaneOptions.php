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
class SearchPaneOptions extends DataTables\Ext {
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Private parameters
	 */
	
	/** @var string Table to get the information from */
	private $_table = null;

	/** @var string Column name containing the value */
	private $_value = null;

	/** @var string[] Column names for the label(s) */
	private $_label = array();

	/** @var string[] Column names for left join */
	private $_leftJoin = array();

	/** @var callable Callback function to do rendering of labels */
	private $_renderer = null;

	/** @var callback Callback function to add where conditions */
	private $_where = null;

	/** @var string ORDER BY clause */
	private $_order = null;

	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Public methods
	 */

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

	/**
	 * Get / set the array values used for a leftJoin condition if it is to be
	 * applied to the query to get the options.
	 * 
	 * @param string $table to get the information from
	 * @param string $field1 the first field to get the information from
	 * @param string $operator the operation to perform on the two fields
	 * @param string $field2 the second field to get the information from
	 * @return self
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
	 * Adds all of the where conditions to the desired query
	 * 
	 * @param string $query the query being built
	 * @return self
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
		return $this;
	}

	/**
	 * Adds a join for all of the leftJoin conditions to the
	 * desired query, using the appropriate values.
	 * 
	 * @param string $query the query being built
	 * @return self
	 */
	private function _perform_left_join ( $query )
	{
		if ( count($this->_leftJoin) ) {
			for ( $i=0, $ien=count($this->_leftJoin) ; $i<$ien ; $i++ ) {
				$join = $this->_leftJoin[$i];
				if ($join['field2'] === null && $join['operator'] === null) {
					$query->join(
						$join['table'],
						$join['field1'],
						'LEFT',
						false
					);
				}
				else {
					$query->join(
						$join['table'],
						$join['field1'].' '.$join['operator'].' '.$join['field2'],
						'LEFT'
					);
				}
			}
		}
		return $this;
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
	public function exec ( $field, $editor, $http, $fields, $leftJoinIn )
	{
		// If the value is not yet set then set the variable to be the field name
		if ( $this->_value == null) {
			$value = $field->dbField();
		}
		else {
			$value = $this->_value;
		}

		$readTable = $editor->readTable();

		// If the table is not yet set then set the table variable to be the same as editor
		// This is not taking a value from the SearchPaneOptions instance as the table should be defined in value/label. This throws up errors if not.
		if($this->_table !== null) {
			$table = $this->_table;
		}
		else if(count($readTable) > 0) {
			$table = $readTable;
		}
		else {
			$table = $editor->table();
		}

		// If the label value has not yet been set then just set it to be the same as value
		if ( $this->_label == null ) {
			$label = $value;
		}
		else {
			$label = $this->_label[0];
		}

		// Set the database from editor
		$db = $editor->db();

		$formatter = $this->_renderer;

		// We need a default formatter if one isn't provided
		if ( ! $formatter ) {
			$formatter = function ( $str ) {
				return $str;
			};
		}

		// Set up the join variable so that it will fit nicely later
		$leftJoin = gettype($this->_leftJoin) === 'array' ?
			$this->_leftJoin :
			[$this->_leftJoin];

		foreach($leftJoinIn as $lj) {
			$found = false;
			foreach($leftJoin as $lje) {
				if($lj['table'] === $lje['table']) {
					$found = true;
				}
			}
			if(!$found) {
				array_push($leftJoin, $lj);
			}
		}

		// Set the query to get the current counts for viewTotal
		$query = $db
			->query('select')
			->table( $table );

		// The last pane to have a selection runs a slightly different query
		$queryLast = $db
			->query('select')
			->table( $table );

		if ( $field->apply('get') && $field->getValue() === null ) {
			$query->get( $value." as value", "COUNT(*) as count");
			$query->group_by( $value);
			$queryLast->get( $value." as value", "COUNT(*) as count");
			$queryLast->group_by( $value);
		}

		// If a join is required then we need to add the following to the query
		// print_r($leftJoin);
		if (count($leftJoin) > 0){
			foreach($leftJoin as $lj) {
				if ($lj['field2'] === null && $lj['operator'] === null) {
					$query->join(
						$lj['table'],
						$lj['field1'],
						'LEFT',
						false
					);
					$queryLast->join(
						$lj['table'],
						$lj['field1'],
						'LEFT',
						false
					);
				}
				else {
					$query->join(
						$lj['table'],
						$lj['field1'].' '.$lj['operator'].' '.$lj['field2'],
						'LEFT'
					);
					$queryLast->join(
						$lj['table'],
						$lj['field1'].' '.$lj['operator'].' '.$lj['field2'],
						'LEFT'
					);
				}
			}
		}

		
		// Construct the where queries based upon the options selected by the user
		// THIS IS TO GET THE SP OPTIONS, NOT THE TABLE ENTRIES
		if( isset($http['searchPanes'])) {
			foreach ($fields as $fieldOpt) {
				if (isset($http['searchPanes'][$fieldOpt->name()])) {
					$query->where( function ($q) use ($fieldOpt, $http) {
						for($j=0, $jen=count($http['searchPanes'][$fieldOpt->name()]); $j < $jen ; $j++){
							$q->or_where(
								$fieldOpt->dbField(),
								isset($http['searchPanes_null'][$fieldOpt->name()][$j]) 
									? null
									: $http['searchPanes'][$fieldOpt->name()][$j],
								'='
							);
						}
					});
				}
			}
		}

		// If there is a last value set then a slightly different set of results is required for cascade
		// That panes results are based off of the results when only considering the selections of all of the others
		if( isset($http['searchPanes']) && isset($http['searchPanesLast'])) {
			foreach ($fields as $fieldOpt) {
				if (isset($http['searchPanes'][$fieldOpt->name()]) && $fieldOpt->name() !== $http['searchPanesLast']) {
					$queryLast->where( function ($q) use ($fieldOpt, $http) {
						for($j=0, $jen=count($http['searchPanes'][$fieldOpt->name()]); $j < $jen ; $j++){
							$q->or_where(
								$fieldOpt->dbField(),
								isset($http['searchPanes_null'][$fieldOpt->name()][$j]) 
									? null
									: $http['searchPanes'][$fieldOpt->name()][$j],
								'='
							);
						}
					});
				}
			}
		}
		
		$res = $query
			->exec()
			->fetchAll();

		$resLast = $queryLast
			->exec()
			->fetchAll();

		// Get the data for the pane options
		$q = $db
			->query('select')
			->table( $table )
			->get( $label." as label", $value." as value", "COUNT(*) as total" )
			->group_by( $value )
			->where( $this->_where );

		// If a join is required then we need to add the following to the query
		if (count($leftJoin) > 0){
			foreach($leftJoin as $lj) {
				if ($lj['field2'] === null && $lj['operator'] === null) {
					$q->join(
						$lj['table'],
						$lj['field1'],
						'LEFT',
						false
					);
				}
				else {
					$q->join(
						$lj['table'],
						$lj['field1'].' '.$lj['operator'].' '.$lj['field2'],
						'LEFT'
					);
				}
			}
		}

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

		// print_r($q);

		$rows = $q
			->exec()
			->fetchAll();

		// Create the output array
		$out = array();

		for ( $i=0, $ien=count($rows) ; $i<$ien ; $i++ ) {
			$set = false;
			// Send slightly different results if this is the last pane
			if (isset($http['searchPanesLast']) && $field->name() === $http['searchPanesLast'] ) {
				for( $j=0 ; $j<count($resLast) ; $j ++) {
					if($resLast[$j]['value'] == $rows[$i]['value']){
						$out[] = array(
							"label" => $formatter($rows[$i]['label']),
							"total" => $rows[$i]['total'],
							"value" => $rows[$i]['value'],
							"count" => $resLast[$j]['count']
						);
						$set = true;
					}
				}
			}
			else {
				for( $j=0 ; $j<count($res) ; $j ++) {
					if($res[$j]['value'] == $rows[$i]['value']){
						$out[] = array(
							"label" => $formatter($rows[$i]['label']),
							"total" => $rows[$i]['total'],
							"value" => $rows[$i]['value'],
							"count" => $res[$j]['count']
						);
						$set = true;
					}
				}
			}
			if(!$set) {
				$out[] = array(
					"label" => $formatter($rows[$i]['label']),
					"total" => $rows[$i]['total'],
					"value" => $rows[$i]['value'],
					"count" => 0
				);
			}
			
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
	