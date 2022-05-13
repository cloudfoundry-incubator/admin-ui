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

namespace DataTables\Editor;
if (!defined('DATATABLES')) exit();


/**
 * Formatter methods for the DataTables Editor
 * 
 * All methods in this class are static with common inputs and returns.
 */
class Format {
	/** Date format: 2012-03-09. jQuery UI equivalent format: yy-mm-dd */
	const DATE_ISO_8601 = "Y-m-d";

	/** Date format: Fri, 9 Mar 12. jQuery UI equivalent format: D, d M y */
	const DATE_ISO_822 = "D, j M y";
	
	/** Date format: Friday, 09-Mar-12.  jQuery UI equivalent format: DD, dd-M-y */
	const DATE_ISO_850 = "l, d-M-y";
	
	/** Date format: Fri, 9 Mar 12. jQuery UI equivalent format: D, d M y */
	const DATE_ISO_1036 = "D, j M y";
	
	/** Date format: Fri, 9 Mar 2012. jQuery UI equivalent format: D, d M yy */
	const DATE_ISO_1123 = "D, j M Y";
	
	/** Date format: Fri, 9 Mar 2012. jQuery UI equivalent format: D, d M yy */
	const DATE_ISO_2822 = "D, j M Y";

	/** Date format: March-. jQuery UI equivalent format: D, d M yy */
	const DATE_USA = "m-d-Y";
	
	/** Date format: 1331251200. jQuery UI equivalent format: @ */
	const DATE_TIMESTAMP = "U";
	
	/** Date format: 1331251200. jQuery UI equivalent format: @ */
	const DATE_EPOCH = "U";


	/**
	 * Convert from SQL date / date time format to a format given by the options
	 * parameter.
	 *
	 * Typical use of this method is to use it with the 
	 * {@see Field::getFormatter()} and {@see Field::setFormatter()} methods of
	 * {@see Field} where the parameters required for this method will be 
	 * automatically satisfied.
	 *   @param string $val Value to convert from MySQL date format
	 *   @param string[] $data Data for the whole row / submitted data
	 *   @param string $opts Format to convert to using PHP date() options.
	 *   @return string Formatted date or empty string on error.
	 */
	public static function dateSqlToFormat( $format ) {
		return function ( $val, $data ) use ( $format ) {
			if ( $val === null || $val === '' ) {
				return null;
			}

			$date = new \DateTime( $val );

			// Allow empty strings or invalid dates
			if ( $date ) {
				return date_format( $date, $format );
			}
			return null;
		};
	}


	/**
	 * Convert from a format given by the options parameter to a format that
	 * SQL servers will recognise as a date.
	 *
	 * Typical use of this method is to use it with the 
	 * {@see Field::getFormatter()} and {@see Field::setFormatter()} methods of
	 * {@see Field} where the parameters required for this method will be 
	 * automatically satisfied.
	 *   @param string $val Value to convert to SQL date format
	 *   @param string[] $data Data for the whole row / submitted data
	 *   @param string $opts Format to convert from using PHP date() options.
	 *   @return string Formatted date or null on error.
	 */
	public static function dateFormatToSql( $format ) {
		return function ( $val, $data ) use ( $format ) {
			if ( $val === null || $val === '' ) {
				return null;
			}

			// Note that this assumes the date is in the correct format (should be
			// checked by validation before being used here!)
			if ( substr($format, 0, 1) !== '!' ) {
				$format = '!'.$format;
			}
			$date = date_create_from_format($format, $val);

			// Invalid dates or empty string are replaced with null. Use the
			// validation to ensure the date given is valid if you don't want this!
			if ( $date ) {
				return date_format( $date, 'Y-m-d' );
			}
			return null;
		};
	}


	/**
	 * Convert from one date time format to another
	 *
	 * Typical use of this method is to use it with the 
	 * {@see Field::getFormatter()} and {@see Field::setFormatter()} methods of
	 * {@see Field} where the parameters required for this method will be 
	 * automatically satisfied.
	 *   @param string $val Value to convert
	 *   @param string[] $data Data for the whole row / submitted data
	 *   @param string $opts Array with `from` and `to` properties which are the
	 *     formats to convert from and to
	 *   @return string Formatted date or null on error.
	 */
	public static function datetime( $from, $to ) {
		return function ( $val, $data ) use ( $from, $to ) {
			if ( $val === null || $val === '' ) {
				return null;
			}

			if ( substr($from, 0, 1) !== '!' ) {
				$from = '!'.$from;
			}
			$date = date_create_from_format( $from, $val );

			// Allow empty strings or invalid dates
			if ( $date ) {
				return date_format( $date, $to );
			}

			return null;
		};
	}


	/**
	 * Convert a string of values into an array for use with checkboxes.
	 *   @param string $val Value to convert to from a string to an array
	 *   @param string[] $data Data for the whole row / submitted data
	 *   @param string $opts Field delimiter
	 *   @return string Formatted value or null on error.
	 */
	public static function explode( $char='|' ) {
		return function ( $val, $data ) use ( $char ) {
			return explode($char, $val);
		};
	}


