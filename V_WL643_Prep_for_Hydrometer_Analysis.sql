


select * from V_WL643_Prep_for_Hydrometer_Analysis where wl643_sample_id = 'W-19-0007-SO'
;



select * from V_WL643_Prep_for_Hydrometer_Analysis
 order by wl643_sample_year desc, wl643_sample_id, wl640_segment_nbr
;



select * from V_WL643_Prep_for_Hydrometer_Analysis
 where wl640_mass_of_fines_nbr <= 0
 order by wl643_sample_year desc, wl643_sample_id, wl640_segment_nbr
;



desc V_WL643_Prep_for_Hydrometer_Analysis;




/***********************************************************************************

 V_WL643_Prep_for_Hydrometer_Analysis
 
***********************************************************************************/


create or replace view V_WL643_Prep_for_Hydrometer_Analysis    as 

select  wl643.sample_id                                        as WL643_sample_id
       ,wl643.sample_year                                      as WL643_sample_year
       ,wl643.test_status                                      as WL643_test_status
       ,wl643.tested_by                                        as WL643_tested_by
       
       ,case when to_char(wl643.date_tested, 'yyyy') = '1959'  then ' '
             else to_char(wl643.date_tested, 'mm/dd/yyyy')     end
                                                               as WL643_date_tested
       
       ,wl643.date_tested                                      as WL643_date_tested_DATE
       ,wl643.date_tested_orig                                 as WL643_date_orig
       
       /*---------------------------------------------------------------------------------
         WL640 summation calculations
       ---------------------------------------------------------------------------------*/
       
       ,v_wl640.WL640_mass_of_fines                            as WL640_mass_of_fines
       ,v_wl640.WL640_mass_retained_summ_coarse                as WL640_Mass_sum_coarse
       ,v_wl640.WL640_Mass_Total                               as WL640_Mass_Total
       
       /*---------------------------------------------------------------------------------
         WL640 Raw Gradation sieves
       ---------------------------------------------------------------------------------*/
       
       ,v_wl640.wl640_segment_nbr                              as WL640_segment_nbr
       ,v_wl640.wl640_sieve_size                               as WL640_sieve_size
       ,v_wl640.WL640_mass_retained                            as WL640_mass_retained
       ,sum(v_wl640.WL640_mass_retained) over (partition by v_wl640.WL640_Sample_ID order by v_wl640.wl640_segment_nbr)
                                                               as WL640_mass_retained_cumulative
       
        /*---------------------------------------------------------------------------------
          WL643
        ---------------------------------------------------------------------------------*/
        
       ,wl643.mass_total_hydrometer_weight                     as WL643_total_hydrometer_weight
       ,wl643.mass_retained_nbr10                              as WL643_mass_retained_nbr10
       ,adjusted_nbr10                                         as WL643_adjusted_nbr10
       
       /*---------------------------------------------------------------------------------
         table relationships
       ---------------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       
       join Test_WL643                                   wl643 on wl643.sample_id = smpl.sample_id
       
       join V_WL640_Prep_Raw_Gradation                 v_wl640 on wl643.sample_id = v_wl640.WL640_Sample_ID       
       
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T88ut_BC.cpp, HydroCalcs::doCalcsPrelim
         
         adjusted #10 is sieved from the WL643 total hydrometer weight subsample
         this recasts it back to the total fines in the entire sample (coarse included)
         adjten = _tenret * _cpan / _thw;
         
         -- cpan (coarse pan) is equivalent to total fines, it is the result of the
         soil that passed the coarse sieves and ended in the cpan, hence, 'the Fines'
       ---------------------------------------------------------------------------------*/
       
       cross apply (select (wl643.mass_retained_nbr10 * v_wl640.WL640_mass_of_fines / wl643.mass_total_hydrometer_weight)
                        as adjusted_nbr10 from dual) adjusted
 
       order by 
       wl643.sample_id,
       v_wl640.wl640_segment_nbr
       ;

  
  






