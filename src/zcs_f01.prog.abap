*&---------------------------------------------------------------------*
*&  Include  ZCS_FUN_F01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                          p_table_name
                          p_mark_name
                 CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA: l_ok     TYPE sy-ucomm,
         l_offset TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
   SEARCH p_ok FOR p_tc_name.
   IF sy-subrc <> 0.
     EXIT.
   ENDIF.
   l_offset = strlen( p_tc_name ) + 1.
   l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
   CASE l_ok.
     WHEN 'INSR'.                      "insert row
       PERFORM fcode_insert_row USING    p_tc_name
                                         p_table_name.
       CLEAR p_ok.

     WHEN 'DELE'.                      "delete row
       PERFORM fcode_delete_row USING    p_tc_name
                                         p_table_name
                                         p_mark_name.
       CLEAR p_ok.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM compute_scrolling_in_tc USING p_tc_name
                                             l_ok.
       CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM fcode_tc_mark_lines USING p_tc_name
                                         p_table_name
                                         p_mark_name   .
       CLEAR p_ok.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM fcode_tc_demark_lines USING p_tc_name
                                           p_table_name
                                           p_mark_name .
       CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.
     WHEN 'PO'.
       SELECT SINGLE qmnum
            FROM zcs_po_head
            INTO @DATA(l_qm)
           WHERE qmnum = @zcs_po_head-qmnum
             AND status = '1'.
       IF sy-subrc EQ 0.
         MESSAGE s000(zsgcn) WITH 'PO:'l_qm  'have already generated!' DISPLAY LIKE 'E'.
         EXIT.
       ENDIF.

       CALL FUNCTION 'POPUP_TO_CONFIRM'
         EXPORTING
           text_question         = TEXT-001
           text_button_1         = TEXT-002
           text_button_2         = TEXT-003
           display_cancel_button = ''
         IMPORTING
           answer                = g_answer
         EXCEPTIONS
           text_not_found        = 1
           OTHERS                = 2.
       IF sy-subrc EQ 0 AND g_answer EQ '1'.

         PERFORM frm_create_po.
       ELSE.

* Implement suitable error handling here
       ENDIF.


       CHECK g_answer = '1'.

     WHEN 'SAVE'.
       DATA l_line1 TYPE i.
       DATA ls_line LIKE LINE OF g_ztc_itab.
       DATA lt_item TYPE  zcs_po_item .

       IF zcs_po_head IS NOT INITIAL.
         MODIFY  zcs_po_head FROM zcs_po_head.
       ENDIF.

       DELETE FROM zcs_po_item WHERE qmnum = zcs_po_head-qmnum.
       LOOP AT g_ztc_itab INTO ls_line WHERE asnum IS NOT INITIAL.
         MOVE-CORRESPONDING ls_line TO lt_item.
         lt_item-qmnum = zcs_po_head-qmnum.
         INSERT  zcs_po_item FROM lt_item.
         l_line1 = l_line1 + 1.
       ENDLOOP.

***    保存完 设置行 ，否则 显示 会少掉，
       FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
       ASSIGN (p_tc_name) TO <tc>.
       DESCRIBE TABLE g_ztc_itab LINES l_line1.
       <tc>-lines = l_line1.
       SET CURSOR LINE l_line1.


       IF sy-subrc EQ 0.
         MESSAGE s368(00) WITH 'Saved !'.
       ENDIF.


     WHEN OTHERS.


   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_insert_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_lines_name       LIKE feld-name.
   DATA l_selline          LIKE sy-stepl.
   DATA l_lastline         TYPE i.
   DATA l_line             TYPE i.
   DATA l_table_name       LIKE feld-name.
   FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
   FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
   ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
   GET CURSOR LINE l_selline.
   IF sy-subrc <> 0.                   " append line to table
     l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
     IF l_selline > <lines>.
       <tc>-top_line = l_selline - <lines> + 1 .
     ELSE.
       <tc>-top_line = 1.
     ENDIF.
   ELSE.                               " insert line into table
     l_selline = <tc>-top_line + l_selline - 1.
     l_lastline = <tc>-top_line + <lines> - 1.
   ENDIF.
