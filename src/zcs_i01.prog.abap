*&---------------------------------------------------------------------*
*&  Include  ZCS_FUN_I01
*&---------------------------------------------------------------------*

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE ztc_modify INPUT.
*  MOVE-CORRESPONDING zcs_po_item TO g_ztc_wa.
  MODIFY g_ztc_itab
    FROM g_ztc_wa
    INDEX ztc-current_line.


ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'ZTC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE ztc_user_command INPUT.
*  g_flag = g_flag + 1.
  ok_code = sy-ucomm.

  PERFORM user_ok_tc USING    'ZTC'
                              'G_ZTC_ITAB'
                              'CHK'
                     CHANGING ok_code.

  IF ok_code = ''.



    SELECT SINGLE qmnum
       FROM zcs_po_head
       INTO @DATA(l_qm)
      WHERE qmnum = @zcs_po_head-qmnum
        AND status = '1'.
    IF sy-subrc EQ 0.
      MESSAGE s000(zsgcn) WITH 'PO:'l_qm  'have already generated!' '' DISPLAY LIKE 'E'.
    ENDIF.



  ENDIF.

  sy-ucomm = ok_code.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ZTC_EXIT_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ztc_exit_command INPUT.

  DATA: l_ok     TYPE sy-ucomm.
  l_ok = sy-ucomm.
  CASE l_ok.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  GET_TEXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_text INPUT.
  CLEAR:g_ztc_wa-maktx. "必须 先 清空. 另外 ：凡是 需要 带出来的字段 都不需要 在 前面 module里定义 ，否则
  SELECT SINGLE maktx
    FROM makt
    INTO g_ztc_wa-maktx
    WHERE  matnr = g_ztc_wa-asnum
     AND spras = sy-langu.

*  SELECT SINGLE ziwerk
*    FROM qmel
*    INTO g_ztc_wa-werks
*   WHERE qmnum = zcs_po_head-qmnum .
ENDMODULE.
