REPORT zsplitwords_git.
SELECTION-SCREEN BEGIN OF BLOCK sentence_type WITH FRAME TITLE TEXT-001.
  PARAMETERS: sentence TYPE string.
SELECTION-SCREEN END OF BLOCK sentence_type.

zcl_count_words_git=>count(
  EXPORTING
    iv_sentence  = sentence
  IMPORTING
    et_map       = DATA(lt_map)
    ev_tot_count = DATA(lv_tot_count)
).
WRITE: 'Number of words of this sentence: ' , lv_tot_count.
ULINE.
LOOP AT lt_map ASSIGNING FIELD-SYMBOL(<ls_map>).
  WRITE: 'Number of unique characters in the word: ' , <ls_map>-word, ': ', <ls_map>-count.
  ULINE.
ENDLOOP.
