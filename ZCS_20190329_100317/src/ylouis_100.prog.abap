*&---------------------------------------------------------------------*
*& Report  YLOUIS_100
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ylouis_100.
PARAMETERS:p_r1  RADIOBUTTON GROUP gr1 DEFAULT 'X',
           p_r2  RADIOBUTTON GROUP gr1,
           p_r1n RADIOBUTTON GROUP gr1,
           p_r2n RADIOBUTTON GROUP gr1.


CASE 'X'.
  WHEN p_r1.
    PERFORM test1.
  WHEN p_r2.
    PERFORM test2.
  WHEN p_r1n.
    PERFORM test1_new.
  WHEN p_r2n.
    PERFORM test2_new.
ENDCASE.


FORM test1.

  DATA lr_kunnr TYPE RANGE OF kunnr.
  DATA lrs_kunnr LIKE LINE OF lr_kunnr.
  SELECT DISTINCT t1~kunnr,
         t1~vbeln,
         t4~name1
  INTO TABLE @DATA(lt_likp)
     FROM likp AS t1
     JOIN vbuk AS t2
     ON t1~vbeln = t2~vbeln
     JOIN lips AS t3
     ON t1~vbeln = t3~vbeln
     LEFT JOIN kna1 AS t4
     ON t1~kunnr = t4~kunnr
     WHERE t3~werks = '4850'
     AND t1~status = '1'
    AND t2~wbstk <> 'C'
    AND t1~kunnr IN @lr_kunnr.
  IF lt_likp IS NOT INITIAL.
    SELECT DISTINCT
            t1~vbeln,
            t1~auart,
            t2~vbeln AS vbeln_vl
        FROM vbak AS t1
        JOIN lips AS t2
        ON t1~vbeln = t2~vgbel
        INTO TABLE @DATA(lt_zss1order)
        FOR ALL ENTRIES IN @lt_likp
        WHERE t2~vbeln = @lt_likp-vbeln
        AND t1~auart = 'ZSS1'.
    "exclude sales order type ZSS1
    LOOP AT lt_zss1order INTO DATA(ls_zss1order).
      DELETE lt_likp WHERE vbeln = ls_zss1order-vbeln_vl.
    ENDLOOP.

    DATA ls_customer TYPE zcl_zcs_gi_confirm_mpc=>ts_customer.
    SORT lt_likp BY kunnr vbeln.
    LOOP AT lt_likp ASSIGNING FIELD-SYMBOL(<fs_likp>).
      AT NEW kunnr.
        ls_customer-kunnr = <fs_likp>-kunnr.
        ls_customer-kuname = <fs_likp>-name1.
      ENDAT.
      ls_customer-dlvcount = ls_customer-dlvcount + 1.
      AT END OF kunnr.
*      APPEND ls_customer TO et_customer.
        CLEAR ls_customer.
      ENDAT.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TEST2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM test2 .
  DATA lr_kunnr TYPE RANGE OF kunnr.
  DATA lrs_kunnr LIKE LINE OF lr_kunnr.

  DATA lr_vbeln TYPE RANGE OF vbeln_vl.
  DATA lrs_vbeln LIKE LINE OF lr_vbeln.

  SELECT DISTINCT
     t1~kunnr,
     t1~vbeln,
     t1~awbno,
     t4~name1
INTO TABLE @DATA(lt_likp)
     FROM likp AS t1
     JOIN vbuk AS t2
     ON t1~vbeln = t2~vbeln
     JOIN lips AS t3
     ON t1~vbeln = t3~vbeln
     LEFT JOIN kna1 AS t4
     ON t1~kunnr = t4~kunnr
     WHERE t3~werks = '4850'
     AND t1~status = '1'
    AND t2~wbstk <> 'C'
    AND t1~vbeln IN @lr_vbeln
    AND t1~kunnr IN @lr_kunnr.
  IF lt_likp IS NOT INITIAL.
    SELECT DISTINCT
            t1~vbeln,
            t1~auart,
            t2~vbeln AS vbeln_vl
        FROM vbak AS t1
        JOIN lips AS t2
        ON t1~vbeln = t2~vgbel
        INTO TABLE @DATA(lt_zss1order)
        FOR ALL ENTRIES IN @lt_likp
        WHERE t2~vbeln = @lt_likp-vbeln
        AND t1~auart = 'ZSS1'.
    "exclude sales order type ZSS1
    LOOP AT lt_zss1order INTO DATA(ls_zss1order).
      DELETE lt_likp WHERE vbeln = ls_zss1order-vbeln_vl.
    ENDLOOP.

    DATA ls_dlvorders  TYPE zcl_zcs_gi_confirm_mpc=>ts_dlvorder.
    SORT lt_likp BY kunnr vbeln.
    LOOP AT lt_likp INTO DATA(ls_likp).
      ls_dlvorders-vbeln = ls_likp-vbeln.
      ls_dlvorders-kunnr = ls_likp-kunnr.
      ls_dlvorders-awbno = ls_likp-awbno.
