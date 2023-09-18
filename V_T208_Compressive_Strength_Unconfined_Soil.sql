


select * from V_T208_Compressive_Strength_Unconfined_Soil
;



select * from test_t208;



select count(*), min(sample_year), max(sample_year) from test_t208
;
-- count    min     max
-- 11	    1987	2019



/***********************************************************************************

 T208 Comp Strength Unconfined (Soil) --- Comp (compressive)
 W-19-0042-SO (some good data)
 W-18-0201-SO, W-18-0226-SO (little data), W-14-0598-SOA, W-12-1142-SO, W-04-0366-SO
 W-97-0043-SO, W-87-0093-SO (good data, relatively), W-87-0125-SO, W-87-0133-SO
 very few samples & very little data
 
 from MTest, Lt_T208_C7.cpp, No calcs defined for this labtest

***********************************************************************************/


create or replace view V_T208_Compressive_Strength_Unconfined_Soil as

select  t208.sample_id
       ,t208.sample_year
       ,t208.test_status
       ,t208.tested_by
       
       ,case when to_char(t208.date_tested, 'yyyy') = '1959' then ' '
            else to_char(t208.date_tested, 'mm/dd/yyyy')
            end as date_tested
            
       ,t208.date_tested as date_tested_DATE
       ,t208.date_tested_orig as T208_date_tested_orig
       
       ,t208.avg_height
       ,t208.avg_diameter
       ,t208.height_diameter_ratio
       ,t208.t100_specific_gravity
       ,t208.initial_dry_density
       ,t208.initial_wet_density
       ,t208.pct_moisture_before_shear
       ,t208.pct_initial_saturation
       ,t208.pct_moisture_after_shear
       ,t208.pct_strain_at_failure
       ,t208.avg_rate_of_strain_pct_minimum
       ,t208.shear_strength
       ,t208.unconfined_compressive_strength
       ,t208.description_specimen
       
       ,t208.remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                     smpl
  join Test_T208                              t208 on t208.sample_id = smpl.sample_id 
 ;
        
  
  
  
  




