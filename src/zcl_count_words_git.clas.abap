class ZCL_COUNT_WORDS_GIT definition
  public
  final
  create public .

public section.

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
    returning
      value(RT_MAP) type MT_MAP .
  class-methods PROCESS
    importing
      !IV_SENTENCE type STRING
    returning
      value(RV_SENTENCE) type STRING .
ENDCLASS.



CLASS ZCL_COUNT_WORDS_GIT IMPLEMENTATION.


  method COUNT.
  DATA: ls_map TYPE ty_map,
          lt_unique_words TYPE STANDARD TABLE OF string with key table_line,
          lt_words TYPE STANDARD TABLE OF string.
   process(
            EXPORTING
                iv_sentence = iv_sentence
            RECEIVING
                rv_sentence = data(lv_sentence)
    ).
    "Add solution here
    SPLIT lv_sentence at ' ' INTO TABLE lt_words.
    sort lt_words.
    lt_unique_words = lt_words.
    delete adjacent duplicates from lt_unique_words.
    delete lt_unique_words where table_line = ' '.
    LOOP AT lt_unique_words into DATA(ls_word).
        data(lt_l) = lt_words.
        DELETE lt_l WHERE TABLE_LINE ne ls_word.
        ls_map-count = lines( lt_l ).
        ls_map-word = ls_word.
        append ls_map to rt_map.
    ENDLOOP.
  endmethod.


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
ENDCLASS.