*&SPWIZARD: set new cursor line                                        *
   l_line = l_selline - <tc>-top_line + 1.
   FIELD-SYMBOLS <field1> TYPE any.
   FIELD-SYMBOLS <field2> TYPE any.
   DATA l_num TYPE zposn.
   FIELD-SYMBOLS <fs> TYPE any.
*&SPWIZARD: insert initial line
   DATA l_line1 TYPE i.
   DESCRIBE TABLE <table> LINES l_line1.
   IF l_line1 >= 1.
     READ TABLE <table> ASSIGNING FIELD-SYMBOL(<fs_ls>)  INDEX l_line1. "               *
     ASSIGN COMPONENT 'POSNR' OF STRUCTURE <fs_ls> TO <field1>.
     l_num = <field1> + 10.

     l_line1 = l_line1 + 1.
     INSERT INITIAL LINE INTO <table> INDEX l_line1."l_selline.
     READ TABLE <table> ASSIGNING <fs> INDEX l_line1.
     ASSIGN COMPONENT 'POSNR' OF STRUCTURE <fs> TO <field2>.
     <field2> = l_num.

   ELSEIF l_line1 = 0..
     l_line1 = l_line1 + 1.
     INSERT INITIAL LINE INTO <table> INDEX l_line1."l_selline.
     READ TABLE <table> ASSIGNING <fs> INDEX l_line1.
     ASSIGN COMPONENT 'POSNR' OF STRUCTURE <fs> TO <field2>.
     <field2> = 10.
   ENDIF.

*   <tc>-lines = <tc>-lines + 1.
   <tc>-lines = l_line1.
*&SPWIZARD: set cursor                                                 *
*   SET CURSOR LINE l_line.
   SET CURSOR LINE l_line1.


*   SORT g_ztc_itab BY posnr ASCENDING.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_delete_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name
                        p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
   DESCRIBE TABLE <table> LINES <tc>-lines.
   CHECK  <tc>-lines > 1.
   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     IF <mark_field> = 'X'.
       DELETE <table> INDEX syst-tabix.
       IF sy-subrc = 0.
         <tc>-lines = <tc>-lines - 1.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
 FORM compute_scrolling_in_tc USING    p_tc_name
                                       p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_tc_new_top_line     TYPE i.
   DATA l_tc_name             LIKE feld-name.
   DATA l_tc_lines_name       LIKE feld-name.
   DATA l_tc_field_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
   ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
   IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
     l_tc_new_top_line = 1.
   ELSE.
*&SPWIZARD: no, ...                                                    *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
       EXPORTING
         entry_act      = <tc>-top_line
         entry_from     = 1
         entry_to       = <tc>-lines
         last_page_full = 'X'
         loops          = <lines>
         ok_code        = p_ok
         overlapping    = 'X'
       IMPORTING
         entry_new      = l_tc_new_top_line
       EXCEPTIONS
*        NO_ENTRY_OR_PAGE_ACT  = 01
*        NO_ENTRY_TO    = 02
*        NO_OK_CODE_OR_PAGE_GO = 03
         OTHERS         = 0.
   ENDIF.

*&SPWIZARD: get actual tc and column                                   *
   GET CURSOR FIELD l_tc_field_name
              AREA  l_tc_name.

   IF syst-subrc = 0.
     IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
       SET CURSOR FIELD l_tc_field_name LINE 1.
     ENDIF.
   ENDIF.

