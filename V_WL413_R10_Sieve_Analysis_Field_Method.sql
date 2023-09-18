


--                                      count       minYr   maxYr
-- WL411 Sieve Analysis, Coarse Wash    1754	    1986	2016
-- WL412 Sieve Analysis, Dry             201	    1986	2015
-- WL413 Sieve Analysis, Field Method   8108	    1986	2020



select * from V_WL413_R10_Sieve_Analysis_Field_Method where WL413_sample_ID = 'W-20-0718-AG';



select * from V_WL413_R10_Sieve_Analysis_Field_Method where WL413_sample_ID in 
 (
  'W-20-0687-AG', 'W-20-0688-AG', 'W-20-0718-AG', 'W-20-0888-AG', 'W-20-0934-AG', 'W-20-1294-AG', 
  'W-19-0584-AG', 'W-19-0607-AG', 'W-19-1636-AG', 'W-18-0546-AG', 'W-18-0606-AG', 
  'W-17-0484-AG', 'W-17-1084-AG', 'W-16-0418-AG', 'W-15-0200-AG', 'W-14-0498-AG'
 )
 order by WL413_sample_year desc, WL413_sample_ID, WL413_segment_nbr
 ;



select * from V_WL413_R10_Sieve_Analysis_pct_passing_grid where sample_id in 
 (
  'W-20-0718-AG'
  -- 'W-20-0687-AG', 'W-20-0888-AG', 'W-20-0980-AG'
  -- 'W-20-0687-AG', 'W-20-0688-AG', 'W-20-0718-AG'
  --,'W-20-0888-AG', 'W-20-0934-AG', 'W-20-1294-AG', 
  --'W-19-0584-AG', 'W-19-0607-AG', 'W-19-1636-AG', 'W-18-0546-AG', 'W-18-0606-AG', 
  --'W-17-0484-AG', 'W-17-1084-AG', 'W-16-0418-AG', 'W-15-0200-AG', 'W-14-0498-AG'
 )
 order by sample_id desc, group_nbr, segment_nbr
 ;



select * from V_WL413_R10_Sieve_Analysis_pct_passing_coarse where WL413_coarse_sample_id in 
 (
  'W-20-0687-AG', 'W-20-0888-AG', 'W-20-0980-AG'
--  'W-20-0688-AG', 'W-20-0718-AG', 'W-20-0934-AG', 'W-20-1294-AG', 
--  'W-19-0584-AG', 'W-19-0607-AG', 'W-19-1636-AG', 'W-18-0546-AG', 'W-18-0606-AG', 
--  'W-17-0484-AG', 'W-17-1084-AG', 'W-16-0418-AG', 'W-15-0200-AG', 'W-14-0498-AG'
 )
 order by WL413_coarse_sample_id desc, WL413_coarse_group_nbr, WL413_coarse_segment_nbr
 ;
 
 

select * from V_WL413_R10_Sieve_Analysis_pct_passing_fine where WL413_fine_sample_id in 
 (
   'W-20-0687-AG', 'W-20-0688-AG', 'W-20-0718-AG'
  -- ,'W-20-0888-AG', 'W-20-0934-AG', 'W-20-1294-AG'
  --,'W-19-0584-AG', 'W-19-0607-AG', 'W-19-1636-AG', 'W-18-0546-AG', 'W-18-0606-AG', 
  --,'W-17-0484-AG', 'W-17-1084-AG', 'W-16-0418-AG', 'W-15-0200-AG', 'W-14-0498-AG'
 )
 order by WL413_fine_sample_id desc, WL413_fine_group_nbr, WL413_fine_segment_nbr
 ;





/***********************************************************************************

 WL413 Sieve Analysis, Field Method 
 
 from MTest, Lt_WL413_BC.cpp
 ---------------------------
 
 int LtWL413_BC::iniMtmSpecific(const char *szmtm)
 {
   _cordaRoot->getExternalData(true);
   // get DL907 data
   _accDL907 = new ExtAccessDL907_BC(_smpl, rqtrans);
   // the Results table (DL907 data) is not part of WL411 data, and is not in the WL411 MTM map
 
 
 int LtWL413_BC::CorGrpRoot::getExternalData(bool initial)
 {
   // Get raw gradation data (from WL640), and display in appropriate fields
   
 
 void LtWL413_BC::CorGrpRoot::doCalcs()
 {
   // do full or abridged R-10 calculations
   bool isFullR10 = ! getMtm()->getUnitSettings()->isabridged(); // if not abridged, then full

 from MTest, External Dependencies, lmtmSpec400_D8.h
 ---------------------------------------------------
   UnitSettingsWL413_BC();
   bool ismetric_sv(){ return m_sz[us_xsv] == 'M'; }
   bool isabridged() { return (m_sz[us_xabridged] == 'A'); }
   void setMetricSv(bool v){ m_sz[us_xsv] = v? 'M' : 'C'; }
   void setAbridged(bool v){ m_sz[us_xabridged] = v? 'A' : 'C'; }
 
 
 from lmtmspec_D8.sln, lmtmSpec400_D8.h
 ---------------------------------------------------
 UNITSTRING:
 [0] C = customary; M = metric sieves
 [1] C = Complete analysis; A: abridged analysis
    
  CustomaryOrMetric
 -----------------
                   Sieve units   R10 Analysis
 W-18-0077-AG |CC| customary     complete
 W-07-0183-AG |MC| metric        complete <-- most recent occurrence of metric

                    
***********************************************************************************/


create or replace view V_WL413_R10_Sieve_Analysis_Field_Method as 

