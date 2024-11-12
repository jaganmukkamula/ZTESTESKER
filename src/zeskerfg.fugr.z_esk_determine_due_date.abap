FUNCTION Z_ESK_DETERMINE_DUE_DATE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_BLDAT) LIKE  SY-DATLO
*"     VALUE(I_BUDAT) LIKE  SY-DATLO
*"     VALUE(I_CPUDT) LIKE  SY-DATLO DEFAULT SY-DATUM
*"     VALUE(I_ZFBDT) LIKE  SY-DATLO OPTIONAL
*"     VALUE(I_ZTERM) LIKE  T052-ZTERM
*"     VALUE(I_LIFNR) LIKE  BSEG-LIFNR OPTIONAL
*"     VALUE(I_BUKRS) LIKE  BKPF-BUKRS OPTIONAL
*"     VALUE(I_KOART) LIKE  FAEDE-KOART DEFAULT 'D'
*"     VALUE(I_SHKZG) LIKE  FAEDE-SHKZG DEFAULT 'S'
*"  EXPORTING
*"     VALUE(E_FAEDE) LIKE  SY-DATLO
*"     VALUE(DISCOUNT1) LIKE  BSEG-ZBD1P
*"     VALUE(DISCOUNT2) LIKE  BSEG-ZBD2P
*"     VALUE(E_T052) LIKE  T052 STRUCTURE  T052
*"     VALUE(DATEDETAILS) LIKE  FAEDE STRUCTURE  FAEDE
*"  EXCEPTIONS
*"      TERMS_NOT_FOUND
*"      ACCOUNT_TYPE_NOT_SUPPORTED
*"----------------------------------------------------------------------
*{   INSERT         EC5K900498                                        1
  DATA ls_faede LIKE FAEDE.
  ls_faede-zfbdt = I_ZFBDT.
  ls_faede-shkzg = I_SHKZG.
  ls_faede-koart = I_KOART.
  ls_faede-bldat = I_BLDAT.

  CALL FUNCTION 'FI_TERMS_OF_PAYMENT_PROPOSE'
    EXPORTING
      i_bldat         = I_BLDAT
      i_budat         = I_BUDAT
      i_cpudt         = I_CPUDT
      i_zterm         = I_ZTERM
      i_lifnr         = I_LIFNR
      i_bukrs         = I_BUKRS
      i_zfbdt         = I_ZFBDT
    IMPORTING
      e_zfbdt         = ls_faede-zfbdt
      e_zbd1t         = ls_faede-zbd1t
      e_zbd2t         = ls_faede-zbd2t
      e_zbd3t         = ls_faede-zbd3t
      e_zbd1p         = DISCOUNT1
      e_zbd2p         = DISCOUNT2
      e_t052          = E_T052
    EXCEPTIONS
      TERMS_NOT_FOUND = 1
      OTHERS          = 3.

  CASE SY-SUBRC.
    WHEN 0.
    WHEN 1.
      RAISE TERMS_NOT_FOUND.
      EXIT.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

  CALL FUNCTION 'DETERMINE_DUE_DATE'
    EXPORTING
      i_faede                    = ls_faede
    IMPORTING
      e_faede                    = ls_faede
    EXCEPTIONS
      ACCOUNT_TYPE_NOT_SUPPORTED = 2
      OTHERS                     = 4.

  CASE SY-SUBRC.
    WHEN 0.
    WHEN 2.
      RAISE ACCOUNT_TYPE_NOT_SUPPORTED.
      EXIT.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

  E_FAEDE = ls_faede-netdt.
  DATEDETAILS = ls_faede.

  IF E_T052-zfael EQ ''.
    E_T052-zfael = 00.
  ENDIF.
  IF E_T052-zmona EQ ''.
    E_T052-zmona = 00.
  ENDIF.




*}   INSERT
ENDFUNCTION.
