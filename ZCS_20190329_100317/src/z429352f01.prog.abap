*&---------------------------------------------------------------------*
*&  Include           Z429352F01
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*& Objekt          REPS Z429352F01
*& Objekt Header   PROG Z429352F01
*&--------------------------------------------------------------------*
*>>>> START OF INSERTION <<<<
*----------------------------------------------------------------------*
*   INCLUDE Z429352F01                                                 *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM write_list                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form write_list.

  data: ls_docflow like gs_docflow.

  perform get_list.

  loop at gt_docflow into gs_docflow.
    if gs_docflow-position = 1.
      ls_docflow = gs_docflow.
      clear gs_docflow.
      uline.
      hide: gs_docflow-line, gs_docflow-display_mode.
      gs_docflow = ls_docflow.
    endif.
    write at /gs_docflow-position gs_docflow-content.
    if not gs_docflow-errortext is initial.
      write at 50 gs_docflow-errortext.
    endif.
    hide: gs_docflow-line, gs_docflow-display_mode.
  endloop.
  uline.

endform.

*---------------------------------------------------------------------*
*       FORM get_list                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form get_list.

  data: ls_rmabuf like gs_rmaorderinfo.
  data: lv_off like sy-tabix.
  data: lv_icon(4) type c.

* sort data, remove duplicates
  sort gt_rmaorderinfo by
    errorlevel descending
    vbeln ascending
    posnr ascending
    pos_sub ascending
    aufnr ascending
    status_aufnr ascending
    vbeln_vbep ascending
    posnr_vbep ascending
    vbeln_aufk ascending
    posnr_aufk ascending
    afru_rueck ascending
    afru_rmzhl ascending
    aufm_mblnr ascending
    aufm_zeile ascending
    eban_banfn ascending
    eban_bnfpo ascending
    ekko_ebeln ascending
    vbfa_0_vbtyp_n ascending
    vbfa_0_vbeln ascending
    vbfa_0_posnn ascending
    vbfa_1_vbtyp_n ascending
    vbfa_1_vbeln ascending
    vbfa_1_posnn ascending.

  delete adjacent duplicates from gt_rmaorderinfo.

* write data
  ls_rmabuf-vbeln = '#'.
  loop at gt_rmaorderinfo into gs_rmaorderinfo.
*   at vbeln change
    if gs_rmaorderinfo-vbeln <> ls_rmabuf-vbeln.
*      uline.
      case gs_rmaorderinfo-errorlevel.
        when '3'.
          gs_docflow-content = '@5C@'.
        when '2' or '1'.
          gs_docflow-content = '@5D@'.
        when others.
          gs_docflow-content = '@5B@'.
      endcase.
      if gs_rmaorderinfo-vbeln is initial.
        write text-005 to gs_docflow-content+5.
      else.
        write text-004 to gs_docflow-content+5.
        perform get_offset using gs_docflow-content changing lv_off.
        write gs_rmaorderinfo-vbeln to gs_docflow-content+lv_off.
        gs_docflow-position = 1.
      endif.
    endif.
*   at posnr change
    if gs_rmaorderinfo-posnr <> ls_rmabuf-posnr and not
       gs_rmaorderinfo-posnr is initial.
      write '@IF@' to gs_docflow-content.
      write text-006 to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-posnr to gs_docflow-content+lv_off no-zero.
      gs_docflow-position = 7.
    endif.
*   at pos_sub change
    if gs_rmaorderinfo-pos_sub <> ls_rmabuf-pos_sub and not
       gs_rmaorderinfo-pos_sub is initial.
      write '@IF@' to gs_docflow-content.
      write text-007 to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-pos_sub
        to gs_docflow-content+lv_off no-zero.
      gs_docflow-position = 9.
    endif.
*   at status_aufnr change
    if not gs_rmaorderinfo-status_aufnr is initial and not
           gs_rmaorderinfo-status_aufnr = ls_rmabuf-status_aufnr.
      gs_docflow-content = '@AI@'.
      if gs_rmaorderinfo-aufnr is initial.
        gs_docflow-position = 9.
        write text-008 to gs_docflow-content+5.
      else.
        gs_docflow-position = 13.
        write text-009 to gs_docflow-content+5.
      endif.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-status_aufnr to gs_docflow-content+lv_off.
    endif.
*   at vbfa_0_vbeln change
    if not ( gs_rmaorderinfo-vbfa_0_vbeln is initial and
           gs_rmaorderinfo-vbfa_0_posnn is initial ) and not
           ( gs_rmaorderinfo-vbfa_0_vbeln = ls_rmabuf-vbfa_0_vbeln and
           gs_rmaorderinfo-vbfa_0_posnn = ls_rmabuf-vbfa_0_posnn ).
      clear gs_docflow-content.
      case gs_rmaorderinfo-vbfa_0_vbtyp_n.
        when 'T' or 'J'.  "Lieferung, Retourenl.
          lv_icon = '@4A@'. " icon
        when 'M'.  "Rechnung
          lv_icon = '@DH@'.
        when 'N'.  "Rechnung Storno
          lv_icon = '@BA@'. "DR?
        when 'K' or 'L'. "Gutschiftanf., Lastschriftanf.
          lv_icon = '@GZ@'.
        when 'R'.  "Mat.doc
          lv_icon = '@B3@'.
        when others.
          lv_icon = '@IF@'.
      endcase.
      gs_docflow-content = lv_icon.
      write gs_rmaorderinfo-vbfa_0_doctext to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-vbfa_0_vbeln
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      if gs_rmaorderinfo-vbfa_0_vbtyp_n = 'R'.
        write '/' to gs_docflow-content+lv_off.
        add 2 to lv_off.
      endif.
      write gs_rmaorderinfo-vbfa_0_posnn to gs_docflow-content+lv_off
        no-zero.
      if gs_rmaorderinfo-vbfa_1_vbtyp_n = 'R'.
        perform get_offset using gs_docflow-content changing lv_off.
        write '(' to gs_docflow-content+lv_off.
        add 4 to lv_off.
        write text-010 to gs_docflow-content+lv_off no-zero.
        perform get_offset using gs_docflow-content changing lv_off.
        write gs_rmaorderinfo-aufm_matnr
          to gs_docflow-content+lv_off no-zero.
        perform get_offset using gs_docflow-content changing lv_off.
        write ',' to gs_docflow-content+lv_off.
        add 2 to lv_off.
        write gs_rmaorderinfo-aufm_menge
          unit gs_rmaorderinfo-aufm_meins
          to gs_docflow-content+lv_off left-justified.
        perform get_offset using gs_docflow-content changing lv_off.
        write gs_rmaorderinfo-aufm_meins to gs_docflow-content+lv_off.
        perform get_offset using gs_docflow-content changing lv_off.
        write ',' to gs_docflow-content+lv_off.
        add 2 to lv_off.
        write text-011 to gs_docflow-content+lv_off no-zero.
        perform get_offset using gs_docflow-content changing lv_off.
        write gs_rmaorderinfo-aufm_bwart
          to gs_docflow-content+lv_off no-zero.
        add 3 to lv_off.
        write gs_rmaorderinfo-aufm_sobkz
          to gs_docflow-content+lv_off no-zero.
        add 2 to lv_off.
        write ')' to gs_docflow-content+lv_off.
      endif.
      gs_docflow-position = 11.
    endif.
*   at vbfa_1_vbeln change
    if not ( gs_rmaorderinfo-vbfa_1_vbeln is initial and
           gs_rmaorderinfo-vbfa_1_posnn is initial ) and not
           ( gs_rmaorderinfo-vbfa_1_vbeln = ls_rmabuf-vbfa_1_vbeln and
           gs_rmaorderinfo-vbfa_1_posnn = ls_rmabuf-vbfa_1_posnn ).
      case gs_rmaorderinfo-vbfa_1_vbtyp_n.
        when 'T' or 'J'.  "Lieferung, Retourenl.
          lv_icon = '@4A@'. " icon
        when 'M'.  "Rechnung
          lv_icon = '@DH@'.
        when 'N'.  "Rechnung Storno
          lv_icon = '@BA@'. "DR?
        when 'K' or 'L'. "Gutschiftanf., Lastschriftanf.
          lv_icon = '@GZ@'.
        when 'R'.  "Mat.doc
          lv_icon = '@B3@'.
        when others.
          lv_icon = '@IF@'.
      endcase.
      gs_docflow-content = lv_icon.
      write gs_rmaorderinfo-vbfa_1_doctext to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-vbfa_1_vbeln
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      if gs_rmaorderinfo-vbfa_1_vbtyp_n = 'R'.
        write '/' to gs_docflow-content+lv_off.
        add 2 to lv_off.
      endif.
      write gs_rmaorderinfo-vbfa_1_posnn to gs_docflow-content+lv_off
        no-zero.
      if gs_rmaorderinfo-vbfa_1_vbtyp_n = 'R'.
        perform get_offset using gs_docflow-content changing lv_off.
        write '(' to gs_docflow-content+lv_off.
        add 4 to lv_off.
        write text-010 to gs_docflow-content+lv_off no-zero.
        perform get_offset using gs_docflow-content changing lv_off.
        write gs_rmaorderinfo-aufm_matnr
          to gs_docflow-content+lv_off no-zero.
        perform get_offset using gs_docflow-content changing lv_off.
        write ',' to gs_docflow-content+lv_off.
        add 2 to lv_off.
        write gs_rmaorderinfo-aufm_menge
          unit gs_rmaorderinfo-aufm_meins
          to gs_docflow-content+lv_off left-justified.
        perform get_offset using gs_docflow-content changing lv_off.
        write gs_rmaorderinfo-aufm_meins to gs_docflow-content+lv_off.
        perform get_offset using gs_docflow-content changing lv_off.
        write ',' to gs_docflow-content+lv_off.
        add 2 to lv_off.
        write text-011 to gs_docflow-content+lv_off no-zero.
        perform get_offset using gs_docflow-content changing lv_off.
        write gs_rmaorderinfo-aufm_bwart
          to gs_docflow-content+lv_off no-zero.
        add 3 to lv_off.
        write gs_rmaorderinfo-aufm_sobkz
          to gs_docflow-content+lv_off no-zero.
        add 2 to lv_off.
        write ')' to gs_docflow-content+lv_off.
      endif.
      gs_docflow-position = 13.
    endif.
