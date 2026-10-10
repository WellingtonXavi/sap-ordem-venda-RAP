CLASS zcl_teste_eml_ov DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_teste_eml_ov IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

   READ ENTITIES OF z_i_ovcab
  ENTITY Ordem
  BY \_Item
  ALL FIELDS
  WITH VALUE #(
    ( Ordemid = 2 )
  )
  RESULT DATA(lt_itens)
  FAILED DATA(lt_failed)
  REPORTED DATA(lt_reported).

out->write( lt_itens ).
out->write( lt_failed ).
out->write( lt_reported ).

  ENDMETHOD.

ENDCLASS.
