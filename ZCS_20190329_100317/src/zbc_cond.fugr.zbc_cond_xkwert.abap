FUNCTION zbc_cond_xkwert.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_KBETR) TYPE  KBETR
*"     VALUE(IV_KAWRT) TYPE  KAWRT
*"     VALUE(IV_KPEIN) TYPE  KPEIN
*"     VALUE(IV_KRECH) TYPE  KRECH
*"     VALUE(IV_KSCHL) TYPE  KSCHL
*"  EXPORTING
*"     VALUE(EV_XKWERT) TYPE  KWERT
*"----------------------------------------------------------------------

  DATA: lv_percentage TYPE p LENGTH 10 DECIMALS 5 .
* Calculate condition value
  IF iv_krech = 'C'. " C - Qauntity
    ev_xkwert = ( iv_kbetr * iv_kawrt ) / iv_kpein / 10.
  ELSEIF iv_krech = 'A' . " A - Percentage
    lv_percentage = iv_kbetr / 1000 .
    " For example: base value = 100, condition = 0.16, result = 0.16 * 100 = 16 .
    ev_xkwert = ( iv_kawrt * lv_percentage ) .
  ELSEIF iv_krech = 'H' . " H - Percentage include
    lv_percentage = iv_kbetr / 1000 .
    " For example: base value = 100, condition = 0.16, result = 100 - 100 / (1+0.16) = 13.79
    ev_xkwert = ( iv_kawrt - iv_kawrt / ( 1 + lv_percentage ) )  .
  ENDIF.
ENDFUNCTION.
