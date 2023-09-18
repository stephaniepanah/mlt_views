


--  T308 Asphalt Content (Ignition) (2020) (formerly WL464)
-- WL164 Asphalt Content (Vacuum)   (2006)
-- CL164 Asphalt Content (Reflux)   (1966)



select * from V_WL164_Asphalt_Content_Vacuum order by WL164_Sample_Year desc, WL164_Sample_ID
;



----------------------------------------------------------------------------
-- this SQL may need work. the values in my calculations do not square 
-- with the captured 'temp' numbers. for now, I have both
-- I am using the calculations drawn from the code
-- I have no idea how those errant temp numbers came about. I tried
----------------------------------------------------------------------------


----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_WL164 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 1617     1986    2006



select * from Test_WL164 order by sample_year desc, sample_id;



   select sample_year, count(sample_year) from Test_WL164
 group by sample_year
 order by sample_year desc
 ;
/* 
2006	  2     W-06-0698-ACA, W-06-0699-ACA
2000	  5     W-00-0024-AC,  W-00-0025-AC, W-00-0026-AC, W-00-0027-AC, W-00-0028-AC

1999	 36
1998	111
1997	 83
1996	 95
1995	141
1994	165
1993	 55
1992	 73
1991	123
1990	157
1989	134
1988	208
1987	 94
1986	135
*/



   select moisture_source, count(moisture_source) from Test_WL164
 group by moisture_source
 order by moisture_source;
 
-- Manual	295
--   T110	1321
--  WL110	1       W-99-0317-AC
--   T329   0



select * from Test_WL164 where moisture_source = 'T110' order by sample_year desc;
-- W-06-0699-ACA, W-06-0698-ACA <-- the only two T110 samples with percent moisture displayed on front page
-- W-97-0162-AC  <--  one in 1997
-- W-96-0641-AC  <-- many in 1996



select * from Test_WL164 where moisture_source = 'Manual' order by sample_year desc, sample_id;
-- 295 Manual samples, most recently in 2000, five samples
-- W-00-0024-AC, W-00-0025-AC, W-00-0026-AC, W-00-0027-AC, W-00-0028-AC
-- no source data the the five samples above
-- all Manual samples have -1 (null) for percent moisture



 -- deleting captured_pct_moisture, no value IMO
   select captured_pct_moisture, count(captured_pct_moisture) from test_wl164
 group by captured_pct_moisture
 order by captured_pct_moisture;
/*
-1	    1615
0.06	1
0.1	    1
*/



/***********************************************************************************

 WL164 Asphalt Content (Vacuum)
 
 W-06-0698-ACA, W-06-0699-ACA, W-00-0024-AC, W-99-0284-AC, W-93-0539-AC 
 
 from MTest, Lt_WL164_C2.cpp, calc(unsigned id)
 ==============================================
 
 EXTRACTION CALCULATIONS 
 Emulsion calculations result in a Residual AC value
 Standard calculations result in a % AC/AG value

 If there is no data in T110 (001) to calculate pct moisture, 
 assume pct moisture = 0 (ie, moisture is not a factor, sample is dry)

 If there is no retention factor, assume retention factor = 0

 CALCULATIONS FOR BOTH STANDARD & EMULSION
 -----------------------------------------

 if Wt wet mix and water are present
      %Moist = water/Wt wet mix
 else %Moist = 0
 
 If Retention Factor is not present, Retention Factor = 0

 ------------------------------------------
 corrected sample mass, xWtSmplCor
 Corr wt = Wt Sample wet - Wt sample wet * %Moist
 ------------------------------------------

 --mtest calculation
 
 if (wtwet >= 0.0)
     if (moco < 0.0) moco = 0.0; // assume moisture content is 0% if not specified
         wtcor = wtwet - wtwet * moco / 100.0;

 --my calculation
 corrected_sample_mass_calc = (mass_sample_wet - (mass_sample_wet * pct moisture * 0.01))

 ------------------------------------------
 mass of fines in filter, xFilteredFines
 ------------------------------------------

 --mtest calculation
 
 if (filtered >= 0.0) // mass_assembly_after_extraction
     if (tare < 0.0) tare = 0.0;
         fines = filtered - tare;

 --my calculation
 mass_of_fines_in_filter_calc = (mass_assembly_after_extraction - mass_tare)

 ------------------------------------------
 mass of extracted aggregate, xExtAgg
 Ext AG = Filter After + AG After - Tare
 Ext AC = Corr wt - Ext AG
 ------------------------------------------

 --mtest calculation from comments
 Ext AG = Filter After + AG After - Tare

 --mtest calculation from code

 if (aggpost >= 0.0)    // mass_aggregate_after_extraction
     if (fines >= 0.0)  // mass_assembly_after_extraction - mass_tare
         extagg = aggpost - fines;

 --my calculation 
 mass_of_extracted_aggregate_calc = (mass_aggregate_after_extraction - mass_of_fines_in_filter_calc)

 ------------------------------------------
 mass of extracted bitumen, xExtBitumen
 ------------------------------------------

 --mtest calculation 

 if (extagg >= 0.0 && wtcor >= extagg)
     extbit = wtcor - extagg;

 --my calculation 
 mass_of_extracted_bitumen_calc = (corrected_sample_mass_calc - mass_of_extracted_aggregate_calc)

 ------------------------------------------
 percent asphalt by agg, xArAgg
 percent asphalt by mix, xArMix
 residual asphalt by mass agg, xResidual
 ------------------------------------------
 
 if (extbit >= 0.0)                          // mass_of_extracted_bitumen_calc
 {
    if (extagg >= 0.0)                       // mass_of_extracted_aggregate_calc (should be > 0, not >= 0)
    {
       if (retent < 0.0) retent = 0.0;       // retention factor
           
       ara = retent + 100.0*extbit / extagg; // percent asphalt by agg, xArAgg
	   arm = 100.0*ara / (100.0 + ara);      // percent asphalt by mix, xArMix
       
       if (wantResid)
       {
          resid = ara;                       // residual asphalt by mass agg, xResidual
          ara = FLT_BLANK;
       }
    }
 }

 STANDARD ONLY
 -------------

 %AC/Mix = 100 * %AC/AG / (%AC/AG + 100)            -- pct asphalt by mix
 %AC/AG  = 100 * Ext AC / Ext AG + Retention Factor -- pct asphalt by agg
 
 EMULSION ONLY
 -------------

 Residual AC = Retention FActor + 100 * Ext AC / Ext AG

***********************************************************************************/


