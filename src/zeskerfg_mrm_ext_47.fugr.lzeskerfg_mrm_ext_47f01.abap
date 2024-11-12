*----------------------------------------------------------------------*
***INCLUDE LZESKERFG_MRM_EXT_47F01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  zesk_mrm_invoice_simulate_call
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_RBKPV  text
*      -->P_TAB_FRSEG[]  text
*      -->P_TAB_CO[]  text
*      -->P_TAB_MA[]  text
*      -->P_C_RBSTAT_POSTED  text
*      -->P_SPACE  text
*      <--P_INVOICEDOCNUMBER  text
*      <--P_FISCALYEAR  text
*      <--P_RETURN[]  text
*      <--P_F_SUBRC  text
*----------------------------------------------------------------------*
FORM zesk_mrm_invoice_simulate_call
                             USING    i_rbkpv       TYPE mrm_rbkpv
                                      ti_frseg      TYPE mmcr_tfrseg
                                      ti_co         TYPE mmcr_tcobl_mrm
                                      ti_ma         TYPE mmcr_tma
                                      i_rbstat_new  TYPE rbstat
                                      i_stgrd       TYPE stgrd
                             CHANGING e_belnr       TYPE re_belnr
                                      e_gjahr       TYPE gjahr
                                      te_return     TYPE mrm_tab_return
                                      e_subrc       LIKE sy-subrc.

  DATA: f_fix_payment_terms LIKE boole-boole.

* fields ZBD1T etc. are not filled when ZTERM is filled: was checked for
* BAPI Create yet, will be checked for BAPI Cancel in MRM_INVOICE_CREATE
  IF i_rbkpv-ivtyp = c_ivtyp_storno.   "zterm should be initial
    f_fix_payment_terms = 'X'.
  ELSEIF NOT i_rbkpv-zterm IS INITIAL. "zterm will be dissolved
    CLEAR f_fix_payment_terms.
  ELSEIF   ( NOT i_rbkpv-zbd1t IS INITIAL"zterm is initial
          OR NOT i_rbkpv-zbd1p IS INITIAL
          OR NOT i_rbkpv-zbd2t IS INITIAL
          OR NOT i_rbkpv-zbd2p IS INITIAL
          OR NOT i_rbkpv-zbd3t IS INITIAL ).
    f_fix_payment_terms = 'X'.
  ELSE.
    CLEAR f_fix_payment_terms.
  ENDIF.

  CALL FUNCTION 'MRM_INVOICE_CREATE'
    EXPORTING
      i_rbkpv                  = i_rbkpv
      i_stgrd                  = i_stgrd
      i_fix_payment_terms      = f_fix_payment_terms
      i_fix_quantity_amount    = 'X'
      i_fix_account_assignment = 'X'
      i_rbstat_new             = i_rbstat_new
      i_simulation             = 'X'
    IMPORTING
      e_belnr                  = e_belnr
      e_gjahr                  = e_gjahr
    TABLES
      t_frseg                  = ti_frseg
      t_co                     = ti_co
      t_ma                     = ti_ma
    EXCEPTIONS
      error_message            = 4.

  IF sy-subrc = 4.
    e_subrc = 8.
    PERFORM bapireturn_fill USING    sy-msgid
                                     sy-msgty
                                     sy-msgno
                                     sy-msgv1
                                     sy-msgv2
                                     sy-msgv3
                                     sy-msgv4
                            CHANGING te_return.
  ENDIF.

ENDFORM.                    " zesk_mrm_invoice_simulate_call
