


select * from V_T265_Moisture_Soil
 order by T265_Sample_Year desc, T265_Sample_ID
;



-- T255 Moisture, Aggregate (current)
-- T265 Moisture, Soil      (current)



select count(*), min(sample_year), max(sample_year) from Test_T255 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 137	    1992	2018



select count(*), min(sample_year), max(sample_year) from Test_T265 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 9357	    1986	2019




/***********************************************************************************

 T255 Moisture, Aggregate
 W-18-0924-CO, W-18-0926-CO, W-18-1018-CO, W-18-1023-CO

 T265 Moisture, Soil
 W-18-0185-SO, W-18-0186-SO, W-18-0187-SO, W-18-0188-SO

 CustomaryOrMetric
 [0] temperature: 'M' = Celsius; 'C' = Fahrenheit

 T255
 W-18-0924-CO |C| Customary - Fahrenheit
 W-02-0040-AG |M| Metric    - Celsius

 T265
 W-18-0201-SO |C| Customary - Fahrenheit
 W-15-0013-SO |M| Metric    - Celsius
 
 
 from MTest, Lt_T255_B6.cpp, void LtT255b::CorGrpRoot::doCalcs(){
 
 T255, T265 formerly 081: natural moisture for Agg, Soils
 Process T255 or T265
 Calculate the percent moisture in a sample, JCU 12-88
 6-91: Combine m097 (SU 45) and m081 (SU 90) into m081 (SU 45)
 6-92: break up into T255 (SU 59) Nat. Moisture, Agg
                 and T265 (SU 45) Nat. Moisture, Soil
                 
 There are two variations of input on the screen: one uses a tare wt, one does not
 Resolve contention by using the tare version if both are present
 Note that if the tare field is left blank, the tare version will act identically to the other
 --  They asked to have it this way
 The two versions are now combined: tare is assumed zero if blank
 
 -1 % moisture        moribund:
 -2 wet sample wt     <--  -4 wt wet sample + tare
 -3 dried sample wt   <--  -5 wt dried sample + tare
 -6 tare
 -8 drying temperature (F)
 
 if (wet >= dry && dry >= 0.0)
 {
     tare = <get data>
     if (tare < 0.0) tare = 0.0;
     double denom = dry - tare;
     
     if (denom > 0.0)                               // my  notes
         moist = 100.0 * (wet - dry) / denom;       // ((wet - dry) / (dry - tare)) * 100
 }
 

***********************************************************************************/



create or replace view V_T265_Moisture_Soil as 

select  t265.sample_id                         as T265_Sample_ID
       ,t265.sample_year                       as T265_Sample_Year
       ,t265.test_status                       as T265_Test_Status
       ,t265.tested_by                         as T265_Tested_by
       
       ,case when to_char(t265.date_tested, 'yyyy') = '1959'
             then ' '
             else to_char(t265.date_tested, 'mm/dd/yyyy')
             end                              as T265_date_tested
            
       ,t265.date_tested                        as T265_date_tested_DATE
       ,t265.date_tested_orig                   as T265_date_tested_orig
       
       /*--------------------------------------------------------------------------
         user-entered values
       --------------------------------------------------------------------------*/
       
       ,case when t265.mass_wet_aggregate >= 0 then trim(to_char(t265.mass_wet_aggregate, '99990.99')) else ' ' end as T265_mass_wet_aggregate
       ,case when t265.mass_dry_aggregate >= 0 then trim(to_char(t265.mass_dry_aggregate, '99990.99')) else ' ' end as T265_mass_dry_aggregate
       ,case when t265.mass_tare          >= 0 then trim(to_char(t265.mass_tare,          '99990.99')) else ' ' end as T265_mass_tare
       
       /*--------------------------------------------------------------------------
         pct_moisture = 
         ((mass_wet_aggregate - mass_dry_aggregate) / mass_dry_aggregate) * 100
         ((calc_mass_wet - calc_mass_dry) / (calc_mass_dry - calc_mass_tare)) * 100
       --------------------------------------------------------------------------*/
       
       ,case when calc_pct_moisture >= 0 then trim(to_char(calc_pct_moisture, '990.9999')) else ' ' end as T255_percent_moisture 
       
       ,t265.drying_temperature as T265_drying_temperature
       ,t265.temperature_scale         as T265_temperature_scale
       
       ,t265.remarks            as T265_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T265                               t265 on t265.sample_id = smpl.sample_id
  
  /*-------------------------------------------------------------
    calculations
  -------------------------------------------------------------*/
  
  cross apply (select case when (t265.mass_wet_aggregate >= 0) then t265.mass_wet_aggregate
                           else 0 end as calc_mass_wet  from dual) CALC_WET
  
  cross apply (select case when (t265.mass_dry_aggregate >= 0) then t265.mass_dry_aggregate
                           else 0 end as calc_mass_dry  from dual) CALC_DRY
                      
  cross apply (select case when (t265.mass_tare >= 0)          then t265.mass_tare
                           else 0 end as calc_mass_tare from dual) CALC_TARE
                          
  cross apply (select (calc_mass_dry - calc_mass_tare) as calc_denominator from dual) CALC_DENOM -- not using this
  
  cross apply (select case when (calc_mass_wet >= calc_mass_dry) and (calc_mass_dry - calc_mass_tare) > 0 
                           then (((calc_mass_wet - calc_mass_dry) / (calc_mass_dry - calc_mass_tare)) * 100)
                           else -1 end as calc_pct_moisture from dual) calc_moist
                           
 ;









