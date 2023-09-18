


select * from V_T92_Shrinkage_Limit where T92_sample_year >= '2000'
 order by T92_sample_year desc, T92_sample_id
 ;




select count(*), min(sample_year), max(sample_year) from Test_T92 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 39	    1993	2010



select * from test_t92 order by sample_year desc, sample_id;




/***********************************************************************************

 T92 Shrinkage Limit
 
 W-10-0171-SO, W-10-0172-SO, W-09-0053-SO, W-09-0054-SO, W-08-0191-SO, W-08-0192-SO
 W-07-0059-SO, W-07-0060-SO, W-06-0042-SO, W-06-0043-SO, W-05-0048-SO, W-05-0049-SO
 W-04-0051-SO, W-04-0052-SO, W-03-0072-SO, W-03-0073-SO, W-02-0026-SO, W-02-0027-SO
 W-01-0015-SO, W-01-0016-SO, W-01-0967-SO, W-01-0968-SO
 W-00-0031-SO, W-00-0772-SO, W-00-0773-SO
 
 W-99-0018-SO, W-99-0019-SO, W-99-0527-SO, W-99-0528-SO
 W-97-0072-SO, W-97-0073-SO, W-96-0704-SO, W-96-0705-SO
 W-94-0081-SO, W-94-0082-SO, W-94-1092-SO, W-94-1093-SO
 W-93-0852-SO, W-93-0853-SO
 
 
 from MTest, Lt_T92_C7.cpp, void LtT92_C7::CorGrpRoot::calc(unsigned fldcode)
 {
    if( tare < 0.0 )       tare = 0.0;
    if( grossdry >= tare ) wtdry = grossdry - tare;
    if( grosswet >= 0.0 )  wtwet = grosswet - tare;
    
    if( wtdry >= 0.0 && wtwet >= 0.0 ) water = 100.0*(wtwet - wtdry)/wtdry;             // water_content_pct
    
    if( volwet > 0.0 && voldry > 0.0 && water > 0.0 )  
                                       limit = water - 100.0*(volwet - voldry) / wtdry; // shrinkage limit
    
    if( voldry > 0.0 )                 ratio = wtdry / voldry;                          // shrinkage ratio
    
    if(  moist >= 0.0 && limit >= 0.0 && ratio >= 0.0 ) 
    {
        change = ratio * (moist - limit);                                               // volumetric change
           tmp = 100.0/(100.0 - change);
         third = 1.0/3.0;
        lineal = 100.0 * ( 1.0 - pow(tmp, third) );                                     // lineal shrinkage
 

***********************************************************************************/


create or replace view V_T92_Shrinkage_Limit as 


select  t92.sample_id                                         as T92_Sample_ID
       ,t92.sample_year                                       as T92_sample_year
       ,t92.test_status                                       as T92_test_status
       ,t92.tested_by                                         as T92_tested_by
       
       ,case when to_char(t92.date_tested, 'yyyy') = '1959'   then ' ' 
        else to_char(t92.date_tested, 'mm/dd/yyyy') end       as T92_date_tested
        
       ,t92.date_tested                                       as T92_date_tested_DATE
       ,t92.date_tested_orig                                  as T92_date_tested_orig         
       
       ,t92.mass_wet_soil_dish                                as T92_mass_wet_soil_and_dish
       ,t92.mass_dry_soil_dish                                as T92_mass_dry_soil_and_dish
       ,t92.mass_dish                                         as T92_mass_dish
       ,t92.volume_wet_soil                                   as T92_volume_wet_soil
       ,t92.volume_dry_soil                                   as T92_volume_dry_soil
       
       ,water_content_pct                                     as T92_water_content_pct
       ,shrinkage_limit                                       as T92_shrinkage_limit
       ,shrinkage_ratio                                       as T92_shrinkage_ratio
       
       ,t92.pct_field_moisture                                as T92_pct_field_moisture
       ,volumetric_change                                     as T92_volumetric_change
       ,lineal_shrinkage                                      as T92_lineal_shrinkage
       
       ,t92.captured_shrinkage_limit                          as T92_captured_shrinkage_limit
       
       ,t92.remarks                                           as T92_remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                           smpl
       join Test_T92                                      t92 on t92.sample_id      = smpl.sample_id
       
       /*-----------------------------------------------------------------------
         calculations
       -----------------------------------------------------------------------*/
       
       cross apply (select case when t92.mass_dish          >= 0 then t92.mass_dish          else 0 end as tare      from dual) tarewt
       cross apply (select case when t92.mass_wet_soil_dish >= 0 then t92.mass_wet_soil_dish else 0 end as gross_wet from dual) grosswet
       cross apply (select case when t92.mass_dry_soil_dish >= 0 then t92.mass_dry_soil_dish else 0 end as gross_dry from dual) grossdry
       
       cross apply (select gross_wet - tare as wt_wet from dual) wtwet
       cross apply (select gross_dry - tare as wt_dry from dual) wtdry
       
       cross apply (select case when (wt_wet >= 0 and wt_dry > 0) then (((wt_wet - wt_dry) / wt_dry) * 100.0)
                                else -1 end as water_content_pct from dual) water
       
       cross apply (select case when (t92.volume_wet_soil > 0 and t92.volume_dry_soil > 0 and water_content_pct > 0) 
                                then water_content_pct - ((100.0 * (t92.volume_wet_soil - t92.volume_dry_soil)) / wt_dry)
                                else -1 end as shrinkage_limit from dual) slimit
       
       cross apply (select case when (t92.volume_dry_soil > 0 and wt_dry >= 0) then (wt_dry / t92.volume_dry_soil)
                                else -1 end as shrinkage_ratio from dual) sratio
       
       cross apply (select case when (t92.pct_field_moisture >= 0 and shrinkage_limit >= 0 and shrinkage_ratio >= 0) 
                                then (shrinkage_ratio * (t92.pct_field_moisture - shrinkage_limit))
                                else -1 end as volumetric_change from dual) volchange
       
       
       cross apply (select case when (t92.pct_field_moisture >= 0 and shrinkage_limit >= 0 and shrinkage_ratio >= 0) 
                                then 100.0 * ( 1.0 - power( (100.0/(100.0 - volumetric_change)), (1.0/3.0) ) )
                                else -1 end as lineal_shrinkage from dual) linealshr
       
       ;









