*&---------------------------------------------------------------------*
*&  Include  ZCS_FUN_O01
*&---------------------------------------------------------------------*

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE ztc_init OUTPUT.
  SET PF-STATUS 'STAT'.
  SET TITLEBAR 'TT'.
  IF g_ztc_copied IS INITIAL.
*  IF   g_flag = 1.
*&SPWIZARD: COPY DDIC-TABLE 'ZCS_PO_ITEM'
*&SPWIZARD: INTO INTERNAL TABLE 'g_ZTC_itab'


    g_ztc_copied = 'X'.

    REFRESH CONTROL 'ZTC' FROM SCREEN '9000'.
  ELSE.


  ENDIF.

*  LOOP AT SCREEN.
*    if screen-GROUP1  = 'PP'.
**      SCREEN-OUTPUT       = 1.
*      SCREEN-INPUT       = 0.
*
*      MODIFY SCREEN.
*    endif.
*  ENDLOOP.
  IF g_qmnum IS INITIAL.
    g_qmnum = zcs_po_head-qmnum.

    SELECT SINGLE lifnr,ekorg,ekgrp,waers
       FROM zcs_po_head
       INTO (@zcs_po_head-lifnr,@zcs_po_head-ekorg,@zcs_po_head-ekgrp,@zcs_po_head-waers)
      WHERE qmnum = @zcs_po_head-qmnum.
    IF sy-subrc NE 0.

*      CLEAR zcs_po_head.
*      zcs_po_head-qmnum = g_qmnum.
    ENDIF.

    SELECT * FROM zcs_po_item
       INTO CORRESPONDING FIELDS
       OF TABLE g_ztc_itab
      WHERE qmnum = zcs_po_head-qmnum.

    IF g_ztc_itab[] IS INITIAL.
      CLEAR g_ztc_wa.
      g_ztc_wa-posnr = '10'.
      APPEND g_ztc_wa TO g_ztc_itab.
    ENDIF.
    CALL METHOD cl_gui_cfw=>flush
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.


  ELSE.
    IF g_qmnum EQ zcs_po_head-qmnum.

    ELSE.
      g_qmnum = zcs_po_head-qmnum.

      SELECT SINGLE lifnr,ekorg,ekgrp,waers
         FROM zcs_po_head
         INTO (@zcs_po_head-lifnr,@zcs_po_head-ekorg,@zcs_po_head-ekgrp,@zcs_po_head-waers)
        WHERE qmnum = @zcs_po_head-qmnum.
      IF sy-subrc NE 0.
        CLEAR zcs_po_head.
        zcs_po_head-qmnum = g_qmnum.
      ENDIF.

      SELECT * FROM zcs_po_item
         INTO CORRESPONDING FIELDS
         OF TABLE g_ztc_itab
        WHERE qmnum = zcs_po_head-qmnum.
      IF g_ztc_itab[] IS INITIAL.
        CLEAR g_ztc_wa.
        g_ztc_wa-posnr = '10'.
        APPEND g_ztc_wa TO g_ztc_itab.
      ENDIF.


      CALL METHOD cl_gui_cfw=>flush
        EXCEPTIONS
          cntl_system_error = 1
          cntl_error        = 2.
    ENDIF.
  ENDIF.

  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  DATA l_line1 TYPE i.
  ASSIGN ('ZTC') TO <tc>.
  DESCRIBE TABLE g_ztc_itab LINES l_line1.

  <tc>-lines = l_line1.

  SET CURSOR LINE l_line1.








ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE ztc_move OUTPUT.
  MOVE-CORRESPONDING g_ztc_wa TO zcs_po_item.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE ztc_get_lines OUTPUT.
  g_ztc_lines = sy-loopc.
ENDMODULE.
