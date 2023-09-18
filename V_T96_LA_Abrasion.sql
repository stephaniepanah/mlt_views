



select * from V_T96_LA_Abrasion order by T96_sample_year desc, T96_sample_id;



--------------------------------------------------------------------------------
-- some diagnostics
--------------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T96 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 2007	    1986	2021


select * from test_t96 order by sample_year desc, sample_id;



select sample_id, count(sample_id) from Test_T96_segments
 group by sample_id having count(sample_id) > 1;
 
 /*  two samples with more than one segment
 W-90-1157-AG	2
 W-88-2036-AG	2
 */
 



/*******************************************************************************

 T96 LA Abrasion (yes, Los Angeles)
 
 W-21-0164-AG, W-21-0740-AG, W-20-0043-AG, W-20-1055-AG
 W-19-0358-AG, W-19-0706-AG, W-18-0047-AG, W-18-0120-AG


 from MTest, Lt_T96_C2.cpp, void LtT96_C2::CorGrpRoot::calcMethod(int xrow)

 if (ini > 0.0 && finF >= 0.0 && finC >= 0.0)
 {
    wfinal = finC + finF; // finC is 1.70mm+, finF is 1.70mm- (essentially, coarse and fine)
    allowance = 0.01 * ini;

    if (ini + allowance < wfinal || ini - allowance > wfinal)
    {
        "Sum of 1.70mm+ and #1.70mm- are not within 1% of initial weight";
    }
    else
    {
        pctWear = 100.0*finF / ini;
    }
 }

 T96 number of steel balls are for each Grade:
 A = 12
 B = 11
 C = 8
 D = 6
 
 T96_segments, from MTest, Lt_T96_C2.cpp: 
 m113 ('A'), m180 ('B'), m181 ('C'), and m182 ('D')
 
    
*******************************************************************************/



create or replace view V_T96_LA_Abrasion as


select  t96.sample_id                                         as T96_Sample_ID
       ,t96.sample_year                                       as T96_sample_year
       ,t96.test_status                                       as T96_test_status
       ,t96.tested_by                                         as T96_tested_by
       
       ,case when to_char(t96.date_tested, 'yyyy') = '1959' then ' ' 
        else to_char(t96.date_tested, 'mm/dd/yyyy') end       as T96_date_tested
        
       ,t96.date_tested                                       as T96_date_tested_DATE
       ,t96.date_tested_orig                                  as T96_date_tested_orig
          
       ,t96.maximum_pct_wear_spec                             as T96_max_pct_wear_spec
       
       /*-----------------------------------------------------------------------
         segments
       -----------------------------------------------------------------------*/
       
       ,case when t96seg.segment_nbr      is not null then t96seg.segment_nbr      else  -1 end as T96_segment_nbr
       ,case when t96seg.grade            is not null then t96seg.grade            else ' ' end as T96_grade
       ,case when t96seg.mass_initial     is not null then t96seg.mass_initial     else  -1 end as T96_mass_initial
       ,case when t96seg.mass_final_plus  is not null then t96seg.mass_final_plus  else  -1 end as T96_mass_final_plus  -- 1.70mm+
       ,case when t96seg.mass_final_minus is not null then t96seg.mass_final_minus else  -1 end as T96_mass_final_minus -- 1.70mm-
       ,case when pct_wear_calculated     is not null then pct_wear_calculated     else  -1 end as T96_percent_wear
       ,case when out_of_bounds           is not null then out_of_bounds           else ' ' end as T96_out_of_bounds  
       
       ,allowance                         as T96_allowance         -- (mass_initial * 0.01) not displayed
       ,final_total                       as T96_final_total       -- (mass_final_plus + mass_final_minus) not displayed
       ,t96seg.captured_pct_wear          as T96_captured_pct_wear -- captured for purposes of comparison
                                                                   -- with pct_wear_calculated
       ,t96.remarks                       as T96_Remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                           smpl
       join Test_T96                                      t96 on t96.sample_id = smpl.sample_id
       left join Test_T96_segments                     t96seg on t96.sample_id = t96seg.sample_id
       
       /*-----------------------------------------------------------------------
         calculations
       -----------------------------------------------------------------------*/
       
       cross apply (select case when (t96seg.mass_initial >= 0) then (t96seg.mass_initial * 0.01)
                                else 0 end as allowance from dual) CALC_ALLOW
       
       
       cross apply (select case when (t96seg.mass_final_plus >= 0 and t96seg.mass_final_minus >= 0)
                                then (t96seg.mass_final_plus + t96seg.mass_final_minus)
                                else 0 end as final_total from dual) CALC_FINAL
       
       
       cross apply (select case when ( ((t96seg.mass_initial + allowance) >= final_total) or
                                       ((t96seg.mass_initial - allowance) <= final_total) )
                                      and t96seg.mass_initial > 0 -- for the denominator
                                then ((100.0 * t96seg.mass_final_minus) / t96seg.mass_initial)
                                else -1 end as pct_wear_calculated from dual) pctwear
       
       
       cross apply (select case when ( ((t96seg.mass_initial + allowance) < final_total) or
                                       ((t96seg.mass_initial - allowance) > final_total) )
                                then ' not within 1% of initial weight '
                                else ' ' end as out_of_bounds from dual) outbounds
       
       
       order by 
       t96.sample_id, 
       t96seg.segment_nbr
       ;









