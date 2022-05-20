<?php
/**
 * DataTables PHP libraries.
 *
 * PHP libraries for DataTables and DataTables Editor, utilising PHP 5.3+.
 *
 *  @author    SpryMedia
 *  @copyright 2012-2014 SpryMedia ( http://sprymedia.co.uk )
 *  @license   http://editor.datatables.net/license DataTables Editor
 *  @link      http://editor.datatables.net
 */

namespace DataTables\Editor;
if (!defined('DATATABLES')) exit();

use DataTables;

/**
 * Common validation options that can be specified for all validation methods.
 */
class ValidateOptions extends DataTables\Ext {
    private $_empty = true;
    private $_message = 'Input not valid';
    private $_optional = true;

	function __construct( $opts=null )
	{
        if ( $opts ) {
            if ( isset( $opts['empty'] ) ) {
                $this->allowEmpty( $opts['empty'] );
            }
            if ( isset( $opts['message'] ) ) {
                $this->message( $opts['message'] );
            }
            if ( isset( $opts['optional'] ) ) {
                $this->optional( $opts['optional'] );
            }
        }

        return $this;
    }
    
    /**
     * Get / set the error message to use if validation fails
     * @param string $msg Error message to use. If not given, the currently
     *   set message will be returned.
     * @return ValidateOptions|string Self if setting, message if getting.
     */
    public function message ( $msg=null ) {
        if ( $msg === null ) {
            return $this->_message;
        }

        $this->_message = $msg;
        return $this;
    }
    
    /**
     * Get / set the field empty option
     * @param boolean $empty `false` if the field is not allowed to be
     *   empty. `true` if it can be.
     * @return ValidateOptions|boolean Self if setting, current value if getting.
     */
    public function allowEmpty ( $empty=null ) {
        if ( $empty === null ) {
            return $this->_empty;
        }

        $this->_empty = $empty;
        return $this;
    }
    
    /**
     * Get / set the field optional option
     * @param boolean $optional `false` if the field does not need to be
     *   submitted. `true` if it must be.
     * @return ValidateOptions|boolean Self if setting, current value if getting.
     */
    public function optional ( $optional=null ) {
        if ( $optional === null ) {
            return $this->_optional;
        }

        $this->_optional = $optional;
        return $this;
    }


    /**
     * @internal
     */
    static public function select ( $user ) {
        if ( $user ) {
            return $user;
        }

        return new ValidateOptions();
    }
}