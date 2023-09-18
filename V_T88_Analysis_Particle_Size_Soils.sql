


/********************************************************************

AASHTO
American Association of State Highway and Transportation Officials
444 North Capitol St., NW, Suite 249 Washington, DC 20001
www.transportation.org

********************************************************************/

select * from V_T88_Analysis_Particle_Size_Soils 
 where T88_sample_id in ( 'W-20-0785-SO', 'W-19-0007-SO', 'W-21-0010-SO');



select * from V_WL643_Prep_for_Hydrometer_Analysis where WL643_sample_id = 'W-19-0007-SO';



select * from V_T88_Analysis_Particle_Size_Soils 
 order by T88_sample_year desc, T88_sample_id
 ;



----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T88 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 8920	    1984	2021




-- find T88 samples without a corresponding T100 sample
select Test_T88.sample_id from Test_T88
 where Test_T88.sample_id not in (select Test_T100.sample_id from Test_T100  
                                  where Test_T100.sample_id = Test_T88.sample_id)
;
-- 89 samples found, 15 post 2000




-- find T100 samples without a corresponding T88 sample
select Test_T100.sample_id from Test_T100 
 where Test_T100.sample_id not in (select Test_T88.sample_id from Test_T88  
                                    where Test_T88.sample_id = Test_T100.sample_id)
;
-- 180 samples found, 16 post 2000




/***********************************************************************************

 T88 Particle Size Analysis of Soils
 W-19-1460-SO, W-18-0124-SO, W-18-0187-SO, W-17-0052-SO

 CustomaryOrMetric

 [0]: M: metric (sieve sizes)  C customary (sieve sizes)
 [1]: M: metric (Centigrade)   C customary (Fahrenheit)

 W-18-0125-SO| |CM| (C) sieve units (M) Temperature, Celsius
 W-12-0116-SO| |CC| (C) sieve units (C) Temperature, Fahrenheit
 W-03-0106-SO| |MM| (M) sieve units (M) Temperature, Celsius
 
 
----------------------------------------------------------------------

From: Rowe, Don (FHWA) 
Sent: Wednesday, October 7, 2020 12:46 PM
To: Ezat-Panah, Stephanie CTR (FHWA) <s.ezat-panah.ctr@dot.gov>
Subject: RE: T88 demonstration

That is correct Stephanie…

From: Ezat-Panah, Stephanie CTR (FHWA) 
Sent: Wednesday, October 7, 2020 12:23 PM
To: Rowe, Don (FHWA) <Don.Rowe@dot.gov>
Subject: RE: T88 demonstration


Hi Don, 
I am reviewing my notes and I wanted a confirmation.
The soil in the -10 pan is split into two even portions.
1/2 is used in the moisture determination test, and that mass is entered into the mass of wet soil field
and
1/2 is used in the mass of soil in the jar, which in turned it used for the hydrometer readings

Thank you,
-s

                    
***********************************************************************************/


create or replace view V_T88_Analysis_Particle_Size_Soils      as 

with WL643_SQL as (select  WL643_sample_id
                          ,WL640_Mass_sum_coarse
                          ,WL640_mass_of_fines
                          ,WL643_adjusted_nbr10
                     from V_WL643_Prep_for_Hydrometer_Analysis
                    where WL640_segment_nbr = 1
)

