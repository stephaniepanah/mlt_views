


--  T329 Moisture Content of Hot Mix    (2021)
-- WL110 Moisture in Asphalt Mix (Oven) (2018)
--  T110 Moisture in Asphalt Mix        (2011)


select * from V_T329_Moisture_Content_of_Hot_Mix order by T329_Sample_Year desc, T329_Sample_ID
;



--------------------------------------------------------------------------------
-- some diagnostics
--------------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T329 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 769	    2010	2021



select * from Test_T329 where mass_wet_mix = mass_dry_mix; -- 31 samples



select * from Test_T329 order by sample_year desc;



/*******************************************************************************

 T329 Moisture Content of Hot Mix
 
 W-19-0525-AC, W-19-0948-AC, W-18-0569-AC, W-18-0676-AC, W-17-1856-AC

 from MTest, LT_T329_C2.cpp, void LtT329_C2::CorGrpRoot::calc()
 
 Note: this formula is (wet - dry) / dry
 This contrasts with WL110 which uses Wet in the denominator
 
 if (tare < 0.0) tare = 0.0; // blank is zero
 
 if (dry > 0.0 && wet >= dry)
 {
    double denom = dry - tare;
    
	if (denom > 0.0)
		moist = 100.0 * (wet - dry) / denom;
 } 

*******************************************************************************/


create or replace view V_T329_Moisture_Content_of_Hot_Mix as 


select  t329.sample_id                                         as T329_Sample_ID
       ,t329.sample_year                                       as T329_Sample_Year
       ,t329.test_status                                       as T329_Test_Status
       ,t329.tested_by                                         as T329_Tested_by
       
       ,case when to_char(t329.date_tested, 'yyyy') = '1959'   then ' '
             else to_char(t329.date_tested, 'mm/dd/yyyy')      end
                                                               as T329_date_tested
            
       ,t329.date_tested                                       as T329_date_tested_DATE
       ,t329.date_tested_orig                                  as T329_date_orig
       
       ,t329.mass_wet_mix                                      as T329_mass_wet_mix
       ,t329.mass_dry_mix                                      as T329_mass_dry_mix
       ,t329.mass_tare                                         as T329_mass_tare
       ,pct_moisture                                           as T329_percent_moisture
       ,t329.captured_pct_moisture                             as T329_captured_pct_moisture
       
       -- the following are used to calculate pct_moisture and are not for display
       ,mass_wet_nbr  -- mass_wet_mix - mass_tare
       ,mass_dry_nbr  -- mass_dry_mix - mass_tare
       ,mass_tare_nbr -- set to 0 if -1
       
       ,t329.remarks as T329_Remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_T329                                     t329 on t329.sample_id = smpl.sample_id
       
       /*-----------------------------------------------------------------------
         calculations
       -----------------------------------------------------------------------*/
       
       cross apply (select case when t329.mass_tare    >= 0 then t329.mass_tare                      else 0 end as mass_tare_nbr from dual) masstare
       cross apply (select case when t329.mass_wet_mix >= 0 then (t329.mass_wet_mix - mass_tare_nbr) else 0 end as mass_wet_nbr  from dual) masswet
       cross apply (select case when t329.mass_dry_mix >= 0 then (t329.mass_dry_mix - mass_tare_nbr) else 0 end as mass_dry_nbr  from dual) massdry
       
       cross apply (select case when (mass_wet_nbr >= mass_dry_nbr) and (mass_dry_nbr > 0)
                           then (((mass_wet_nbr - mass_dry_nbr) / mass_dry_nbr) * 100)
                           else 0 end as pct_moisture from dual) pctmoisture
       ;









