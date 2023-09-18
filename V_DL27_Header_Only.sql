


-- DL11 Sieve Analysis, fine wash T11/T27     (2020)
-- DL27 Sieve Analysis, Complete Dry/Washed   (2020)
-- T30  Sieve Analysis of Extracted Aggregate (2020)
-- T37  Sieve Analysis of Mineral Filler      (1994)



select * from V_DL27_Header_Only order by DL27_Sample_Year desc, DL27_Sample_ID;




select count(*), min(sample_year), max(sample_year) from Test_DL27 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 1160	    1988	2019
-- 1168 including 1960




/***********************************************************************************

 DL27 Sieve Analysis, Complete Dry/Washed
 
 W-18-0078-AG, W-18-0120-AG, W-17-0014-AG, W-17-0043-SO, W-17-0116-SO

 CustomaryOrMetric
 -----------------
 W-18-0078-AG |C| Sieve Units, Customary
 W-03-0737-AG |M| Sieve Units, Metric (very few instances of metric)
 W-02-0433-AC |M| Sieve Units, Metric
                    
***********************************************************************************/


create or replace view V_DL27_Header_Only as

with DL27_sql as (

     select sample_id as sample_id
     
     /*------------------------------------------------------------------------------
       Moisture Ratio: from Mtest, Lt_DL27_BC.cpp, calcMD()
       if (mdry > 0.0 && mwet >= mdry) ratio = ((mwet - mdry) / mdry)
       used for pct_moisture and total_dry_mass, and not displayed upon the screen
     ------------------------------------------------------------------------------*/
  
     ,case when (mass_dry > 0 and mass_wet >= mass_dry) then round(((mass_wet - mass_dry) / mass_dry), 6)
           else -1 end as DL27_calc_moisture_ratio
     
     /*------------------------------------------------------------------------------
       Percent Moisture: from Mtest, Lt_DL27_BC.cpp, calcMD()
       if (mdry > 0.0 && mwet >= mdry) mpct = (((mwet - mdry) / mdry) * 100.0)
       ....or, Moisture Ratio * 100
     ------------------------------------------------------------------------------*/
     
     ,case when (mass_dry > 0 and mass_wet >= mass_dry) then round((((mass_wet - mass_dry) / mass_dry) * 100),4)
           else -1 end as DL27_calc_pct_moisture
      
     /*---------------------------------------------------------------------------
       Wash: from TMtest, Lt_DL27_BC.cpp calcWash()
       
       // do moisture adjustment if there is one                 my notes:
       if (wwet > 0.0)                                           if (mass_wet_total > 0)
       {
         if ((mwet - mdry) / mdry) >= 0.0                        if (mass_dry > 0 and mass_wet >= mass_dry) >= 0.0
              wdry = wwet  / (1.0 + ((mwet - mdry) / mdry));         mass_wet_total / (1.0 + (mass_wet - mass_dry) / mass_dry))
         else                                                    else
              wdry = wwet; // no correction                        mass_wet_total
    
       The cases below are where DL27_calc_total_dry_mass follows the logic above but Total Dry Mass is blank.
       my calculations yield values. weird
       W-98-0168-ACB, W-98-0168-ACEL, W-98-0168-ACDL, W-98-0168-ACD, W-98-0168-ACCL, W-98-0168-ACC, W-98-0168-ACA
     ---------------------------------------------------------------------------*/
  
     ,case when (mass_wet_total > 0)
           then case when (mass_dry > 0 and mass_wet >= mass_dry)
                     then (mass_wet_total / (1.0 + ((mass_wet - mass_dry) / mass_dry)))
                     else (mass_wet_total)
                     end
           else -1
           end as DL27_calc_total_dry_mass
           
     from Test_DL27
)

select  dl27.sample_id      as DL27_Sample_ID
       ,dl27.sample_year    as DL27_Sample_Year
       ,dl27.test_status
       ,dl27.tested_by
       
       ,case when to_char(dl27.dt_tested, 'yyyy') = '1959' then ' '
             else to_char(dl27.dt_tested, 'mm/dd/yyyy')
             end as dt_tested
            
       ,dl27.dt_tested as dt_tested_DATE
       ,dl27.dt_tested_orig
       
       ,dl27.customary_metric
       
       /*---------------------------------------------------------------------------
         Moisture Determination: 
         Wet mass, Dry Mass, Moisture Ratio and percent moisture
       ---------------------------------------------------------------------------*/
       
       ,case when dl27.mass_wet            >= 0 then trim(to_char(dl27.mass_wet,            '999990.99')) else ' ' end as DL27_wet_mass
       ,case when dl27.mass_dry            >= 0 then trim(to_char(dl27.mass_dry,            '999990.99')) else ' ' end as DL27_dry_mass
       ,case when DL27_calc_pct_moisture   >= 0 then trim(to_char(DL27_calc_pct_moisture,   '9990.9999')) else ' ' end as DL27_pct_moisture
       
       ,DL27_calc_pct_moisture   -- numeric value, not displayed
       ,DL27_calc_moisture_ratio -- not displayed
       
       /*---------------------------------------------------------------------------
         Wash: total_wet_mass, total_wet_mass, washed_mass
       ---------------------------------------------------------------------------*/
       
       ,case when dl27.mass_wet_total      >= 0 then trim(to_char(dl27.mass_wet_total,      '999990.99')) else ' ' end as DL27_total_wet_mass
       ,case when DL27_calc_total_dry_mass >= 0 then trim(to_char(DL27_calc_total_dry_mass, '999990.99')) else ' ' end as DL27_total_dry_mass
       ,case when dl27.mass_washed         >= 0 then trim(to_char(dl27.mass_washed,         '999990.99')) else ' ' end as DL27_washed_mass
             
       ,dl27.remarks
  
  /*---------------------------------------------------------------------------
    table relationships
  ---------------------------------------------------------------------------*/
  
  from MLT_1_WL900_Sample                  smpl
  join Test_DL27                           dl27 on dl27.sample_id = smpl.sample_id
  join DL27_sql                                 on dl27.sample_id = DL27_sql.sample_id  
 ;









-- a wee test. find samples that meet the conditions, below

select sample_id, mass_wet, mass_dry from t_dl27 
 where mass_wet > 0 and mass_dry > 0 and mass_wet <> mass_dry
 order by sample_year desc;
 
/**-----------------------------

sample_id       mass_wet  mass_dry
W-19-1116-AG	1192.2	  1140.1
W-17-1020-AC	2279      2277.4
W-17-0509-AC	2475      2448
W-16-0364-AG	263.1     244.5
W-16-1370-AC	2500      2478.7
W-16-0352-AC	2500      2492.6
W-16-0363-AG	221.4      213.8
W-03-0738-AG	2700      2698.6
W-02-0121-AC	2500      2485.6
W-98-1432-AC	1250      1235.7
W-60-1370-AC	2500      2478.7

-----------------------------**/









