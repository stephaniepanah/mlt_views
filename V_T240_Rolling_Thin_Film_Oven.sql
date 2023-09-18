


select * from V_T240_Rolling_Thin_Film_Oven
 order by t240_sample_year desc, t240_sample_year
;



select * from V_T240_Rolling_Thin_Film_Oven where sample_year = '2020'
;



select * from V_T240_Rolling_Thin_Film_Oven where sample_id = 'W-19-1576-AB'
;



select count(*), min(sample_year), max(sample_year) from Test_T240 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 1469	    2000	2019



/***********************************************************************************

 T240 Rolling Thin Film Oven Test
 W-18-0006-AB, W-18-0086-AB, W-18-0183-AB, W-18-0418-AB


 from MTest, Lt_T240_BB.cpp, void LtT240_BB::CorRowTrial::calcTrial()
 {
	double tare, before, after, change;

	if (tare > 0.0) // if blank, assume not used
	{
		before -= tare;
		after -= tare;
	}    
	if (after >= 0.0 && before > 0.0)
	{
		change = (100.0 * (after - before) / before);
	}
 }

 calcAvChange()
 {
	val = sum / n; --- avg_pct_mass_change
 }

***********************************************************************************/



create or replace view V_T240_Rolling_Thin_Film_Oven as

select  t240.sample_id                         as T240_Sample_ID
       ,t240.sample_year                       as T240_Sample_Year
       ,t240.test_status                       as T240_Test_Status
       ,t240.tested_by                         as T240_Tested_by 
       
       ,case when to_char(t240.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t240.date_tested, 'mm/dd/yyyy')
             end                               as T240_date_tested
            
       ,t240.date_tested                         as T240_date_tested_DATE
       ,t240.date_tested_orig                    as T240_date_tested_orig
       
       -------------------------------------------
       -- Trial1
       -------------------------------------------
       
       ,case when t240.trial1_mass_tare   >= 0 then trim(to_char(t240.trial1_mass_tare,   '9990.999')) else ' ' end 
        as T240_trial1_mass_tare
        
       ,case when t240.trial1_mass_before >= 0 then trim(to_char(t240.trial1_mass_before, '9990.999')) else ' ' end 
        as T240_trial1_mass_before
        
       ,case when t240.trial1_mass_after  >= 0 then trim(to_char(t240.trial1_mass_after,  '9990.999')) else ' ' end 
        as T240_trial1_mass_after
       
       ,case when calc_trial1_pct_mass_change <> 0 then trim(to_char(calc_trial1_pct_mass_change, '990.9999')) else ' ' end
        as T240_trial1_pct_mass_change
       
       -------------------------------------------
       -- Trial2
       -------------------------------------------
       
       ,case when t240.trial2_mass_tare   >= 0 then trim(to_char(t240.trial2_mass_tare,   '9990.999')) else ' ' end
       as T240_trial2_mass_tare
       
       ,case when t240.trial2_mass_before >= 0 then trim(to_char(t240.trial2_mass_before, '9990.999')) else ' ' end
       as T240_trial2_mass_before
       
       ,case when t240.trial2_mass_after  >= 0 then trim(to_char(t240.trial2_mass_after,  '9990.999')) else ' ' end 
       as T240_trial2_mass_after
       
       ,case when calc_trial2_pct_mass_change <> 0 then trim(to_char(calc_trial2_pct_mass_change, '9990.9999')) else ' ' end 
        as T240_trial2_pct_mass_change
       
       -------------------------------------------
       -- average of Trial 1 and Trial 2
       -------------------------------------------
       
       ,avg_pct_mass_change         as T240_Avg_Percent_Mass_Change
       
       ,calc_trial1_pct_mass_change as T240_calc_trial1_pct_mass_change -- not for display
       ,calc_trial2_pct_mass_change as T240_calc_trial2_pct_mass_change -- not for display
       
       ,t240.remarks                as T240_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T240                               t240 on t240.sample_id = smpl.sample_id
  
  /*---------------------------------------------------------------
    Trial 1 calculations
    remove tare from before and after, then calculate pct change
  ---------------------------------------------------------------*/
  
  cross apply (select case when t240.trial1_mass_before >= 0 and 
                                t240.trial1_mass_before >= t240.trial1_mass_tare
                           then t240.trial1_mass_before  - t240.trial1_mass_tare
                           else 0 end
                           as trial1_before from dual
  ) before1

  cross apply (select case when t240.trial1_mass_after  >= 0 and 
                                t240.trial1_mass_after  >= t240.trial1_mass_tare
                           then t240.trial1_mass_after   - t240.trial1_mass_tare
                           else 0 end
                           as trial1_after from dual
  ) after1

  cross apply (select case when trial1_before > 0 
                           then round(((100 * (trial1_after - trial1_before)) / trial1_before),4)
                           else 0 end
                           as calc_trial1_pct_mass_change from dual
  ) change1
  
  /*---------------------------------------------------------------
    Trial 2 calculations
    remove tare from before and after, then calculate pct change
  ---------------------------------------------------------------*/
  
  cross apply (select case when t240.trial2_mass_before >= 0 and 
                                t240.trial2_mass_before >= t240.trial2_mass_tare
                           then t240.trial2_mass_before  - t240.trial2_mass_tare
                           else 0 end
                           as trial2_before from dual
  ) before2
  
  cross apply (select case when t240.trial2_mass_after  >= 0 and 
                                t240.trial2_mass_after  >= t240.trial2_mass_tare
                           then t240.trial2_mass_after   - t240.trial2_mass_tare
                           else 0 end
                           as trial2_after from dual
  ) after2
  
  cross apply (select case when trial2_before > 0 
                           then round(((100 * (trial2_after - trial2_before)) / trial2_before),4)
                           else 0 end
                           as calc_trial2_pct_mass_change from dual
  ) change2
  
  
  /*---------------------------------------------------------------
    average pct mass change
  ---------------------------------------------------------------*/
  
  cross apply (select case
  
        -- > 99% of samples
        when calc_trial1_pct_mass_change <> 0 and calc_trial2_pct_mass_change <> 0
        then to_char(((calc_trial1_pct_mass_change + calc_trial2_pct_mass_change) / 2), '9990.9999')
        
        -- W-16-0483-AB, W-10-1692-AB, W-05-1032-AB, W-03-0620-AB, W-03-1190-AB, W-03-1395-AB
        when calc_trial1_pct_mass_change <> 0 and calc_trial2_pct_mass_change = 0
        then to_char(calc_trial1_pct_mass_change, '9990.9999')
        
        -- W-04-0006-AB, W-03-0212-AB
        when calc_trial2_pct_mass_change <> 0 and calc_trial1_pct_mass_change = 0
        then to_char(calc_trial2_pct_mass_change, '9990.9999')
        
        else ' ' -- W-10-1692-AB
        
        end as avg_pct_mass_change from dual
        
 ) average_change
 
 ;