with v_wl640 as ( -- WL640 summation values

     -- WL640 is the source of the coarse sieves, and CPan (coarse pan, the Fines, #4-) as well
     -- Use a single segment, otherwise, a cartesian join will result, and what a mess that would be
    
         select  WL640_Sample_ID
                ,WL640_mass_of_fines -- #4-
                ,WL640_Mass_Total    -- step 1
                ,WL640_mass_retained_summ_coarse as WL640_summ_coarse
           from  V_WL640_Prep_Raw_Gradation
          where  WL640_segment_nbr = 1
)

,summation_sql as ( -- WL413 Fine segment summation values

     select  sample_id as sample_id
            ,sum(case when mass_fine_washed_aggregate >= 0 then mass_fine_washed_aggregate else 0 end) as mass_fine_washed_agg_summation
            ,sum(case when mass_fine_dry_aggregate    >= 0 then mass_fine_dry_aggregate    else 0 end) as mass_fine_dry_agg_summation
       from Test_WL413_segments
      group by sample_id
)

/*----------------------------------------------------------------------------
  main SQL
----------------------------------------------------------------------------*/

select  wl413.sample_id                                        as WL413_Sample_ID
       ,wl413.sample_year                                      as WL413_Sample_Year
       
       ,wl413.test_status                                      as WL413_Test_Status
       ,wl413.tested_by                                        as WL413_Tested_by
       
       ,case when to_char(wl413.date_tested, 'yyyy') = '1959'  then ' '
             else to_char(wl413.date_tested, 'mm/dd/yyyy')     end
                                                               as WL413_date_tested
            
       ,wl413.date_tested                                      as WL413_date_tested_DATE
       ,wl413.date_tested_orig                                 as WL413_date_tested_orig
       
       ,wl413.customary_metric                                 as WL413_customary_metric
       
       /*----------------------------------------------------------------------------
         WL640 summation values
         step 2 lists the WL640 coarse sieves, and is not performed here
       ----------------------------------------------------------------------------*/
       
       ,case when v_wl640.WL640_summ_coarse   is not null then v_wl640.WL640_summ_coarse   else -1 end as WL640_step3_summ_coarse
       ,case when v_wl640.WL640_mass_of_fines is not null then v_wl640.WL640_mass_of_fines else -1 end as WL640_step3_mass_fines_nbr4minus
       ,case when v_wl640.WL640_Mass_Total    is not null then v_wl640.WL640_Mass_Total    else -1 end as WL640_step3_Mass_Total -- this is also step1
       
       /*----------------------------------------------------------------------------
         Moisture determination, Coarse - steps 4, 8, 9, 10
       ----------------------------------------------------------------------------*/
       
       ,moisture_coarse_mass_wet_agg                           as WL413_step4_moisture_coarse_mass_wet_agg
       ,moisture_coarse_mass_dry_agg                           as WL413_step8_moisture_coarse_mass_dry_agg
       ,step9_moisture_coarse_wt_of_water                      as WL413_step9_moisture_coarse_wt_of_water
       ,step10_coarse_pct_moisture                             as WL413_step10_coarse_pct_moisture
       
       /*----------------------------------------------------------------------------
         Moisture determination, Fine - steps 6, 11, 12, 13
       ----------------------------------------------------------------------------*/
       
       ,moisture_fine_mass_wet_agg                             as WL413_step6_moisture_fine_mass_wet_agg
       ,moisture_fine_mass_dry_agg                             as WL413_step11_moisture_fine_mass_dry_agg
       ,step12_moisture_fine_wt_of_water                       as WL413_step12_moisture_fine_wt_of_water
       ,step13_fine_pct_moisture                               as WL413_step13_fine_pct_moisture
       
       /*----------------------------------------------------------------------------
         P-200 Wash, Coarse - steps 5, 14, 15, 16
       ----------------------------------------------------------------------------*/
       
       ,p200_coarse_mass_wet_agg                               as WL413_step5_p200_wash_coarse_mass_wet_agg
       ,step14a_coarse_factor                                  as WL413_step14a_p200_wash_coarse_factor
       ,step14b_coarse_wt_dry_agg                              as WL413_step14b_p200_wash_coarse_wt_dry_agg
       ,p200_coarse_mass_dry_agg                               as WL413_step15_p200_wash_coarse_mass_washed_dry_agg
       ,step16_p200_wash_coarse_wt_of_p200                     as WL413_step16_p200_wash_coarse_wt_of_p200
       
       /*----------------------------------------------------------------------------
         P-200 Wash, Fine - steps 7, 17, 18, 19
       ----------------------------------------------------------------------------*/
       
       ,p200_fine_mass_wet_agg                                 as WL413_step7_p200_wash_fine_mass_wet_agg
       ,step17a_fine_factor                                    as WL413_step17a_p200_wash_fine_factor
       ,step17b_fine_wt_dry_agg                                as WL413_step17b_p200_wash_fine_wt_dry_agg
       ,p200_fine_mass_dry_agg                                 as WL413_step18_p200_wash_fine_mass_washed_dry_agg
       ,step19_p200_wash_fine_wt_of_p200                       as WL413_step19_p200_wash_fine_wt_of_p200
       
       /*----------------------------------------------------------------------------
         WL413 fine segments, summation
       ----------------------------------------------------------------------------*/
       
       ,case when summation_sql.mass_fine_washed_agg_summation is not null 
             then summation_sql.mass_fine_washed_agg_summation else -1 end 
             as WL413_mass_fine_washed_agg_dry_wt_summation -- step27, in summation form
        
       ,case when summation_sql.mass_fine_dry_agg_summation    is not null 
             then summation_sql.mass_fine_dry_agg_summation    else -1 end 
             as WL413_mass_fine_dry_wt_summation            -- step35, in summation form
       
       /*----------------------------------------------------------------------------
         Fine Pan
       ----------------------------------------------------------------------------*/
       
       ,case when wl413.mass_pan_fine_washed >= 0 then wl413.mass_pan_fine_washed else -1 end as WL413_mass_pan_fine_washed
       ,case when wl413.mass_pan_fine_dry    >= 0 then wl413.mass_pan_fine_dry    else -1 end as WL413_mass_pan_fine_dry
       
       /*----------------------------------------------------------------------------
         step20b  dry wt coarse = (WL640_summ_coarse / step14a_coarse_factor)
         step21b  dry wt #4-    = (WL640_mass_of_fines / step17a_fine_factor)
         step22   dry wt total  = (step20b + step21b)
         step23a  pct_factor    = (step22_dry_wt_total / 100)
         step24   check_to_equal_100 = (step22_dry_wt_total / step23a_pct_factor)
       ----------------------------------------------------------------------------*/
       
       ,step20b_dry_wt_coarse_summ                             as WL413_step20b_dry_wt_coarse_summ
       ,step21b_dry_wt_Nbr4_minus                              as WL413_step21b_dry_wt_Nbr4_minus
       ,step22_dry_wt_total                                    as WL413_step22_dry_wt_total
       ,step23a_pct_factor                                     as WL413_step23a_pct_factor
       ,step24_check_to_equal_100                              as WL413_step24_check_to_equal_100
       
       ,wl413.remarks                                          as WL413_Remarks
       
       /*----------------------------------------------------------------------------
         table relationships
       ----------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_WL413                                   wl413 on wl413.sample_id = smpl.sample_id 
       left join v_wl640                                       on wl413.sample_id = v_wl640.WL640_Sample_ID
       left join summation_sql                                 on wl413.sample_id = summation_sql.sample_id 
       
       /*----------------------------------------------------------------------------
         Moisture determination, Coarse
       ----------------------------------------------------------------------------*/
       
       -- step 9, (step 4 - step 8)
       cross apply (select case 
                           when (moisture_coarse_mass_wet_agg >= moisture_coarse_mass_dry_agg and moisture_coarse_mass_dry_agg > 0)
                           then (moisture_coarse_mass_wet_agg - moisture_coarse_mass_dry_agg)
                           else -1 end as step9_moisture_coarse_wt_of_water from dual) step9
       
       -- step 10, ((step 9 / step 8) * 100)
       cross apply (select case 
                           when ( step9_moisture_coarse_wt_of_water > 0 and moisture_coarse_mass_dry_agg > 0)
                           then ((step9_moisture_coarse_wt_of_water / moisture_coarse_mass_dry_agg) * 100)
                           else -1 end as step10_coarse_pct_moisture from dual) step10
       
       /*----------------------------------------------------------------------------
         Moisture determination, Fine
       ----------------------------------------------------------------------------*/
       
       -- step 12, (step 6 - step 11)
       cross apply (select case 
                           when (moisture_fine_mass_wet_agg >= moisture_fine_mass_dry_agg and moisture_fine_mass_dry_agg > 0)
                           then (moisture_fine_mass_wet_agg - moisture_fine_mass_dry_agg)
                           else -1 end as step12_moisture_fine_wt_of_water from dual) step12
  
       -- step 13, ((step 12 / step 11) * 100)
       cross apply (select case 
                           when ( step12_moisture_fine_wt_of_water > 0 and moisture_fine_mass_dry_agg > 0) 
                           then ((step12_moisture_fine_wt_of_water / moisture_fine_mass_dry_agg) * 100)
                           else -1 end as step13_fine_pct_moisture from dual) step13
   
       /*----------------------------------------------------------------------------
         P-200 Wash, Coarse
       ----------------------------------------------------------------------------*/
  
       -- step 14a, ((step10 + 100) / 100))
       cross apply (select case when  step10_coarse_pct_moisture > 0 then ((step10_coarse_pct_moisture + 100) * 0.01)
                                else -1 end as step14a_coarse_factor from dual) step14a
  
       -- step 14b, (step 5 / step14a) -- coarse wt_of_dry_agg
       cross apply (select case when (p200_coarse_mass_wet_agg > 0 and step14a_coarse_factor > 0) 
                                then (p200_coarse_mass_wet_agg / step14a_coarse_factor)
                                else -1 end as step14b_coarse_wt_dry_agg from dual) step14b
  
       -- step 16, (step14b - step 15)
       cross apply (select case when (step14b_coarse_wt_dry_agg > p200_coarse_mass_dry_agg and p200_coarse_mass_dry_agg > 0) 
                                then (step14b_coarse_wt_dry_agg - p200_coarse_mass_dry_agg)
                                else -1 end as step16_p200_wash_coarse_wt_of_p200 from dual) step16
  
       /*----------------------------------------------------------------------------
         P-200 Wash, Fine
       ----------------------------------------------------------------------------*/
       
       -- step 17a, ((step13 + 100) / 100))
       cross apply (select case when  step13_fine_pct_moisture > 0 then ((step13_fine_pct_moisture + 100) * 0.01) 
                                else -1 end as step17a_fine_factor from dual) step17a
  
       -- step 17b, (step 7 / step17a) -- fine wt_of_dry_agg
       cross apply (select case when (p200_fine_mass_wet_agg > 0 and step17a_fine_factor > 0) 
                                then (p200_fine_mass_wet_agg / step17a_fine_factor) 
                                else -1 end as step17b_fine_wt_dry_agg from dual) step17b
  
       -- step 19, (step17b - step 18)
       cross apply (select case when (step17b_fine_wt_dry_agg > p200_fine_mass_dry_agg and p200_fine_mass_dry_agg > 0) 
                                then (step17b_fine_wt_dry_agg - p200_fine_mass_dry_agg) 
                                else -1 end as step19_p200_wash_fine_wt_of_p200 from dual) step19
  
       /*----------------------------------------------------------------------------
         step20a  is the same as step14a_coarse_factor, so why recalculate?
         step20b  dry wt coarse = (WL640_summ_coarse / step14a_coarse_factor)
         step21a  is the same as step17a_fine_factor, so why recalculate?
         step21b  dry wt fines  = (WL640_mass_of_fines / step17a_fine_factor)
         step22   dry wt total  = (step20b + step21b)
         step23a  pct_factor    = (step22_dry_wt_total / 100)
         step24   check_to_equal_100 = (step22_dry_wt_total / step23a_pct_factor)
       ----------------------------------------------------------------------------*/
       
       -- step 20b
       cross apply (select case when (v_wl640.WL640_summ_coarse > 0 and step14a_coarse_factor > 0)
                                then (v_wl640.WL640_summ_coarse / step14a_coarse_factor)
                                else -1 end as step20b_dry_wt_coarse_summ from dual) step20b
       
       -- step 21b
       cross apply (select case when (v_wl640.WL640_mass_of_fines > 0 and step17a_fine_factor > 0)
                                then (v_wl640.WL640_mass_of_fines / step17a_fine_factor)
                                else -1 end as step21b_dry_wt_Nbr4_minus from dual) step21b
       
       -- step 22
       cross apply (select case when (step20b_dry_wt_coarse_summ > 0 and step21b_dry_wt_Nbr4_minus > 0)
                                then (step20b_dry_wt_coarse_summ + step21b_dry_wt_Nbr4_minus)
                                else -1 end as step22_dry_wt_total from dual) step22
       
       -- step 23a
       cross apply (select case when (step22_dry_wt_total > 0) then (step22_dry_wt_total * 0.01) else -1 end 
                    as step23a_pct_factor from dual) step23a
       
       -- step 24
       cross apply (select case when (step22_dry_wt_total > 0 and step23a_pct_factor > 0) 
                                then (step22_dry_wt_total / step23a_pct_factor) 
                                else -1 end as step24_check_to_equal_100 from dual) step24
  ;
 
 