*   at aufnr change
    if gs_rmaorderinfo-aufnr <> ls_rmabuf-aufnr and not
       gs_rmaorderinfo-aufnr is initial.
      gs_docflow-content = '@45@'.
      write text-012 to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-aufnr to gs_docflow-content+lv_off no-zero.
      write gs_rmaorderinfo-errortext to gs_docflow-errortext.
      clear gs_rmaorderinfo-errortext.
      gs_docflow-position = 11.
    endif.
*   at vbeln_vbep change
    if not gs_rmaorderinfo-vbeln_vbep is initial and not
           gs_rmaorderinfo-vbeln_vbep = ls_rmabuf-vbeln_vbep.
      gs_docflow-content = '@5C@'.
      write text-013
        to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write '(' to gs_docflow-content+lv_off.
      add 2 to lv_off.
      write gs_rmaorderinfo-vbeln_vbep
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write '/' to gs_docflow-content+lv_off.
      add 1 to lv_off.
      write gs_rmaorderinfo-posnr_vbep
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write ')' to gs_docflow-content+lv_off.
      gs_docflow-position = 13.
    endif.
*   at vbeln_aufk change
    if not gs_rmaorderinfo-vbeln_aufk is initial and not
           gs_rmaorderinfo-vbeln_aufk = ls_rmabuf-vbeln_aufk.
      gs_docflow-content = '@5C@'.
      write text-014 "'Serviceauftrag verweist auf andere Hauptposition'
        to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write '(' to gs_docflow-content+lv_off.
      add 2 to lv_off.
      write gs_rmaorderinfo-vbeln_aufk
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write '/' to gs_docflow-content+lv_off.
      add 1 to lv_off.
      write gs_rmaorderinfo-posnr_aufk
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write ')' to gs_docflow-content+lv_off.
      gs_docflow-position = 13.
      clear gs_rmaorderinfo-errortext.
    endif.
*   at afru_rueck change
    if not ( gs_rmaorderinfo-afru_rueck is initial or
           gs_rmaorderinfo-afru_rmzhl is initial ) and not
           ( gs_rmaorderinfo-afru_rueck = ls_rmabuf-afru_rueck and
           gs_rmaorderinfo-afru_rmzhl = ls_rmabuf-afru_rmzhl ).
      if gs_rmaorderinfo-afru_stokz is initial.
        gs_docflow-content = '@B4@'.
      else.
        gs_docflow-content = '@B6@'.
      endif.
      write text-015 to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-afru_rueck
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-afru_rmzhl
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write text-016 to gs_docflow-content+lv_off.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-afru_vornr
        to gs_docflow-content+lv_off no-zero.
      if not gs_rmaorderinfo-afru_stokz is initial.
        perform get_offset using gs_docflow-content changing lv_off.
        write text-017 to gs_docflow-content+lv_off.
      endif.
      gs_docflow-position = 13.
    endif.
*   at aufm_mblnr change
    if not ( gs_rmaorderinfo-aufm_mblnr is initial or
           gs_rmaorderinfo-aufm_zeile is initial ) and not
           ( gs_rmaorderinfo-aufm_mblnr = ls_rmabuf-aufm_mblnr and
           gs_rmaorderinfo-aufm_zeile = ls_rmabuf-aufm_zeile ).
      gs_docflow-content = '@B3@'.
      write text-018 to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-aufm_mblnr
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write '/' to gs_docflow-content+lv_off.
      add 2 to lv_off.
      write gs_rmaorderinfo-aufm_zeile
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write '(' to gs_docflow-content+lv_off.
      add 4 to lv_off.
      write text-010 to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-aufm_matnr
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write ',' to gs_docflow-content+lv_off.
      add 2 to lv_off.
      write gs_rmaorderinfo-aufm_menge unit gs_rmaorderinfo-aufm_meins
        to gs_docflow-content+lv_off left-justified.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-aufm_meins to gs_docflow-content+lv_off.
      perform get_offset using gs_docflow-content changing lv_off.
      write ',' to gs_docflow-content+lv_off.
      add 2 to lv_off.
      write text-011 to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-aufm_bwart
        to gs_docflow-content+lv_off no-zero.
      add 3 to lv_off.
      write gs_rmaorderinfo-aufm_sobkz
        to gs_docflow-content+lv_off no-zero.
      add 2 to lv_off.
      write ')' to gs_docflow-content+lv_off.
      gs_docflow-position = 13.
    endif.
*   at eban_banfn change
    if not ( gs_rmaorderinfo-eban_banfn is initial or
           gs_rmaorderinfo-eban_bnfpo is initial ) and not
           ( gs_rmaorderinfo-eban_banfn = ls_rmabuf-eban_banfn and
           gs_rmaorderinfo-eban_bnfpo = ls_rmabuf-eban_bnfpo ).
      gs_docflow-content = '@IF@'.
      write text-019 to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-eban_banfn
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write '/' to gs_docflow-content+lv_off.
      add 2 to lv_off.
      write gs_rmaorderinfo-eban_bnfpo
        to gs_docflow-content+lv_off no-zero.
      gs_docflow-position = 13.
      if not gs_rmaorderinfo-ekstat is initial.
        perform get_offset using gs_docflow-content changing lv_off.
        write '(' to gs_docflow-content+lv_off.
        add 2 to lv_off.
        write gs_rmaorderinfo-ekstat
          to gs_docflow-content+lv_off.
        perform get_offset using gs_docflow-content changing lv_off.
        write ')' to gs_docflow-content+lv_off.
      endif.
    endif.
*   at ekko_ebeln change
    if not ( gs_rmaorderinfo-ekko_ebeln is initial ) and not
           ( gs_rmaorderinfo-ekko_ebeln = ls_rmabuf-ekko_ebeln ).
      gs_docflow-content = '@IF@'.
      write text-020 to gs_docflow-content+5.
      perform get_offset using gs_docflow-content changing lv_off.
      write gs_rmaorderinfo-ekko_ebeln
        to gs_docflow-content+lv_off no-zero.
      perform get_offset using gs_docflow-content changing lv_off.
      write '/' to gs_docflow-content+lv_off.
      add 2 to lv_off.
      write gs_rmaorderinfo-ekpo_ebelp
        to gs_docflow-content+lv_off no-zero.
      if not gs_rmaorderinfo-ekstat is initial.
        perform get_offset using gs_docflow-content changing lv_off.
        write '(' to gs_docflow-content+lv_off.
        add 2 to lv_off.
        write gs_rmaorderinfo-ekstat
          to gs_docflow-content+lv_off.
        perform get_offset using gs_docflow-content changing lv_off.
        write ')' to gs_docflow-content+lv_off.
      endif.
      gs_docflow-position = 15.
    endif.

    if not gs_docflow-content is initial.
      condense gs_docflow-content.
      if not gs_rmaorderinfo-errortext is initial.
        gs_docflow-errortext = gs_rmaorderinfo-errortext.
      endif.
*      write at /gs_docflow-position gs_docflow-content.
      gs_docflow-display_mode = gs_rmaorderinfo-display_mode.
      gs_docflow-line = sy-tabix.
    endif.
    ls_rmabuf = gs_rmaorderinfo.
    if not gs_docflow-position is initial.
      append gs_docflow to gt_docflow.
    endif.
    clear gs_docflow-content.
    clear gs_docflow-position.
    clear gs_docflow-errortext.
  endloop.

*  uline.

endform.

*---------------------------------------------------------------------*
*       FORM get_offset                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_str                                                         *
*  -->  p_offset                                                      *
*---------------------------------------------------------------------*
form get_offset using p_str changing p_offset like sy-tabix.

  call function 'STRING_LENGTH'
       exporting
            string = p_str
       importing
            length = p_offset.
  add 1 to p_offset.

endform.

*---------------------------------------------------------------------*
*       FORM select_from_sd                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form select_from_sd.

* get valid order types
  perform get_repairorder_types.
* get order header data
  perform get_repairorders.
* get sd documents for relevant serviceorders
  perform get_sd_docs_by_viaufkst.

endform.

*---------------------------------------------------------------------*
*       FORM get_repairorders                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form get_repairorders.

  data: lt_vbak like table of vbak.
  data: lt_vbep like table of vbep.

* get repair order header
  select * from vbak into table lt_vbak
    for all entries in gt_tvak
    where auart = gt_tvak-auart
    and   vbeln in go_vbeln
    and   erdat in go_erdat.
  check sy-subrc is initial.

* get repair oder sched. lines
  select * from vbep into table lt_vbep
    for all entries in lt_vbak
    where vbeln = lt_vbak-vbeln
    and   vbeln in go_vbeln
    and   aufnr <> 0.

  check sy-subrc is initial.