create or replace view V_WL164_Asphalt_Content_Vacuum as 

select  wl164.sample_id                            as WL164_Sample_ID
       ,wl164.sample_year                          as WL164_Sample_Year
       ,wl164.test_status                          as WL164_Test_Status
       ,wl164.tested_by                            as WL164_Tested_by
       
       ,case when to_char(wl164.date_tested, 'yyyy') = '1959' then ' '
             else to_char(wl164.date_tested, 'mm/dd/yyyy')    end
                                                   as WL164_date_tested
            
       ,wl164.date_tested                            as WL164_date_tested_DATE
       ,wl164.date_tested_orig                       as WL164_date_tested_orig
       
       ,wl164.moisture_source                      as WL164_moisture_source -- T110, WL110, T329, Manual
       ,percent_moisture                           as WL164_percent_moisture
       
       -------------------------------------------------------------------------------------
       --,wl164.captured_pct_moisture                as WL164_captured_pct_moisture
       -- captured_pct_moisture is user entered. this field was dropped as there were only
       -- two entries and they correlated with the imported values (WL164_percent_moisture)
       -------------------------------------------------------------------------------------
       
       ,wl164.mass_sample_wet                      as WL164_mass_sample_wet
       ,wl164.mass_assembly_after_extraction       as WL164_mass_assembly_after_extraction
       ,wl164.mass_aggregate_after_extraction      as WL164_mass_aggregate_after_extraction
       ,wl164.mass_tare                            as WL164_mass_tare -- if null, then 0, not -1
       ,wl164.retention_factor                     as WL164_retention_factor
       
       ,case when corrected_sample_mass_calc >= 0 then trim(to_char(corrected_sample_mass_calc, '999990.99'))
             else ' ' end                          as WL164_corrected_sample_mass
       ,wl164.temp_mass_corrected                  as temp_mass_corrected -- raw value from data
       
       ,mass_of_fines_in_filter_calc               as WL164_mass_of_fines_in_filter_nbr
       ,case when mass_of_fines_in_filter_calc >= 0 then trim(to_char(mass_of_fines_in_filter_calc, '999990.99'))
             else ' ' end                          as WL164_mass_of_fines_in_filter
       ,wl164.temp_mass_fines                      as temp_mass_fines     -- raw value from data
       
       ,mass_of_extracted_aggregate_calc           as WL164_mass_of_extracted_aggregate_nbr
       ,case when mass_of_extracted_aggregate_calc >= 0 then trim(to_char(mass_of_extracted_aggregate_calc, '999990.99'))
             else ' ' end                          as WL164_mass_of_extracted_aggregate
       ,wl164.temp_mass_agg                        as temp_mass_extagg    -- raw value from data
       
       ,case when mass_of_extracted_bitumen_calc >= 0 then trim(to_char(mass_of_extracted_bitumen_calc, '999990.99'))
             else ' ' end                          as WL164_mass_of_extracted_bitumen
       ,wl164.temp_mass_bitumen                    as temp_mass_extbit    -- raw value from data
       
       ,percent_asphalt_by_mix_calc                as WL164_percent_asphalt_by_mix
       ,wl164.temp_pct_mix                         as temp_pct_mix        -- raw value from data
       
       ,percent_asphalt_by_agg_calc                as WL164_percent_asphalt_by_agg
       ,wl164.temp_pct_agg                         as temp_pct_agg        -- raw value from data
       
       ,residual_asphalt_by_mass_agg               as WL164_residual_asphalt_by_mass_aggregate
       ,wl164.temp_residual                        as temp_residual       -- raw value from data
              
       ,wl164.pct_asphalt_mixture_minimum_spec             as WL164_pct_asphalt_mix_min_spec -- never assigned to
       ,wl164.pct_asphalt_mixture_maximum_spec             as WL164_pct_asphalt_mix_max_spec -- never assigned to
       
       ,wl164.pct_asphalt_aggregate_minimum_spec             as WL164_pct_asphalt_agg_min_spec -- never assigned to
       ,wl164.pct_asphalt_aggregate_maximum_spec             as WL164_pct_asphalt_agg_max_spec -- never assigned to
       
       ,wl164.residual_asphalt_wanted              as WL164_residual_asphalt_wanted  -- checkbox, never assigned to
       
       ,wl164.remarks                              as WL164_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                            smpl
  join Test_WL164                                   wl164 on wl164.sample_id = smpl.sample_id
  
  -- W-06-0699-ACA, W-06-0698-ACA - most recent samples
  -- W-97-0162-AC,  W-96-0641-AC  - next most recent samples
  left join V_T110_Moisture_in_Asphalt_Mix         v_t110 on wl164.sample_id = v_t110.T110_Sample_ID
  
   -- W-99-0317-AC
  left join V_WL110_Moisture_in_Asphalt_Mix_Oven  v_wl110 on wl164.sample_id = v_wl110.WL110_Sample_ID
  
  -- available, but no occurrences
  left join V_T329_Moisture_Content_of_Hot_Mix     v_t329 on wl164.sample_id = v_t329.T329_Sample_ID
  
  /*-------------------------------------------------------------
    calculations
  -------------------------------------------------------------*/
  
  cross apply (select case when wl164.moisture_source = 'T329' 
                           then case when v_t329.T329_percent_moisture is not null 
                                     then v_t329.T329_percent_moisture
                                     else 0
                                     end
             
                           when wl164.moisture_source = 'WL110' 
                           then case when v_wl110.WL110_percent_moisture is not null
                                     then v_wl110.WL110_percent_moisture
                                     else 0
                                     end
                       
                           when wl164.moisture_source = 'T110' 
                           then case when v_t110.T110_pct_moisture is not null 
                                     then v_t110.T110_pct_moisture
                                     else 0
                                     end
             
                           when wl164.moisture_source = 'Manual' then 0
                           
                           else 0 end as percent_moisture from dual) moco -- moisture content

  /*-----------------------------------------------------
    corrected_sample_mass
    wtcor = wtwet - wtwet*moco / 100.0;
  -----------------------------------------------------*/
  
  cross apply (select case when percent_moisture >= 0 and wl164.mass_sample_wet >= 0
                           then wl164.mass_sample_wet - (wl164.mass_sample_wet * percent_moisture * 0.01)
                           else -1
                           end as corrected_sample_mass_calc from dual) wtcor

  /*-----------------------------------------------------
    mass_of_fines_in_filter
    fines = filtered - tare;
  -----------------------------------------------------*/
  
  cross apply (select case when wl164.mass_assembly_after_extraction >= 0
                           then wl164.mass_assembly_after_extraction - wl164.mass_tare
                           else 0
                           end as mass_of_fines_in_filter_calc from dual) fines

  /*-----------------------------------------------------
    mass_of_extracted_aggregate
    extagg = aggpost - fines;
  -----------------------------------------------------*/
  
  cross apply (select case when wl164.mass_aggregate_after_extraction >= 0 and mass_of_fines_in_filter_calc >= 0
                           then wl164.mass_aggregate_after_extraction - mass_of_fines_in_filter_calc
                           else 0
                           end as mass_of_extracted_aggregate_calc from dual) extagg

  /*-----------------------------------------------------
    mass_of_extracted_bitumen
    extbit = wtcor - extagg;
  -----------------------------------------------------*/
  
  cross apply (select case when corrected_sample_mass_calc >= mass_of_extracted_aggregate_calc and 
                                mass_of_extracted_aggregate_calc >= 0
                           then corrected_sample_mass_calc - mass_of_extracted_aggregate_calc
                           else 0
                           end as mass_of_extracted_bitumen_calc from dual) extbit
                           
  /*-----------------------------------------------------
    percent asphalt by agg, xArAgg
    percent asphalt by mix, xArMix
    residual asphalt by mass agg, xResidual
  -----------------------------------------------------*/
  
  cross apply (select case when mass_of_extracted_bitumen_calc   >  0 and 
                                mass_of_extracted_aggregate_calc >  0 and 
                                wl164.retention_factor           >= 0
                           then round((((mass_of_extracted_bitumen_calc / mass_of_extracted_aggregate_calc) * 100.0) + wl164.retention_factor),4)
                           else 0 
                           end as percent_asphalt_by_agg_calc from dual) xArAgg -- aka ara
  
  cross apply (select case when percent_asphalt_by_agg_calc > 0  
                           then round((percent_asphalt_by_agg_calc * 100.0) / (percent_asphalt_by_agg_calc + 100.0),4)
                           else 0 
                           end as percent_asphalt_by_mix_calc from dual) xArMix -- aka arm
  
  cross apply (select case when percent_asphalt_by_agg_calc > 0 
                           then percent_asphalt_by_agg_calc
                           else 0
                           end as residual_asphalt_by_mass_agg from dual) xResidual -- aka resid
 ;


  