/***********************************************************************************

 V_WL413_Sieve_Analysis_pct_passing_grid

***********************************************************************************/

create or replace view V_WL413_R10_Sieve_Analysis_pct_passing_grid as 

select  WL413_COARSE_SAMPLE_ID                          as sample_id
       ,WL413_COARSE_GROUP_NBR                          as group_nbr
       ,WL413_COARSE_SEGMENT_NBR                        as segment_nbr
       ,WL413_COARSE_STEP2_SIEVE_SIZE                   as sieve_size
       ,WL413_COARSE_step25_pct_passing_coarse          as pct_passing
       ,sieve_metric_in_mm                              as sieve_metric_in_mm
       
  from V_WL413_R10_Sieve_Analysis_pct_passing_coarse
 where sieve_metric_in_mm > 4.75 -- #4
 
 union
 
select  WL413_FINE_SAMPLE_ID                            as sample_id
       ,WL413_FINE_group_nbr                            as group_nbr
       ,WL413_FINE_segment_nbr                          as segment_nbr
       ,WL413_FINE_step26_sieve_size                    as sieve_size
       ,WL413_FINE_step43_pct_passing_fine              as pct_passing
       ,sieve_metric_in_mm                              as sieve_metric_in_mm
       
  from V_WL413_R10_Sieve_Analysis_pct_passing_fine
  
 order by 1,2,3
