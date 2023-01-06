class ZCL_COUNT_WORDS_GIT definition
  public
  final
  create public .

public section.

  types:
    TT_CHAR TYPE STANDARD TABLE OF c .
  types:
    BEGIN OF ty_map,
   word TYPE string,
   count TYPE i,
   END OF ty_map .
  types:
    mt_map TYPE STANDARD TABLE OF ty_map WITH KEY word .

  class-methods COUNT
    importing
      !IV_SENTENCE type STRING
    exporting
      value(ET_MAP) type MT_MAP
      !EV_TOT_COUNT type I .
  class-methods PROCESS
    importing
      !IV_SENTENCE type STRING
    returning
      value(RV_SENTENCE) type STRING .
  class-methods COUNT_CHAR
    importing
      !IV_WORD type STRING
    changing
      value(CT_MAP) type MT_MAP .
private section.
ENDCLASS.



CLASS ZCL_COUNT_WORDS_GIT IMPLEMENTATION.


  METHOD count.
    DATA: ls_map          TYPE ty_map,
          lt_unique_words TYPE STANDARD TABLE OF string WITH KEY table_line,
          lt_words        TYPE STANDARD TABLE OF string.
    process(
      EXPORTING
        iv_sentence = iv_sentence
      RECEIVING
        rv_sentence = DATA(lv_sentence)
    ).
    "Add solution here
    SPLIT lv_sentence AT ' ' INTO TABLE lt_words.
    ev_tot_count = lines( lt_words ).
    LOOP AT lt_words ASSIGNING FIELD-SYMBOL(<ls_word>).
      count_char(
        EXPORTING
          iv_word = <ls_word>
        changing
          ct_map  = et_map
      ).

    ENDLOOP.
  ENDMETHOD.


  method PROCESS.
  rv_sentence = iv_sentence.
    "Convert all to lower case
    rv_sentence = to_lower( rv_sentence ).
    "Convert all word breakers into space
    REPLACE ALL OCCURRENCES OF REGEX '(''|:|&|@|$|%|^)' IN rv_sentence WITH ''.
    REPLACE ALL OCCURRENCES OF '$' IN rv_sentence WITH ''.
    REPLACE ALL OCCURRENCES OF '^' IN rv_sentence WITH ''.
    REPLACE ALL OCCURRENCES OF '\t' IN rv_sentence WITH ' '.
    REPLACE ALL OCCURRENCES OF '\n' IN rv_sentence WITH ' '.
    REPLACE ALL OCCURRENCES OF '.' IN rv_sentence WITH ' '.
    REPLACE ALL OCCURRENCES OF '!' IN rv_sentence WITH ''.
    REPLACE ALL OCCURRENCES OF ', ' IN rv_sentence WITH ' '.
    REPLACE ALL OCCURRENCES OF ',' IN rv_sentence WITH ' '.
    CONDENSE rv_sentence.
  endmethod.


  METHOD count_char.
    DATA:
      v             TYPE c,
      n             TYPE i,
      unique_string TYPE string value '',
      ls_map TYPE ty_map.
    DATA(lv_word) = iv_word.
    REPLACE ALL OCCURRENCES OF REGEX '(\d)' IN lv_word WITH ''.
    DATA(cnt) = STRLEN( lv_word ).
    DO cnt TIMES.
      MOVE lv_word+n(1) TO v.
      n = n + 1.
      FIND ALL OCCURRENCES OF v IN unique_string MATCH COUNT DATA(count).
      IF count < 1.
        CONCATENATE v unique_string INTO unique_string.
      ENDIF.
    ENDDO.
    data(charcount) = STRLEN( unique_string ).
    ls_map-word = iv_word .
    ls_map-count = charcount .
    COLLECT ls_map INTO ct_map.

  ENDMETHOD.
ENDCLASS.
