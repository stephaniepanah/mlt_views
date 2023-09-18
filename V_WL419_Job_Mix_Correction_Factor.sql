


select * from V_WL419_Job_Mix_Correction_Factor
 order by WL419_sample_year desc, WL419_sample_id, WL419_segment_nbr
;

-- samples with good data

select * from V_WL419_Job_Mix_Correction_Factor where WL419_sample_id = 'W-21-0184-AC';
select * from V_WL419_Job_Mix_Correction_Factor where WL419_sample_id = 'W-18-0036-AC';
select * from V_WL419_Job_Mix_Correction_Factor where WL419_sample_id = 'W-18-0631-AC';
select * from V_WL419_Job_Mix_Correction_Factor where WL419_sample_id = 'W-17-0509-AC';
select * from V_WL419_Job_Mix_Correction_Factor where WL419_sample_id = 'W-17-0998-AC';
select * from V_WL419_Job_Mix_Correction_Factor where WL419_sample_id = 'W-17-1020-ACA';
select * from V_WL419_Job_Mix_Correction_Factor where WL419_sample_id = 'W-17-1445-ACA';
select * from V_WL419_Job_Mix_Correction_Factor where WL419_sample_id = 'W-16-0834-AC';
select * from V_WL419_Job_Mix_Correction_Factor where WL419_sample_id = 'W-16-1370-AC';
select * from V_WL419_Job_Mix_Correction_Factor where WL419_sample_id = 'W-13-0014-AC';





--------------------------------------------------------------------------------
-- some diagnostics
--------------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_WL419 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 131	    1999	2021



select * from test_wl419 order by sample_year desc, sample_id;




/***********************************************************************************

 WL419 Job Mix Correction Factor
 
 from MTest, Lt_WL419b_C2.cpp
 
 void LtWL419_C2::CorRowLauf::doCalcs(unsigned fldid)
 {
      if( bowlfin >= 0.0 && bowlini >= bowlini ) <--- this is not right (my  notes)
          bowldiff = bowlfin - bowlini;
      
      if( agg >= 0.0 && both >= agg )   // both = agg & binder
          binder = both - agg;          // binder mass = (agg & binder) - agg
      
      if( bowldiff >= 0.0 && binder >= 0.0)
          bindercor = binder - bowldiff;
      
      if( agg >= 0.0 && bindercor >= 0 )
	  {
          if((bindercor + agg) > 0)
              actual = 100.0 * bindercor/(bindercor + agg);
      
      if( basket >= 0.0 && baskall >= 0.0 )
          mix = baskall - basket;

      if( actual >= 0.0 && furnace >= 0.0 )
          cf = furnace - actual; // correction factor
      
 
 void LtWL419_C2::CorGrpRoot::calcAvCF()
 {
    // Find least extreme pair and calculate their average and difference
    // kill highs and lows til you have only the least hi and the least lo left
    
    -- not doing this, just get the average and the difference (will fix later, good grief)
   
      
***********************************************************************************/


create or replace view V_WL419_Job_Mix_Correction_Factor as 


with wl419_segment_sql as (

select  sample_id
       ,segment_nbr       
       ,trial_id
       
       ,mass_bowl_initial
       ,mass_bowl_final
       
       ,case when (mass_bowl_initial > 0 and mass_bowl_final >= mass_bowl_initial)
             then (mass_bowl_final - mass_bowl_initial)
             else -1 end as mass_final_minus_initial
       
       ,mass_dry_aggregate
       ,mass_aggregate_binder -- both = agg & binder
       
       ,case when (mass_dry_aggregate > 0 and mass_aggregate_binder >= mass_dry_aggregate)
             then (mass_aggregate_binder - mass_dry_aggregate)
             else -1 end as mass_binder
       
       ,case when ((mass_dry_aggregate > 0 and mass_aggregate_binder >= mass_dry_aggregate) and 
                   (mass_bowl_initial  > 0 and mass_bowl_final       >= mass_bowl_initial))
             then ((mass_aggregate_binder - mass_dry_aggregate) - (mass_bowl_final - mass_bowl_initial))
             else -1 end as mass_corrected_binder
       
       ,mass_basket_assembly
       ,mass_basket_assembly_mix
       
       ,case when (mass_basket_assembly >= 0 and mass_basket_assembly_mix >= 0 )
             then (mass_basket_assembly_mix - mass_basket_assembly)
             else -1 end as mass_mix
             
       ,pct_ignition_binder_content
       
       ,include_indicator
       ,sum(case when include_indicator = 'X' then 1 else 0 end) over (partition by sample_id) as include_summ
       
  from Test_WL419_segments
)

