CLASS zcl_aoc_check_34 DEFINITION
  PUBLIC
  INHERITING FROM zcl_aoc_super
  CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS constructor.

    METHODS check
        REDEFINITION.
    METHODS get_attributes
        REDEFINITION.
    METHODS get_message_text
        REDEFINITION.
    METHODS if_ci_test~query_attributes
        REDEFINITION.
    METHODS put_attributes
        REDEFINITION.
  PROTECTED SECTION.

    DATA mv_lines TYPE i.
    DATA mv_incl_comments TYPE flag.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_AOC_CHECK_34 IMPLEMENTATION.


  METHOD check.

* abapOpenChecks
* https://github.com/larshp/abapOpenChecks
* MIT License

* todo, move this macro to method instead
    DEFINE _check.
      IF lv_start > 0 AND ( ( mv_incl_comments EQ abap_true
          AND ( ( lv_start + mv_lines ) < <ls_token>-row  ) )
          OR ( mv_incl_comments EQ abap_false
          AND ( ( lv_start + mv_lines ) < ( <ls_token>-row - lv_comment_lines ) ) ) ).
        lv_include = get_include( p_level = <ls_statement>-level ).
        inform( p_sub_obj_type = c_type_include
                p_sub_obj_name = lv_include
                p_line         = lv_start
                p_kind         = mv_errty
                p_test         = myname
                p_code         = '001' ).
      ENDIF.
    END-OF-DEFINITION.

    DATA: lv_start         TYPE i,
          lv_include       TYPE sobj_name,
          lv_comment_lines TYPE i.

    FIELD-SYMBOLS: <ls_statement> LIKE LINE OF it_statements,
                   <ls_token>     LIKE LINE OF it_tokens.


    LOOP AT it_statements ASSIGNING <ls_statement>
        WHERE type = scan_stmnt_type-standard OR
              type = scan_stmnt_type-comment.

      READ TABLE it_tokens ASSIGNING <ls_token> INDEX <ls_statement>-from.
      ASSERT sy-subrc = 0.

      CASE <ls_token>-str.
        WHEN 'WHEN'.
          _check.
          lv_comment_lines = 0.
          lv_start = <ls_token>-row.
        WHEN 'ENDCASE'.
          _check.
          lv_comment_lines = 0.
          lv_start = 0.
        WHEN OTHERS.
          IF <ls_statement>-type EQ scan_stmnt_type-comment.
            lv_comment_lines = lv_comment_lines + <ls_statement>-to - <ls_statement>-from.
          ENDIF.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD constructor.

    super->constructor( ).

    version        = '001'.
    position       = '034'.

    has_attributes = abap_true.
    attributes_ok  = abap_true.

    enable_rfc( ).

    mv_errty = c_error.
    mv_lines = 20.

  ENDMETHOD.                    "CONSTRUCTOR


  METHOD get_attributes.

    EXPORT
      mv_errty = mv_errty
      mv_lines = mv_lines
      mv_incl_comments = mv_incl_comments
      TO DATA BUFFER p_attributes.

  ENDMETHOD.


  METHOD get_message_text.

    CLEAR p_text.

    CASE p_code.
      WHEN '001'.
        p_text = 'Large WHEN construct'.                    "#EC NOTEXT
      WHEN OTHERS.
        super->get_message_text( EXPORTING p_test = p_test
                                           p_code = p_code
                                 IMPORTING p_text = p_text ).
    ENDCASE.

  ENDMETHOD.                    "GET_MESSAGE_TEXT


  METHOD if_ci_test~query_attributes.

    zzaoc_top.

    zzaoc_fill_att mv_errty 'Error Type' ''.                "#EC NOTEXT
    zzaoc_fill_att mv_lines 'Lines' ''.                     "#EC NOTEXT
    zzaoc_fill_att mv_incl_comments 'Include comments?' ''. "#EC NOTEXT
    zzaoc_popup.

  ENDMETHOD.


  METHOD put_attributes.

    IMPORT
      mv_errty = mv_errty
      mv_lines = mv_lines
      mv_incl_comments = mv_incl_comments
      FROM DATA BUFFER p_attributes.                 "#EC CI_USE_WANTED
    ASSERT sy-subrc = 0.

  ENDMETHOD.
ENDCLASS.
