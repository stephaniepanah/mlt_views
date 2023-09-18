


select * from V_T51_Ductility_of_Bituminous_Materials
 order by T51_Sample_Year desc, T51_Sample_ID
;



--   T44 Solubility  of Bituminous Materials  (current)
--   T49 Penetration of Bituminous Materials  (current)
--   T51 Ductility   of Bituminous Materials  (current)
--  T301 Elastic Recovery of Bituminous materials (current)
-- D7553 Solubility  of Bituminous Materials  (2015) -- same layout as T44



select count(*), min(sample_year), max(sample_year) from Test_T51 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 276	    2006	2019



/***********************************************************************************

 T51 Ductility of Bituminous Materials

 W-18-0123-AB, W-18-0436-AB, W-17-0547-AB, W-13-0857-AB

 from MTest, Lt_T51_BC.cpp, void LtT51_BC::CorGrpRoot::calc(){
 
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



create or replace view V_T51_Ductility_of_Bituminous_Materials as 

select  t51.sample_id                         as T51_Sample_ID
       ,t51.sample_year                       as T51_Sample_Year
       ,t51.test_status                       as T51_Test_Status
       ,t51.tested_by                         as T51_Tested_by
       
       ,case when to_char(t51.date_tested, 'yyyy') = '1959'
             then ' '
             else to_char(t51.date_tested, 'mm/dd/yyyy')
             end                              as T51_date_tested
            
       ,t51.date_tested                         as T51_date_tested_DATE
       ,t51.date_tested_orig                    as T51_date_tested_orig
       
       /*----------------------------------------------------------
         Trials
       ----------------------------------------------------------*/
       
       ,case when t51.trial1 >= 0 then to_char(t51.trial1, '9990.99') else ' ' end as T51_trial1
       ,case when t51.trial2 >= 0 then to_char(t51.trial2, '9990.99') else ' ' end as T51_trial2
       ,case when t51.trial3 >= 0 then to_char(t51.trial3, '9990.99') else ' ' end as T51_trial3
       
       ,case when (calc_numerator.summation_of_trials > 0) and (calc_denominator.number_of_trials > 0)
             then to_char((calc_numerator.summation_of_trials / calc_denominator.number_of_trials), 9990.999)
             else ' '
             end as T51_avg_ductility
       
       ,calc_numerator.summation_of_trials
       ,calc_denominator.number_of_trials
       
       ,case when t51.temperature >= 0 then to_char(t51.temperature)         else ' ' end as T51_temperature
       ,case when t51.speed       >= 0 then to_char(t51.speed) || ' cm/min ' else ' ' end as T51_speed
       ,case when t51.minimum_spec    >= 0 then to_char(t51.minimum_spec)            else ' ' end as T51_min_spec
                            
       ,t51.remarks as T51_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T51                                 t51 on t51.sample_id = smpl.sample_id
  
  /*-------------------------------------------------------------
    numerator
  -------------------------------------------------------------*/
  
  cross apply (select  
       case when t51.trial1 > 0 then t51.trial1 else 0 end +
       case when t51.trial2 > 0 then t51.trial2 else 0 end +
       case when t51.trial3 > 0 then t51.trial3 else 0 end
       as summation_of_trials from dual
  ) calc_numerator
  
  /*-------------------------------------------------------------
    denominator
  -------------------------------------------------------------*/
  
  cross apply (select  
       case when t51.trial1 > 0 then 1 else 0 end +
       case when t51.trial2 > 0 then 1 else 0 end +
       case when t51.trial3 > 0 then 1 else 0 end
       as number_of_trials from dual
  ) calc_denominator
  
  ;






