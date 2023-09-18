



select * from V_WL642_Prep_Coarse_Wash
 where WL642_sample_year in ('2019','2016','2015')
 order by WL642_sample_year desc, WL642_sample_id, WL640_segment_nbr
 ;
 


select * from test_WL642;




/***********************************************************************************

 V_WL642_Prep_Coarse_Wash
 
***********************************************************************************/



create or replace view V_WL642_Prep_Coarse_Wash as 


select  wl642.sample_id                           as WL642_sample_id
       ,wl642.sample_year                         as WL642_sample_year
       ,wl642.test_status                         as WL642_test_status
       ,wl642.tested_by                           as WL642_tested_by
       
       ,case when to_char(wl642.date_tested, 'yyyy') = '1959' then ' '
             else to_char(wl642.date_tested, 'mm/dd/yyyy') end
                                                  as WL642_date_tested
            
       ,wl642.date_tested                         as WL642_date_tested_DATE
       ,wl642.date_tested_orig                    as WL642_date_orig
       
       /*----------------------------------------------------
         WL640 summation calculations
       ----------------------------------------------------*/
       
       ,v_wl640.WL640_mass_of_fines               as WL640_mass_of_fines
       ,v_wl640.WL640_mass_retained_summ_coarse   as WL640_Mass_sum_coarse
       ,v_wl640.WL640_Mass_Total                  as WL640_Mass_Total
       
       /*----------------------------------------------------
         WL640 Raw Gradation coarse sieves
       ----------------------------------------------------*/
       
       ,v_wl640.wl640_segment_nbr                 as WL640_segment_nbr
       ,v_wl640.wl640_sieve_size                  as WL640_sieve_size
       ,v_wl640.WL640_mass_retained               as WL640_mass_retained
       
       /*----------------------------------------------------
         WL642 batch weight and sieves
       ----------------------------------------------------*/
       
       ,case when wl642.batch_weight >= 0 then wl642.batch_weight else -1 end 
                                                  as WL642_batch_weight

       ,v_wl640.wl640_sieve_size                  as WL642_batch_wt_sieve_size
       
       ,wl642_calc_batch_mass_retained            as WL642_batch_wt_mass_retained
       
       ,sum(wl642_calc_batch_mass_retained) over (partition by wl642.sample_id order by wl642.sample_id, v_wl640.wl640_segment_nbr)
                                                  as WL642_batch_wt_cumulative_mass
              
       ,wl642.remarks                             as WL642_remarks

  /*----------------------------------------------------
    table relationships
  ----------------------------------------------------*/
  
  from MLT_1_Sample_WL900                   smpl
  join Test_WL642                          wl642 on smpl.sample_id = wl642.sample_id
  join V_WL640_Prep_Raw_Gradation        v_wl640 on smpl.sample_id = v_wl640.WL640_Sample_ID
      
  /*----------------------------------------------------
    for each sieve size: batch weight mass retained =
    raw gradation mass retained * (batch weight / WL640 total mass)
    if mass of fines is 0 in WL642, then use total coarse mass
  ----------------------------------------------------*/
       
  cross apply 
  (select case when wl642.batch_weight                      > 0 and 
                    v_wl640.WL640_mass_retained_summ_coarse > 0 and 
                    v_wl640.WL640_Mass_Total                > 0 -- ensure denominator > 0  
               then round(((wl642.batch_weight / v_wl640.WL640_Mass_Total) * v_wl640.WL640_mass_retained_summ_coarse), 2)
               else 0 
               end as wl642_calc_batch_mass_retained from dual  
  ) batch_mass_ret
  
union

/*----------------------------------------------------
  WL641 batch weight calculations - Pan
----------------------------------------------------*/

select  wl642.sample_id                           as WL642_sample_id
       ,wl642.sample_year                         as WL642_sample_year
       ,wl642.test_status                         as WL642_test_status
       ,wl642.tested_by                           as WL642_tested_by
       
       ,case when to_char(wl642.date_tested, 'yyyy') = '1959' then ' '
             else to_char(wl642.date_tested, 'mm/dd/yyyy') end
                                                  as WL642_date_tested
            
       ,wl642.date_tested                         as WL642_date_tested_DATE
       ,wl642.date_tested_orig                    as WL642_date_orig
       
       /*----------------------------------------------------
         WL640 summation calculations
       ----------------------------------------------------*/
       
       ,v_wl640.WL640_mass_of_fines               as WL640_mass_of_fines
       ,v_wl640.WL640_mass_retained_summ_coarse   as WL640_Mass_sum_coarse
       ,v_wl640.WL640_Mass_Total                  as WL640_Mass_Total
       
       /*----------------------------------------------------
         WL640 sieves --- Pan dummy placeholders
       ----------------------------------------------------*/
       
       ,99                                        as wl640_segment_nbr
       ,'Pan'                                     as wl640_sieve_size
       ,0                                         as wl640_mass_retained
       
       /*----------------------------------------------------
         WL642 batch weight and sieves
       ----------------------------------------------------*/
       
       ,case when wl642.batch_weight >= 0 then wl642.batch_weight else -1 end 
                                                  as WL642_batch_weight
                                        
       ,'Pan'                                     as WL642_batch_wt_sieve_size
       ,wl642_calc_batch_wt_pan                   as WL642_batch_wt_mass_retained
       
       ,wl642_calc_cumulative_mass_pan            as WL642_batch_wt_cumulative_mass
              
       ,' '                                       as WL642_remarks
       
  /*----------------------------------------------------
    table relationships
  ----------------------------------------------------*/
  
  from MLT_1_Sample_WL900                   smpl
  join Test_WL642                          wl642 on smpl.sample_id = wl642.sample_id
  join V_WL640_Prep_Raw_Gradation        v_wl640 on smpl.sample_id = v_wl640.WL640_Sample_ID
  
  /*----------------------------------------------------
    wl642_calc_batch_mass_retained is the cumulative
    mass retained on the sieve prior to the Pan
  ----------------------------------------------------*/
  
  cross apply 
  (select case when wl642.batch_weight                      > 0 and 
                    v_wl640.WL640_mass_retained_summ_coarse > 0 and 
                    v_wl640.WL640_Mass_Total                > 0 -- ensure denominator > 0  
               then round(((wl642.batch_weight / v_wl640.WL640_Mass_Total) * v_wl640.WL640_mass_retained_summ_coarse), 2)
               else 0 
               end as wl642_calc_batch_mass_retained from dual  
  ) batch_mass_ret
  
  /*----------------------------------------------------
    subtract wl642_calc_batch_mass_retained from the 
    wl642.batch_weight to achieve the mass retained
    in the Pan
  ----------------------------------------------------*/
  
  cross apply (select case when wl642.batch_weight > 0 and wl642_calc_batch_mass_retained > 0 
                           then round((wl642.batch_weight - wl642_calc_batch_mass_retained), 2)
                           else 0 end
                           as wl642_calc_batch_wt_pan from dual
  ) calc_pan
  
  /*----------------------------------------------------
    adding wl642_calc_batch_mass_retained to wl642_calc_batch_wt_pan
    should return to the WL642 Batch Weight
  ----------------------------------------------------*/
  
  cross apply (select wl642_calc_batch_mass_retained + wl642_calc_batch_wt_pan
               as wl642_calc_cumulative_mass_pan from dual
  ) calc_cum_pan
    
  order by wl642_sample_id, wl640_segment_nbr
;




  




