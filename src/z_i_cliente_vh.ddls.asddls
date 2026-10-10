@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help Cliente'

define view entity Z_I_CLIENTE_VH
  as select from kna1
{

  key   kunnr as Clienteid,
        name1 as Nome

}