* get viaufkst data
  select * from viaufkst into table gt_viaufkst
    for all entries in lt_vbep
    where aufnr = lt_vbep-aufnr
    and rsord = 'X'.

endform.

*---------------------------------------------------------------------*
*       FORM get_repairorder_types                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form get_repairorder_types.

* get tvak
  select * from tvak into table gt_tvak
    where vbtyp = 'C' and ( vbklt = 'F' or vbklt = 'G' )
    and   auart in go_vauar.
  check sy-subrc is initial.

* get service order types
  perform get_rma_ordertypes.

endform.

*---------------------------------------------------------------------*
*       FORM select_from_cs                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form select_from_cs.

* get valid order types
  perform get_rma_ordertypes.
* get order header data
  perform get_serviceorders.
* get sd documents for relevant serviceorders
  perform get_sd_docs_by_viaufkst.
endform.

*---------------------------------------------------------------------*
*       FORM get_rmaorderinfo_of_viaufkst                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_t_rmaorderinfo                                              *
*  -->  p_vbeln                                                       *
*  -->  p_posnr                                                       *
*  -->  p_posnr_rma                                                   *
*  -->  p_aufnr                                                       *
*  -->  p_errorlevel                                                  *
*---------------------------------------------------------------------*
form get_rmaorderinfo_of_viaufkst
  tables   p_t_rmaorderinfo structure gs_rmaorderinfo
  using    p_vbeln          like viaufkst-kdauf
           p_posnr          like viaufkst-kdpos
           p_posnr_rma      like caufv-posnr_rma
           p_aufnr          like viaufkst-aufnr
  changing p_errorlevel     like gs_rmaorderinfo-errorlevel.

  data: ls_rmaorderinfo like gs_rmaorderinfo.
  data: ls_rmaordercomp like gs_rmaorderinfo.
  data: ls_vbap like vbap.
*  data: ls_vbep like vbep.
  data: lt_vbep like table of vbep.

* check main item
  ls_rmaordercomp-vbeln = p_vbeln.
  ls_rmaordercomp-posnr = p_posnr.
  ls_rmaordercomp-display_mode = 'VA03'.

  read table p_t_rmaorderinfo from ls_rmaordercomp
    into ls_rmaorderinfo comparing all fields.
  if sy-subrc > 2.
    select single * from vbap into ls_vbap
      where vbeln = p_vbeln
      and   posnr = p_posnr.
    if not sy-subrc is initial.
      clear ls_rmaordercomp-display_mode.
      ls_rmaordercomp-errortext
        = text-021.
      perform change_errorlevel using '2' changing p_errorlevel.
    endif.
    append ls_rmaordercomp to p_t_rmaorderinfo.
    clear ls_rmaordercomp-errortext.
  endif.

* check sub item
  ls_rmaordercomp-pos_sub = p_posnr_rma.

  read table p_t_rmaorderinfo from ls_rmaordercomp
    into ls_rmaorderinfo comparing all fields.
  if sy-subrc > 2.
    select single * from vbap into ls_vbap
      where vbeln = p_vbeln
      and   posnr = p_posnr_rma.
    if not sy-subrc is initial.
      clear ls_rmaordercomp-display_mode.
      ls_rmaordercomp-errortext
        = text-022.
      perform change_errorlevel using '2' changing p_errorlevel.
    endif.
    append ls_rmaordercomp to p_t_rmaorderinfo.
    clear ls_rmaordercomp-errortext.
  endif.

* check service order
  ls_rmaordercomp-aufnr = p_aufnr.
  ls_rmaordercomp-display_mode = 'IW33'.
  read table p_t_rmaorderinfo from ls_rmaordercomp
    into ls_rmaorderinfo comparing all fields.
  if sy-subrc > 2.
    select * from vbep into table lt_vbep
      where vbeln = p_vbeln
      and   posnr = p_posnr_rma
      and   aufnr <> p_aufnr
      and   aufnr <> space.
    if sy-subrc is initial.
      ls_rmaordercomp-errortext
        = text-023.
      perform change_errorlevel using '2' changing p_errorlevel.
      ls_rmaordercomp-display_mode = 'IW33'.
    else.
      describe table lt_vbep lines sy-tabix.
      if sy-tabix > 0.
        ls_rmaordercomp-errortext
          = text-024.
        perform change_errorlevel using '2' changing p_errorlevel.
      endif.
    endif.
    append ls_rmaordercomp to p_t_rmaorderinfo.
    clear ls_rmaordercomp-errortext.
  endif.

endform.


*---------------------------------------------------------------------*
*       FORM get_rmaorderinfo_by_vbeln                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_t_rmaorderinfo                                              *
*---------------------------------------------------------------------*
form get_rmaorderinfo_of_vbeln
  tables   p_t_rmaorderinfo structure gs_rmaorderinfo
  using    p_vbeln          like viaufkst-kdauf
           p_posnr          like viaufkst-kdpos
           p_posnr_rma      like caufv-posnr_rma
           p_aufnr          like viaufkst-aufnr
  changing p_errorlevel     like gs_rmaorderinfo-errorlevel.

* local variables
  DATA: LV_POS_SUB_INITIAL LIKE CAUFV-KDPOS.
* local structures
  data: ls_rmaorderinfo like gs_rmaorderinfo.
  data: ls_vbak like vbak.
  data: ls_vbap like vbap.
  data: ls_vbep like vbep.
  DATA: LS_CAUFV LIKE CAUFV.
* local tables
  data: lt_vbep like table of vbep.
  data: lt_vbap like table of vbap.
  DATA: LT_CAUFV LIKE TABLE OF CAUFV.

  ls_rmaorderinfo-display_mode = 'VA03'.

  ls_rmaorderinfo-vbeln = p_vbeln.
  select single * from vbak into ls_vbak
    where vbeln = p_vbeln.
  if not sy-subrc is initial.
    clear ls_rmaorderinfo-display_mode.
    if p_vbeln is initial or p_vbeln = '%TMP'.
      perform change_errorlevel using '3' changing p_errorlevel.
      ls_rmaorderinfo-errortext = text-025.
    else.
      perform change_errorlevel using '2' changing p_errorlevel.
      ls_rmaorderinfo-errortext = text-026.
    endif.
    append ls_rmaorderinfo to p_t_rmaorderinfo.
    ls_rmaorderinfo-errortext
        = text-021.
    ls_rmaorderinfo-posnr = p_posnr.
    append ls_rmaorderinfo to p_t_rmaorderinfo.
    ls_rmaorderinfo-errortext
        = text-022.
    ls_rmaorderinfo-pos_sub = p_posnr_rma.
    append ls_rmaorderinfo to p_t_rmaorderinfo.
    ls_rmaorderinfo-display_mode = 'IW33'.
    clear ls_rmaorderinfo-errortext.
    ls_rmaorderinfo-aufnr = p_aufnr.
    append ls_rmaorderinfo to p_t_rmaorderinfo.
  else.
    append ls_rmaorderinfo to p_t_rmaorderinfo.
    select * from vbap into table lt_vbap
      where vbeln = p_vbeln.
    loop at lt_vbap into ls_vbap.
      if ls_vbap-uepos is initial.
        ls_rmaorderinfo-posnr = ls_vbap-posnr.
        clear ls_rmaorderinfo-pos_sub.
        append ls_rmaorderinfo to p_t_rmaorderinfo.
      else.
        ls_rmaorderinfo-posnr = ls_vbap-uepos.
        ls_rmaorderinfo-pos_sub = ls_vbap-posnr.
        clear ls_rmaorderinfo-aufnr.
        append ls_rmaorderinfo to p_t_rmaorderinfo.
        select * from vbep into table lt_vbep
          where vbeln = p_vbeln
          and   posnr = ls_rmaorderinfo-pos_sub
          and   aufnr <> space.
        loop at lt_vbep into ls_vbep.
          ls_rmaorderinfo-aufnr = ls_vbep-aufnr.
          ls_rmaorderinfo-display_mode = 'IW33'.
          append ls_rmaorderinfo to p_t_rmaorderinfo.
          ls_rmaorderinfo-display_mode = 'VA03'.
          clear ls_rmaorderinfo-aufnr.
        endloop. " at lt_vbep
      endif.
    endloop.
*   get all other relevant service orders (e.g. the blocked ones)
    SELECT * FROM CAUFV INTO TABLE LT_CAUFV
      WHERE KDAUF = P_VBELN
      AND   RSORD = 'X'.
*   check may be not necessary but was added for completeness ;)
    CHECK SY-SUBRC IS INITIAL.
    LOOP AT LT_CAUFV INTO LS_CAUFV.
*     check existence of main item
      READ TABLE P_T_RMAORDERINFO WITH KEY VBELN = P_VBELN
                                        POSNR = LS_CAUFV-POSNV_RMA
                                        POS_SUB = LV_POS_SUB_INITIAL.
      IF NOT SY-SUBRC IS INITIAL.
        CLEAR LS_RMAORDERINFO.
        LS_RMAORDERINFO-VBELN = P_VBELN.
        LS_RMAORDERINFO-POSNR = LS_CAUFV-POSNV_RMA.
        LS_RMAORDERINFO-DISPLAY_MODE = 'VA03'.
        LS_RMAORDERINFO-ERRORTEXT = TEXT-021.
        APPEND LS_RMAORDERINFO TO P_T_RMAORDERINFO.
        PERFORM CHANGE_ERRORLEVEL USING '2' CHANGING P_ERRORLEVEL.
      ENDIF.
