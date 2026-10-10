@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection Item Ordem de Venda'
@Metadata.allowExtensions: true 

define view entity Z_C_OVITEM  as projection on Z_I_OVITEM
{

    key Ordemid,
    key Itemid,
    Material,
    Descricao,
    Quantidade,
    @UI.hidden: true
    Moeda,
    @Semantics.amount.currencyCode: 'Moeda'
    Precouni,
    @Semantics.amount.currencyCode: 'Moeda'
    Precotot,
    
    _Header : redirected to parent Z_C_OVCAB
   
    
}
