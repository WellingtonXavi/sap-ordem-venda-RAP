CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.


    METHODS earlynumbering_cba_Item FOR NUMBERING IMPORTING entities FOR CREATE Ordem\_Item.

    METHODS calcularPrecoTotal FOR DETERMINE ON MODIFY        IMPORTING keys FOR Item~calcularPrecoTotal.
    METHODS recalcularTotalOrdem FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Item~recalcularTotalOrdem.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.



  METHOD earlynumbering_cba_item.

    " 1. Loop por todas as entidades pai (Ordem) recebidas
    LOOP AT entities INTO DATA(ls_ordem).

      " Busca o maior Itemid existente na base/draft para essa Ordem
      READ ENTITIES OF z_i_ovcab IN LOCAL MODE
        ENTITY Ordem BY \_Item
        FIELDS ( Itemid )
        WITH VALUE #( ( %tky = ls_ordem-%tky ) )
        RESULT DATA(lt_itens_existentes).

      DATA(lv_max_item) = 0.

      LOOP AT lt_itens_existentes INTO DATA(ls_item_existente).
        IF ls_item_existente-Itemid > lv_max_item.
          lv_max_item = ls_item_existente-Itemid.
        ENDIF.
      ENDLOOP.

      " 2. Para cada novo item contido em %target, atribui a nova chave
      LOOP AT ls_ordem-%target INTO DATA(ls_novo_item).

        lv_max_item += 10. " Incremente de 10 em 10 (ex: 10, 20, 30...)

        " PREENCHIMENTO OBRIGATÓRIO PARA CADA INSTÂNCIA
        APPEND VALUE #(
          %cid      = ls_novo_item-%cid
          %is_draft = ls_novo_item-%is_draft
          Ordemid   = ls_novo_item-Ordemid
          Itemid    = lv_max_item
        ) TO mapped-item.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD calcularPrecoTotal.

    READ ENTITIES OF z_i_ovcab IN LOCAL MODE
    ENTITY Item
    FIELDS ( Quantidade Precouni )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_itens).


    DATA lt_update TYPE TABLE FOR UPDATE z_i_ovitem.

    lt_update = VALUE #(
     FOR ls_item IN lt_itens
     (
       %tky     = ls_item-%tky
       Precotot = ls_item-Quantidade * ls_item-Precouni
     )
   ).




    MODIFY ENTITIES OF z_i_ovcab IN LOCAL MODE
    ENTITY Item
    UPDATE FIELDS ( Precotot )
    WITH lt_update.

  ENDMETHOD.

  METHOD recalcularTotalOrdem.

    " 1. Lê a ordem pai (_Header) a partir dos itens alterados
    READ ENTITIES OF z_i_ovcab IN LOCAL MODE
      ENTITY Item BY \_Header
        FIELDS ( Ordemid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ordens).

    IF lt_ordens IS INITIAL.
      RETURN.
    ENDIF.

    " Remove duplicadas preservando a chave do Draft
    SORT lt_ordens BY Ordemid %is_draft.
    DELETE ADJACENT DUPLICATES FROM lt_ordens COMPARING Ordemid %is_draft.

    " 2. Processa o recálculo para cada ordem afetada
    LOOP AT lt_ordens INTO DATA(ls_ordem_key).

      " --- LEITURA DO FRETE (Lido 1x por Ordem) ---
      READ ENTITIES OF z_i_ovcab IN LOCAL MODE
        ENTITY Ordem
          FIELDS ( Totalfrete )
          WITH VALUE #( ( %tky = ls_ordem_key-%tky ) )
        RESULT DATA(lt_ordem_dados).

      DATA(lv_frete) = VALUE #( lt_ordem_dados[ 1 ]-Totalfrete OPTIONAL ).

      DATA lv_valortotalitens TYPE z_i_ovcab-Totalitens VALUE 0.

      " --- LEITURA DOS ITENS DA ORDEM ---
      READ ENTITIES OF z_i_ovcab IN LOCAL MODE
        ENTITY Ordem BY \_Item
          FIELDS ( Precotot Quantidade Precouni )
          WITH VALUE #( ( %tky = ls_ordem_key-%tky ) )
        RESULT DATA(lt_itens).

      " Acumula o valor total dos itens
      LOOP AT lt_itens INTO DATA(ls_item).
        IF ls_item-Precotot IS NOT INITIAL AND ls_item-Precotot <> 0.
          lv_valortotalitens += ls_item-Precotot.
        ELSE.
          " Calcula diretamente caso Precotot ainda não tenha sido atualizado na sessão
          lv_valortotalitens += ( ls_item-Quantidade * ls_item-Precouni ).
        ENDIF.
      ENDLOOP.

      " --- CÁLCULO DO TOTAL DA ORDEM (ITENS + FRETE) ---
      DATA(lv_total_ordem) = lv_valortotalitens + lv_frete.

      " 3. Atualiza os totais (Totalitens e Totalordem) na Ordem
      MODIFY ENTITIES OF z_i_ovcab IN LOCAL MODE
        ENTITY Ordem
          UPDATE SET FIELDS WITH VALUE #( (
            %tky                = ls_ordem_key-%tky
            Totalitens          = lv_valortotalitens
            Totalordem          = lv_total_ordem
            %control-Totalitens = if_abap_behv=>mk-on
            %control-Totalordem = if_abap_behv=>mk-on
          ) ).

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
