;









/***********************************************************************************

 V_WL413_Sieve_Analysis_pct_passing_coarse

***********************************************************************************/

create or replace view V_WL413_R10_Sieve_Analysis_pct_passing_coarse as 

/*----------------------------------------------------------------------------
  WL640 coarse sieves, preliminary SQL
----------------------------------------------------------------------------*/

with 
cumulative_sql as (select  sample_id    as sample_id
                          ,segment_nbr  as segment_nbr
                          
                          ,sum(case when mass_retained >= 0 then mass_retained else 0 end) 
                               over (partition by sample_id order by segment_nbr) as mass_ret_cumulative
                               
                     from  Test_WL640_segments
                   --where  sieve_size <> '#4-' -- exclude the fines
                    order  by sample_id, segment_nbr
)

,summation_sql as (select  sample_id as sample_id

                          -- summation_sql is included, but never used 
                          ,sum(case when mass_retained >= 0 then mass_retained else 0 end) as mass_ret_summation_coarse
                          
                     from  Test_WL640_segments 
                    where  sieve_size <> '#4-'  -- exclude the fines
                    group  by sample_id
)
             
/*----------------------------------------------------------------------------
  WL640 coarse sieves, main SQL
----------------------------------------------------------------------------*/

select  wl640seg.Sample_ID                                   as WL413_coarse_sample_id
       ,1                                                    as WL413_coarse_group_nbr
       ,wl640seg.segment_nbr                                 as WL413_coarse_segment_nbr
       ,wl640seg.sieve_size                                  as WL413_coarse_step2_sieve_size
         
       -- sieves, individual
       ,wl640seg.mass_retained                               as WL413_coarse_step3_mass_retained_wet_wt
       ,v_wl413.WL413_step14a_p200_wash_coarse_factor        as WL413_coarse_step14a_coarse_factor
       ,step20b_dry_wt                                       as WL413_coarse_step20b_dry_wt
       ,step23b_pct_retained                                 as WL413_coarse_step23b_pct_retained
         
       -- sieves, cumulative
       ,cumulative_sql.mass_ret_cumulative                   as WL413_coarse_step3_mass_retained_cumulative
       ,step20b_dry_wt_cumulative                            as WL413_coarse_step20b_dry_wt_cumulative
       ,step23b_pct_retained_cumulative                      as WL413_coarse_step23b_pct_retained_cumulative
         
       ,step25_pct_passing                                   as WL413_coarse_step25_pct_passing_coarse
       
       ,ss.sieve_customary                                   as sieve_customary
       ,ss.sieve_metric                                      as sieve_metric
       ,ss.sieve_metric_in_mm                                as sieve_metric_in_mm
       
       /*----------------------------------------------------------------------------
         table relationships
       ----------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                          smpl
           
       join V_WL413_R10_Sieve_Analysis_Field_Method  v_wl413 on v_wl413.WL413_Sample_ID = smpl.sample_id
           
       join Test_WL640_segments                     wl640seg on wl640seg.Sample_ID   = smpl.sample_id 
                                                          --and wl640seg.sieve_size <> '#4-'
       
       join cumulative_sql                                   on wl640seg.Sample_ID   = cumulative_sql.sample_id 
                                                            and wl640seg.segment_nbr = cumulative_sql.segment_nbr
       
       join summation_sql                                    on wl640seg.Sample_ID   = summation_sql.sample_id
       
       join mlt_sieve_size                                ss on wl640seg.sieve_size  = ss.sieve_customary 
                                                             or wl640seg.sieve_size  = ss.sieve_metric
           
       /*----------------------------------------------------------------------------
         mass_retained and pct_retained by segment
       ----------------------------------------------------------------------------*/
           
       cross apply (select case when (wl640seg.mass_retained > 0 and v_wl413.WL413_step14a_p200_wash_coarse_factor > 0)
                                then (wl640seg.mass_retained / v_wl413.WL413_step14a_p200_wash_coarse_factor)
                                else 0 end as step20b_dry_wt from dual) step20b
           
       cross apply (select case when (step20b_dry_wt > 0 and v_wl413.WL413_step23a_pct_factor > 0)
                                then (step20b_dry_wt / v_wl413.WL413_step23a_pct_factor)
                                else 0 end as step23b_pct_retained from dual) step23b
           
       /*----------------------------------------------------------------------------
         mass_retained cumulative and pct_retained cumulative
       ----------------------------------------------------------------------------*/
           
       cross apply (select case when (cumulative_sql.mass_ret_cumulative > 0 and v_wl413.WL413_step14a_p200_wash_coarse_factor > 0)
                                then (cumulative_sql.mass_ret_cumulative / v_wl413.WL413_step14a_p200_wash_coarse_factor)
                                else 0 end as step20b_dry_wt_cumulative from dual) step20b_cumulative
           
       cross apply (select case when (step20b_dry_wt_cumulative > 0 and v_wl413.WL413_step23a_pct_factor > 0)
                                then (step20b_dry_wt_cumulative / v_wl413.WL413_step23a_pct_factor)
                                else 0 end as step23b_pct_retained_cumulative from dual) step23b_cumulative
           
       /*----------------------------------------------------------------------------
         percent passing is calculated using the pct_retained_cumulative
       ----------------------------------------------------------------------------*/
           
       cross apply (select (100 - step23b_pct_retained_cumulative) as step25_pct_passing from dual) step25
       
       order by wl640seg.Sample_ID, wl640seg.segment_nbr
       ;









