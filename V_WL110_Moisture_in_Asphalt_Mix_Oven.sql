


--  T329 Moisture Content of Hot Mix    (2020)
-- WL110 Moisture in Asphalt Mix (Oven) (2018)
--  T110 Moisture in Asphalt Mix        (2011)


select * from V_WL110_Moisture_in_Asphalt_Mix_Oven order by WL110_Sample_Year desc, WL110_Sample_ID
;



----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_WL110 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 1221	    1999	2018



select * from Test_WL110;



select count(*) from Test_WL110 where mass_wet_mix <= 0;            -- 6
select count(*) from Test_WL110 where mass_dry_mix <= 0;            -- 6 (same six)
select count(*) from Test_WL110 where mass_wet_mix >= mass_dry_mix; -- 1221 (perfect)
select count(*) from Test_WL110 where mass_wet_mix  = mass_dry_mix; -- 7
select count(*) from Test_WL110 where mass_wet_mix  < mass_dry_mix; -- 0 (good, this should never be)



/***********************************************************************************

 WL110 Moisture in Asphalt Mix (Oven)
 
 W-18-0676-AC, W-18-0677-AC, W-16-0439-AC, W-16-1150-AC

 from MTest, Lt_WL110.cpp

 void LtWL110_C2::CorGrpRoot::calc()
 {
	// (wet - dry) / wet
    
	double tare, wet, dry, moist;

	if (tare < 0.0) tare = 0.0; // blank is zero

	if (dry > 0.0 && wet >= dry)
	{
		double denom = wet - tare;

		if (denom > 0.0)
			moist = 100.0 * (wet - dry) / denom;
	}
 }

***********************************************************************************/


create or replace view V_WL110_Moisture_in_Asphalt_Mix_Oven as 


select  wl110.sample_id                                        as WL110_Sample_ID
       ,wl110.sample_year                                      as WL110_Sample_Year
       ,wl110.test_status                                      as WL110_Test_Status
       ,wl110.tested_by                                        as WL110_Tested_By
       
       ,case when to_char(wl110.date_tested, 'yyyy') = '1959'  then ' '
             else to_char(wl110.date_tested, 'mm/dd/yyyy')     end
                                                               as WL110_date_tested
            
       ,wl110.date_tested                                      as WL110_date_tested_DATE
       ,wl110.date_tested_orig                                 as WL110_date_orig
       
       ,wl110.mass_wet_mix                                     as WL110_mass_wet_mix
       ,wl110.mass_dry_mix                                     as WL110_mass_dry_mix
       ,wl110.mass_tare                                        as WL110_mass_tare
       
       ,pct_moisture                                           as WL110_percent_moisture      -- calculated
       ,wl110.captured_pct_moisture                            as WL110_captured_pct_moisture -- for comparison
       
       ,wl110.remarks                                          as WL110_Remarks
       
       /*---------------------------------------------------------------------------
         table relationships
       ---------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_WL110                                   wl110 on wl110.sample_id = smpl.sample_id
       
       /*---------------------------------------------------------------------------
         calculations - percent moisture
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when wl110.mass_tare    >= 0 then wl110.mass_tare                      else 0 end as mass_tare_nbr from dual) masstare
       cross apply (select case when wl110.mass_wet_mix >= 0 then (wl110.mass_wet_mix - mass_tare_nbr) else 0 end as mass_wet_nbr  from dual) masswet
       cross apply (select case when wl110.mass_dry_mix >= 0 then (wl110.mass_dry_mix - mass_tare_nbr) else 0 end as mass_dry_nbr  from dual) massdry
       
       cross apply (select case when (mass_wet_nbr >= mass_dry_nbr) and (mass_wet_nbr > 0)
                           then (((mass_wet_nbr - mass_dry_nbr) / mass_wet_nbr) * 100)
                           else 0 end as pct_moisture  from dual) pctmoisture
      ;









