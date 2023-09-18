


select * from V_T301_Elastic_Recovery_of_Bituminous_Materials 
 order by T301_Sample_Year desc, T301_Sample_ID, T301seg_segment_nbr;



select * from V_T301_Elastic_Recovery_of_Bituminous_Materials where T301_Sample_ID = 'W-16-0094-AB';



select * from V_T301_Elastic_Recovery_of_Bituminous_Materials where T301_Sample_ID like 'W-20%'
 order by T301_Sample_Year desc, T301_Sample_ID, T301seg_segment_nbr;



select * from V_T301_Elastic_Recovery_of_Bituminous_Materials 
 where T301_Sample_ID in (
 'W-20-0155', 'W-20-1355-AB', 'W-19-0898-AB', 'W-19-0919-AB', 
 'W-18-1953-AB', 'W-18-0772-AB', 'W-17-0326-AB', 'W-17-0333-AB'
 )
 order by T301_Sample_Year desc, T301_Sample_ID, T301seg_segment_nbr
 ;



--   T44 Solubility  of Bituminous Materials  (current)
-- D7553 Solubility  of Bituminous Materials  (2015) -- same layout as T44
--   T49 Penetration of Bituminous Materials  (current)
--   T51 Ductility   of Bituminous Materials  (current)
--  T301 Elastic Recovery of Bituminous Materials (current)

-----------------------------------------------------------------------
-- some diagnostics
-----------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T301 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
--   301	2009	2020



select * from Test_T301 order by sample_year desc, sample_id;



/***********************************************************************************

 T301 Elastic Recovery of Bituminous materials
 
 W-20-0135,    W-20-0136,    W-20-0155,    W-20-0846-AB, W-20-0876-AB, W-20-0878-AB
 W-19-0110-AB, W-19-0111-AB, W-19-0112-AB, W-18-0086-AB, W-18-0184-AB, W-18-0418-AB
 W-17-0584-AB, W-17-0585-AB, W-17-0586-AB, W-16-1306-AB, W-16-1328-AB, W-16-1428-AB
 W-15-0422-AB, W-15-0786-AB, W-15-0853-AB, W-14-0069-AB, W-14-0653-AB, W-14-1003-AB

 ----------------------------------
 from MTest, Lt_T301_BC.cpp
 ----------------------------------

 if (reading >= 0.0 && reading <= 20.0)
     recovery = (20.0 - reading) * 5.0;

 for (each segment)
 {
      if( recovery >= 0.0 )
      {
         sum += recovery;
         ++n;
      }
   
 if(n > 0)
    av = sum / n;

***********************************************************************************/


create or replace view V_T301_Elastic_Recovery_of_Bituminous_Materials as 

with count_sql as (select sample_id,

                          -- obtain a count of valid final_readings 
                          -- from all segments across each sample
                          count(case when final_reading >= 0 and final_reading <= 20 
                                     then 1 else 0 end) as final_reading_valid_count
                                     
                   from Test_T301_segments
                  group by sample_id 
)

select  t301.sample_id                        as T301_Sample_ID
       ,t301.sample_year                      as T301_Sample_Year
       ,t301.test_status                      as T301_Test_Status
       ,t301.tested_by                        as T301_Tested_by
       
       ,case when to_char(t301.date_tested, 'yyyy') = '1959'
             then ' '
             else to_char(t301.date_tested, 'mm/dd/yyyy')
             end                              as T301_date_tested
            
       ,t301.date_tested                        as T301_date_tested_DATE
       ,t301.date_tested_orig                   as T301_date_tested_orig
       
       /*-------------------------------------------------------------
         segments
       -------------------------------------------------------------*/
       
       ,case when t301seg.segment_nbr is not null then to_char(t301seg.segment_nbr) else ' ' end
        as T301seg_segment_nbr
        
       ,case when t301seg.final_reading >= 0 then trim(to_char(t301seg.final_reading,'990.99')) else ' ' end
        as T301seg_final_reading
       
       ,calc_pct_elongation_recovery_rounded  
        as T301seg_pct_recovery_rounded
       
       ,case when sum(calc_pct_elongation_recovery_rounded) over (partition by t301seg.sample_id) > 0 and final_reading_valid_count > 0
             then round((sum(calc_pct_elongation_recovery_rounded) over (partition by t301seg.sample_id)) / final_reading_valid_count)
             else -1 end
        as T301seg_pct_recovery_rounded_avg
       
       /*-------------------------------------------------------------
         segments - ancillary calculations, not for display
       -------------------------------------------------------------*/
       
       ,sum(case when calc_pct_elongation_recovery_rounded >= 0 then calc_pct_elongation_recovery_rounded else 0 end) 
        over (partition by t301seg.sample_id)
        as T301_pct_recovery_rounded_sum
       
       ,calc_pct_elongation_recovery_raw
        as T301seg_pct_recovery_raw -- a check on calc_pct_elongation_recovery_rounded
       
       ,case when final_reading_valid_count is not null then final_reading_valid_count else -1 end
        as T301_final_reading_valid_count
        
       ,t301.remarks as T301_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T301                               t301 on t301.sample_id = smpl.sample_id
  left outer join Test_T301_segments        t301seg on t301.sample_id = t301seg.sample_id  
  left outer join count_sql                         on t301.sample_id = count_sql.sample_id
  
  /*-------------------------------------------------------------
    calculations - t301seg.final_reading is valid at 0-20
  -------------------------------------------------------------*/
  
  cross apply (select case when t301seg.final_reading >= 0 and t301seg.final_reading <= 20
                           then round((20 - t301seg.final_reading) * 5) 
                           else -1 
                           end as calc_pct_elongation_recovery_rounded from dual) calc_round
                           
  cross apply (select case when t301seg.final_reading >= 0 and t301seg.final_reading <= 20
                           then (20 - t301seg.final_reading) * 5
                           else -1
                           end as calc_pct_elongation_recovery_raw from dual) calc_raw

  order by T301_Sample_ID, T301seg_segment_nbr
  ;
  
  
  






