


select * from V_T49_Penetration_of_Bituminous_Materials
 order by T49_Sample_Year desc, T49_Sample_ID
;



--   T44 Solubility  of Bituminous Materials  (current)
--   T49 Penetration of Bituminous Materials  (current)
--   T51 Ductility   of Bituminous Materials  (current)
--  T301 Elastic Recovery of Bituminous materials (current)
-- D7553 Solubility  of Bituminous Materials  (2015) -- same layout as T44



select count(*), min(sample_year), max(sample_year) from Test_T49 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 407	    2006	2019



/***********************************************************************************

 T49 Penetration of Bituminous Materials
 
 W-18-0123-AB, W-18-0440-AB, W-17-0547-AB, W-15-0656-AB

 from MTest, Lt_T49_BC.cpp, void LtT49_BC::CorGrpRoot::calc(){
 
 if (trial >= 0.0)
 {
    sum += trial;
    ++nsum;
 }
        
 if (nsum > 0)
 {
    av = sum / nsum;
 }


***********************************************************************************/



create or replace view V_T49_Penetration_of_Bituminous_Materials as 

select  t49.sample_id                         as T49_Sample_ID
       ,t49.sample_year                       as T49_Sample_Year
       ,t49.test_status                       as T49_Test_Status
       ,t49.tested_by                         as T49_Tested_by
       
       ,case when to_char(t49.date_tested, 'yyyy') = '1959'
             then ' '
             else to_char(t49.date_tested, 'mm/dd/yyyy')
             end                              as T49_date_tested
            
       ,t49.date_tested                         as T49_date_tested_DATE
       ,t49.date_tested_orig                    as T49_date_tested_orig
       
       /*----------------------------------------------------------
         Trials
       ----------------------------------------------------------*/
       
       ,case when t49.trial1 >= 0 then to_char(t49.trial1, '9990.99')  else ' ' end as T49_trial1
       ,case when t49.trial2 >= 0 then to_char(t49.trial2, '9990.99')  else ' ' end as T49_trial2
       ,case when t49.trial3 >= 0 then to_char(t49.trial3, '9990.99')  else ' ' end as T49_trial3
       
       ,case when (calc_numerator.summation_of_trials > 0) and (calc_denominator.number_of_trials > 0)
             then to_char((calc_numerator.summation_of_trials / calc_denominator.number_of_trials), 9990.999)
             else ' '
             end as T49_avg_ductility
       
       ,calc_numerator.summation_of_trials
       ,calc_denominator.number_of_trials
       
       ,case when t49.temperature  >= 0 then to_char(t49.temperature)  else ' ' end as T49_temperature
       ,case when t49.mass         >= 0 then to_char(t49.mass)         else ' ' end as T49_mass
       ,case when t49.time_seconds >= 0 then to_char(t49.time_seconds) else ' ' end as T49_time_seconds
       ,case when t49.minimum_spec     >= 0 then to_char(t49.minimum_spec)     else ' ' end as T49_min_spec
       ,case when t49.maximum_spec     >= 0 then to_char(t49.maximum_spec)     else ' ' end as T49_max_spec
                            
       ,t49.remarks as T49_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T49                                 t49 on t49.sample_id = smpl.sample_id
  
  /*-------------------------------------------------------------
    numerator
  -------------------------------------------------------------*/
  
  cross apply (select  
       case when t49.trial1 > 0 then t49.trial1 else 0 end +
       case when t49.trial2 > 0 then t49.trial2 else 0 end +
       case when t49.trial3 > 0 then t49.trial3 else 0 end
       as summation_of_trials from dual
  ) calc_numerator
  
  /*-------------------------------------------------------------
    denominator
  -------------------------------------------------------------*/
  
  cross apply (select  
       case when t49.trial1 > 0 then 1 else 0 end +
       case when t49.trial2 > 0 then 1 else 0 end +
       case when t49.trial3 > 0 then 1 else 0 end
       as number_of_trials from dual
  ) calc_denominator
  
  ;