*      APPEND ls_dlvorders TO et_dlvorder.
    ENDLOOP.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TEST1_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM test1_new .

  TYPES:BEGIN OF ty_out,
          kunnr TYPE likp-kunnr,
          vbeln TYPE likp-vbeln,
          vgbel TYPE lips-vgbel,
          name1 TYPE kna1-name1,
        END OF ty_out.
  DATA lt_out TYPE TABLE OF ty_out.
  DATA ls_out TYPE          ty_out.

  DATA lt_likp TYPE TABLE OF ty_out.
  DATA ls_likp TYPE          ty_out.

  DATA lr_kunnr    TYPE RANGE OF kunnr.
  DATA lrs_kunnr   LIKE LINE  OF lr_kunnr.
  DATA lr_vkorg    TYPE RANGE OF vkorg.
  DATA lrs_vkorg   LIKE LINE  OF lr_vkorg.

  DATA lr_erdat    TYPE RANGE OF erdat.
  DATA lrs_erdat   LIKE LINE  OF lr_erdat.

  DATA ls_zfiort01 TYPE  zfiort01.

  DATA lt_zbc_ctrl_item TYPE TABLE OF zbc_ctrl_item.
  DATA ls_zbc_ctrl_item TYPE          zbc_ctrl_item.
  CLEAR:lt_out,ls_out,lr_kunnr,lr_vkorg,lrs_kunnr,lrs_vkorg.
  CLEAR:lt_zbc_ctrl_item,ls_zbc_ctrl_item,ls_zfiort01.
  CLEAR:lr_erdat,lrs_erdat.

*VKORG
  SELECT *
    INTO TABLE lt_zbc_ctrl_item
    FROM zbc_ctrl_item
    WHERE zenh_id = 'SD-061'
      AND active = 'X'.

  LOOP AT lt_zbc_ctrl_item INTO ls_zbc_ctrl_item.
    CLEAR:lrs_vkorg.
    lrs_vkorg-low = ls_zbc_ctrl_item-vkorg.
    lrs_vkorg-sign = 'I'.
    lrs_vkorg-option = 'EQ'.
    APPEND lrs_vkorg TO lr_vkorg.
  ENDLOOP.

*ERDAT
  DATA lv_date_i TYPE sy-datum.
  DATA lv_date_o TYPE sy-datum.
  CLEAR:lv_date_i,lv_date_o.

  SELECT SINGLE *
    INTO ls_zfiort01
    FROM zfiort01
    WHERE uname = sy-uname.

  lv_date_i = sy-datum.

  IF ls_zfiort01-anzdays IS INITIAL.
    lrs_erdat-high   = sy-datum.
    lrs_erdat-option = 'BT'.
    lrs_erdat-sign   = 'I'.
    lrs_erdat-low    = '20190101'.
    APPEND lrs_erdat TO lr_erdat.
  ELSE.
    CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
      EXPORTING
        date      = lv_date_i
        days      = ls_zfiort01-anzdays
        months    = '00'
        signum    = '-'
        years     = '00'
      IMPORTING
        calc_date = lv_date_o.

    lrs_erdat-high   = sy-datum.
    lrs_erdat-option = 'BT'.
    lrs_erdat-sign   = 'I'.
    lrs_erdat-low    = lv_date_o.
    APPEND lrs_erdat TO lr_erdat.
  ENDIF.
*
*  READ TABLE it_filter_select_options INTO DATA(ls_filter) WITH KEY property = 'KUNNR'.
*  IF sy-subrc = 0.
*    LOOP AT ls_filter-select_options INTO DATA(ls_options).
*      lrs_kunnr-sign    = ls_options-sign  .
*      lrs_kunnr-option  = ls_options-option.
*      lrs_kunnr-low     = ls_options-low   .
*      lrs_kunnr-high    = ls_options-high  .
*      APPEND lrs_kunnr TO lr_kunnr.
*    ENDLOOP.
*  ENDIF.
*  IF iv_kunnr IS NOT INITIAL.
*    CLEAR lrs_kunnr.
*    lrs_kunnr-sign    = 'I' .
*    lrs_kunnr-option  = 'EQ'.
*    lrs_kunnr-low     = iv_kunnr.
*    APPEND lrs_kunnr TO lr_kunnr.
*  ENDIF.

  SELECT DISTINCT t1~kunnr,t1~vbeln,t3~vgbel
        INTO CORRESPONDING FIELDS OF TABLE @lt_out
        FROM likp AS t1
        JOIN vbuk AS t2 ON t1~vbeln = t2~vbeln
        JOIN lips AS t3 ON t1~vbeln = t3~vbeln
        WHERE t1~erdat IN @lr_erdat
          AND t1~vkorg IN @lr_vkorg
          AND t1~kunnr IN @lr_kunnr
          AND t1~status = '1'
          AND t3~werks = '4850'
          AND t2~wbstk <> 'C'.