*&SPWIZARD: set the new top line                                       *
   <tc>-top_line = l_tc_new_top_line.


 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_mark_lines USING p_tc_name
                                p_table_name
                                p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = 'X'.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_demark_lines USING p_tc_name
                                  p_table_name
                                  p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = space.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  FRM_CREATE_PO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM frm_create_po .


   DATA: ls_header  TYPE bapimepoheader,
         ls_headerx TYPE bapimepoheaderx.
   DATA lt_return2       TYPE TABLE OF bapi_alm_return.

   DATA lt_message      TYPE esp1_message_tab_type.
   DATA lw_message      TYPE esp1_message_wa_type.

   DATA: lt_return TYPE TABLE OF bapiret2,
         ls_return TYPE bapiret2.
   DATA: lt_poitem  TYPE TABLE OF bapimepoitem,
         ls_poitem  TYPE bapimepoitem,
         lt_poitemx TYPE TABLE OF bapimepoitemx,
         ls_poitemx TYPE bapimepoitemx.
   DATA: lt_poschedule  TYPE TABLE OF bapimeposchedule,
         ls_poschedule  TYPE bapimeposchedule,
         lt_poschedulex TYPE TABLE OF bapimeposchedulx,
         ls_poschedulex TYPE bapimeposchedulx.


   DATA: lt_poaccount  TYPE TABLE OF bapimepoaccount,
         ls_poaccount  TYPE bapimepoaccount,
         lt_poaccountx TYPE TABLE OF bapimepoaccountx,
         ls_poaccountx TYPE bapimepoaccountx.

   DATA lv_number TYPE bapimepoheader-po_number.
   DATA lt_serv TYPE TABLE OF bapiesllc.
   DATA lt_val TYPE TABLE OF bapiesklc.
   DATA ls_val TYPE bapiesklc.
   DATA ls_serv TYPE  bapiesllc.
   TYPES: BEGIN OF ys_ekko,
            ebeln TYPE ekko-ebeln,
            ekorg TYPE ekko-ekorg,
            ekgrp TYPE ekko-ekgrp,
            bukrs TYPE ekko-bukrs,
          END OF ys_ekko.
   DATA: ls_ekko TYPE ys_ekko,
         lt_ekko TYPE TABLE OF ys_ekko.
   DATA: lv_vgbel TYPE lips-vgbel.
   DATA: lv_ekorg TYPE ekko-ekorg,
         lv_ekgrp TYPE ekko-ekgrp,
         lv_bukrs TYPE ekko-bukrs.
   DATA: lv_message TYPE string.
   DATA: lv_po_line TYPE i.
   DATA l_pk TYPE packno.
   DATA l_no TYPE srv_line_no .
   CLEAR: lv_po_line.

   CLEAR: lv_message.

   CLEAR: lv_bukrs,lv_ekgrp,lv_ekorg.
   CLEAR: lv_vgbel.
   CLEAR: ls_ekko,lt_ekko[].
   CLEAR: ls_header,ls_headerx,ls_return,ls_poitem,ls_poitemx,
          ls_poschedule,ls_poschedulex.

   REFRESH: lt_return,lt_poitem,lt_poitemx,
          lt_poschedule,lt_poschedulex.


*po header fill
   ls_header-doc_type = 'Z7'.
   ls_header-vendor = zcs_po_head-lifnr .
   ls_header-purch_org = zcs_po_head-ekorg.
   ls_header-pur_group =  zcs_po_head-ekgrp.

   ls_headerx-doc_type = 'X'.
   ls_headerx-vendor = 'X'.
   ls_headerx-purch_org = 'X'.
   ls_headerx-pur_group = 'X'.

   l_no =  '0000000002'.
* article number
   DATA ls_line LIKE LINE OF g_ztc_itab.
   DATA l_net  LIKE zcs_po_item-tbtwr.

   LOOP AT g_ztc_itab INTO ls_line .
     l_net = l_net + ls_line-tbtwr.
   ENDLOOP.

   LOOP AT g_ztc_itab INTO ls_line .
*po item fill

     IF g_flg1 IS INITIAL.
       g_flg1 = 'X'.
       ls_poitem-po_item = ls_line-posnr.
       ls_poitem-plant = ls_line-werks."repair site
*     ls_poitem-material = ls_line-asnum.

       ls_poitem-short_text = 'SERVICE'.
       ls_poitem-matl_group = 'SERVICE'.
       ls_poitem-quantity = 1.
       ls_poitem-orderpr_un = 'ST'.
       ls_poitem-net_price = l_net.
       ls_poitem-item_cat = 'D'.
       ls_poitem-acctasscat = 'F'.
       ls_poitem-gr_ind = 'X'.
       ls_poitem-pckg_no = '0000000001'.
       ls_poitem-period_ind_expiration_date = 'D'.

       APPEND ls_poitem TO lt_poitem.

       ls_poitemx-po_item = ls_line-posnr.
       ls_poitemx-plant = 'X'.