	/**
	 * Convert an array of values from a checkbox into a string which can be
	 * used to store in a text field in a database.
	 *   @param string $val Value to convert to from an array to a string
	 *   @param string[] $data Data for the whole row / submitted data
	 *   @param string $opts Field delimiter
	 *   @return string Formatted value or null on error.
	 */
	public static function implode( $char='|' ) {
		return function ( $val, $data ) use ( $char ) {
			return implode($char, $val);
		};
	}


	/**
	 * Convert an empty string to `null`. Null values are very useful in
	 * databases, but HTTP variables have no way of representing `null` as a
	 * value, often leading to an empty string and null overlapping. This method
	 * will check the value to operate on and return null if it is empty.
	 *   @param string $val Value to convert to from a string to an array
	 *   @param string[] $data Data for the whole row / submitted data
	 *   @param string $opts Field delimiter
	 *   @return string Formatted value or null on error.
	 */
	public static function nullEmpty () {
		// Legacy function - use `ifEmpty` now
		return self::ifEmpty( null );
	}


	/**
	 * Formatter that can be used to specify what value should be used if an
	 * empty value is submitted by the client-side (e.g. null, 0, 'Not set',
	 * etc)
	 *   @param string $val Value to convert to from a string to an array
	 *   @param string[] $data Data for the whole row / submitted data
	 *   @param string $opts Empty value
	 *   @return string Formatted value or null on error.
	 */
	public static function ifEmpty ( $ret ) {
		return function ( $val, $data ) use ( $ret ) {
			return $val === '' ?
				$ret :
				$val;
		};
	}


	/**
	 * Convert a number from using any character other than a period (dot) to
	 * one which does use a period. This is useful for allowing numeric user
	 * input in regions where a comma is used as the decimal character. Use with
	 * a set formatter.
	 *   @param string $val Value to convert to from a string to an array
	 *   @param string[] $data Data for the whole row / submitted data
	 *   @param string $opts Decimal place character (default ',')
	 *   @return string Formatted value or null on error.
	 */
	public static function fromDecimalChar ( $char=',' ) {
		return function ( $val, $data ) use ( $char ) {
			return str_replace( $char, '.', $val );
		};
	}


	/**
	 * Convert a number with a period (dot) as the decimal character to use
	 * a different character (typically a comma). Use with a get formatter.
	 *   @param string $val Value to convert to from a string to an array
	 *   @param string[] $data Data for the whole row / submitted data
	 *   @param string $opts Decimal place character (default ',')
	 *   @return string Formatted value or null on error.
	 */
	public static function toDecimalChar ( $char=',' ) {
		return function ( $val, $data ) use ( $char ) {
			return str_replace( '.', $char, $val );
		};
	}



	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Internal functions
	 * These legacy methods are for backwards compatibility with the old way of
	 * using the formatter methods. They basically do argument swapping.
	 */

	/**
	 * @internal
	 */
	public static function date_sql_to_format ( $opts ) {
		return self::dateSqlToFormat( $opts );
	}

	/**
	 * @internal
	 */
	public static function date_sql_to_formatLegacy ( $opts ) {
		return self::dateSqlToFormat( $opts );
	}

	/**
	 * @internal
	 */
	public static function date_format_to_sql ( $opts ) {
		return self::dateFormatToSql( $opts );
	}

	/**
	 * @internal
	 */
	public static function date_format_to_sqlLegacy ( $opts ) {
		return self::dateFormatToSql( $opts );
	}
	
	/**
	 * @internal
	 */
	public static function datetimeLegacy ( $opts ) {
		return self::datetime( $opts['from'], $opts['to'] );
	}
	
	/**
	 * @internal
	 */
	public static function explodeLegacy ( $opts ) {
		if ( $opts === null ) {
			$opts = '|';
		}
		return self::explode( $opts );
	}

	/**
	 * @internal
	 */
	public static function implodeLegacy ( $opts ) {
		if ( $opts === null ) {
			$opts = '|';
		}
		return self::implode( $opts );
	}

	/**
	 * @internal
	 */
	public static function nullEmptyLegacy ( $opts ) {
		return self::nullEmpty( null );
	}
	
	/**
	 * @internal
	 */
	public static function ifEmptyLegacy ( $opts ) {
		return self::ifEmpty( $opts );
	}

	/**
	 * @internal
	 */
	public static function fromDecimalCharLegacy ( $opts ) {
		if ( $opts === null ) {
			$opts = ',';
		}
		return self::fromDecimalChar( $opts );
	}
	
	/**
	 * @internal
	 */
	public static function toDecimalCharLegacy ( $opts ) {
		if ( $opts === null ) {
			$opts = ',';
		}
		return self::toDecimalChar( $opts );
	}
}

