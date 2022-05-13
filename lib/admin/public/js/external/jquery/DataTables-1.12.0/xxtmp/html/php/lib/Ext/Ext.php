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


/**
 * Base class for DataTables classes.
 */
class Ext {
	/**
	 * Static method to instantiate a new instance of a class.
	 *
	 * A factory method that will create a new instance of the class
	 * that has extended 'Ext'. This allows classes to be instantiated
	 * and then chained - which otherwise isn't available until PHP 5.4.
	 * If using PHP 5.4 or later, simply create a 'new' instance of the
	 * target class and chain methods as normal.
	 *  @return \DataTables\Editor|\DataTables\Editor\Field|\DataTables\Editor\Join|\DataTables\Editor\Upload Instantiated class
	 *  @static
	 */
	public static function instantiate ()
	{
		$rc = new \ReflectionClass( get_called_class() );
		$args = func_get_args();

		return count( $args ) === 0 ?
			$rc->newInstance() :
			$rc->newInstanceArgs( $args );
	}

	/**
	 * Static method to instantiate a new instance of a class (shorthand of 
	 * 'instantiate').
	 *
	 * This method performs exactly the same actions as the 'instantiate'
	 * static method, but is simply shorter and easier to type!
	 *  @return \DataTables\Editor|\DataTables\Editor\Field|\DataTables\Editor\Join|\DataTables\Editor\Upload class
	 *  @static
	 */
	public static function inst ()
	{
		$rc = new \ReflectionClass( get_called_class() );
		$args = func_get_args();

		return count( $args ) === 0 ?
			$rc->newInstance() :
			$rc->newInstanceArgs( $args );
	}

	/**
	 * Common getter / setter function for DataTables classes.
	 *
	 * This getter / setter method makes building getter / setting methods
	 * easier, by abstracting everything to a single function call.
	 *  @param mixed &$prop The property to set
	 *  @param mixed $val The value to set - if given as null, then we assume
	 *    that the function is being used as a getter.
	 *  @param boolean $array Treat the target property as an array or not
	 *    (default false). If used as an array, then values passed in are added
	 *    to the $prop array.
	 *  @return self|* Class instance if setting (allowing chaining), or
	 *    the value requested if getting.
	 */
	protected function _getSet( &$prop, $val, $array=false )
	{
		// Get
		if ( $val === null ) {
			return $prop;
		}

		// Set
		if ( $array ) {
			// Property is an array, merge or add to array
			is_array( $val ) ?
				$prop = array_merge( $prop, $val ) :
				$prop[] = $val;
		}
		else {
			// Property is just a value
			$prop = $val;
		}

		return $this;
	}

	/**
	 * Determine if a property is available in a data set (allowing `null` to be
	 * a valid value)
	 * @param  string $name  Javascript dotted object name to write to
	 * @param  array  $data  Data source array to read from
	 * @return boolean       true if present, false otherwise
	 * @private
	 */
	protected function _propExists ( $name, $data )
	{
		if ( strpos($name, '.') === false ) {
			return isset( $data[ $name ] );
		}

		$names = explode( '.', $name );
		$inner = $data;

		for ( $i=0 ; $i<count($names)-1 ; $i++ ) {
			if ( ! isset( $inner[ $names[$i] ] ) ) {
				return false;
			}

			$inner = $inner[ $names[$i] ];
		}

		if ( isset( $names[count($names)-1] ) ) {
			$idx = $names[count($names)-1];

			return isset( $inner[ $idx ] );
		}

		return false;
	}

	/**
	 * Read a value from a data structure, using Javascript dotted object
	 * notation. This is the inverse of the `_writeProp` method and provides
	 * the same support, matching DataTables' ability to read nested JSON
	 * data objects.
	 *
	 * @param  string $name  Javascript dotted object name to write to
	 * @param  array  $data  Data source array to read from
	 * @return mixed         The read value, or null if no value found.
	 * @private
	 */
	protected function _readProp ( $name, $data )
	{
		if ( strpos($name, '.') === false ) {
			return isset( $data[ $name ] ) ?
				$data[ $name ] :
				null;
		}

		$names = explode( '.', $name );
		$inner = $data;

		for ( $i=0 ; $i<count($names)-1 ; $i++ ) {
			if ( ! isset( $inner[ $names[$i] ] ) ) {
				return null;
			}

			$inner = $inner[ $names[$i] ];
		}

		if ( isset( $names[count($names)-1] ) ) {
			$idx = $names[count($names)-1];

			return isset( $inner[ $idx ] ) ?
				$inner[ $idx ] :
				null;
		}

		return null;
	}

	/**
	 * Write the field's value to an array structure, using Javascript dotted
	 * object notation to indicate JSON data structure. For example `name.first`
	 * gives the data structure: `name: { first: ... }`. This matches DataTables
	 * own ability to do this on the client-side, although this doesn't
	 * implement implement quite such a complex structure (no array / function
	 * support).
	 *
	 * @param  array  &$out   Array to write the data to
	 * @param  string  $name  Javascript dotted object name to write to
	 * @param  mixed   $value Value to write
	 * @throws \Exception Information about duplicate properties
	 * @private
	 */
	protected function _writeProp( &$out, $name, $value )
	{
		if ( strpos($name, '.') === false ) {
			$out[ $name ] = $value;
			return;
		}

		$names = explode( '.', $name );
		$inner = &$out;
		for ( $i=0 ; $i<count($names)-1 ; $i++ ) {
			$loopName = $names[$i];

			if ( ! isset( $inner[ $loopName ] ) ) {
				$inner[ $loopName ] = array();
			}
			else if ( ! is_array( $inner[ $loopName ] ) ) {
				throw new \Exception(
					'A property with the name `'.$name.'` already exists. This '.
					'can occur if you have properties which share a prefix - '.
					'for example `name` and `name.first`.'
				);
			}

			$inner = &$inner[ $loopName ];
		}

		if ( isset( $inner[ $names[count($names)-1] ] ) ) {
			throw new \Exception(
				'Duplicate field detected - a field with the name `'.$name.'` '.
				'already exists.'
			);
		}

		$inner[ $names[count($names)-1] ] = $value;
	}
}