*VBAK
  CLEAR:lt_likp.
  lt_likp[] = lt_out[].
  SORT lt_likp BY vgbel.
  DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING vgbel.
  IF lt_likp[] IS NOT INITIAL.
    SELECT DISTINCT vbeln,auart
        FROM vbak
        INTO TABLE @DATA(lt_zss1order)
        FOR ALL ENTRIES IN @lt_likp
        WHERE vbeln = @lt_likp-vgbel
          AND auart = 'ZSS1'.

    LOOP AT lt_zss1order INTO DATA(ls_zss1order).
      DELETE lt_out WHERE vgbel = ls_zss1order-vbeln.
    ENDLOOP.
  ENDIF.

*KNA1
  CLEAR:lt_likp.
  lt_likp[] = lt_out[].
  SORT lt_likp BY kunnr.
  DELETE ADJACENT DUPLICATES FROM lt_likp COMPARING kunnr.
  IF lt_likp[] IS NOT INITIAL.
    SELECT kunnr,name1
      INTO TABLE @DATA(lt_kna1)
      FROM kna1
      FOR ALL ENTRIES IN @lt_likp
      WHERE kunnr = @lt_likp-kunnr.

    SORT lt_kna1 BY kunnr.
  ENDIF.

  IF lt_out IS NOT INITIAL.
    DATA ls_customer TYPE zcl_zcs_gi_confirm_mpc=>ts_customer.
    SORT lt_likp BY kunnr vbeln.

    LOOP AT lt_out ASSIGNING FIELD-SYMBOL(<fs_out>).
      AT NEW kunnr.
        READ TABLE lt_kna1 INTO DATA(ls_kna1)
             WITH KEY kunnr = <fs_out>-kunnr BINARY SEARCH.
        IF sy-subrc = 0.
          ls_customer-kuname = ls_kna1-name1.
        ENDIF.
        ls_customer-kunnr  = <fs_out>-kunnr.
      ENDAT.

      ls_customer-dlvcount = ls_customer-dlvcount + 1.

      AT END OF kunnr.
*        APPEND ls_customer TO et_customer.
        CLEAR ls_customer.
      ENDAT.
    ENDLOOP.
  ENDIF.
*end----louis----20190312


