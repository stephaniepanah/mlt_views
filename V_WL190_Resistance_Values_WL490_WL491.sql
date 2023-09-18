


select * from V_WL190_Resistance_Values 
 order by WL190_Sample_Year desc, WL190_Sample_ID
 ;



--------------------------------------------------------------------------------
-- some diagnostics
--------------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_WL190 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 4031	    1980	2021




select sample_year, count(sample_year) from Test_WL190 
--having count(*) > 100
 group by sample_year
 order by sample_year desc
 ;
 


/***********************************************************************************

 WL190 R-Value with Structural Design (WFLHD)
 W-18-0076-SO, W-18-0627-SO, W-17-0317-SO, W-17-1192-SO

 WL490 R-Value with Structural Design (Revised)   
 4 samples: W-92-1024-SO, W-89-0426-AG, W-66-9001-GEO, W-66-9011-GEO - no segments

 WL491 R-Value with Structural Design (Additives)
 3 samples: W-87-0449-SO, W-66-9001-GEO, W-66-9011-GEO - no segments
  
 from MTest
 Lt_BWL190_B6.cpp 
 Lt_BWL190_B6.h
 Lt_BWL190_ca_B6.cpp
 Lt_BWL190_da_B6.cpp
 Lt_BWL190_pl_B6.cpp
 Lt_BWL190_pm_B6.cpp
 
 -----------------
 CustomaryOrMetric
 -----------------
                           Metric       Customary
 [0] Reporting Units       (M) kPa       (C) psi
 [1] Initial, Final Height (M) mm        (C) inches
 [2] Compactor             (M) kPa       (C) psi
 [3] Exudation Pressure    (M) kPa       (C) lbs
 [4] Stabilometer Ph, Pv   (M) kPa, N    (C) lbs
 [5] Expansion             (M) mm        (C) inches
 [6] Gravel Equivalent     (M) mm        (C) inches

  select distinct(Customary_Metric), count(Customary_Metric)
    from Test_WL190
   group by Customary_Metric
   order by count(Customary_Metric) desc;

  CCCCCCC	    3793    W-18-2336-SO
  ' ' 	         164    W-20-0774-SO, W-19-1870-SO, W-18-0628-SO -- I suspect that Customary_Metric is not really important/used
  CCCCCC5000	  57    W-07-0001-SO -invalid units string (units key T190) CCCCCC (position 6) actually, index 6
  CCCCCC5	      19    W-02-0186-SO -invalid units string (units key T190) CCCCCC (position 6) index 6
  MCCCC50	       2    W-03-0010-AG, W-02-0431-SO -invalid units string (units key T190) MCCCC (position 5) index 5
  CMCMCCC	       1    W-00-0031-SO
  MCCCCCC	       1    W-00-0589-SO


 ------------------------------------------------
 R values - R-value (insulation) - From Wikipedia
 ------------------------------------------------

 In the context of building and construction, the R-value is a measure of how well a two-dimensional barrier, 
 such as a layer of insulation, a window or a complete wall or ceiling, resists the conductive flow of heat
 
 R-value is the temperature difference per unit of heat flux needed to sustain one unit of heat flux between 
 the warmer surface and colder surface of a barrier under steady-state conditions
 
 The R-value is the building industry term for thermal resistance "per unit area"
 It is sometimes denoted RSI-value if the SI (metric) units are used. 
 An R-value can be given for a material (polyethylene foam), or for an assembly of materials (a wall or a window)
 
 In the case of materials, it is often expressed in terms of R-value per unit length (eg per inch or metre of thickness)
 R-values are additive for layers of materials, and the higher the R-value the better the performance


***********************************************************************************/



create or replace view V_WL190_Resistance_Values as 

--------------------------------------------------------------------------------
-- main SQL
--------------------------------------------------------------------------------

