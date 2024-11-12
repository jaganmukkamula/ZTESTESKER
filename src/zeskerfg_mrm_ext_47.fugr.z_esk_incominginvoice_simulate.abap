FUNCTION Z_ESK_INCOMINGINVOICE_SIMULATE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(HEADERDATA) LIKE  BAPI_INCINV_CREATE_HEADER STRUCTURE
*"        BAPI_INCINV_CREATE_HEADER
*"     VALUE(ADDRESSDATA) LIKE  BAPI_INCINV_CREATE_ADDRESSDATA
*"       STRUCTURE  BAPI_INCINV_CREATE_ADDRESSDATA OPTIONAL
*"  EXPORTING
*"     VALUE(INVOICEDOCNUMBER) LIKE  BAPI_INCINV_FLD-INV_DOC_NO
*"     VALUE(FISCALYEAR) LIKE  BAPI_INCINV_FLD-FISC_YEAR
*"  TABLES
*"      ITEMDATA STRUCTURE  BAPI_INCINV_CREATE_ITEM
*"      ACCOUNTINGDATA STRUCTURE  BAPI_INCINV_CREATE_ACCOUNT OPTIONAL
*"      GLACCOUNTDATA STRUCTURE  BAPI_INCINV_CREATE_GL_ACCOUNT OPTIONAL
*"      MATERIALDATA STRUCTURE  BAPI_INCINV_CREATE_MATERIAL OPTIONAL
*"      TAXDATA STRUCTURE  BAPI_INCINV_CREATE_TAX OPTIONAL
*"      WITHTAXDATA STRUCTURE  BAPI_INCINV_CREATE_WITHTAX OPTIONAL
*"      VENDORITEMSPLITDATA STRUCTURE  BAPI_INCINV_CREATE_VENDORSPLIT
*"       OPTIONAL
*"      RETURN STRUCTURE  BAPIRET2
*"      ACCOUNTINGINFO STRUCTURE  ZESKACCIT OPTIONAL
*"      CURRENCYINFO STRUCTURE  ZESKACCCR OPTIONAL
*"----------------------------------------------------------------------
  DATA:
    tab_frseg  TYPE mmcr_tfrseg,  " item data for MRM_INVOICE_CREATE
    tab_co     TYPE mmcr_tcobl_mrm,    " direct posting G/L account
    tab_ma     TYPE mmcr_tma,          " direct posting material
    tab_accit  TYPE TABLE OF accit,    " local array of item details
    tab_acccr  TYPE TABLE OF acccr,    " local array of currency details
    s_rbkpv    TYPE mrm_rbkpv,    " header data for MRM_INVOICE_CREATE
    f_belnr    LIKE rbkp_v-belnr,      " doc number of created invoice
    f_gjahr    LIKE rbkp_v-gjahr,      " fiscal year of created invoice
    f_subrc    LIKE sy-subrc,          " return code
    l_accit    LIKE accit,          " line of item details
    l_zeskaccit  LIKE zeskaccit,    " line of Esker type 'zeskaccit'
    l_acccr    LIKE acccr,          " line of currency details
    l_zeskacccr  LIKE zeskacccr.    " line of Esker type 'zeskacccr'

  CLEAR:
      return.
  REFRESH:
      return.

*---------------------------------------------------------------------*
*     F_SUBRC = 0 --> ok, go on                                       *
*     F_SUBRC = 4 --> error, go on                                    *
*     F_SUBRC = 8 --> error, no processing                            *
*---------------------------------------------------------------------*

  PERFORM importing_data_check       TABLES    itemdata
                                               accountingdata
                                               taxdata
                                               withtaxdata
                                               vendoritemsplitdata
                                               glaccountdata
                                               materialdata
                                     USING     headerdata
                                               addressdata
                                               c_rbstat_posted
                                               invoicedocnumber "EhP6 DInv Auto Proc
                                               fiscalyear "EhP6 DInv Auto Proc
                                     CHANGING  return[]
                                               f_subrc.

  CHECK f_subrc < 8.

  PERFORM rbkpv_fill                 TABLES    itemdata
                                     USING     headerdata
                                               addressdata
                                               c_rbstat_posted
                                     CHANGING  s_rbkpv
                                               return[]
                                               f_subrc.

  CHECK f_subrc < 8.

  PERFORM frseg_fill                 TABLES    itemdata
                                               accountingdata
                                     USING     s_rbkpv-waers
                                               s_rbkpv-tbtkz    "1097704
                                     CHANGING  tab_frseg[]
                                               return[]
                                               f_subrc.

  CHECK f_subrc < 8.

  PERFORM co_fill                    TABLES    glaccountdata
                                     USING     s_rbkpv-waers
                                               s_rbkpv-blart "1796950 start
                                               s_rbkpv-bldat
                                               s_rbkpv-budat
                                               s_rbkpv-kursf "1796950 end
                                     CHANGING  tab_co[]
                                               return[]
                                               f_subrc.

  CHECK f_subrc < 8.

  PERFORM ma_fill                    TABLES    materialdata
                                     USING     s_rbkpv-waers
                                     CHANGING  tab_ma[]
                                               return[]
                                               f_subrc.

  CHECK f_subrc < 8.

  PERFORM rbtx_fill                  TABLES    taxdata
                                               withtaxdata
                                               vendoritemsplitdata
                                     USING     s_rbkpv-waers
                                               s_rbkpv-bukrs
                                               headerdata
                                     CHANGING  s_rbkpv-rbtx[]
                                               s_rbkpv-h_rbws[]
                                               s_rbkpv-h_rbvs[]
                                               return[]
                                               f_subrc.

  CHECK f_subrc = 0.

  PERFORM zesk_mrm_invoice_simulate_call    USING     s_rbkpv
                                               tab_frseg[]
                                               tab_co[]
                                               tab_ma[]
                                               c_rbstat_posted
                                               space
                                     CHANGING  invoicedocnumber
                                               fiscalyear
                                               return[]
                                               f_subrc.

  CALL FUNCTION 'MRM_XACCITCR_EXPORT'
       TABLES
            t_acccr    = tab_acccr
            t_accit    = tab_accit.

  LOOP AT tab_accit INTO l_accit.
    CLEAR l_zeskaccit.
    MOVE-CORRESPONDING l_accit to l_zeskaccit.
    APPEND l_zeskaccit TO accountinginfo.
  ENDLOOP.

  LOOP AT tab_acccr INTO l_acccr.
    CLEAR l_zeskacccr.
    MOVE-CORRESPONDING l_acccr to l_zeskacccr.
    APPEND l_zeskacccr TO currencyinfo.
  ENDLOOP.

ENDFUNCTION.