/***********************************************************************************

 V_WL413_Sieve_Analysis_pct_passing_fine
 
 This View displays the Fine washed and dry aggregate grid (the fine segments),
 as well as producing the Fine values for the percent passing grid

***********************************************************************************/

create or replace view V_WL413_R10_Sieve_Analysis_pct_passing_fine as 

/*----------------------------------------------------------------------------
  WL413 fine sieves, preliminary SQL
----------------------------------------------------------------------------*/
 
with 
cumulative_sql as (select  sample_id    as sample_id
                          ,segment_nbr  as segment_nbr
                          
                          ,sum(case when mass_fine_washed_aggregate >= 0 then mass_fine_washed_aggregate else 0 end) 
                               over (partition by sample_id order by sample_id, segment_nbr) as mass_fine_washed_cumulative
                               
                          ,sum(case when mass_fine_dry_aggregate    >= 0 then mass_fine_dry_aggregate    else 0 end) 
                               over (partition by sample_id order by sample_id, segment_nbr) as mass_fine_dry_cumulative
                               
                     from  Test_WL413_segments
                    order  by sample_id, segment_nbr
)

,summation_sql as (select  sample_id as sample_id
                          ,sum(case when mass_fine_washed_aggregate >= 0 then mass_fine_washed_aggregate else 0 end) as mass_fine_washed_summation
                          ,sum(case when mass_fine_dry_aggregate    >= 0 then mass_fine_dry_aggregate    else 0 end) as mass_fine_dry_summation
                          
                     from  Test_WL413_segments 
                    group  by sample_id
)

/*----------------------------------------------------------------------------
  WL413 fine sieves, main SQL
----------------------------------------------------------------------------*/