select  wl190.sample_id                                        as WL190_Sample_ID
       ,wl190.sample_year                                      as WL190_Sample_Year
       ,wl190.test_status                                      as WL190_Test_Status
       ,wl190.tested_by                                        as WL190_Tested_by
       
       ,case when to_char(wl190.date_tested, 'yyyy') = '1959'  then ' '
             else to_char(wl190.date_tested, 'mm/dd/yyyy') end as WL190_date_tested
       
       ,wl190.date_tested                                      as WL190_date_tested_DATE
       ,wl190.date_tested_orig                                 as WL190_date_orig
       
       ,wl190.customary_metric                                 as WL190_customary_metric
       
       ,wl190.bar_calibration_factor                           as WL190_bar_calibration_factor
       ,wl190.target_exudation_pressure                        as WL190_target_exudation_pressure
       
       ,wl190.Resistance_value_at_equilibrium                  as WL190_R_value_at_equilibrium
       ,wl190.Resistance_value_by_exudation                    as WL190_R_value_by_exudation
       ,wl190.Resistance_value_by_expansion                    as WL190_R_value_by_expansion
       ,wl190.Resistance_value_density                         as WL190_R_value_density
       ,wl190.Resistance_value_pct_moisture                    as WL190_R_value_pct_moisture
       
       ,wl190.remarks                                          as WL190_Remarks
       
       /*--------------------------------------------------------------------------------
         table relationships
       --------------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_WL190                                   wl190 on wl190.sample_id = smpl.sample_id
;









/***********************************************************************************
* WL490 R-Value with Structural Design (Revised)
* 4 samples: W-92-1024-SO, W-89-0426-AG, W-66-9001-GEO, W-66-9011-GEO
* contains no wl190segments or structural design
***********************************************************************************/


select * from Test_WL490;



select * from V_WL490_R_Values_Structural_Design_Revised;



create or replace view V_WL490_R_Values_Structural_Design_Revised as 

select  wl490.sample_id                                        as WL490_Sample_ID
       ,wl490.sample_year                                      as WL490_Sample_Year
       ,wl490.test_status                                      as WL490_Test_Status
       ,wl490.tested_by                                        as WL490_Tested_by
       
       ,case when to_char(wl490.date_tested, 'yyyy') = '1959' then ' '
             else to_char(wl490.date_tested, 'mm/dd/yyyy') end as WL490_date_tested
       
       ,wl490.date_tested                                      as WL490_date_tested_DATE
       ,wl490.date_tested_orig                                 as WL490_date_orig
       
       ,wl490.customary_metric                                 as WL490_customary_metric
       
       ,wl490.bar_calibration_factor                           as WL490_bar_calibration_factor
       ,wl490.target_exudation_pressure                        as WL490_target_exudation_pressure
       
       ,wl490.Resistance_value_at_equilibrium                  as WL490_R_value_at_equilibrium
       ,wl490.Resistance_value_by_exudation                    as WL490_R_value_by_exudation
       ,wl490.Resistance_value_by_expansion                    as WL490_R_value_by_expansion
       ,wl490.Resistance_value_density                         as WL490_R_value_density
       ,wl490.Resistance_value_pct_moisture                    as WL490_R_value_pct_moisture
       
       ,wl490.remarks                                          as WL490_Remarks
       
       /*--------------------------------------------------------------------------------
         table relationships
       --------------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_WL490                                   wl490 on wl490.sample_id = smpl.sample_id
;









/***********************************************************************************
* WL491 R-Value with Structural Design (Additives)
* 3 samples: W-87-0449-SO, W-66-9001-GEO, W-66-9011-GEO
* contains no wl190segments or structural design
***********************************************************************************/


select * from Test_WL491;



select * from V_WL491_R_Values_Structural_Design_Additives;



create or replace view V_WL491_R_Values_Structural_Design_Additives as 

select  wl491.sample_id                                        as WL491_Sample_ID
       ,wl491.sample_year                                      as WL491_Sample_Year
       ,wl491.test_status                                      as WL491_Test_Status
       ,wl491.tested_by                                        as WL491_Tested_by
       
       ,case when to_char(wl491.date_tested, 'yyyy') = '1959' then ' '
             else to_char(wl491.date_tested, 'mm/dd/yyyy') end as WL491_date_tested
       
       ,wl491.date_tested                                      as WL491_date_tested_DATE
       ,wl491.date_tested_orig                                 as WL491_date_orig
       
       ,wl491.customary_metric                                 as WL491_customary_metric
       
       ,wl491.bar_calibration_factor                           as WL491_bar_calibration_factor
       ,wl491.target_exudation_pressure                        as WL491_target_exudation_pressure
       
       ,wl491.Resistance_value_at_equilibrium                  as WL491_R_value_at_equilibrium
       ,wl491.Resistance_value_by_exudation                    as WL491_R_value_by_exudation
       ,wl491.Resistance_value_by_expansion                    as WL491_R_value_by_expansion
       ,wl491.Resistance_value_density                         as WL491_R_value_density
       ,wl491.Resistance_value_pct_moisture                    as WL491_R_value_pct_moisture
       
       ,wl491.remarks                                          as WL491_Remarks
       
       /*--------------------------------------------------------------------------------
         table relationships
       --------------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_WL491                                   wl491 on wl491.sample_id = smpl.sample_id
;









