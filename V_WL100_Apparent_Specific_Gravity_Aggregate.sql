


-- T100 Specific Gravity of Soils (current)
-- WL100 Apparent Specific Gravity, Aggregate (current)



select * from V_WL100_Apparent_Specific_Gravity_Aggregate where sample_id = 'W-20-0984-AG'
;



select * from V_WL100_Apparent_Specific_Gravity_Aggregate
;



select count(*), min(sample_year), max(sample_year) from test_wl100 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 2338	    1986	2020




/***********************************************************************************

* WL100 Apparent Specific Gravity, Aggregate
* W-18-0134-AG, W-18-0483-AG, W-18-0576-AG, W-17-0442-AG

W-20-0984-AG
W-19-0165-AG
W-19-0399-AG
W-19-0400-AG
W-19-0706-AG
W-19-0750-AG

-----------------------------------------
 from MTest, Lt_WL100_B9.cpp, doCalcs
-----------------------------------------

      "Volume of flask" MEANS: mass of flask and stopper, full of water (grams)
     "Dry Wt of sample" MEANS: mass of dry sample (grams)
"Final volume of flask" MEANS: mass of flask, containing the sample, filled with water, and stopper
 (That is, the sample has displaced some of the water included in the "Volume of Flask",
  the difference between these two measurements is the difference between the weight 
  of the sample and an equivalent volume of water)

 THERE AREN'T REALLY ANY MEASURED VOLUMES ANYWHERE

 if (flask > 0.0 && smpl > 0.0 && final > 0.0)
 {
   double tmp = smpl + flask - final; // tmp is the denominator

   if (tmp > 0.0)
   {
       asg = smpl / tmp;              // asg (apparent specific gravity)
   }
   else asg = blank
 }
        
***********************************************************************************/



create or replace view V_WL100_Apparent_Specific_Gravity_Aggregate as 


select  wl100.sample_id                                        as WL100_sample_id
       ,wl100.sample_year                                      as T100_Sample_Year
       ,wl100.test_status                                      as T100_Test_Status
       ,wl100.tested_by                                        as T100_Tested_by
       
       ,case when to_char(wl100.date_tested, 'yyyy') = '1959'  then ' '
             else to_char(wl100.date_tested, 'mm/dd/yyyy')     end
                                                               as WL100_date_tested
            
       ,wl100.date_tested                                      as WL100_date_tested_DATE
       ,wl100.date_tested_orig                                 as WL100_date_tested_orig
              
       /*-----------------------------------------------------------------------
         coarse values and calculations
       -----------------------------------------------------------------------*/
       
       ,wl100.mass_coarse_flask                                as WL100_mass_coarse_flask
       ,wl100.mass_coarse_dry                                  as WL100_mass_coarse_dry
       ,wl100.mass_coarse_final                                as WL100_mass_coarse_final
       ,mass_ASG_coarse                                        as WL100_mass_coarse_Apparent_Specific_Gravity
       
       /*-----------------------------------------------------------------------
         fine values and calculations
       -----------------------------------------------------------------------*/
       
       ,wl100.mass_fine_flask                                  as WL100_mass_fine_flask
       ,wl100.mass_fine_dry                                    as WL100_mass_fine_dry
       ,wl100.mass_fine_final                                  as WL100_mass_fine_final
       ,mass_ASG_fine                                          as WL100_mass_fine_Apparent_Specific_Gravity
       
       ,wl100.remarks                                          as WL100_Remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_WL100                                   wl100 on wl100.sample_id = smpl.sample_id
       
       /*-----------------------------------------------------------------------
         coarse apparent specific gravity
       -----------------------------------------------------------------------*/
       
       cross apply (select case when (wl100.mass_coarse_flask > 0 and wl100.mass_coarse_dry > 0 and wl100.mass_coarse_final > 0)                                      
                                then (wl100.mass_coarse_dry / (wl100.mass_coarse_flask + wl100.mass_coarse_dry - wl100.mass_coarse_final))
                                else -1 end as mass_ASG_coarse from dual) massASGcoarse

       /*-----------------------------------------------------------------------
         fine apparent specific gravity
       -----------------------------------------------------------------------*/
     
       cross apply (select case when (wl100.mass_fine_flask > 0 and wl100.mass_fine_dry > 0 and wl100.mass_fine_final > 0)
                                then (wl100.mass_fine_dry / (wl100.mass_fine_flask + wl100.mass_fine_dry - wl100.mass_fine_final))
                                else -1 end as mass_ASG_fine from dual) massASGfine
       ;