*     check existence of sub item
      READ TABLE P_T_RMAORDERINFO WITH KEY VBELN = P_VBELN
                                        POSNR = LS_CAUFV-POSNV_RMA
                                        POS_SUB = LS_CAUFV-POSNR_RMA.
      IF NOT SY-SUBRC IS INITIAL.
        CLEAR LS_RMAORDERINFO.
        LS_RMAORDERINFO-VBELN = P_VBELN.
        LS_RMAORDERINFO-POSNR = LS_CAUFV-POSNV_RMA.
        LS_RMAORDERINFO-POS_SUB = LS_CAUFV-POSNR_RMA.
        LS_RMAORDERINFO-DISPLAY_MODE = 'VA03'.
        LS_RMAORDERINFO-ERRORTEXT = TEXT-022.
        APPEND LS_RMAORDERINFO TO P_T_RMAORDERINFO.
        PERFORM CHANGE_ERRORLEVEL USING '2' CHANGING P_ERRORLEVEL.
      ENDIF.
*     check the attached order (if existing)
      LOOP AT P_T_RMAORDERINFO WHERE VBELN = P_VBELN
                               AND   POSNR = LS_CAUFV-POSNV_RMA
                               AND   POS_SUB = LS_CAUFV-POSNR_RMA
                               AND   AUFNR <> SPACE.
         EXIT.
      ENDLOOP.
      IF NOT SY-SUBRC IS INITIAL.
        CLEAR LS_RMAORDERINFO.
        LS_RMAORDERINFO-VBELN = P_VBELN.
        LS_RMAORDERINFO-POSNR = LS_CAUFV-POSNV_RMA.
        LS_RMAORDERINFO-POS_SUB = LS_CAUFV-POSNR_RMA.
        LS_RMAORDERINFO-AUFNR = LS_CAUFV-AUFNR.
        LS_RMAORDERINFO-DISPLAY_MODE = 'IW33'.
        LS_RMAORDERINFO-ERRORTEXT = TEXT-024.
        APPEND LS_RMAORDERINFO TO P_T_RMAORDERINFO.
        PERFORM CHANGE_ERRORLEVEL USING '2' CHANGING P_ERRORLEVEL.
      ENDIF.
      IF P_T_RMAORDERINFO-AUFNR = LS_CAUFV-AUFNR.
        CONTINUE.
      ENDIF.
*     check if the order from caufv is already in the list
      READ TABLE P_T_RMAORDERINFO WITH KEY VBELN = P_VBELN
                                        POSNR = LS_CAUFV-POSNV_RMA
                                        POS_SUB = LS_CAUFV-POSNR_RMA
                                        AUFNR = LS_CAUFV-AUFNR.
      IF NOT SY-SUBRC IS INITIAL.
        CLEAR LS_RMAORDERINFO.
        LS_RMAORDERINFO-VBELN = P_VBELN.
        LS_RMAORDERINFO-POSNR = LS_CAUFV-POSNV_RMA.
        LS_RMAORDERINFO-POS_SUB = LS_CAUFV-POSNR_RMA.
        LS_RMAORDERINFO-AUFNR = LS_CAUFV-AUFNR.
        LS_RMAORDERINFO-DISPLAY_MODE = 'IW33'.
        LS_RMAORDERINFO-ERRORTEXT = TEXT-023.
        APPEND LS_RMAORDERINFO TO P_T_RMAORDERINFO.
        PERFORM CHANGE_ERRORLEVEL USING '2' CHANGING P_ERRORLEVEL.
      ENDIF.
    ENDLOOP.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM get_sd_docs_by_viaufkst                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form get_sd_docs_by_viaufkst.

* local structures
*  data: ls_vbak like vbak.
  data: ls_viaufkst like viaufkst.
*  data: ls_viaufkst_buf like viaufkst.
  data: ls_caufv like caufv.
  data: ls_vbap like vbap.
  data: ls_vbep like vbep.
  data: ls_rmaorderinfo like gs_rmaorderinfo.
* local tables
  data: lt_vbep like table of vbep.
*  data: lt_vbap like table of vbap.
  data: lt_rmaorderinfo like table of gs_rmaorderinfo.
  data: lt_serviceorders like table of gs_rmaorderinfo with header line.
  data: lt_repairorders like table of gs_rmaorderinfo with header line.
* local vars
  data: lv_errorlevel like sy-subrc.

  loop at gt_viaufkst into ls_viaufkst.
*   reset some data
    clear gs_rmaorderinfo.
    clear lv_errorlevel.
*   get caufv data for RMA Headerpos.
    select single * from caufv into ls_caufv
      where aufnr = ls_viaufkst-aufnr.
*   get infos from vbap, vbep
    refresh lt_rmaorderinfo.
    perform get_rmaorderinfo_of_vbeln tables   lt_rmaorderinfo
                                      using    ls_viaufkst-kdauf
                                               ls_viaufkst-kdpos
                                               ls_caufv-posnr_rma
                                               ls_viaufkst-aufnr
                                      changing lv_errorlevel.

*   add infos from viaufkst and caufv
    perform get_rmaorderinfo_of_viaufkst  tables   lt_rmaorderinfo
                                          using    ls_viaufkst-kdauf
                                                   ls_viaufkst-kdpos
                                                   ls_caufv-posnr_rma
                                                   ls_viaufkst-aufnr
                                          changing lv_errorlevel.

*   check if another repair order references to viaufkst-aufnr
*   get vbep entries from viaufkst
    refresh lt_vbep.
    select * from vbep into table lt_vbep
      where aufnr = ls_viaufkst-aufnr and vbeln <> ls_viaufkst-kdauf.
    if sy-subrc is initial.
*     service order is referenced by another repair order (!)
      perform change_errorlevel using 3 changing lv_errorlevel.
      loop at lt_vbep into ls_vbep.
        ls_rmaorderinfo-aufnr = ls_viaufkst-aufnr.
        ls_rmaorderinfo-vbeln = ls_viaufkst-kdauf.
        ls_rmaorderinfo-posnr = ls_viaufkst-kdpos.
        ls_rmaorderinfo-pos_sub = ls_caufv-posnr_rma.
        ls_rmaorderinfo-vbeln_vbep = ls_vbep-vbeln.
        ls_rmaorderinfo-posnr_vbep = ls_vbep-posnr.
        ls_rmaorderinfo-display_mode = 'VA03'.
        append ls_rmaorderinfo to lt_rmaorderinfo.
        loop at gt_rmaorderinfo into ls_rmaorderinfo
              where vbeln = ls_vbep-vbeln.
          exit.
        endloop.
        if not sy-subrc is initial.
          select single * from vbap into ls_vbap
            where vbeln = ls_vbep-vbeln
            and   posnr = ls_vbep-posnr.
          perform get_rmaorderinfo_of_vbeln tables   lt_rmaorderinfo
                                            using    ls_vbep-vbeln
                                                     ls_vbap-uepos
                                                     ls_caufv-posnr_rma
                                                     ls_viaufkst-aufnr
                                            changing lv_errorlevel.
        endif.
      endloop.
    endif.
    refresh lt_vbep.

*   get all orders to check
    refresh lt_serviceorders.
    loop at lt_rmaorderinfo into ls_rmaorderinfo
      where aufnr <> space
      and   vbeln_vbep = space.
      ls_rmaorderinfo-display_mode = 'IW33'.
      lt_serviceorders = ls_rmaorderinfo.
      append lt_serviceorders.
    endloop.
    sort lt_serviceorders.
    delete adjacent duplicates from lt_serviceorders.

*   check serviceorder entries
    loop at lt_serviceorders into ls_rmaorderinfo.
      perform check_order_relation tables   lt_rmaorderinfo
                                   using    ls_rmaorderinfo
                                   changing lv_errorlevel.
      perform get_pm_status using    ls_rmaorderinfo-aufnr
                            changing ls_rmaorderinfo-status_aufnr.
      clear ls_rmaorderinfo-errortext.
      append ls_rmaorderinfo to lt_rmaorderinfo.
      clear ls_rmaorderinfo-status_aufnr.
      perform get_confirmations tables lt_rmaorderinfo
                                using ls_rmaorderinfo.
      perform get_materialdocs tables lt_rmaorderinfo
                               using ls_rmaorderinfo.
      perform get_banf_and_po tables lt_rmaorderinfo
                              using ls_rmaorderinfo.
    endloop.

*   get all repairorder items to check
    refresh lt_repairorders.
    loop at lt_rmaorderinfo into ls_rmaorderinfo
      where aufnr is initial.
      append ls_rmaorderinfo to lt_repairorders.
    endloop.

    loop at lt_repairorders into ls_rmaorderinfo.
*     get repairorder item status
      perform get_repord_status tables lt_rmaorderinfo
                                using  ls_rmaorderinfo.
      perform get_vbfa_docflow  tables lt_rmaorderinfo
                                using  ls_rmaorderinfo.
    endloop.

*   save results
    clear ls_rmaorderinfo.
    ls_rmaorderinfo-errorlevel = lv_errorlevel.
    modify lt_rmaorderinfo from ls_rmaorderinfo
      transporting errorlevel
      where errorlevel <> lv_errorlevel.
    append lines of lt_rmaorderinfo to gt_rmaorderinfo.

  endloop.

endform.

