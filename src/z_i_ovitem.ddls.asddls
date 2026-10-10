@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity Z_I_OVITEM as select from zovitem
association to parent Z_I_OVCAB as _Header on $projection.Ordemid = _Header.Ordemid
{
    key ordemid as Ordemid,
    key itemid as Itemid,
    material as Material,
    descricao as Descricao,
    quantidade as Quantidade,
    @UI.hidden: true
    cast( 'BRL' as abap.cuky ) as Moeda,
    @Semantics.amount.currencyCode: 'Moeda'
    precouni as Precouni,
    @Semantics.amount.currencyCode: 'Moeda'
    precotot as Precotot,
    
    _Header
}