*     ls_poitemx-material = 'X'.
       ls_poitemx-po_itemx = 'X'.
       ls_poitemx-short_text = 'X'.
       ls_poitemx-matl_group = 'X'.
       ls_poitemx-quantity = 'X'.
       ls_poitemx-orderpr_un = 'X'.
       ls_poitemx-net_price = 'X'.
       ls_poitemx-item_cat = 'X'.
       ls_poitemx-acctasscat = 'X'.
       ls_poitemx-gr_ind = 'X'.
       ls_poitemx-pckg_no = 'X'.
       ls_poitemx-period_ind_expiration_date = 'X'.
       APPEND ls_poitemx TO lt_poitemx.

*POSCHEDULE fill
       ls_poschedule-po_item = ls_line-posnr.
       ls_poschedule-sched_line = '0001'.
       ls_poschedule-del_datcat_ext = 'D'.
       ls_poschedule-delivery_date = sy-datlo.
       ls_poschedule-quantity = ls_line-menge.
       APPEND ls_poschedule TO lt_poschedule.

       ls_poschedulex-po_item = ls_line-posnr.
       ls_poschedulex-sched_line = '0001'.
       ls_poschedulex-po_itemx = 'X'.
       ls_poschedulex-sched_linex = 'X'.
       ls_poschedulex-del_datcat_ext = 'X'.
       ls_poschedulex-delivery_date = 'X'.
       ls_poschedulex-quantity = 'X'.
       APPEND ls_poschedulex TO lt_poschedulex.

*** ACCOUNT
       ls_poaccount-po_item = ls_line-posnr.
       ls_poaccount-serial_no = '01'.
       ls_poaccount-distr_perc = 1.

       ls_poaccount-gl_account = '0070700000'.
       SELECT SINGLE vbeln
         FROM qmel
         INTO @DATA(l_vbeln)
         WHERE qmnum = @zcs_po_head-qmnum.
*** Get service order according to sales order
       SELECT SINGLE aufnr
         FROM aufk
         INTO @DATA(l_aufnr)
        WHERE kdauf = @l_vbeln.

       ls_poaccount-orderid = l_aufnr.
       ls_poaccount-co_area = '4800'.
       ls_poaccount-tax_code = 'J0'.
       APPEND ls_poaccount TO lt_poaccount.

       ls_poaccountx-po_item = ls_line-posnr.
       ls_poaccountx-serial_no = '01'.
       ls_poaccountx-po_itemx = 'X'.
       ls_poaccountx-serial_nox = 'X'.
       ls_poaccountx-distr_perc = 'X'.
       ls_poaccountx-gl_account = 'X'.
       ls_poaccountx-orderid = 'X'.
       ls_poaccountx-co_area = 'X'.
       ls_poaccountx-tax_code = 'X'.
       APPEND ls_poaccountx TO lt_poaccountx.
     ENDIF.

