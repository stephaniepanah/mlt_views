


select * from V_T228_Specific_Gravity_of_Semi_Solid_Bituminous_Materials
;



select * from V_T228_Specific_Gravity_of_Semi_Solid_Bituminous_Materials
 order by T228_Sample_Year desc, T228_Sample_ID
;




select count(*), min(sample_year), max(sample_year) from Test_T228 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 32	    2012	2019





/***********************************************************************************

 T228 Specific Gravity of Semi-Solid Bituminous Materials
 pycnometer - a device used for measuring density (from Wiki)
 
 W-18-0183-AB, W-18-1952-AB, W-17-1788-AB, W-16-1306-AB, W-15-0854-AB
 
 from MTest, Lt_T228_BC.cpp 
 2011-12-05 Notes from meeting with Bill McKenna:
 
 Mass of Pycnometer            (A)
 Pycnometer + water            (B)
 Pycnometer + asphalt          (C)
 Pycnometer + asphalt + water  (D)
 specific gravity              (E)
 (no min or max spec)
 E = (C-A) / ( (B-A) - (D-C) )
 
 No conversion constants for density used
 
 void LtT228_BC::CorGrpRoot::calc()
 
 if (pyc >= 0.0 && pycAs > pyc && pycWater > pyc && pycAsWater > pyc)
 {
     double denom = (pycWater - pyc) - (pycAsWater - pycAs);
     
     if (denom > 0.0)
     {
         double res = (pycAs - pyc) / denom;
         
         if (res > 0.0)
             sg = res;
     }
 }

***********************************************************************************/



create or replace view V_T228_Specific_Gravity_of_Semi_Solid_Bituminous_Materials as 

with T228_sql as (

     select  sample_id                        as Sample_ID
     
            ,case when  mass_pycnometer               > 0               and -- A
                        mass_pycnometer_water         > mass_pycnometer and -- B
                        mass_pycnometer_asphalt       > mass_pycnometer and -- C
                        mass_pycnometer_asphalt_water > mass_pycnometer and -- D
                        
                        -- numerator
                        (mass_pycnometer_asphalt - mass_pycnometer) > 0 and -- (C-A)
                        
                        -- denominator                                         ((B-A) - (D-C))
                       ((mass_pycnometer_water - mass_pycnometer) - 
                        (mass_pycnometer_asphalt_water - mass_pycnometer_asphalt)) > 0 
                       
                  then -- specific gravity E = (C-A) / ((B-A) - (D-C))
                       ( (mass_pycnometer_asphalt - mass_pycnometer) /               -- numerator
                         ( (mass_pycnometer_water - mass_pycnometer) -               -- denominator
                           (mass_pycnometer_asphalt_water - mass_pycnometer_asphalt)
                         )
                        )
                  
                  else -1 end
                  as Specific_Gravity
     
       from  Test_T228
)

select  t228.sample_id                        as T228_Sample_ID
       ,t228.sample_year                      as T228_Sample_Year
       ,t228.test_status                      as T228_Test_Status
       ,t228.tested_by                        as T228_Tested_by
       
       ,case when to_char(t228.date_tested, 'yyyy') = '1959'
             then ' '
             else to_char(t228.date_tested, 'mm/dd/yyyy')
             end                              as T228_date_tested
            
       ,t228.date_tested                        as T228_date_tested_DATE
       ,t228.date_tested_orig                   as T228_date_tested_orig
       
       ,t228.mass_pycnometer                  as T228_mass_pycnometer
       ,t228.mass_pycnometer_water            as T228_mass_pycnometer_water
       ,t228.mass_pycnometer_asphalt          as T228_mass_pycnometer_asphalt
       ,t228.mass_pycnometer_asphalt_water    as T228_mass_pycnometer_asphalt_water
       
       ,round(T228_sql.Specific_Gravity,4)    as T228_Specific_Gravity
                            
       ,t228.remarks                          as T228_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T228                               t228 on t228.sample_id = smpl.sample_id
  join T228_sql                                     on t228.sample_id = T228_sql.sample_id
 ;
 
 
 
 