select  wl413seg.Sample_ID                                      as WL413_fine_sample_id
       ,2                                                       as WL413_fine_group_nbr
       ,wl413seg.segment_nbr                                    as WL413_fine_segment_nbr
       
       /*----------------------------------------------------------------------------
         sieves, P200 fine washed aggregate
       ----------------------------------------------------------------------------*/
       
       ,wl413seg.sieve_size                                     as WL413_fine_step26_sieve_size
       ,wl413seg.mass_fine_washed_aggregate                           as WL413_fine_step27_mass_fine_washed_agg_dry_wt
       ,cumulative_sql.mass_fine_washed_cumulative              as WL413_fine_step27_mass_fine_washed_agg_cumulative
       ,summation_sql.mass_fine_washed_summation                as WL413_fine_step27_mass_fine_washed_agg_summation
       
       ,v_wl413.WL413_mass_pan_fine_washed                      as WL413_fine_step28a_mass_pan_fine_washed
       ,v_wl413.WL413_step16_p200_wash_coarse_wt_of_p200        as WL413_fine_step28b_step16_wt_of_p200
       ,step29_total_p200                                       as WL413_fine_step29_total_p200              -- step28a + step28b
       ,step30_original_dry_wt                                  as WL413_fine_step30_original_dry_wt         -- step27 summation + step28a + step28b
       ,v_wl413.WL413_step14b_p200_wash_coarse_wt_dry_agg       as WL413_fine_step14_check_of_step30         -- ....not getting an exact match
       
       ,step31_factor                                           as WL413_fine_step31_factor                  -- step30_original_dry_wt / 100
       ,step31_pct_retained_washed                              as WL413_fine_step31_pct_retained_washed     -- washed sieve / step31_factor
       ,step31_pct_retained_summ                                as WL413_fine_step31_pct_retained_summation  -- mass_fine_washed_summation / step31_factor
       ,step31_pct_retained_total_p200                          as WL413_fine_step31_pct_retained_total_p200 -- step29 / step31_factor
       ,step32_pct_retained_total                               as WL413_fine_step32_pct_retained_total      -- step31summ + step31totalP200 (equals 100)
       
       ,step33_pct_retained_cum                                 as WL413_fine_step33_pct_retained_cumulative -- mass_fine_washed_cumulative / step31_factor
       ,step33_pct_passing                                      as WL413_fine_step33_pct_passing             -- 100 - step33_pct_retained_cum
       
       ,v_coarse.WL413_coarse_step25_pct_passing_coarse         as WL413_fine_step34_pct_passing_coarse_nbr4 -- from the coarse sieves
       
       ,step34_adj_pct_passing_factor                           as WL413_fine_step34_adj_pct_passing_factor  -- (100 - step25 pct_passing_nbr4) * 0.01
       ,step34_adj_pct_passing                                  as WL413_fine_step34_adj_percent_passing     -- step33_pct_passing * adj_factor
       
       /*----------------------------------------------------------------------------
         sieves, P200 fine dry aggregate
       ----------------------------------------------------------------------------*/
       
       ,wl413seg.sieve_size                                     as WL413_fine_step26_sieve_size2
       ,wl413seg.mass_fine_dry_aggregate                              as WL413_fine_step35_mass_fine_dry_agg_dry_wt
       ,cumulative_sql.mass_fine_dry_cumulative                 as WL413_fine_step35_mass_fine_dry_agg_cumulative
       ,summation_sql.mass_fine_dry_summation                   as WL413_fine_step35_mass_fine_dry_agg_summation
       
       ,v_wl413.WL413_mass_pan_fine_dry                         as WL413_fine_step36a_mass_pan_fine_dry
       ,v_wl413.WL413_step19_p200_wash_fine_wt_of_p200          as WL413_fine_step36b_step19_wt_of_p200
       ,step37_total_p200                                       as WL413_fine_step37_total_p200              -- step36a + step36b
       ,step38_original_dry_wt                                  as WL413_fine_step38_original_dry_wt         -- step35 summation + step36a + step36b
       ,v_wl413.WL413_step17b_p200_wash_fine_wt_dry_agg         as WL413_fine_step17_check_of_step38         -- very close, better than step14 check of step30
       
       ,step39_factor                                           as WL413_fine_step39_factor                  -- step38_original_dry_wt / 100       
       ,step39_pct_retained_dry                                 as WL413_fine_step39_pct_retained_dry        -- dry sieve / step39_factor       
       ,step39_pct_retained_summ                                as WL413_fine_step39_pct_retained_summation  -- mass_fine_dry_summation / step39_factor
       ,step39_pct_retained_total_p200                          as WL413_fine_step39_pct_retained_total_p200 -- step37 / step39_factor
       ,step40_pct_retained_total                               as WL413_fine_step40_pct_retained_total      -- step35summ + step39totalP200 (equals 100)
       
       ,step41_pct_retained_cum                                 as WL413_fine_step41_pct_retained_cumulative -- mass_fine_dry_cumulative / step39_factor
       ,step41_pct_passing                                      as WL413_fine_step41_pct_passing             -- 100 - step41_pct_retained_cum
        
       ,step42_adj_pct_passing_factor                           as WL413_fine_step42_adj_pct_passing_factor  -- step25 pct_passing_nbr4 * 0.01
       ,step42_adj_pct_passing                                  as WL413_fine_step42_adj_percent_passing     -- step41_pct_passing * adj_factor
       
       /*----------------------------------------------------------------------------
         percent passing, fine sieves
       ----------------------------------------------------------------------------*/
       
       ,step43_pct_passing                                      as WL413_fine_step43_pct_passing_fine        -- this is the one
       
       ,ss.sieve_customary                                      as sieve_customary
       ,ss.sieve_metric                                         as sieve_metric
       ,ss.sieve_metric_in_mm                                   as sieve_metric_in_mm
       
       /*----------------------------------------------------------------------------
         table relationships
       ----------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                             smpl
       
       join V_WL413_R10_Sieve_Analysis_Field_Method     v_wl413 on v_wl413.WL413_Sample_ID = smpl.sample_id
       
       join Test_WL413_segments                        wl413seg on v_wl413.WL413_Sample_ID = wl413seg.sample_id
       
       join cumulative_sql                                      on wl413seg.Sample_ID      = cumulative_sql.sample_id 
                                                               and wl413seg.segment_nbr    = cumulative_sql.segment_nbr
                                                            
       join summation_sql                                       on wl413seg.Sample_ID      = summation_sql.sample_id
       
       join V_WL413_R10_Sieve_Analysis_pct_passing_coarse
                                                       v_coarse on wl413seg.Sample_ID      = v_coarse.WL413_coarse_sample_id
                                                               and v_coarse.WL413_coarse_step2_sieve_size = '#4'
       
       join mlt_sieve_size                                   ss on wl413seg.sieve_size     = ss.sieve_customary 
                                                                or wl413seg.sieve_size     = ss.sieve_metric
       
       /*----------------------------------------------------------------------------
          calculations, P200 fine washed aggregate
       ----------------------------------------------------------------------------*/
       
       -- step28a + step28b (28b is step16)
       cross apply (select (case when v_wl413.WL413_mass_pan_fine_washed >= 0 
                                 then v_wl413.WL413_mass_pan_fine_washed else 0 end)
                         + (case when v_wl413.WL413_step16_p200_wash_coarse_wt_of_p200 >= 0 
                                 then v_wl413.WL413_step16_p200_wash_coarse_wt_of_p200 else 0 end)
       as step29_total_p200 from dual) step29
       
       cross apply (select (case when summation_sql.mass_fine_washed_summation >= 0 
                                 then summation_sql.mass_fine_washed_summation else 0 end)
                         + (case when step29_total_p200 >= 0 then step29_total_p200 else 0 end)
       as step30_original_dry_wt from dual) step30
       
       cross apply (select (step30_original_dry_wt * 0.01)                                  as step31_factor                  from dual) step31factor
       
       cross apply (select (wl413seg.mass_fine_washed_aggregate / step31_factor)                  as step31_pct_retained_washed     from dual) step31
       
       cross apply (select (summation_sql.mass_fine_washed_summation / step31_factor)       as step31_pct_retained_summ       from dual) step31summ
       
       cross apply (select (step29_total_p200 / step31_factor)                              as step31_pct_retained_total_p200 from dual) step31p200
       
       cross apply (select (step31_pct_retained_summ + step31_pct_retained_total_p200)      as step32_pct_retained_total      from dual) step32
       
       cross apply (select (cumulative_sql.mass_fine_washed_cumulative / step31_factor)     as step33_pct_retained_cum        from dual) step33cum
       
       cross apply (select (100 - step33_pct_retained_cum)                                  as step33_pct_passing             from dual) step33pass
       
       cross apply (select ((100 - v_coarse.WL413_coarse_step25_pct_passing_coarse) * 0.01) as step34_adj_pct_passing_factor  from dual) step34factor
       
       cross apply (select (step33_pct_passing * step34_adj_pct_passing_factor)             as step34_adj_pct_passing         from dual) step34pctpass
       
       /*----------------------------------------------------------------------------
          calculations, P200 fine dry aggregate
       ----------------------------------------------------------------------------*/
       
       -- step36a + step36b (36b is step19)
       cross apply (select (case when v_wl413.WL413_mass_pan_fine_dry >= 0 
                                 then v_wl413.WL413_mass_pan_fine_dry else 0 end) 
                         + (case when v_wl413.WL413_step19_p200_wash_fine_wt_of_p200 >= 0 
                                 then v_wl413.WL413_step19_p200_wash_fine_wt_of_p200 else 0 end)
       as step37_total_p200 from dual) step37
       
       cross apply (select (case when summation_sql.mass_fine_dry_summation >= 0 
                                 then summation_sql.mass_fine_dry_summation else 0 end) 
                         + (case when step37_total_p200 >= 0 then step37_total_p200 else 0 end)
       as step38_original_dry_wt from dual) step38
       
       cross apply (select (step38_original_dry_wt * 0.01)                                  as step39_factor                  from dual) step39factor
       
       cross apply (select (wl413seg.mass_fine_dry_aggregate / step39_factor)                     as step39_pct_retained_dry        from dual) step39
       
       cross apply (select (summation_sql.mass_fine_dry_summation / step39_factor)          as step39_pct_retained_summ       from dual) step39summ
       
       cross apply (select (step37_total_p200 / step39_factor)                              as step39_pct_retained_total_p200 from dual) step39p200
       
       cross apply (select (step39_pct_retained_summ + step39_pct_retained_total_p200)      as step40_pct_retained_total      from dual) step40
       
       cross apply (select (cumulative_sql.mass_fine_dry_cumulative / step39_factor)        as step41_pct_retained_cum        from dual) step41cum
       
       cross apply (select (100 - step41_pct_retained_cum)                                  as step41_pct_passing             from dual) step41pass
       
       cross apply (select (v_coarse.WL413_coarse_step25_pct_passing_coarse * 0.01)         as step42_adj_pct_passing_factor  from dual) step42factor
       
       cross apply (select (step41_pct_passing * step42_adj_pct_passing_factor)             as step42_adj_pct_passing         from dual) step42pctpass
       
       /*----------------------------------------------------------------------------
          percent passing, fine sieves
       ----------------------------------------------------------------------------*/
       
       cross apply (select (step34_adj_pct_passing + step42_adj_pct_passing)                as step43_pct_passing             from dual) step43pctpass
       
       order by wl413seg.Sample_ID,wl413seg.segment_nbr
       ;
 
 
 
 
 




