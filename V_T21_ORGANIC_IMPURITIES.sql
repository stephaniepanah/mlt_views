


select * from V_T21_Organic_Impurities
 order by T21_Sample_Year desc, T21_Sample_ID
;




select count(*), min(sample_year), max(sample_year) from Test_T21 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 5	    1986	2002



select * from Test_T21
 order by Sample_Year desc, Sample_ID
;




/***********************************************************************************

 T21 Organic Impurities
 W-02-0341-AG, W-94-0087-AG, W-91-0873-AG, W-86-0923-AG, W-86-0924-AG
 W-66-9001-GEO, W-66-9011-GEO
 
 Gardner Color Scale is a one-dimensional scale to measure the 
 shade of the color yellow, values are 1-18

***********************************************************************************/



create or replace view V_T21_Organic_Impurities as 

select  t21.sample_id                         as T21_Sample_ID
       ,t21.sample_year                       as T21_Sample_Year
       ,t21.test_status                       as T21_Test_Status
       ,t21.tested_by                         as T21_Tested_by
       
       ,case when to_char(t21.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t21.date_tested, 'mm/dd/yyyy')
             end                              as T21_date_tested
            
       ,t21.date_tested                         as T21_date_tested_DATE
       ,t21.date_tested_orig                    as T21_date_tested_orig
       
       ,t21.gardner_result                    as T21_gardner_result
       ,t21.gardner_color_standard_nbr        as T21_gardner_color_standard_nbr
                                   
       ,t21.remarks                           as T21_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T21                                 t21 on t21.sample_id = smpl.sample_id
 ;