*  DATA lr_kunnr TYPE RANGE OF kunnr.
*  DATA lrs_kunnr LIKE LINE OF lr_kunnr.
*  TYPES:BEGIN OF ty_likp,
*          kunnr TYPE likp-kunnr,
*          vbeln TYPE likp-vbeln,
*          name1 TYPE kna1-name1,
*          vgbel TYPE lips-vgbel,
*        END OF ty_likp.
*  DATA lt_likp TYPE TABLE OF ty_likp.
*
*  SELECT DISTINCT likp~vbeln likp~kunnr lips~vgbel
*      INTO CORRESPONDING FIELDS OF TABLE lt_likp
*      FROM lips
*      INNER JOIN likp ON likp~vbeln = lips~vbeln
*      INNER JOIN vbuk ON vbuk~vbeln = likp~vbeln
*      WHERE lips~werks = '4850'
*        AND likp~status = '1'
**        AND LIPS~ERNAM = SY-UNAME
*        AND vbuk~wbstk <> 'C'.
*
*
*  DATA wt_likp TYPE TABLE OF ty_likp.
*  CLEAR:wt_likp.
*  wt_likp[] = lt_likp[].
*  SORT wt_likp BY kunnr.
*  DELETE ADJACENT DUPLICATES FROM wt_likp COMPARING kunnr.
*  IF wt_likp[] IS NOT INITIAL.
*    SELECT kunnr,name1
*      INTO TABLE @DATA(lt_kna1)
*      FROM kna1
*      FOR ALL ENTRIES IN @wt_likp
*      WHERE kunnr = @wt_likp-kunnr.
*  ENDIF.
*
*  SORT lt_kna1 BY kunnr.
*  LOOP AT lt_likp ASSIGNING FIELD-SYMBOL(<fs_likp>).
*    READ TABLE lt_kna1 INTO DATA(ls_kna1)
*         WITH KEY kunnr = <fs_likp>-kunnr BINARY SEARCH.
*    IF sy-subrc = 0.
*      <fs_likp>-name1 = ls_kna1-name1.
*    ENDIF.
*  ENDLOOP.
*
**
*  CLEAR:wt_likp.
*  wt_likp[] = lt_likp[].
*  SORT wt_likp BY vgbel.
*  DELETE ADJACENT DUPLICATES FROM wt_likp COMPARING vgbel.
*  IF wt_likp[] IS NOT INITIAL.
*    SELECT DISTINCT
*            vbeln,
*            auart
*        FROM vbak AS t1
*        INTO TABLE @DATA(lt_zss1order)
*        FOR ALL ENTRIES IN @wt_likp
*        WHERE vbeln = @wt_likp-vgbel
*          AND auart = 'ZSS1'.
*
*  ENDIF.
*
*
**  SELECT DISTINCT t1~kunnr,
**         t1~vbeln,
**         t4~name1
**  INTO TABLE @DATA(lt_likp)
**     FROM likp AS t1
**     JOIN vbuk AS t2
**     ON t1~vbeln = t2~vbeln
**     JOIN lips AS t3
**     ON t1~vbeln = t3~vbeln
**     LEFT JOIN kna1 AS t4
**     ON t1~kunnr = t4~kunnr
**     WHERE t3~werks = '4850'
**     AND t1~status = '1'
**    AND t2~wbstk <> 'C'
**    AND t1~kunnr IN @lr_kunnr.
*
*
*
*  IF lt_likp IS NOT INITIAL.
**    SELECT DISTINCT
**            t1~vbeln,
**            t1~auart,
**            t2~vbeln AS vbeln_vl
**        FROM vbak AS t1
**        JOIN lips AS t2
**        ON t1~vbeln = t2~vgbel
**        INTO TABLE @DATA(lt_zss1order)
**        FOR ALL ENTRIES IN @lt_likp
**        WHERE t2~vbeln = @lt_likp-vbeln
**        AND t1~auart = 'ZSS1'.
*    "exclude sales order type ZSS1
*    LOOP AT lt_zss1order INTO DATA(ls_zss1order).
*      DELETE lt_likp WHERE vgbel = ls_zss1order-vbeln.
*    ENDLOOP.
*
*    DATA ls_customer TYPE zcl_zcs_gi_confirm_mpc=>ts_customer.
*    SORT lt_likp BY kunnr vbeln.
*    LOOP AT lt_likp ASSIGNING <fs_likp>.
*      AT NEW kunnr.
*        ls_customer-kunnr = <fs_likp>-kunnr.
*        ls_customer-kuname = <fs_likp>-name1.
*      ENDAT.
*      ls_customer-dlvcount = ls_customer-dlvcount + 1.
*      AT END OF kunnr.
**      APPEND ls_customer TO et_customer.
*        CLEAR ls_customer.
*      ENDAT.
*    ENDLOOP.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TEST2_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM test2_new.
  DATA lr_kunnr TYPE RANGE OF kunnr.
  DATA lrs_kunnr LIKE LINE OF lr_kunnr.

  DATA lr_vbeln TYPE RANGE OF vbeln_vl.
  DATA lrs_vbeln LIKE LINE OF lr_vbeln.

  SELECT DISTINCT
     t1~kunnr,
     t1~vbeln,
     t1~awbno,
     t4~name1
INTO TABLE @DATA(lt_likp)
     FROM likp AS t1
     JOIN vbuk AS t2
     ON t1~vbeln = t2~vbeln
     JOIN lips AS t3
     ON t1~vbeln = t3~vbeln
     LEFT JOIN kna1 AS t4
     ON t1~kunnr = t4~kunnr
     WHERE t3~werks = '4850'
     AND t1~status = '1'
    AND t2~wbstk <> 'C'
    AND t1~vbeln IN @lr_vbeln
    AND t1~kunnr IN @lr_kunnr.
  IF lt_likp IS NOT INITIAL.
    SELECT DISTINCT
            t1~vbeln,
            t1~auart,
            t2~vbeln AS vbeln_vl
        FROM vbak AS t1
        JOIN lips AS t2
        ON t1~vbeln = t2~vgbel
        INTO TABLE @DATA(lt_zss1order)
        FOR ALL ENTRIES IN @lt_likp
        WHERE t2~vbeln = @lt_likp-vbeln
        AND t1~auart = 'ZSS1'.
    "exclude sales order type ZSS1
    LOOP AT lt_zss1order INTO DATA(ls_zss1order).
      DELETE lt_likp WHERE vbeln = ls_zss1order-vbeln_vl.
    ENDLOOP.

    DATA ls_dlvorders  TYPE zcl_zcs_gi_confirm_mpc=>ts_dlvorder.
    SORT lt_likp BY kunnr vbeln.
    LOOP AT lt_likp INTO DATA(ls_likp).
      ls_dlvorders-vbeln = ls_likp-vbeln.
      ls_dlvorders-kunnr = ls_likp-kunnr.
      ls_dlvorders-awbno = ls_likp-awbno.
*      APPEND ls_dlvorders TO et_dlvorder.
    ENDLOOP.
  ENDIF.
ENDFORM.