*** POSERVICES


     IF lines( g_ztc_itab ) = 1.
       CLEAR ls_serv.
       l_pk = '0000000001'.
       ls_serv-pckg_no = l_pk.
       ls_serv-line_no = '0000000001'.

       ls_serv-outl_ind = 'X'.
       ls_serv-subpckg_no = '0000000002'.
       ls_serv-quantity = 1 .
       ls_serv-base_uom = 'ST'.
       ls_serv-price_unit = 1 .
       ls_serv-gr_price = ls_line-tbtwr .
       ls_serv-short_text = 'TEST'.
       APPEND ls_serv TO   lt_serv.

       CLEAR ls_serv.
       ls_serv-pckg_no = '0000000002'.
       ls_serv-line_no = '0000000002'.
       ls_serv-ext_line = ls_line-posnr.
       ls_serv-outl_ind = 'X'.
       ls_serv-service = ls_line-asnum.
       ls_serv-quantity = 1 .
       ls_serv-base_uom = 'ST'.
       ls_serv-price_unit = 1 .
       ls_serv-ovf_unlim = 'X'.
       ls_serv-gr_price = ls_line-tbtwr .
       ls_serv-short_text = 'TEST'.
       ls_serv-price_chg = 'X'.
       ls_serv-hi_line_no = '0000000001'.
       APPEND ls_serv TO   lt_serv.


       ls_val-pckg_no = '0000000002'.
       ls_val-line_no = '0000000002'.
       ls_val-serno_line = '01'.
       ls_val-serial_no = '01'.
       ls_val-quantity = 1.
       ls_val-net_value = ls_line-tbtwr.
       APPEND ls_val TO lt_val.


     ELSEIF lines( g_ztc_itab ) > 1.
       IF g_flg IS INITIAL.
         g_flg = 'X'.
         CLEAR ls_serv.
         l_pk = '0000000001'.
         ls_serv-pckg_no = l_pk.
         ls_serv-line_no = '0000000001'.

         ls_serv-outl_ind = 'X'.
         ls_serv-subpckg_no = '0000000002'.
         ls_serv-quantity = 1 .
         ls_serv-base_uom = 'ST'.
         ls_serv-price_unit = 1 .
         ls_serv-gr_price = l_net .
         ls_serv-short_text = 'TEST'.
         APPEND ls_serv TO   lt_serv.
       ENDIF.

       CLEAR ls_serv.
       l_no = l_no + 1.
       ls_serv-pckg_no = '0000000002'.
       ls_serv-line_no = l_no.
       ls_serv-ext_line = ls_line-posnr.
       ls_serv-outl_ind = 'X'.
       ls_serv-service = ls_line-asnum.
       ls_serv-quantity = ls_line-menge .
       ls_serv-base_uom = 'ST'.
       ls_serv-price_unit = 1 .
       ls_serv-ovf_unlim = 'X'.
       ls_serv-gr_price = ls_line-tbtwr .
       ls_serv-short_text = 'TEST'.
       ls_serv-price_chg = 'X'.
       ls_serv-hi_line_no = '0000000001'.
       APPEND ls_serv TO   lt_serv.

       ls_val-pckg_no = '0000000002'.
       ls_val-line_no = l_no.
       ls_val-serno_line = '01'.
       ls_val-serial_no = '01'.
       ls_val-quantity = ls_line-menge.
       ls_val-net_value = ls_line-tbtwr.
       APPEND ls_val TO lt_val.

     ENDIF.


***
   ENDLOOP.



   CALL FUNCTION 'BAPI_PO_CREATE1'
     EXPORTING
       poheader          = ls_header
       poheaderx         = ls_headerx
     IMPORTING
       exppurchaseorder  = lv_number
*      EXPHEADER         =
*      EXPPOEXPIMPHEADER =
     TABLES
       return            = lt_return
       poitem            = lt_poitem
       poitemx           = lt_poitemx
*      POADDRDELIVERY    =
       poschedule        = lt_poschedule
       poschedulex       = lt_poschedulex
       poaccount         = lt_poaccount
       poaccountx        = lt_poaccountx
       poservices        = lt_serv
       posrvaccessvalues = lt_val.
*       poshipping       = lt_poshipping
*       poshippingx      = lt_poshippingx.
*      POSHIPPINGEXP    =
*       serialnumber     = lt_serialnumber
*       serialnumberx    = lt_serialnumberx.
*successful
   IF lv_number <> ''.
     CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
       EXPORTING
         wait = 'X'.

     UPDATE zcs_po_head
        SET status = '1'
            ebeln = lv_number
        WHERE qmnum = zcs_po_head-qmnum.
     MESSAGE s000 WITH '成功创建po!' lv_number.


   ELSE.
     CLEAR: g_flg,g_flg1.


     CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*     MESSAGE s000 WITH '成功创建po!' lv_number DISPLAY LIKE 'E'.
     LOOP AT lt_return INTO DATA(ls_ret).
       lw_message-msgid      = ls_ret-id.
       lw_message-msgty      = ls_ret-type.
       lw_message-msgno      = ls_ret-number.
       lw_message-msgv1      = ls_ret-message_v1.
       lw_message-msgv2      = ls_ret-message_v2.
       lw_message-msgv3      = ls_ret-message_v3.
       lw_message-msgv4      = ls_ret-message_v4.
       lw_message-lineno = sy-tabix.
       APPEND lw_message TO lt_message[].
     ENDLOOP.
     IF lt_message[] IS NOT INITIAL.
       CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
         TABLES
           i_message_tab = lt_message.
     ENDIF.

   ENDIF.





 ENDFORM.