select  t88.sample_id                                          as T88_sample_id
       ,t88.sample_year                                        as T88_sample_year
       ,t88.test_status                                        as T88_test_status
       ,t88.tested_by                                          as T88_tested_by
       
       ,case when to_char(t88.date_tested, 'yyyy') = '1959'    then ' '
             else to_char(t88.date_tested, 'mm/dd/yyyy')       end
                                                               as T88_date_tested
            
       ,t88.date_tested                                        as T88_date_tested_DATE
       ,t88.date_tested_orig                                   as T88_date_orig
       
       ,t88.customary_metric                                   as T88_customary_metric
       
       /*---------------------------------------------------------------------------------
         Specific Gravity from T100
       ---------------------------------------------------------------------------------*/
              
       ,t88.Specific_Gravity_Source                            as T88_Specific_Gravity_Source
       
       ,case when V_T100.T100_Apparent_Specific_Gravity        is not null 
             then V_T100.T100_Apparent_Specific_Gravity        else -1 end 
                                                               as T100_Apparent_Specific_Gravity
       
       /*---------------------------------------------------------------------------------
         T88 moisture determination
       ---------------------------------------------------------------------------------*/
       
       ,t88.mass_wet_soil                                      as T88_mass_wet_soil
       ,t88.mass_dry_soil                                      as T88_mass_dry_soil
       ,pct_moisture                                           as T88_percent_moisture
              
       /*---------------------------------------------------------------------------------
         T88 hydrometer preparation
       ---------------------------------------------------------------------------------*/
       
       ,A_Factor                                               as T88_A_Factor
       ,t88.mass_soil_in_jar                                   as T88_mass_soil_in_jar       
       ,mass_dry_soil_DS                                       as T88_mass_of_dry_soil_DS
       
       ,t88.remarks                                            as T88_Remarks
       
       /*---------------------------------------------------------------------------------
         not for display, used in calculations
       ---------------------------------------------------------------------------------*/
       
       ,moisture_ratio                                         as T88_moisture_ratio
       ,adjusted_fine_wt                                       as T88_adjusted_fine_wt
       ,adjusted_total_sample_wt                               as T88_adjusted_total_sample_wt
       ,pct_pass_factor                                        as T88_percent_pass_factor
       ,pct_pass_nbr4                                          as T88_percent_pass_Nbr4
       ,pct_pass_nbr10                                         as T88_percent_pass_Nbr10
       ,fines_factor                                           as T88_fines_factor
       ,pfactor                                                as T88_pfactor_for_recast
       
       ,WL640_Mass_sum_coarse
       ,WL640_mass_of_fines
       ,WL643_adjusted_nbr10
       
       /*---------------------------------------------------------------------------------
         the following are not used, at all
       ---------------------------------------------------------------------------------*/
       
       ,t88.Specific_Gravity_Source_original  -- for any clarification
       ,t88.specific_gravity_captured         -- as seen on the T88 screen
       ,t88.specific_gravity_from_T100        as SG_from_T100 
       
       /*---------------------------------------------------------------------------------
         table relationships
       ---------------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_T88                                       t88 on t88.sample_id = smpl.sample_id
       left join V_T100_Specific_Gravity_of_Soils       V_T100 on t88.sample_id = V_T100.T100_Sample_ID
       left join WL643_SQL                                     on t88.sample_id = WL643_SQL.WL643_sample_id
       
       /*---------------------------------------------------------------------------------
         moisture determination, from MTest, Lt_T88b_BC.cpp, calcMD()
         moisture ratio = (dry / wet) --- this is not percent moisture
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (t88.mass_dry_soil > 0 and t88.mass_wet_soil > 0) 
                                then (t88.mass_dry_soil / t88.mass_wet_soil)
                                else -1 end as moisture_ratio from dual) moistureratio
                                 
       /*---------------------------------------------------------------------------------
         moisture determination, from MTest, Lt_T88b_BC.cpp, calcMD()
         if (wet > 0 and dry > 0 and moisture ratio > 0)
             pct moisture = ((wet - dry) / wet) * 100
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (t88.mass_dry_soil > 0 and t88.mass_wet_soil > 0 and moisture_ratio > 0)
                                then (((t88.mass_wet_soil - t88.mass_dry_soil) / t88.mass_wet_soil) * 100)
                                else -1 end as pct_moisture from dual) pctmoisture
                                 
       /*---------------------------------------------------------------------------------
         A-Factor, from MTest, Lt_T88b_BC.cpp, calcAF()
         if SG > 0
         then (((2.65 - 1)/2.65) * SG) /(SG - 1) == ((0.622642 * SG) /(SG - 1))
         0.622642 is the specific gravity of water <-- correct this
         ....I thought that the specific gravity of water was 1.0 -ish (at 20C)
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (V_T100.T100_Apparent_Specific_Gravity is not null and 
                                      V_T100.T100_Apparent_Specific_Gravity  > 0        and
                                      V_T100.T100_Apparent_Specific_Gravity <> 1) -- may need to check this
                                then ((0.622642 * V_T100.T100_Apparent_Specific_Gravity) / (V_T100.T100_Apparent_Specific_Gravity - 1))
                                else -1 end as A_Factor from dual) afactor
  
       /*---------------------------------------------------------------------------------
         Mass of Dry Soil (DS), from MTest, Lt_T88b_BC.cpp, calcDS()
         if (mass_soil_in_jar > 0 and moisture_ratio >= 0)
             mass_DS = mass_soil_in_jar * moisture_ratio
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (t88.mass_soil_in_jar > 0 and moisture_ratio >= 0) 
                                then (t88.mass_soil_in_jar * moisture_ratio) 
                                else -1 end as mass_dry_soil_DS from dual) DS
                                 
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T88ut_BC.cpp, HydroCalcs::doCalcsPrelim
         adjust fine weight to total sample size
         adjfwt: Applies moisture correction to #10- portion of cpan
         adjfwt = _moisture * (_cpan - adjten);
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (WL643_SQL.wl640_mass_of_fines is not null and WL643_SQL.WL643_adjusted_nbr10 is not null) 
                                then (moisture_ratio * (WL643_SQL.wl640_mass_of_fines - WL643_SQL.WL643_adjusted_nbr10))
                                else -1 end as adjusted_fine_wt from dual) adjfwt
  
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T88ut_BC.cpp, HydroCalcs::doCalcsPrelim
       
         adjusted total sample weight = 
           sum of coarse weights (coarse values must be >= #4)
         + adjusted weight #10   (adjusted: recast from thw, total hydrometer weight)
         + weight passing #10 adjusted (for moisture and recast from thw - #10+)
       
         ...and of course, there just has to be one sample with three coarse sieve sizes < #4
         ...for now, disregard and include them
       
         Sample ID       sieve   mass retained
         W-12-1295-AG    #10     26281.3
         W-12-1295-AG    #40     24267.5
         W-12-1295-AG    #200	 7521
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (WL643_SQL.WL640_Mass_sum_coarse is not null and WL643_SQL.WL640_Mass_sum_coarse > 0 and 
                                      WL643_SQL.WL643_adjusted_nbr10  is not null and WL643_SQL.WL643_adjusted_nbr10  > 0 and 
                                      WL643_SQL.WL640_Mass_sum_coarse + WL643_SQL.WL643_adjusted_nbr10 + adjusted_fine_wt > 0)
                      
                                then (WL643_SQL.WL640_Mass_sum_coarse + WL643_SQL.WL643_adjusted_nbr10 + adjusted_fine_wt)
                                else -1 end as adjusted_total_sample_wt from dual) adjwt  
  
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T88ut_BC.cpp, HydroCalcs::doCalcsPrelim
       
         percents passing down through #4. assumes that coarse stops above #10
         factor = 100.0 / factor;
         
         in this case; pct_pass_factor = (100 / adjusted_total_sample_wt)
         t88_calc_factor is multiplied by the mass retained to obtain pct passing
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (adjusted_total_sample_wt > 0) then (100 / adjusted_total_sample_wt)
                                else -1 end as pct_pass_factor from dual) pctpassfactor
  
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T88ut_BC.cpp, HydroCalcs::doCalcsPrelim
         
         to calculate pct passing #4, simply use total coarse mass, so...
         pp#4 = (100 - (sum coarse mass * factor))
         
         percent passing #10 (from #10+ of Total hydrometer sample, recast)
         _tblPp[xten].pp = tmp - (adjten * factor);
         pp#10 = (pp#4 - (t88_calc_adjusted_nbr10 * t88_calc_factor))
         
         including the ffactor, factor for fines (hydrometer does not use this)
         ffactor = factor * adjfwt / _ds;
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (WL643_SQL.WL640_Mass_sum_coarse is not null and WL643_SQL.WL640_Mass_sum_coarse > 0)
                                then (100 - (WL643_SQL.WL640_Mass_sum_coarse * pct_pass_factor)) 
                                else -1 end as pct_pass_nbr4 from dual) pctpassNbr4
                        
       
       cross apply (select case when (WL643_SQL.WL643_adjusted_nbr10 is not null and WL643_SQL.WL643_adjusted_nbr10 > 0)
                                then (pct_pass_nbr4 - (WL643_SQL.WL643_adjusted_nbr10 * pct_pass_factor)) 
                                else -1 end as pct_pass_nbr10 from dual) pctpassNbr10
       
       
       cross apply (select case when (pct_pass_factor > 0 and adjusted_fine_wt > 0 and mass_dry_soil_DS > 0)
                                then (pct_pass_factor * adjusted_fine_wt / mass_dry_soil_DS) 
                                else -1 end as fines_factor from dual) ffactor
  
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T88ut_BC.cpp, HydroCalcs::run()
         double pfactor = _tblPp[xten].pp / _ds;
         doCalcsHydroTbl(pfactor, eh); used to calculate recast
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (pct_pass_nbr10 > 0 and mass_dry_soil_DS > 0)
                                then (pct_pass_nbr10 / mass_dry_soil_DS)
                                else -1 end as pfactor from dual) p_factor
       ;









