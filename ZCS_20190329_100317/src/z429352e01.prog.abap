*&---------------------------------------------------------------------*
*&  Include           Z429352E01
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*& Objekt          REPS Z429352E01
*& Objekt Header   PROG Z429352E01
*&--------------------------------------------------------------------*
*>>>> START OF INSERTION <<<<
*----------------------------------------------------------------------*
*   INCLUDE Z429352E01                                                 *
*----------------------------------------------------------------------*

at selection-screen.

* pass when F8
  check sy-ucomm = 'ONLI'.

  if ( go_auart[] is initial and
       go_aufnr[] is initial and
       go_erdat[] is initial ) and not
     ( go_vauar[] is initial and
       go_vbeln[] is initial and
       go_anlda[] is initial ).
    perform select_from_sd.
  else.
    perform select_from_cs.
  endif.

end-of-selection.

  perform write_list.

at line-selection.

  if sy-lisel ca '@'.
    perform show_doc
      tables gt_rmaorderinfo
      using  gs_docflow-line gs_docflow-display_mode.

  endif.