----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_WL413 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 8108	    1986	2020



   select sample_year, count(sample_year) from test_wl413
 group by sample_year
 order by sample_year desc
 ;
/**

2020	98
2019	132
2018	168
2017	259
2016	110
2015	186
2014	78
2013	117
2012	223
2011	195
2010	147
2009	161
2008	305
2007	209
2006	153
2005	227
2004	192
2003	254
2002	344
2001	378
2000	317
1999	253
1998	194
1997	277
1996	204
1995	432
1994	281
1993	285
1992	272
1991	436
1990	420
1989	414
1988	232
1987	94
1986	61
1960	2

**/




select customary_metric, count(customary_metric) 
  from test_wl413
 group by customary_metric
 order by customary_metric
 ;
/** 

 [0] C = customary; M = metric sieves
 [1] C = Complete analysis; A = abridged analysis --- not one is an 'abridged R10 Analysis' 

 ' '  	4497
 CC	    3598
 MC	      15

**/




-- find headers without segments
select hdr.sample_id from test_wl413 hdr
 where hdr.sample_id not in (select seg.sample_id from test_wl413_segments seg
                              where seg.sample_id = hdr.sample_id)
;
-- 81 samples without segments




-- find segments without headers (none should be found)
select seg.sample_id from test_wl413_segments seg
 where seg.sample_id not in (select hdr.sample_id from test_wl413 hdr
                              where hdr.sample_id = seg.sample_id)
;
-- none found







