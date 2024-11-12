FUNCTION Z_ESK_CALCULATE_TAX_FRM_NET.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_BUKRS) LIKE  BKPF-BUKRS
*"     VALUE(I_MWSKZ) LIKE  BSEG-MWSKZ
*"     VALUE(I_TXJCD) LIKE  BSEG-TXJCD OPTIONAL
*"     VALUE(I_WAERS) LIKE  BKPF-WAERS
*"     VALUE(I_WRBTR) LIKE  BSEG-WRBTR
*"     VALUE(I_ZBD1P) LIKE  BSEG-ZBD1P OPTIONAL
*"     VALUE(I_PRSDT) LIKE  KOMK-PRSDT OPTIONAL
*"     VALUE(I_PROTOKOLL) LIKE  BAPIEKPO-GR_IND OPTIONAL
*"     VALUE(I_ACCDATA) TYPE  BSEG OPTIONAL
*"  EXPORTING
*"     VALUE(E_FWNAV) LIKE  BSET-FWSTE
*"     VALUE(E_FWNVV) LIKE  BSET-FWSTE
*"     VALUE(E_FWSTE) LIKE  BSET-FWSTE
*"     VALUE(E_FWAST) LIKE  BSET-FWSTE
*"  TABLES
*"      T_MWDAT STRUCTURE  RTAX1U15
*"  EXCEPTIONS
*"      BUKRS_NOT_FOUND
*"      COUNTRY_NOT_FOUND
*"      MWSKZ_NOT_DEFINE
*"      MWSKZ_NOT_VALID
*"      MWSKZ_NOT_DEFINED
*"----------------------------------------------------------------------
*{   INSERT         EC5K900498                                        1

  CLEAR: E_FWNAV,
         E_FWNVV,
         E_FWSTE,
         E_FWAST,
         T_MWDAT.
  REFRESH: T_MWDAT.

  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
       EXPORTING
            I_BUKRS           = I_BUKRS
            I_MWSKZ           = I_MWSKZ
            I_TXJCD           = I_TXJCD
            I_WAERS           = I_WAERS
            I_WRBTR           = I_WRBTR
            I_ZBD1P           = I_ZBD1P
            I_PRSDT           = I_PRSDT
            I_ACCDATA         = I_ACCDATA
       IMPORTING
            E_FWNAV           = E_FWNAV
            E_FWNVV           = E_FWNVV
            E_FWSTE           = E_FWSTE
            E_FWAST           = E_FWAST
       TABLES
            T_MWDAT           = T_MWDAT
       EXCEPTIONS
            BUKRS_NOT_FOUND   = 1
            COUNTRY_NOT_FOUND = 2
            MWSKZ_NOT_DEFINED = 3
            MWSKZ_NOT_VALID   = 4.
  CASE SY-SUBRC.
    WHEN 0.
    WHEN 1.
      RAISE BUKRS_NOT_FOUND.
      EXIT.
    WHEN 2.
      RAISE COUNTRY_NOT_FOUND.
      EXIT.
    WHEN 3.
      RAISE MWSKZ_NOT_DEFINED.
      EXIT.
    WHEN 4.
      RAISE MWSKZ_NOT_VALID.
      EXIT.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

*}   INSERT
ENDFUNCTION.
