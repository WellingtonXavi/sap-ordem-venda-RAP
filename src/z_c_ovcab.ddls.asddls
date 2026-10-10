@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Ordem de Venda'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity Z_C_OVCAB
  provider contract transactional_query
  as projection on Z_I_OVCAB
{


  key Ordemid,
      CriacaoData,
      CriacaoHora,
      CriacaoUsuario,
      @Consumption.valueHelpDefinition: [
      {
      entity: {
      name: 'Z_I_CLIENTE_VH',
      element: 'Clienteid'
      }
      }
      ]
      Clienteid,
      @UI.hidden: true
      Moeda,
      @Semantics.amount.currencyCode: 'Moeda'
      Totalitens,
      @Semantics.amount.currencyCode: 'Moeda'
      Totalfrete,
      @Semantics.amount.currencyCode: 'Moeda'
      Totalordem,
      Status,
      status_texto,
      classificacao_valor,
      LastChangedAt,
      status_criticality,



      _Item : redirected to composition child Z_C_OVITEM


}
