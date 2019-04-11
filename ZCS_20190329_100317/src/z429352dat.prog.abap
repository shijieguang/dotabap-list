*&---------------------------------------------------------------------*
*&  Include           Z429352DAT
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*& Objekt          REPS Z429352DAT
*& Objekt Header   PROG Z429352DAT
*&--------------------------------------------------------------------*
*>>>> START OF INSERTION <<<<
*----------------------------------------------------------------------*
*   INCLUDE Z429352DAT                                                 *
*----------------------------------------------------------------------*

data: caufv type caufv,
      vbak type vbak.
data: gt_t350 type table of t350.
data: gt_tvak type table of tvak.
data: gt_viaufkst type table of viaufkst.

data: begin of gs_rmaorderinfo,
        errorlevel like sy-subrc,
        vbeln like vbak-vbeln,
        posnr like vbap-posnr,
        pos_sub like vbap-posnr,
        aufnr like viaufkst-aufnr,
        vbeln_vbep like vbep-vbeln,
        posnr_vbep like vbep-posnr,
        vbeln_aufk like vbep-vbeln,
        posnr_aufk like vbep-posnr,
        afru_rueck like afru-rueck,
        afru_rmzhl like afru-rmzhl,
        afru_aufnr like afru-aufnr,
        afru_vornr like afru-vornr,
        afru_stokz like afru-stokz,
        aufm_mblnr like aufm-mblnr,
        aufm_mjahr like aufm-mjahr,
        aufm_zeile like aufm-zeile,
        aufm_bwart like aufm-bwart,
        aufm_sobkz like aufm-sobkz,
        aufm_werks like aufm-werks,
        aufm_lgort like aufm-lgort,
        aufm_matnr like aufm-matnr,
        aufm_menge like aufm-menge,
        aufm_meins like aufm-meins,
        pur_doctyp(15) type c,
        eban_banfn like eban-banfn,
        eban_bnfpo like eban-bnfpo,
        ekko_ebeln like ekko-ebeln,
        ekpo_ebelp like ekpo-ebelp,
        status_aufnr(80) type c,
        ekstat like dd07v-ddtext,
        errortext(80) type c,
        vbfa_0_vbeln like vbfa-vbeln,
        vbfa_0_posnn like vbfa-posnn,
        vbfa_0_vbtyp_n like vbfa-vbtyp_n,
        vbfa_0_bwart like vbfa-bwart,
        vbfa_0_sobkz like vbfa-sobkz,
        vbfa_0_doctext like dd07v-ddtext,
        vbfa_0_lgnum like LTAK-LGNUM,
        vbfa_1_vbeln like vbfa-vbeln,
        vbfa_1_posnn like vbfa-posnn,
        vbfa_1_vbtyp_n like vbfa-vbtyp_n,
        vbfa_1_bwart like vbfa-bwart,
        vbfa_1_sobkz like vbfa-sobkz,
        vbfa_1_doctext like dd07v-ddtext,
        vbfa_1_lgnum like LTAK-LGNUM,
        display_mode like sy-cprog,
      end of gs_rmaorderinfo.

data: gt_rmaorderinfo like table of gs_rmaorderinfo.


data: begin of gs_docflow,
        line like sy-tabix,
        icon(4) type c,
        position like sy-tabix,
        content(128) type c,
        display_mode like sy-cprog,
        errortext(80) type c,
        open type c,
      end of gs_docflow.
data: gt_docflow like table of gs_docflow.

* selection screen definitions

selection-screen begin of block g_selframe0
  with frame title text-003.

selection-screen skip 1.

selection-screen begin of block g_selframe1
  with frame title text-001.

select-options go_auart for caufv-auart.
select-options go_aufnr for caufv-aufnr.
select-options go_erdat for caufv-erdat.

selection-screen end of block g_selframe1.

selection-screen begin of block g_selframe2
  with frame title text-002.

select-options go_vauar for vbak-auart.
select-options go_vbeln for vbak-vbeln.
select-options go_anlda for vbak-erdat.

selection-screen end of block g_selframe2.

selection-screen skip 1.

selection-screen end of block g_selframe0.