*---------------------------------------------------------------------*
*       FORM check_order_relation                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_rmaorderinfo                                                *
*  -->  p_errorlevel                                                  *
*---------------------------------------------------------------------*
form check_order_relation
  tables   p_t_rmaorderinfo structure gs_rmaorderinfo
  using    p_rmaorderinfo   like      gs_rmaorderinfo
  changing p_errorlevel     like      gs_rmaorderinfo-errorlevel.

  data: ls_caufv like caufv.
  data: ls_rmaorderinfo like gs_rmaorderinfo.

  ls_rmaorderinfo = p_rmaorderinfo.

  select single * from caufv into ls_caufv
    where aufnr = p_rmaorderinfo-aufnr.

  if not ( ls_caufv-kdauf = p_rmaorderinfo-vbeln and
           ls_caufv-kdpos = p_rmaorderinfo-posnr and
           ls_caufv-posnr_rma = p_rmaorderinfo-pos_sub ).
*    ls_rmaorderinfo-errortext =
*      'Serviceauftrag verweist auf anderen Reparaturauftrag'.
    ls_rmaorderinfo-vbeln_aufk = ls_caufv-kdauf.
    ls_rmaorderinfo-posnr_aufk = ls_caufv-kdpos.
    append ls_rmaorderinfo to p_t_rmaorderinfo.
    perform change_errorlevel using 3 changing p_errorlevel.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM get_sd_materialdoc                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_index                                                       *
*  -->  p_rmaorderinfo                                                *
*---------------------------------------------------------------------*
form get_sd_materialdoc using p_index like sy-subrc
                        changing p_rmaorderinfo like gs_rmaorderinfo.

  data: ls_mseg like mseg.

  case p_index.
    when 1.
      select single * from mseg into ls_mseg
        where mblnr = p_rmaorderinfo-vbfa_1_vbeln
        and   zeile = p_rmaorderinfo-vbfa_1_posnn
        and   mat_kdauf = p_rmaorderinfo-vbeln.
    when 0.
      select single * from mseg into ls_mseg
        where mblnr = p_rmaorderinfo-vbfa_0_vbeln
        and   zeile = p_rmaorderinfo-vbfa_0_posnn
        and   mat_kdauf = p_rmaorderinfo-vbeln.
  endcase.
  if not sy-subrc is initial.
    case p_index.
      when 1.
        select single * from mseg into ls_mseg
          where mblnr = p_rmaorderinfo-vbfa_1_vbeln
          and   zeile = p_rmaorderinfo-vbfa_1_posnn.
      when 0.
        select single * from mseg into ls_mseg
          where mblnr = p_rmaorderinfo-vbfa_0_vbeln
          and   zeile = p_rmaorderinfo-vbfa_0_posnn.
    endcase.
  endif.
  check sy-subrc is initial.

  p_rmaorderinfo-aufm_bwart = ls_mseg-bwart.
  p_rmaorderinfo-aufm_sobkz = ls_mseg-sobkz.
  p_rmaorderinfo-aufm_werks = ls_mseg-werks.
  p_rmaorderinfo-aufm_lgort = ls_mseg-lgort.
  p_rmaorderinfo-aufm_matnr = ls_mseg-matnr.
  p_rmaorderinfo-aufm_menge = ls_mseg-menge.
  p_rmaorderinfo-aufm_meins = ls_mseg-meins.

endform.

*---------------------------------------------------------------------*
*       FORM get_amterialdocs                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_rmaorderinfo                                                *
*---------------------------------------------------------------------*
form get_materialdocs
  tables   p_t_rmaorderinfo structure gs_rmaorderinfo
  using    p_rmaorderinfo   like      gs_rmaorderinfo.

  data: ls_rmaorderinfo like gs_rmaorderinfo.
  data: lt_aufm like table of aufm.
  data: ls_aufm like aufm.

  ls_rmaorderinfo = p_rmaorderinfo.
  ls_rmaorderinfo-display_mode = 'MB03'.

  select * from aufm into table lt_aufm
    where aufnr = p_rmaorderinfo-aufnr.

  check sy-subrc is initial.

  loop at lt_aufm into ls_aufm.
    ls_rmaorderinfo-aufm_mblnr = ls_aufm-mblnr.
    ls_rmaorderinfo-aufm_zeile = ls_aufm-zeile.
    ls_rmaorderinfo-aufm_bwart = ls_aufm-bwart.
    ls_rmaorderinfo-aufm_sobkz = ls_aufm-sobkz.
    ls_rmaorderinfo-aufm_werks = ls_aufm-werks.
    ls_rmaorderinfo-aufm_lgort = ls_aufm-lgort.
    ls_rmaorderinfo-aufm_matnr = ls_aufm-matnr.
    ls_rmaorderinfo-aufm_menge = ls_aufm-menge.
    ls_rmaorderinfo-aufm_meins = ls_aufm-meins.
    append ls_rmaorderinfo to p_t_rmaorderinfo.
  endloop.

endform.


*---------------------------------------------------------------------*
*       FORM get_confs                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_rmaorderinfo                                                *
*---------------------------------------------------------------------*
form get_confirmations
  tables   p_t_rmaorderinfo structure gs_rmaorderinfo
  using    p_rmaorderinfo   like      gs_rmaorderinfo.

  data: ls_rmaorderinfo like gs_rmaorderinfo.
  data: lt_afru like table of afru.
  data: ls_afru like afru.
  data: lt_afvc like table of afvc.
  data: ls_caufv like caufv.

  ls_rmaorderinfo = p_rmaorderinfo.
  ls_rmaorderinfo-display_mode = 'IW43'.

* get caufv
  select single * from caufv into ls_caufv
    where aufnr = p_rmaorderinfo-aufnr.
  check sy-subrc is initial.
* get operations
  select * from afvc into table lt_afvc
    where aufpl = ls_caufv-aufpl.
  check sy-subrc is initial.
* get confirmations for operations
  select * from afru into table lt_afru
    for all entries in lt_afvc where
    rueck = lt_afvc-rueck
    and stzhl = space.
* append to global table
  if sy-subrc is initial.
    loop at lt_afru into ls_afru .
      ls_rmaorderinfo-afru_rueck = ls_afru-rueck.
      ls_rmaorderinfo-afru_rmzhl = ls_afru-rmzhl.
      ls_rmaorderinfo-afru_aufnr = ls_afru-aufnr.
      ls_rmaorderinfo-afru_vornr = ls_afru-vornr.
      ls_rmaorderinfo-afru_stokz = ls_afru-stokz.
      append ls_rmaorderinfo to p_t_rmaorderinfo.
    endloop.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM change_errorlevel                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_new                                                         *
*  -->  p_old                                                         *
*---------------------------------------------------------------------*
form change_errorlevel using p_new like sy-subrc
                       changing p_old like sy-subrc.
  check p_new > p_old.
  p_old = p_new.

endform.

*---------------------------------------------------------------------*
*       FORM get_serviceorders                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form get_serviceorders.

* get orders whgen valid auart was found only
  check not gt_t350[] is initial.
* select order header data (with refurbishment flag)
  select * from viaufkst into table gt_viaufkst
           for all entries in gt_t350
           where auart = gt_t350-auart
           and aufnr in go_aufnr
           and erdat in go_erdat
           and rsord = 'X'.

endform.

*---------------------------------------------------------------------*
*       FORM get_rma_ordertypes                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form get_rma_ordertypes.

  data: lt_t003o type table of t003o.

* get order types without revenues
  select * from t003o into table lt_t003o
    where autyp   = '30'
    and   erloese = ' '.
* get order types
* - without revenues
* - from given order type range
* - with service and refurbishment flags set
  select * from t350 into table gt_t350
    for all entries in lt_t003o
    where auart   = lt_t003o-auart
    and   auart   in go_auart
    and   service = 'X'
    and   rsord   = 'X'.

endform.

*---------------------------------------------------------------------*
*       FORM GET_PM_STATUS                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_OBJNR                                                       *
*  -->  P_STATUS                                                      *
*---------------------------------------------------------------------*
form get_pm_status using    p_aufnr
                   changing p_status.

  data ls_caufv like caufv.
  data lv_status like  bsvx-sttxt.

* get object number

  select single * from caufv into ls_caufv
    where aufnr = p_aufnr.

* Buffer zurücksetzen, um aktuelle Status (NON cache) zu erhalten
  call function 'STATUS_BUFFER_REFRESH'
       exporting
            i_free = ' '.

  call function 'STATUS_TEXT_EDIT'
       exporting
            objnr            = ls_caufv-objnr
            only_active      = 'X'
            spras            = sy-langu
*            bypass_buffer    = 'X'
       importing
            line             = lv_status
       exceptions
            object_not_found = 01.

  if not sy-subrc is initial.
    MESSAGE S351(IW).
  else.
    p_status = lv_status.
  endif.

endform.                               " GET_PM_STATUS

*---------------------------------------------------------------------*
*       FORM get_banf                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_aufnr                                                       *
*---------------------------------------------------------------------*
form get_banf_and_po tables  p_t_rmaorderinfo structure gs_rmaorderinfo
                     using   p_rmaorderinfo like gs_rmaorderinfo.

  data: ls_afko like afko.