select  wl419.sample_id                                         as WL419_Sample_ID
       ,wl419.sample_year                                       as WL419_sample_year
       ,wl419.test_status                                       as WL419_test_status
       ,wl419.tested_by                                         as WL419_tested_by
       
       ,case when to_char(wl419.date_tested, 'yyyy') = '1959'   then ' ' 
        else to_char(wl419.date_tested, 'mm/dd/yyyy') end       as WL419_date_tested
        
       ,wl419.date_tested                                       as WL419_date_tested_DATE
       ,wl419.date_tested_orig                                  as WL419_date_tested_orig         
       
       ,wl419.target_binder_pct_mass_mix                        as WL419_target_binder_pct_mass_mix
       ,wl419.target_binder_pct_mass_aggregate                  as WL419_target_binder_pct_mass_agg
       ,wl419.temperature                                       as WL419_temperature
       
       /*-----------------------------------------------------------------------
         segments
       -----------------------------------------------------------------------*/
       
       ,case when wl419seg.segment_nbr                 is not null then wl419seg.segment_nbr                 else  -1 end as WL419_segment_nbr       
       ,case when wl419seg.trial_id                    is not null then wl419seg.trial_id                    else ' ' end as WL419_trial_id
       
       ,case when wl419seg.mass_bowl_initial           is not null then wl419seg.mass_bowl_initial           else  -1 end as WL419_mass_bowl_initial
       ,case when wl419seg.mass_bowl_final             is not null then wl419seg.mass_bowl_final             else  -1 end as WL419_mass_bowl_final
       ,case when wl419seg.mass_final_minus_initial    is not null then wl419seg.mass_final_minus_initial    else  -1 end as WL419_mass_difference
       
       ,case when wl419seg.mass_dry_aggregate          is not null then wl419seg.mass_dry_aggregate          else  -1 end as WL419_mass_dry_aggregate
       ,case when wl419seg.mass_aggregate_binder       is not null then wl419seg.mass_aggregate_binder       else  -1 end as WL419_mass_agg_and_binder
       ,case when wl419seg.mass_binder                 is not null then wl419seg.mass_binder                 else  -1 end as WL419_mass_binder 
       ,case when wl419seg.mass_corrected_binder       is not null then wl419seg.mass_corrected_binder       else  -1 end as WL419_corrected_binder_mass
       ,actual_binder_pct                                                                                                 as WL419_actual_binder_pct
       
       ,case when wl419seg.mass_basket_assembly        is not null then wl419seg.mass_basket_assembly        else  -1 end as WL419_mass_basket_assembly
       ,case when wl419seg.mass_basket_assembly_mix    is not null then wl419seg.mass_basket_assembly_mix    else  -1 end as WL419_mass_basket_assembly_mix
       ,case when wl419seg.mass_mix                    is not null then wl419seg.mass_mix                    else  -1 end as WL419_mass_mix
       
       ,case when wl419seg.pct_ignition_binder_content is not null then wl419seg.pct_ignition_binder_content else  -1 end as WL419_pct_ignition_binder_content
       ,correction_factor_pct                                                                                             as WL419_correction_factor_pct
       
       ,lag(correction_factor_pct,1,0) over (order by wl419seg.segment_nbr) as correction_lag
       
       --- this is not working
       ,case when (wl419seg.include_summ = 2 and wl419seg.segment_nbr = 2) 
       
             then abs(correction_factor_pct - lag(correction_factor_pct,1,0) over (order by wl419seg.segment_nbr))
             
             --then lag(correction_factor_pct,1,0) over (order by wl419seg.segment_nbr)
             
             
             else -1 end as WL419_trial_difference
             
             
       ,case when (wl419seg.include_summ > 0)
             then (sum(case when correction_factor_pct >= 0 then correction_factor_pct else 0 end) 
                      over (partition by wl419.sample_id))
             else -1 end as WL419_correction_factor_summ -- not displayed
       
       ,case when (wl419seg.include_summ > 0)
             then ((sum(case when correction_factor_pct >= 0 then correction_factor_pct else 0 end) 
                      over (partition by wl419.sample_id)) / wl419seg.include_summ)
             else -1 end as WL419_Average_correction_factor
       
       
       ,case when wl419seg.include_indicator           is not null then wl419seg.include_indicator           else ' ' end as WL419_include_indicator
       ,case when wl419seg.include_summ                is not null then wl419seg.include_summ                else  -1 end as WL419_include_summ
       
       ,wl419.remarks as WL419_remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                             smpl
       join Test_WL419                                    wl419 on wl419.sample_id = smpl.sample_id       
       left join wl419_segment_sql                     wl419seg on wl419.sample_id = wl419seg.sample_id
       
       /*-----------------------------------------------------------------------
         calculations
       -----------------------------------------------------------------------*/
       
       -- actual binder content by misture mass, %
       cross apply (select case when ((wl419seg.mass_dry_aggregate >= 0 and wl419seg.mass_corrected_binder >= 0) and 
                                      (wl419seg.mass_dry_aggregate + wl419seg.mass_corrected_binder > 0))
                                then ((wl419seg.mass_corrected_binder / (wl419seg.mass_dry_aggregate + wl419seg.mass_corrected_binder)) * 100.0)
                                else -1 end as actual_binder_pct from dual) pctactual
       
       -- correction factor, %
       cross apply (select case when (wl419seg.pct_ignition_binder_content >= 0 and actual_binder_pct >= 0) 
                                then (wl419seg.pct_ignition_binder_content - actual_binder_pct) 
                                else -1 end as correction_factor_pct from dual) pctcorrection
       
       
       order by 
       wl419.sample_id,
       wl419seg.segment_nbr
       ;









