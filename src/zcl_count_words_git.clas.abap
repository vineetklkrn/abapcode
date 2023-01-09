CLASS zcl_count_words_git DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      tt_char TYPE STANDARD TABLE OF c .
    TYPES:
      BEGIN OF ty_map,
        word  TYPE string,
        count TYPE i,
      END OF ty_map .
    TYPES:
      mt_map TYPE STANDARD TABLE OF ty_map WITH KEY word .

    CLASS-METHODS count
      IMPORTING
        !iv_sentence  TYPE string
      EXPORTING
        VALUE(et_map) TYPE mt_map
        !ev_tot_count TYPE i .
    CLASS-METHODS process
      IMPORTING
        !iv_sentence       TYPE string
      RETURNING
        VALUE(rv_sentence) TYPE string .
    CLASS-METHODS count_char
      IMPORTING
        !iv_word      TYPE string
      CHANGING
        VALUE(ct_map) TYPE mt_map .

ENDCLASS.



CLASS zcl_count_words_git IMPLEMENTATION.


  METHOD count.
    DATA: ls_map          TYPE ty_map,
          lt_unique_words TYPE STANDARD TABLE OF string WITH KEY table_line,
          lt_words        TYPE STANDARD TABLE OF string.

    "First pre-process the sentence
    process(
      EXPORTING
        iv_sentence = iv_sentence
      RECEIVING
        rv_sentence = DATA(lv_sentence)
    ).

    "split the sentence and store it in itab.
    SPLIT lv_sentence AT ' ' INTO TABLE lt_words.
    ev_tot_count = lines( lt_words ).

    "count unique characters in each line and update the et_map.
    LOOP AT lt_words ASSIGNING FIELD-SYMBOL(<ls_word>).
      count_char(
        EXPORTING
          iv_word = <ls_word>
        CHANGING
          ct_map  = et_map
      ).

    ENDLOOP.
  ENDMETHOD.


  METHOD process.
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
  ENDMETHOD.


  METHOD count_char.
    DATA:
      v             TYPE c,
      n             TYPE i,
      unique_string TYPE string VALUE '',
      ls_map        TYPE ty_map.
    DATA(lv_word) = iv_word.
    "Do not consider integer while counting the unique characters.
    REPLACE ALL OCCURRENCES OF REGEX '(\d)' IN lv_word WITH ''.
    DATA(cnt) = strlen( lv_word ).

    "create the string with unique char and then count the strlen
    DO cnt TIMES.
      MOVE lv_word+n(1) TO v.
      n = n + 1.
      FIND ALL OCCURRENCES OF v IN unique_string MATCH COUNT DATA(count).
      IF count < 1.
        CONCATENATE v unique_string INTO unique_string.
      ENDIF.
    ENDDO.
    DATA(charcount) = strlen( unique_string ).

    "build and return the map for each line
    ls_map-word = iv_word .
    ls_map-count = charcount .
    INSERT ls_map INTO TABLE ct_map.

  ENDMETHOD.
ENDCLASS.
