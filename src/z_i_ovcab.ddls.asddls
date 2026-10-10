@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface ordem de Venda'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z_I_OVCAB
  as select from zovcab
  composition [0..*] of Z_I_OVITEM as _Item
{


  key ordemid         as Ordemid,
      criacao_data    as CriacaoData,
      criacao_hora    as CriacaoHora,
      criacao_usuario as CriacaoUsuario,

    
      clienteid       as Clienteid,
      
    
    @UI.hidden: true
      cast( 'BRL' as abap.cuky ) as Moeda,
    
      @Semantics.amount.currencyCode: 'Moeda'
      totalitens      as Totalitens,
      @Semantics.amount.currencyCode: 'Moeda'
      totalfrete      as Totalfrete,
      @Semantics.amount.currencyCode: 'Moeda'
      totalordem      as Totalordem,
      status          as Status,

      case status
      when 'N' then 'NOVO'
      when 'F' then 'FORNECIDO'
      when 'B' then 'FATURADA'
      when 'C' then 'CANCELADA'
      else          'DESCONHECIDA'
      end             as status_texto,
      
      
      case status
        when 'N' then 2  
        when 'F' then 3  
        when 'B' then 4  
        when 'C' then 1  
        else          0  
      end as status_criticality,
      


      cast(
      case
      when totalordem > 10000 then 'ALTO'
      when totalordem > 5000  then 'MEDIO'
      else 'BAIXO'
      end
      as abap.char(5)
      )               as classificacao_valor,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at as LastChangedAt,
      
      
      _Item
}