CLASS lhc_Ordem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Ordem RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Ordem RESULT result.


    METHODS determinardadoscriacao FOR DETERMINE ON SAVE
      IMPORTING keys FOR ordem~determinardadoscriacao.

    METHODS fornecer FOR MODIFY
      IMPORTING keys FOR ACTION ordem~fornecer .

    METHODS validarcliente FOR VALIDATE ON SAVE
      IMPORTING keys FOR ordem~validarcliente.



    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Ordem.

ENDCLASS.

CLASS lhc_Ordem IMPLEMENTATION.

  METHOD get_instance_authorizations.


  ENDMETHOD.

  METHOD earlynumbering_create.

    SELECT MAX( ordemid )
        FROM zovcab
        INTO @DATA(lv_max_ordem).

    IF lv_max_ordem IS INITIAL.
      lv_max_ordem = 0.
    ENDIF.

    LOOP AT entities INTO DATA(ls_entity).

      lv_max_ordem += 1.

      APPEND VALUE #(
        %cid      = ls_entity-%cid
        %is_draft = ls_entity-%is_draft
        ordemid   = lv_max_ordem
      ) TO mapped-ordem.

    ENDLOOP.



  ENDMETHOD.



  METHOD determinarDadosCriacao.



    DATA(lv_data)    = cl_abap_context_info=>get_system_date( ).
    DATA(lv_hora)    = cl_abap_context_info=>get_system_time( ).
    DATA(lv_usuario) = cl_abap_context_info=>get_user_technical_name( ).

    MODIFY ENTITIES OF z_i_ovcab IN LOCAL MODE
     ENTITY Ordem
     UPDATE FIELDS ( CriacaoData CriacaoHora CriacaoUsuario Status )
     WITH VALUE #(
       FOR key IN keys
       (
         ordemid        = key-ordemid
         CriacaoData    = lv_data
         CriacaoHora    = lv_hora
         CriacaoUsuario = lv_usuario
         Status = 'N'
       )
     ).



  ENDMETHOD.

  METHOD fornecer.


    READ ENTITIES OF z_i_ovcab IN LOCAL MODE
     ENTITY Ordem
     FIELDS ( Status )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_ordens)
     FAILED DATA(lt_failed_read)
     REPORTED DATA(lt_reported_read).

    LOOP AT lt_ordens INTO DATA(ls_ordem).

      IF ls_ordem-Status <> 'N'.

        APPEND VALUE #(
          %tky = ls_ordem-%tky
        ) TO failed-ordem.

        APPEND VALUE #(
          %tky = ls_ordem-%tky
          %msg = new_message(
            id       = 'ZMC_OV'
            number   = '001'
            severity = if_abap_behv_message=>severity-error
            v1       = CONV #( ls_ordem-Ordemid )
            v2       = ls_ordem-Status
          )
        ) TO reported-ordem.

      ENDIF.

    ENDLOOP.

    DATA lt_validas TYPE TABLE FOR READ RESULT z_i_ovcab\\Ordem.

    lt_validas = VALUE #(
      FOR ls_ordem2 IN lt_ordens
      WHERE ( Status = 'N' )
      (
        Ordemid = ls_ordem2-Ordemid
      )
    ).


    MODIFY ENTITIES OF z_i_ovcab IN LOCAL MODE
    ENTITY Ordem
    UPDATE FIELDS ( Status )
    WITH VALUE #(
      FOR ls_ordem2 IN lt_validas
      (
        Ordemid = ls_ordem2-Ordemid
        Status  = 'F'
      )
    )
    FAILED DATA(lt_failed_update)
    REPORTED DATA(lt_reported_update).



  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF z_i_ovcab IN LOCAL MODE
    ENTITY Ordem
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_ordens).


    result = VALUE #(
   FOR ls_ordem IN lt_ordens
   (
     %tky = ls_ordem-%tky

     %action-fornecer = COND #(
       WHEN ls_ordem-Status = 'N'
       THEN if_abap_behv=>fc-o-enabled
       ELSE if_abap_behv=>fc-o-disabled
     )
   )
 ).




  ENDMETHOD.

  METHOD validarCliente.

    READ ENTITIES OF z_i_ovcab IN LOCAL MODE
       ENTITY Ordem
       FIELDS ( Clienteid )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_ordens).

    LOOP AT lt_ordens INTO DATA(ls_ordem).

      IF ls_ordem-Clienteid IS INITIAL.

        APPEND VALUE #( %tky = ls_ordem-%tky ) TO failed-ordem.

        APPEND VALUE #(
          %tky               = ls_ordem-%tky
          %element-clienteid = if_abap_behv=>mk-on  "
          %msg               = new_message(
            id       = 'ZMC_OV'
            number   = '002'
            severity = if_abap_behv_message=>severity-error
            v1       = CONV #( ls_ordem-Ordemid )
          )
        ) TO reported-ordem.

       ENDIF.

      endloop.

      ENDMETHOD.

ENDCLASS.
