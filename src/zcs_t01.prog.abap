*&---------------------------------------------------------------------*
*&  Include  ZCS_FUN_T01
*&---------------------------------------------------------------------*

***&SPWIZARD: DATA DECLARATION FOR TABLECONTROL 'ZTC'
*&SPWIZARD: DEFINITION OF DDIC-TABLE
TABLES: zcs_po_head,  zcs_po_item.

*&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'ZTC'
TYPES: BEGIN OF t_ztc,
         chk   TYPE c,
         posnr LIKE zcs_po_item-posnr,
         asnum LIKE zcs_po_item-asnum,
         maktx LIKE zcs_po_item-maktx,
         menge LIKE zcs_po_item-menge,
         tbtwr LIKE zcs_po_item-tbtwr,
         werks LIKE zcs_po_item-werks,
       END OF t_ztc.

*&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'ZTC'
DATA: g_ztc_itab TYPE t_ztc OCCURS 0,
      g_ztc_wa   TYPE t_ztc. "work area
DATA:     g_ztc_copied.           "copy flag

*&SPWIZARD: DECLARATION OF TABLECONTROL 'ZTC' ITSELF
CONTROLS: ztc TYPE TABLEVIEW USING SCREEN 9000.

*&SPWIZARD: LINES OF TABLECONTROL 'ZTC'
DATA:     g_ztc_lines  LIKE sy-loopc.

DATA:     ok_code LIKE sy-ucomm.
DATA: g_qmnum TYPE qmel-qmnum.
DATA g_answer  TYPE c.
data g_flag type i.
data: g_flg type c.

data: g_flg1 type c.
