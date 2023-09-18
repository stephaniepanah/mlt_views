



select * from V_T85_Header_SG_Absorption_Coarse 
 order by t85_sample_year desc
 ;
 
 
 

-- T85 Specific Gravity and Absorption of Coarse Aggregate (current)
-- T_T85_RAP - T85 T85 Combined SGs & T85 RAP - Recycled Asphalt Pavement



select count(*), min(sample_year), max(sample_year) from Test_T85 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 622	    1985	2019




/***********************************************************************************

 T85 Specific Gravity and Absorption of Coarse Aggregate
 
 W-18-0036-AC, W-18-0391-AC, W-18-0771-AG

***********************************************************************************/



create or replace view V_T85_Header_SG_Absorption_Coarse as


select  t85.sample_id                                    as T85_Sample_ID
       ,t85.sample_year                                  as T85_Sample_Year
       ,t85.test_status                                  as T85_test_status
       ,t85.tested_by                                    as T85_tested_by
       
       ,case when to_char(t85.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t85.date_tested, 'mm/dd/yyyy') end
                                                         as T85_date_tested
            
       ,t85.date_tested                                  as T85_date_tested_DATE
       ,t85.date_tested_orig                             as T85_date_tested_orig
       
       ,t85.remarks                                      as T85_remarks
       
       /*-------------------------------------------------------------
         table relationships
       -------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                     smpl
       join Test_T85                                t85 on t85.sample_id = smpl.sample_id 
       ;