*  data: begin of ls_purch_list,
*          doctype(15) type c,
*          banfn like eban-banfn,
*          bnfpo like eban-bnfpo,
*          ebeln like ekko-ebeln,
*        end of ls_purch_list.
  data: ls_rmaorderinfo like gs_rmaorderinfo.

  data h_reserv_tab      like resb occurs 0 with header line.
  data h_dbschelmt_tab   like rsdb occurs 0 with header line.
  data h_dbschelmt_tab_l like rsdb occurs 0 with header line.
  data h_lin type i.

  check not p_rmaorderinfo-aufnr is initial.

  ls_rmaorderinfo = p_rmaorderinfo.
  clear ls_rmaorderinfo-errortext.

* Material Purch.Req.
  select single * from afko into ls_afko
    where aufnr  = p_rmaorderinfo-aufnr.
* get reservations for non stock material
  select * from resb into table h_reserv_tab
    where rsnum eq ls_afko-rsnum and postp ne 'L'.

  loop at h_reserv_tab.
    select * from rsdb into h_dbschelmt_tab
             where rsnum eq h_reserv_tab-rsnum and
                   rspos eq h_reserv_tab-rspos.
      if not h_dbschelmt_tab-banfn is initial.
        append h_dbschelmt_tab.
      endif.
    endselect.
  endloop.

* get 'leistungsbestellung'
  select * from afvc into corresponding fields of h_dbschelmt_tab
    where aufpl eq ls_afko-aufpl and banfn ne space.
    append h_dbschelmt_tab.
  endselect.

* Bestellungen zu Leistung
  loop at h_dbschelmt_tab.
    if not h_dbschelmt_tab-banfn is initial.
      select * from eban into corresponding fields of h_dbschelmt_tab_l
        where banfn eq h_dbschelmt_tab-banfn   and
              bnfpo eq h_dbschelmt_tab-bnfpo.
        append h_dbschelmt_tab_l.
      endselect.
    endif.
  endloop.

  loop at h_dbschelmt_tab_l.
    if not h_dbschelmt_tab_l-ebeln is initial.
      append h_dbschelmt_tab_l to h_dbschelmt_tab.
    endif.
  endloop.

  describe table h_dbschelmt_tab lines h_lin.
  if h_lin is initial.
    exit.
  endif.

* sort and delete duplicates
  sort h_dbschelmt_tab by ebeln ebelp banfn bnfpo.
  delete adjacent duplicates from h_dbschelmt_tab.

  loop at h_dbschelmt_tab.
    ls_rmaorderinfo-eban_banfn  = h_dbschelmt_tab-banfn.
    ls_rmaorderinfo-eban_bnfpo   = h_dbschelmt_tab-bnfpo.
    ls_rmaorderinfo-ekko_ebeln = h_dbschelmt_tab-ebeln.
    ls_rmaorderinfo-ekpo_ebelp = h_dbschelmt_tab-ebelp.
    if h_dbschelmt_tab-ebeln is initial.
      ls_rmaorderinfo-display_mode = 'ME53'.
      ls_rmaorderinfo-pur_doctyp = text-019.
      perform get_banf_status changing ls_rmaorderinfo.
    else.
      ls_rmaorderinfo-display_mode = 'ME23'.
      ls_rmaorderinfo-pur_doctyp = text-020.
      perform get_po_status changing ls_rmaorderinfo.
    endif.
    append ls_rmaorderinfo to p_t_rmaorderinfo.
    clear ls_rmaorderinfo-ekstat.
  endloop.

endform.                               " GET_BANF

*---------------------------------------------------------------------*
*       FORM get_po_status                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_rmaorderdisplay                                             *
*---------------------------------------------------------------------*
form get_po_status
  changing p_rmaorderdisplay like gs_rmaorderinfo.

  data: ls_ekpo like ekpo.
  data: ls_dd04t like dd04t.
  data: lv_postatus like gs_rmaorderinfo-ekstat.

  select single * from ekpo into ls_ekpo
    where ebeln = p_rmaorderdisplay-ekko_ebeln
    and   ebelp = p_rmaorderdisplay-ekpo_ebelp.

  check sy-subrc is initial.

  if not ls_ekpo-abskz is initial.
    select single * from dd04t into ls_dd04t
      where ddlanguage = sy-langu and rollname = 'ABSKZ'.
    concatenate lv_postatus ls_dd04t-scrtext_m
      into lv_postatus separated by space.
  endif.
  if not ls_ekpo-elikz is initial.
    select single * from dd04t into ls_dd04t
      where ddlanguage = sy-langu and rollname = 'ELIKZ'.
    concatenate lv_postatus ls_dd04t-scrtext_m
      into lv_postatus separated by space.
  endif.
  if not ls_ekpo-erekz is initial.
    select single * from dd04t into ls_dd04t
      where ddlanguage = sy-langu and rollname = 'EREKZ'.
    concatenate lv_postatus ls_dd04t-scrtext_m
      into lv_postatus separated by space.
  endif.
  if not ls_ekpo-twrkz is initial.
    select single * from dd04t into ls_dd04t
      where ddlanguage = sy-langu and rollname = 'TWRKZ'.
    concatenate lv_postatus ls_dd04t-scrtext_m
      into lv_postatus separated by space.
  endif.
  if not ls_ekpo-wepos is initial.
    select single * from dd04t into ls_dd04t
      where ddlanguage = sy-langu and rollname = 'WEPOS'.
    concatenate lv_postatus ls_dd04t-scrtext_m
      into lv_postatus separated by space.
  endif.

  p_rmaorderdisplay-ekstat = lv_postatus.

endform.


*---------------------------------------------------------------------*
*       FORM get_banf_status                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_rmaorderdisplay                                             *
*---------------------------------------------------------------------*
form get_banf_status
  changing p_rmaorderdisplay like gs_rmaorderinfo.

  data: ls_eban like eban.

  select single * from eban into ls_eban
    where banfn = p_rmaorderdisplay-eban_banfn
    and   bnfpo = p_rmaorderdisplay-eban_bnfpo.

  check sy-subrc is initial.

  data: ls_dd07v like dd07v.

  ls_dd07v-domname = 'BANST'.
  ls_dd07v-domvalue_l = ls_eban-statu.

  call function 'RV_DOMAIN_VALUE_TEXTS'
       exporting
            domname  = ls_dd07v-domname
            domvalue = ls_dd07v-domvalue_l
       importing
            ddtext   = p_rmaorderdisplay-ekstat.

endform.

*---------------------------------------------------------------------*
*       FORM get_repord_status                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_t_rmaorderinfo                                              *
*  -->  p_rmaorderinfo                                                *
*---------------------------------------------------------------------*
form get_repord_status tables p_t_rmaorderinfo structure gs_rmaorderinfo
                       using  p_rmaorderinfo like gs_rmaorderinfo.


  constants:
        status_ve   like jest-stat value 'I0218',       "VerwEntscheid
       status_mabg like jest-stat value 'I0072',       "Meldung abgeschl
        status_pakt like jest-stat value 'I0281',       "Prüflos aktiv
        status_irep like jest-stat value 'I0384',       "in Reparatur
        status_trep like jest-stat value 'I0385',       "Teil repariert
        status_repa like jest-stat value 'I0386',       "Repariert
        status_kzen like jest-stat value 'I0387',       "Kaufm. zu ents.
       status_kent like jest-stat value 'I0388'.       "Kaufm. entschie.


  data: ls_rmaorderinfo like gs_rmaorderinfo.
  data: ls_vbap like vbap.
  data: lt_jstat type table of jstat with header line.
  data: lv_status_check like tj02t-txt30.
  data: lv_status_repai like tj02t-txt30.
  data: lv_status_deter like tj02t-txt30.


  check not p_rmaorderinfo-vbeln is initial.
  check not p_rmaorderinfo-posnr is initial.
  check p_rmaorderinfo-pos_sub is initial.
  check p_rmaorderinfo-aufnr is initial.

  select single * from vbap into ls_vbap
    where vbeln = p_rmaorderinfo-vbeln
    and   posnr = p_rmaorderinfo-posnr.
  check sy-subrc is initial.

  ls_rmaorderinfo = p_rmaorderinfo.

  call function 'STATUS_READ'
       exporting
            objnr            = ls_vbap-objnr
            only_active      = 'X'
       tables
            status           = lt_jstat
       exceptions
            object_not_found = 1
            others           = 2.

  check sy-subrc is initial.

  loop at lt_jstat.
    case lt_jstat-stat.
      when status_ve.
        call function 'STATUS_NUMBER_CONVERSION'
             exporting
                  language      = sy-langu
                  status_number = lt_jstat-stat
             importing
                  txt30         = lv_status_check.
      when status_mabg.
        call function 'STATUS_NUMBER_CONVERSION'
             exporting
                  language      = sy-langu
                  status_number = lt_jstat-stat
             importing
                  txt30         = lv_status_check.
      when status_pakt.
        call function 'STATUS_NUMBER_CONVERSION'
             exporting
                  language      = sy-langu
                  status_number = lt_jstat-stat
             importing
                  txt30         = lv_status_check.
      when status_irep.
        call function 'STATUS_NUMBER_CONVERSION'
             exporting
                  language      = sy-langu
                  status_number = lt_jstat-stat
             importing
                  txt30         = lv_status_repai.
      when status_trep.
        call function 'STATUS_NUMBER_CONVERSION'
             exporting
                  language      = sy-langu
                  status_number = lt_jstat-stat
             importing
                  txt30         = lv_status_repai.
      when status_repa.
        call function 'STATUS_NUMBER_CONVERSION'
             exporting
                  language      = sy-langu
                  status_number = lt_jstat-stat
             importing
                  txt30         = lv_status_repai.
      when status_kzen.
        call function 'STATUS_NUMBER_CONVERSION'
             exporting
                  language      = sy-langu
                  status_number = lt_jstat-stat
             importing
                  txt30         = lv_status_deter.
      when status_kent.
        call function 'STATUS_NUMBER_CONVERSION'
             exporting
                  language      = sy-langu
                  status_number = lt_jstat-stat
             importing
                  txt30         = lv_status_deter.
    endcase.
  endloop.

  concatenate lv_status_check lv_status_repai lv_status_deter
    into ls_rmaorderinfo-status_aufnr separated by space.

  append ls_rmaorderinfo to p_t_rmaorderinfo.

