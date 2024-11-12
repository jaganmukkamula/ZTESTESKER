FUNCTION Z_ESK_CONV_TO_FOREIGN_CURRENCY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CLIENT) LIKE  SY-MANDT DEFAULT SY-MANDT
*"     VALUE(DATE) LIKE  SYST-DATUM
*"     VALUE(FOREIGN_CURRENCY) LIKE  TCURC-WAERS
*"     VALUE(LOCAL_AMOUNT) LIKE  BSEG-WRBTR
*"     VALUE(LOCAL_CURRENCY) LIKE  TCURC-WAERS
*"     VALUE(RATE) LIKE  TCURR-UKURS DEFAULT 0
*"     VALUE(TYPE_OF_RATE) LIKE  TCURV-BKUZU DEFAULT 'M'
*"     VALUE(READ_TCURR) LIKE  TCURV-XBWRL DEFAULT 'X'
*"  EXPORTING
*"     VALUE(EXCHANGE_RATE) LIKE  TCURR-UKURS
*"     VALUE(FOREIGN_AMOUNT) LIKE  BSEG-WRBTR
*"     VALUE(FOREIGN_FACTOR) LIKE  TCURF-FFACT
*"     VALUE(LOCAL_FACTOR) LIKE  TCURF-TFACT
*"     VALUE(DERIVED_RATE_TYPE) LIKE  TCURR-KURST
*"     VALUE(FIXED_RATE) LIKE  TCURR-UKURS
*"  EXCEPTIONS
*"      NO_RATE_FOUND
*"      OVERFLOW
*"      NO_FACTORS_FOUND
*"      NO_SPREAD_FOUND
*"      DERIVED_2_TIMES
*"--------------------------------------------------------------------
*{   INSERT         EC5K900498                                        1
  CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
       EXPORTING
            CLIENT            = CLIENT
            DATE              = DATE
            FOREIGN_CURRENCY  = FOREIGN_CURRENCY
            LOCAL_AMOUNT      = LOCAL_AMOUNT
            LOCAL_CURRENCY    = LOCAL_CURRENCY
            RATE              = RATE
            TYPE_OF_RATE      = TYPE_OF_RATE
            READ_TCURR        = READ_TCURR
       IMPORTING
            EXCHANGE_RATE     = EXCHANGE_RATE
            FOREIGN_AMOUNT    = FOREIGN_AMOUNT
            FOREIGN_FACTOR    = FOREIGN_FACTOR
            LOCAL_FACTOR      = LOCAL_FACTOR
            DERIVED_RATE_TYPE = DERIVED_RATE_TYPE
            FIXED_RATE        = FIXED_RATE.

*}   INSERT
ENDFUNCTION.