/**

void LtWL413_BC::CorGrpRoot::doCalcs()
{
   // do full or abridged R-10 calculations

   enum
   {            // indices to specific binary data (adata)
      xMCwet,   // Moisture: Coarse wet agg
      xMFwet,   // Moisture: Fine wet agg
      xMCdry,   // Moisture: Coarse dry agg
      xMFdry,   // Moisture: Fine dry agg
      xCpan,    // coarse pan
      xWCwet,   // P-200 wash: coarse wet agg
      xWFwet,   // P-200 wash: fine wet agg
      xWCdry,   // P-200 wash: coarse washed dry agg
      xWFdry,   // P-200 wash: fine washed dry agg
      xFpanW,   // Fines: washed pan
      xFpanD,   // Fines: dry pan
      nData
   };

   array<SvRowVals>^   aGradRows = nullptr;
   array<SvRowVals>^   aCseRows  = nullptr;
   array<FineRowVals>^ aFineRows = nullptr;

   // coarse sieves – load an array of coarse sieves

   CorTblNum^ tblCse = getTblCse();
   nrcse = tblCse->nTrimmedRows();

   if( nrcse > 0 )
   {
      //  "+ 1": will add the Cpan to this group
      aCseRows = gcnew array<SvRowVals>(nrcse + 1);

      for( xr = 0; xr < nrcse; ++xr )
      {
         aCseRows[xr].sv  =  
         aCseRows[xr].val =  
      }

      if( aCseRows[nrcse-1].sv == SV_NR4 )
      {
         // add coarse pan to coarse sieve table
         aCseRows[nrcse].sv  = 0.0;  // pan
         aCseRows[nrcse].val = adata[xCpan];
         nrcse++;
      }
   }

   // fine sieves – load an array of fine sieves

   CorTblNum^ tblFine = getTblFines();
   nrfine = tblFine->nTrimmedRows();

   if( nrfine > 0 )
   {
      aFineRows = gcnew array<FineRowVals>(nrfine);

      for( xr = 0; xr < nrfine; ++xr )
	  {
         aFineRows[xr].sv     =  
         aFineRows[xr].washed =  
         aFineRows[xr].dry    =  
      }

      if( aFineRows[0].sv != SV_NR4 )  // the #4 sieve seems to be a marker, only,
      {                                // and should be [0], else error
         // print error
      }

	  else if( aFineRows[0].dry != 0.0 ) // dry[0] should be 0 mass, else error
	  {
         // print error
      }
   } 

   ngrad = nrcse + nrfine; // nrcse includes the coarse pan
   aGradRows = gcnew array<SvRowVals>(ngrad);

   for( x = 0; x < ngrad; ++x )
   {
      aGradRows[x].sv = 0.0;
   }

   cmoist = 1.0 + (adata[xMCwet] - adata[xMCdry]) / adata[xMCdry]; 
   fmoist = 1.0 + (adata[xMFwet] - adata[xMFdry]) / adata[xMFdry];

   // coarse sieves: convert wet wts to dry wts, get total
   fnum = 0.0;

   for( xr = 0; xr < nrcse; xr++ )             // nrcse includes the coarse pan 
   {
      if( aCseRows[xr].sv >= SV_NR4 )
      {
         aCseRows[xr].val /= cmoist;   // WL640_summ_coarse / cmoist
      }
      else
      { // the cpan (fines) 
       Debug::Assert( xr == nrcse-1 && aCseRows[xr].sv == 0.0 );
       aCseRows[xr].val /= fmoist;   // mass_dry_wt_fines = (WL640_mass_of_fines / fmoist)
      }

      fnum += aCseRows[xr].val;        // fnum1, WL413_mass_dry_wt_total
   }

   // convert dry weights retained to percents retained

   fnum = 100.0 / fnum;                // pct_retained_factor, I guess

   for( xr = 0; xr < nrcse; ++xr )
   {
      aCseRows[xr].val *= fnum;        // *= fnum2, pct_retained_factor
   }                                   // pct_retained = val * pct_retained_factor

   // convert to % passing > #4 into results; #4 is saved
   // convert percents retained to percents passing
   // Only coarse % passing > #4 will be output; #4 will be used to set pass4 variable

   fnum = 100.0;
   for( xg = 0; xg < nrcse; ++xg )
   {
      aGradRows[xg].sv = aCseRows[xg].sv;
      aGradRows[xg].val = fnum - aCseRows[xg].val; // pct_passing
      fnum = aGradRows[xg].val;

      if( aGradRows[xg].sv <= SV_NR4 )
	  {
         if( aGradRows[xg].sv == SV_NR4 )
         {
            pass4 = aGradRows[xg].val;  // save %passing #4
         }
      }
   }

   if( isFullR10 )
   {
      double wetwt, drywt, wetret; 

      // get total P200 weights
      fnum = adata[xFpanW] + adata[xWCwet]/cmoist - adata[xWCdry]; -- wetwt
      wetwt = fnum;                                                -- wetwt

      for( x = 0; x < nrfine; x++ )
      {
         Debug::Assert( aFineRows[x].sv > 0.0 );
         wetwt += aFineRows[x].washed;   // fnum + summation of fine washed agg
      }                                  -- wetwt_and_summ_washed = wetwt + mass_fine_washed_summation

      // convert wet weights to decimal percents retained
      wetret = fnum / wetwt;             -- wetret = wetwt / wetwt_and_summ_washed

      for( x = 0; x < nrfine; x++ )
      {
         aFineRows[x].washed /= wetwt;   -- pct_ret[x] = (fine[x]wash / wetwt_and_summ_washed) 

         wetret += aFineRows[x].washed;  -- wetret + pct_ret[x] 
                                            wetret + (summ_washed / wetwt_and_summ_washed)
      }                                   = wetret_and_pct_ret_summ 


      drywt = adata[xFpanD] + adata[xWFwet]/fmoist - adata[xWFdry];
            = (mass_fine_dry_pan + (fine_mass_wet_agg / fmoist) - fine_mass_dry_agg)

      fnum = wetret;                     -- wetret_and_pct_ret_summ 


      // convert wet percent retained to percent passing

      for( x = 0; x < nrfine; x++ )
      {
         fnum -= aFineRows[x].washed;    -- wetret_and_pct_ret_summ -= pct_ret[x] or, 
         aFineRows[x].washed = fnum;     -- wetret_and_pct_ret_summ -= cumulative 
                                         -- pct_passing_washed (decimal)

         drywt += aFineRows[x].dry;      -- drywt_and_summ_dry
      }

      // convert dry wts to decimal % retained; convert these to %passing 

      fnum = wetret;                     -- wetret_and_pct_ret_summ 

      for( x = 0; x < nrfine; x++ )
      {
         fnum -= aFineRows[x].dry/drywt;
         aFineRows[x].dry = fnum;
      }

      fnum = 100.0 - pass4;

      for( x = 0; x < nrfine; x++ )
      {
         aGradRows[xg].sv = aFineRows[x].sv;
         aGradRows[xg].val = aFineRows[x].washed * fnum + aFineRows[x].dry * pass4;
         ++xg;               pct_passing_washed
      }
   }

   else
   {   
      // abridged R-10
      szmethod = "Abridged Analysis";

      aFineRows[0].washed = 1.0;

      for( x = 1; x < nrfine; ++x ) 
      {
         aFineRows[x].washed = aFineRows[x-1].washed - aFineRows[x].dry/adata[xMFdry];
      }

      for( x = 0; x < nrfine; ++x )
      {
         aGradRows[xg].sv = aFineRows[x].sv;
         aGradRows[xg].val = aFineRows[x].washed*pass4;
         ++xg;
      }
   }

   // xg will probably be less than ngrad because of pan and duplicate #4
   Debug::Assert( xg <= ngrad );
}

**/








        
/**** false values for fine washed evaluation

W-90-1700-AG
Washed Dry not entered (probably 0)
does not contain a WL640 coarse sieve analysis. what is the source of the coarse sieves?
coarse data is from DL907, Sieve Analysis Results? or, the other way around?

W-93-0646-AG
would it be possible to switch Sieves and Washed?
does not contain a WL640 coarse sieve analysis. what is the source of the coarse sieves?
contains DL907, Sieve Analysis Results, stating Results generated by WL413


W-95-0516-AG
Sieves and Washed are switched, but Dry is > 0, so this will not matter
does not contain a WL640 coarse sieve analysis. what is the source of the coarse sieves?

****/






     
  