endform.


*---------------------------------------------------------------------*
*       FORM get_vbfa_docflow                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_t_rmaorderinfo                                              *
*  -->  p_rmaorderinfo                                                *
*---------------------------------------------------------------------*
form get_vbfa_docflow tables p_t_rmaorderinfo structure gs_rmaorderinfo
                      using  p_rmaorderinfo   like      gs_rmaorderinfo.

  data: ls_rmaorderinfo like gs_rmaorderinfo.
  data: lt_vbfa_stufe_0 like table of vbfa.
  data: lt_vbfa_stufe_1 like table of vbfa.
  data: ls_vbfa_stufe_0 like vbfa.
  data: ls_vbfa_stufe_1 like vbfa.

  ls_rmaorderinfo = p_rmaorderinfo.

* doc flow for main item
  if ls_rmaorderinfo-pos_sub is initial.
    select * from vbfa into table lt_vbfa_stufe_0
      where vbelv =  ls_rmaorderinfo-vbeln
      and   posnv =  ls_rmaorderinfo-posnr
      and   vbeln <> ls_rmaorderinfo-vbeln
      and   stufe =  0.
    check sy-subrc is initial.
    select * from vbfa into table lt_vbfa_stufe_1
      for all entries in lt_vbfa_stufe_0
      where vbelv = lt_vbfa_stufe_0-vbeln
      and   posnv = lt_vbfa_stufe_0-posnn
      and   stufe = 0.
    loop at lt_vbfa_stufe_0 into ls_vbfa_stufe_0.
      ls_rmaorderinfo-vbfa_0_vbeln = ls_vbfa_stufe_0-vbeln.
      ls_rmaorderinfo-vbfa_0_posnn = ls_vbfa_stufe_0-posnn.
      ls_rmaorderinfo-vbfa_0_vbtyp_n = ls_vbfa_stufe_0-vbtyp_n.
      perform get_sd_doctype
        using ls_vbfa_stufe_0-vbtyp_n
        changing ls_rmaorderinfo-vbfa_0_doctext
                 ls_rmaorderinfo-display_mode.
      if ls_rmaorderinfo-vbfa_0_vbtyp_n ca 'JR'.
        perform get_sd_materialdoc
          using 0
          changing ls_rmaorderinfo.
      endif.
      if ls_rmaorderinfo-vbfa_0_vbtyp_n = 'Q'.
        perform check_lvs using 0 ls_vbfa_stufe_0
                          changing ls_rmaorderinfo.
      endif.
      append ls_rmaorderinfo to p_t_rmaorderinfo.
      loop at lt_vbfa_stufe_1 into ls_vbfa_stufe_1.
        ls_rmaorderinfo-vbfa_1_vbeln = ls_vbfa_stufe_1-vbeln.
        ls_rmaorderinfo-vbfa_1_posnn = ls_vbfa_stufe_1-posnn.
        ls_rmaorderinfo-vbfa_1_vbtyp_n = ls_vbfa_stufe_1-vbtyp_n.
        perform get_sd_doctype
          using ls_vbfa_stufe_1-vbtyp_n
          changing ls_rmaorderinfo-vbfa_1_doctext
                   ls_rmaorderinfo-display_mode.
        if ls_rmaorderinfo-vbfa_1_vbtyp_n ca 'JR'.
          perform get_sd_materialdoc
            using 1
            changing ls_rmaorderinfo.
        endif.
        if ls_rmaorderinfo-vbfa_1_vbtyp_n = 'Q'.
          perform check_lvs using 1 ls_vbfa_stufe_1
                            changing ls_rmaorderinfo.
        endif.
        append ls_rmaorderinfo to p_t_rmaorderinfo.
      endloop.
      clear ls_rmaorderinfo-vbfa_1_vbeln.
      clear ls_rmaorderinfo-vbfa_1_posnn.
      clear ls_rmaorderinfo-vbfa_1_vbtyp_n.
    endloop.
* doc flow for sub item
  else.
    select * from vbfa into table lt_vbfa_stufe_0
      where vbelv =  ls_rmaorderinfo-vbeln
      and   posnv =  ls_rmaorderinfo-pos_sub
      and   stufe =  0.
    check sy-subrc is initial.
    select * from vbfa into table lt_vbfa_stufe_1
      for all entries in lt_vbfa_stufe_0
      where vbelv = lt_vbfa_stufe_0-vbeln
      and   posnv = lt_vbfa_stufe_0-posnn
      and   stufe = 0.
    loop at lt_vbfa_stufe_0 into ls_vbfa_stufe_0.
      ls_rmaorderinfo-vbfa_0_vbeln = ls_vbfa_stufe_0-vbeln.
      ls_rmaorderinfo-vbfa_0_posnn = ls_vbfa_stufe_0-posnn.
      ls_rmaorderinfo-vbfa_0_vbtyp_n = ls_vbfa_stufe_0-vbtyp_n.
      perform get_sd_doctype
        using ls_vbfa_stufe_0-vbtyp_n
        changing ls_rmaorderinfo-vbfa_0_doctext
                 ls_rmaorderinfo-display_mode.
      if ls_rmaorderinfo-vbfa_0_vbtyp_n ca 'R'.
        perform get_sd_materialdoc
          using 0
          changing ls_rmaorderinfo.
      endif.
      if ls_rmaorderinfo-vbfa_0_vbtyp_n = 'Q'.
        perform check_lvs using 0 ls_vbfa_stufe_0
                          changing ls_rmaorderinfo.
      endif.
      append ls_rmaorderinfo to p_t_rmaorderinfo.
      loop at lt_vbfa_stufe_1 into ls_vbfa_stufe_1.
        ls_rmaorderinfo-vbfa_1_vbeln = ls_vbfa_stufe_1-vbeln.
        ls_rmaorderinfo-vbfa_1_posnn = ls_vbfa_stufe_1-posnn.
        ls_rmaorderinfo-vbfa_1_vbtyp_n = ls_vbfa_stufe_1-vbtyp_n.
        perform get_sd_doctype
          using ls_vbfa_stufe_1-vbtyp_n
          changing ls_rmaorderinfo-vbfa_1_doctext
                   ls_rmaorderinfo-display_mode.
        if ls_rmaorderinfo-vbfa_1_vbtyp_n ca 'R'.
          perform get_sd_materialdoc
            using 1
            changing ls_rmaorderinfo.
        endif.
        if ls_rmaorderinfo-vbfa_1_vbtyp_n = 'Q'.
          perform check_lvs using 1 ls_vbfa_stufe_1
                            changing ls_rmaorderinfo.
        endif.
        append ls_rmaorderinfo to p_t_rmaorderinfo.
      endloop.
      clear ls_rmaorderinfo-vbfa_1_vbeln.
      clear ls_rmaorderinfo-vbfa_1_posnn.
      clear ls_rmaorderinfo-vbfa_1_vbtyp_n.
    endloop.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM check_lvs                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_step                                                        *
*  -->  p_vbfa                                                        *
*  -->  p_rmaorderinfo                                                *
*---------------------------------------------------------------------*
form check_lvs using    p_step         like sy-subrc
                        p_vbfa         like vbfa
               changing p_rmaorderinfo like gs_rmaorderinfo.

  data: lv_date like sy-datlo,
        lv_time like sy-timlo.
  data: lt_ltak like table of ltak with header line.

* Manuelle Kommimengeneintr?ge berücksichtigen!
  move p_vbfa-vbeln to lv_date.
  move p_vbfa-posnn to lv_time.

  if lv_date = p_vbfa-erdat and
     lv_time = p_vbfa-erzet.
    case p_step.
      when 0.
        p_rmaorderinfo-vbfa_0_doctext = text-028.
      when 1.
        p_rmaorderinfo-vbfa_1_doctext = text-028.
    endcase.
    clear p_rmaorderinfo-display_mode.
  else.
*   Lagernummer für Navigation bestimmen
    case p_step.
      when 0.
        select * from ltak into table lt_ltak
          where tanum = p_rmaorderinfo-vbfa_0_vbeln.
        check sy-subrc is initial.
        read table lt_ltak index 1.
        clear p_rmaorderinfo-vbfa_0_posnn.
        p_rmaorderinfo-vbfa_0_lgnum = lt_ltak-lgnum.
      when 1.
        select * from ltak into table lt_ltak
          where tanum = p_rmaorderinfo-vbfa_1_vbeln.
        check sy-subrc is initial.
        read table lt_ltak index 1.
        clear p_rmaorderinfo-vbfa_1_posnn.
        p_rmaorderinfo-vbfa_1_lgnum = lt_ltak-lgnum.
    endcase.
  endif.

endform.

