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
      MESSAGE s000(zsgcn) WITH 'PO:'l_qm  'have already generated!' DISPLAY LIKE 'E'.
    ENDIF.



    SELECT SINGLE eknam
      FROM t024
      INTO zcs_po_head-text1
     WHERE ekgrp = zcs_po_head-ekgrp
     .
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


  SELECT SINGLE SPART
    FROM asmd
    INTO @DATA(l_spart)
   WHERE asnum = @g_ztc_wa-asnum
   .
  IF l_spart <> zcs_po_head-ekgrp+1(2).
    MESSAGE s000(zsgcn) WITH '服务行与所选品牌不一致!' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SELECT SINGLE asktx
    FROM asmdt
    INTO g_ztc_wa-maktx
   WHERE asnum = g_ztc_wa-asnum
     AND spras = sy-langu.
  IF sy-subrc NE 0.
    CLEAR g_ztc_wa-maktx.
  ENDIF.

  SELECT SINGLE ziwerk
    FROM qmel
    INTO g_ztc_wa-werks
   WHERE qmnum = zcs_po_head-qmnum .


  IF g_ztc_wa-tbtwr IS INITIAL.
    SELECT SINGLE kbetr, kpein
      FROM a096 AS a INNER JOIN konp AS b
       ON a~knumh = b~knumh AND a~kappl = b~kappl AND a~kschl = b~kschl
      INTO (  @DATA(l_kbetr) ,@DATA(l_kpein) )
     WHERE a~ekorg = @zcs_po_head-ekorg
       AND a~lifnr = @zcs_po_head-lifnr
       AND a~srvpos = @g_ztc_wa-asnum .

    IF sy-subrc EQ 0.
      g_ztc_wa-tbtwr = l_kbetr * l_kpein ."* g_ztc_wa-menge.
    ELSE.
      SELECT SINGLE kbetr, kpein
       FROM a104 AS a INNER JOIN konp AS b
        ON a~knumh = b~knumh AND a~kappl = b~kappl AND a~kschl = b~kschl
       INTO (  @DATA(l_kbetr2) ,@DATA(l_kpein2) )
      WHERE
         a~srvpos = @g_ztc_wa-asnum
       AND a~datab <= @sy-datum
       AND a~datbi >= @sy-datum.
      IF sy-subrc EQ 0.
        g_ztc_wa-tbtwr = l_kbetr2 * l_kpein2." * g_ztc_wa-menge.
      ENDIF.

    ENDIF.
  ENDIF.


  MODIFY g_ztc_itab
    FROM g_ztc_wa
    INDEX ztc-current_line.




ENDMODULE.