*---------------------------------------------------------------------*
*       FORM get_sd_doctype                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_vbtyp                                                       *
*  -->  p_doctext                                                     *
*---------------------------------------------------------------------*
form get_sd_doctype using p_vbtyp like vbfa-vbtyp_n
                    changing p_doctext like dd07v-ddtext
                             p_display_mode like sy-cprog.

  data: ls_dd07v like dd07v.

  ls_dd07v-domname = 'VBTYP'.
  ls_dd07v-domvalue_l = p_vbtyp.

  call function 'RV_DOMAIN_VALUE_TEXTS'
       exporting
            domname  = ls_dd07v-domname
            domvalue = ls_dd07v-domvalue_l
       importing
            ddtext   = p_doctext.

  case p_vbtyp.
    when 'A'. p_display_mode = 'VA13'.
    when 'B'. p_display_mode = 'VA23'.
    when 'C'. p_display_mode = 'VA03'.
    when 'E'. p_display_mode = 'VA33'.
    when 'F'. p_display_mode = 'VA33'.
    when 'G'. p_display_mode = 'VA43'.
    when 'H'. p_display_mode = 'VA03'.
    when 'I'. p_display_mode = 'VA03'.
    when 'J'. p_display_mode = 'VL03'.
    when 'K'. p_display_mode = 'VA03'.
    when 'L'. p_display_mode = 'VA03'.
    when 'M'. p_display_mode = 'VF03'.
    when 'N'. p_display_mode = 'VF03'.
    when 'O'. p_display_mode = 'VF03'.
    when 'P'. p_display_mode = 'VF03'.
    when 'Q'. p_display_mode = 'LT21'.
    when 'R'. p_display_mode = 'MB03'.
    when 'S'. p_display_mode = 'VF03'.
    when 'T'. p_display_mode = 'VL03'.
    when 'U'. p_display_mode = 'VF03'.
    when 'V'. p_display_mode = 'ME23'.
    when 'h'. p_display_mode = 'MB03'.

    when others.
      clear p_display_mode.
  endcase.

endform.

*---------------------------------------------------------------------*
*       FORM show_doc                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_rmaorderinfo                                                *
*  -->  p_line                                                        *
*  -->  p_display_mode                                                *
*---------------------------------------------------------------------*
form show_doc
  tables p_rmaorderinfo structure gs_rmaorderinfo
  using  p_line         like      gs_docflow-line
         p_display_mode like      gs_docflow-display_mode.


*  data: lv_vbeln like gs_rmaorderinfo-vbeln.
  data: ls_rmaorderinfo like gs_rmaorderinfo.
  data: lv_exit  like sy-subrc.
  data: lv_mblnr like aufm-mblnr,
        lv_mjahr like aufm-mjahr.
  data: lv_rueck like coruf-rueck,
        lv_aufnr like coruf-aufnr,
        lv_vornr like coruf-vornr,
        lv_rmzhl like coruf-rmzhl,
        lv_kapar like coruf-kapar,
        lv_tplnr like coruf-tplnr,
        lv_equnr like coruf-equnr,
        lv_aufnr_ini like coruf-aufnr,
        lv_rmzhl_ini like coruf-rmzhl,
        lv_kapar_ini like coruf-kapar,
        lv_tplnr_ini like coruf-tplnr,
        lv_vornr_ini like coruf-vornr,
        lv_equnr_ini like coruf-equnr,
        lv_vbeln like vbak-vbeln,
        lv_vbeln_vf like vbak-vbeln,
        lv_vbeln_vl like vbak-vbeln,
        lv_tanum like ltak-tanum,
        lv_tapos like rl03t-tapos,
        lv_lgnum like ltak-lgnum
        .

  check not p_display_mode is initial.

  read table p_rmaorderinfo into ls_rmaorderinfo index p_line.

  get parameter id 'MBN' field lv_mblnr.
  get parameter id 'MJA' field lv_mjahr.
  get parameter id 'RCK' field lv_rueck.
  get parameter id 'ANR' field lv_aufnr.
  get parameter id 'VGN' field lv_vornr.
  get parameter id 'RZL' field lv_rmzhl.
  get parameter id 'CAA' field lv_kapar.
  get parameter id 'IFL' field lv_equnr.
  get parameter id 'EQN' field lv_tplnr.
  get parameter id 'AUN' field lv_vbeln.
  get parameter id 'VF'  field lv_vbeln_vf.
  get parameter id 'VL'  field lv_vbeln_vl.
  get parameter id 'TAN' field lv_tanum.
  get parameter id 'TAP' field lv_tapos.
  get parameter id 'LGN' field lv_lgnum.

* docs from service order
  if not ls_rmaorderinfo-ekko_ebeln is initial.
    set parameter id 'BES' field ls_rmaorderinfo-ekko_ebeln.
  elseif not ls_rmaorderinfo-eban_banfn is initial.
    set parameter id 'BAN' field ls_rmaorderinfo-eban_banfn.
  elseif not ls_rmaorderinfo-aufm_mblnr is initial.
    set parameter id 'MBN' field ls_rmaorderinfo-aufm_mblnr.
    set parameter id 'MJA' field ls_rmaorderinfo-aufm_mjahr.
  elseif not ls_rmaorderinfo-afru_rueck is initial.
    set parameter id 'ANR' field lv_aufnr_ini.
    set parameter id 'RZL' field lv_rmzhl_ini.
    set parameter id 'CAA' field lv_kapar_ini.
    set parameter id 'IFL' field lv_tplnr_ini.
    set parameter id 'EQN' field lv_equnr_ini.
    set parameter id 'RCK' field ls_rmaorderinfo-afru_rueck.
    set parameter id 'VGN' field lv_vornr_ini.
  elseif not ls_rmaorderinfo-aufnr is initial.
    set parameter id 'ANR' field ls_rmaorderinfo-aufnr.
* docs from sales order
  elseif not ls_rmaorderinfo-vbeln is initial.
    if not ls_rmaorderinfo-vbfa_1_vbeln is initial.
      case ls_rmaorderinfo-vbfa_1_vbtyp_n.
        when 'A' or 'B' or 'C' or 'G' or 'H' or 'I' or 'K' or 'L'.
          set parameter id 'AUN' field ls_rmaorderinfo-vbfa_1_vbeln.
        when 'J' or 'T'.
          set parameter id 'VL' field ls_rmaorderinfo-vbfa_1_vbeln.
        when 'M' or 'N' or 'O' or 'P' or 'S'.
          set parameter id 'VL' field ls_rmaorderinfo-vbfa_1_vbeln.
        when 'R' or 'h'.
          set parameter id 'MBN' field ls_rmaorderinfo-vbfa_1_vbeln.
          set parameter id 'MJA' field ls_rmaorderinfo-aufm_mjahr.
        when 'Q'.
          set parameter id 'TAN' field ls_rmaorderinfo-vbfa_1_vbeln.
          set parameter id 'LGN' field ls_rmaorderinfo-vbfa_1_lgnum.
        when 'V'.
          set parameter id 'BES' field ls_rmaorderinfo-ekko_ebeln.
        when others.
          message s889(co) with text-027.
           "  'Beleg mit diesem Typ kann nicht angezeigt werden.'.
          lv_exit = 1.
      endcase.
    elseif not ls_rmaorderinfo-vbfa_0_vbeln is initial.
      case ls_rmaorderinfo-vbfa_0_vbtyp_n.
        when 'A' or 'B' or 'C' or 'G' or 'H' or 'I' or 'K' or 'L'.
          set parameter id 'AUN' field ls_rmaorderinfo-vbfa_0_vbeln.
        when 'J' or 'T'.
          set parameter id 'VL' field ls_rmaorderinfo-vbfa_0_vbeln.
        when 'M' or 'N' or 'O' or 'P' or 'S'.
          set parameter id 'VF' field ls_rmaorderinfo-vbfa_0_vbeln.
        when 'R' or 'h'.
          set parameter id 'MBN' field ls_rmaorderinfo-vbfa_0_vbeln.
          set parameter id 'MJA' field ls_rmaorderinfo-aufm_mjahr.
        when 'Q'.
          set parameter id 'TAN' field ls_rmaorderinfo-vbfa_0_vbeln.
          set parameter id 'LGN' field ls_rmaorderinfo-vbfa_0_lgnum.
        when 'V'.
          set parameter id 'BES' field ls_rmaorderinfo-ekko_ebeln.
        when others.
          message s889(co) with text-027.
          lv_exit = 1.
      endcase.
    elseif not ls_rmaorderinfo-vbeln is initial.
      set parameter id 'AUN' field ls_rmaorderinfo-vbeln.
    else.
      exit.
    endif.
  endif.
  if lv_exit is initial.
    call transaction p_display_mode and skip first screen.
  endif.

* small turnaround for matdocs and confs
  set parameter id 'MBN' field lv_mblnr.
  set parameter id 'MJA' field lv_mjahr.
  set parameter id 'RCK' field lv_rueck.
  set parameter id 'ANR' field lv_aufnr.
  set parameter id 'VGN' field lv_vornr.
  set parameter id 'RZL' field lv_rmzhl.
  set parameter id 'CAA' field lv_kapar.
  set parameter id 'IFL' field lv_equnr.
  set parameter id 'EQN' field lv_tplnr.
  set parameter id 'AUN' field lv_vbeln.
  set parameter id 'VF'  field lv_vbeln_vf.
  set parameter id 'VL'  field lv_vbeln_vl.
  set parameter id 'TAN' field lv_tanum.
  set parameter id 'TAP' field lv_tapos.
  set parameter id 'LGN' field lv_lgnum.

endform.
