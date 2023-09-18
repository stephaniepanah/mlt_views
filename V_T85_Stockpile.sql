



select * from V_T85_Stockpile where T85_Stk_Sample_ID in (

'W-20-1070',     'W-20-1056-AG', 'W-19-0955-AC',
'W-18-1617-AG',  'W-18-1618-AG', 'W-09-0296-AC',
'W-95-0457-ACZ', 'W-96-1552-AC07'

); 



select * from V_T85_Stockpile where T85_Stk_Sample_ID = 'W-20-0323'; 
select * from Test_T85_Stockpile where sample_id = 'W-20-0323'; 



select * from Test_T85_Stockpile where sample_id like 'W-2%'; -- 2020,2021

/*
                stk     seg
W-20-0170	    1	    1   -- one stockpile with three segments
W-20-0170	    1	    2
W-20-0170	    1	    3

W-20-0323	    1	    1   -- one stockpile with three segments
W-20-0323	    1	    2
W-20-0323	    1	    3

W-20-1055-AG	1	    1   -- two stockpiles, each with one segment
W-20-1055-AG	2	    1

W-20-1056-AG	1	    1   -- two stockpiles, each with one segment
W-20-1056-AG	2	    1

*/




/***********************************************************************************

 T85 Specific Gravity and Absorption of Coarse Aggregate

 from MTest, Lt_T85_B5_da.cpp, void LtT85::CorTblSp::calcRow(int xRow)
 {

   // Calculations assume that volume of flask == wt of water
   // X ml water == X grams water

     coarse bulk specific gravity: BSG    = dry wt / (SSD wt - wt in water)
      coarse SSD specific gravity: SSD SG = SSD wt / (SSD wt - wt in water)
 coarse apparent specific gravity: ASG    = dry wt / (dry wt - wt in water)
        coarse percent absorption: Absorption = ((100 * (SSD wt - dry wt)) / dry wt)

    // MTest                           // my notes
                                       
	if (msd > 0.0)                     // mass_dry_sample
	{
		if (mssd > 0.0)                // mass_ssd_actual
		{
			if (msw > 0.0)             // mass_sample_in_water
				cancalc = true;
		}
	}
    
	if (cancalc)
	{
		denbsg = mssd - msw;           // (mass_ssd_actual - mass_sample_in_water)
        
		if (denbsg > 0.0)              // (mass_ssd_actual - mass_sample_in_water) > 0
		{
			denasg = msd - msw;        // (mass_dry_sample - mass_sample_in_water)
            
			if (denasg > 0.0)          // (mass_dry_sample - mass_sample_in_water) > 0
			{
				bsg =  msd / denbsg;   // mass_dry_sample / (mass_ssd_actual - mass_sample_in_water)
				ssg = mssd / denbsg;   // mass_ssd_actual / (mass_ssd_actual - mass_sample_in_water)
				asg =  msd / denasg;   // mass_dry_sample / (mass_dry_sample - mass_sample_in_water)
                
				abs = ((100.0*(mssd - msd)) / msd); // ((mass_ssd_actual - mass_dry_sample) / mass_dry_sample) * 100
			}
    
    
 from MTest, Lt_T85_B5_da.cpp
 void LtT85::CorGrpRoot::calcT85Avs()
 {
   // Assume that if BsgAv is valid all results are
   
   ratio = grpSp->getNum(CorSpX::xRatio);
   bsg = grpSp->getNum(CorSpX::xBsgAv);
   
   if( ratio > 0.0 && bsg > 0.0 )
   {
         ssg = grpSp->getNum(CorSpX::xSsgAv);
         asg = grpSp->getNum(CorSpX::xAsgAv);
         abs = grpSp->getNum(CorSpX::xAbsAv);
         
         avbsg += bsg*ratio;
         avssg += ssg*ratio;
         avasg += asg*ratio;
         avabs += abs*ratio;
         
         parts += ratio;   // my notes: sum the ratios, even if > 100. yes, most odd
   }
   if( parts > 0.0 )
   {
      bsg = avbsg / parts; // and then, divide by the parts! 
      ssg = avssg / parts; // this will render a true value. good grief, ...but it works
      asg = avasg / parts;
      abs = avabs / parts;
   }
   
    
***********************************************************************************/



create or replace view V_T85_Stockpile as 

--------------------------------------------------------------------------------
-- obtain the calculated values per segment
--------------------------------------------------------------------------------

with stockpile_segment_evaluation as (

     select  sample_id   -- used in the join clause
            ,stockpile   -- used in the join clause
            ,segment_nbr -- used in the join clause
            
            ,case when  mass_dry_sample                   > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 
                  then 'true'
                  else 'false' end 
                  as cancalc
            
            ,case when  mass_dry_sample                   > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 
                  then 1
                  else 0 end
                  as valid_segment_count
            
            ,sum(case when  mass_dry_sample               > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 
                  then 1
                  else 0 end) over (partition by sample_id, stockpile)
                  as valid_segment_count_summ
            
            ,case when  mass_dry_sample                   > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 and
                       (Mass_saturated_surface_dry_Actual - mass_sample_in_water) > 0 
                  then (Mass_saturated_surface_dry_Actual - mass_sample_in_water)
                  else -1 end
                  as BSG_denominator
            
            ,case when  mass_dry_sample                   > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 and
                       (Mass_saturated_surface_dry_Actual - mass_sample_in_water) > 0  
                  then (mass_dry_sample / (Mass_saturated_surface_dry_Actual - mass_sample_in_water))
                  else -1 end
                  as BSG
                  
            ,sum(case when mass_dry_sample                > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 and
                       (Mass_saturated_surface_dry_Actual - mass_sample_in_water) > 0 -- denominator
                  then (mass_dry_sample / (Mass_saturated_surface_dry_Actual - mass_sample_in_water))
                  else 0 end) over (partition by sample_id, stockpile)
                  as BSG_summation
            
            ,case when  mass_dry_sample                   > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 and
                       (Mass_saturated_surface_dry_Actual - mass_sample_in_water) > 0
                  then (Mass_saturated_surface_dry_Actual / (Mass_saturated_surface_dry_Actual - mass_sample_in_water))
                  else -1 end
                  as SSDSG
            
            ,sum(case when  mass_dry_sample               > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 and
                       (Mass_saturated_surface_dry_Actual - mass_sample_in_water) > 0
                  then (Mass_saturated_surface_dry_Actual / (Mass_saturated_surface_dry_Actual - mass_sample_in_water))
                  else 0 end) over (partition by sample_id, stockpile)
                  as SSDSG_summation
            
            ,case when  mass_dry_sample                   > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 and
                       (mass_dry_sample - mass_sample_in_water) > 0
                  then (mass_dry_sample - mass_sample_in_water)
                  else -1 end
                  as ASG_denominator
            
            ,case when  mass_dry_sample                   > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 and
                       (mass_dry_sample - mass_sample_in_water) > 0
                  then (mass_dry_sample / (mass_dry_sample - mass_sample_in_water))
                  else -1 end
                  as ASG
            
            ,sum(case when  mass_dry_sample               > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 and
                       (mass_dry_sample - mass_sample_in_water) > 0
                  then (mass_dry_sample / (mass_dry_sample - mass_sample_in_water))
                  else 0 end) over (partition by sample_id, stockpile)
                  as ASG_summation
            
            ,case when  mass_dry_sample                   > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 and
                       (Mass_saturated_surface_dry_Actual - mass_dry_sample) > 0
                  then (((Mass_saturated_surface_dry_Actual - mass_dry_sample) / mass_dry_sample) * 100)
                  else -1 end
                  as Absorption_Percent
            
            ,sum(case when  mass_dry_sample               > 0 and 
                        Mass_saturated_surface_dry_Actual > 0 and 
                        mass_sample_in_water              > 0 and
                       (Mass_saturated_surface_dry_Actual - mass_dry_sample) > 0
                  then (((Mass_saturated_surface_dry_Actual - mass_dry_sample) / mass_dry_sample) * 100)
                  else 0 end) over (partition by sample_id, stockpile)
                  as Absorption_Percent_summation
                  
       from Test_T85_Stockpile
)

--------------------------------------------------------------------------------
-- obtain the sum of the ratios, and render it as a decimal percent, ie; * 0.01
-- from MTest calcT85Avs() code above: parts += ratio;
--------------------------------------------------------------------------------

,ratio_summation as (

     select  sample_id
            ,(sum(case when ratio > 0 then ratio else 0 end) * 0.01) as ratio_summ_pct
       from Test_T85_Stockpile
      group by sample_id
)

--------------------------------------------------------------------------------
-- main sql
--------------------------------------------------------------------------------

select  t85stk.sample_id                                      as T85_Stk_Sample_ID   -- key
       ,t85stk.stockpile                                      as T85_Stk_Stockpile   -- key
       ,t85stk.segment_nbr                                    as T85_Stk_segment_nbr -- key
       
       ,t85eval.cancalc                                       as T85_Stk_cancalc     -- not used
       
       /*-------------------------------------------------------------------
         Description and Ratio
       -------------------------------------------------------------------*/
       
       ,t85stk.description_T85                                as T85_Stk_Description       
       ,t85stk.ratio                                          as T85_Stk_Ratio
       ,ratio.ratio_summ_pct                                  as T85_Stk_ratio_summ_pct
       
       /*-------------------------------------------------------------------
         user entered fields (per segment)
       -------------------------------------------------------------------*/
       
       ,t85stk.mass_dry_sample                                as T85_Stk_mass_dry_sample
       ,t85stk.Mass_saturated_surface_dry_Actual              as T85_Stk_mass_ssd_actual
       ,t85stk.mass_sample_in_water                           as T85_Stk_mass_sample_in_water
       
       /*-----------------------------------------------------------------------
         calculated fields, from stockpile_segment_evaluation (per segment)
       -----------------------------------------------------------------------*/
       
       ,t85eval.BSG                                           as T85_Stk_Bulk_SG
       ,t85eval.SSDSG                                         as T85_Stk_SSD_SG
       ,t85eval.ASG                                           as T85_Stk_Apparent_SG
       ,t85eval.Absorption_Percent                            as T85_Stk_Absorption_Pct
       
       /*-----------------------------------------------------------------------
         obtain the averages; per sample, per stockpile
         performed in the cross apply
       -----------------------------------------------------------------------*/
       
       ,BSG_avg                                               as T85_Stk_Avg_BSG
       ,SSDSG_avg                                             as T85_Stk_Avg_SSDSG
       ,ASG_avg                                               as T85_Stk_Avg_ASG
       ,Absorption_Pct_avg                                    as T85_Stk_Avg_Absorption_Pct
       
       /*-----------------------------------------------------------------------
         averages * ratio * 0.01 <-- render the ratio as a decimal (per stockpile)
         - these calculation are are not displayed, but an intermediate step
         - they are used to produce the Avg of the averages, as seen on the front page
         performed in the cross apply
       -----------------------------------------------------------------------*/
       
       ,BSG_avg_times_ratio                                   as T85_Stk_BSG_avg_times_ratio
       ,SSDSG_avg_times_ratio                                 as T85_Stk_SSDSG_avg_times_ratio
       ,ASG_avg_times_ratio                                   as T85_Stk_ASG_avg_times_ratio
       ,Absorption_Pct_avg_times_ratio                        as T85_Stk_Abs_Pct_avg_times_ratio
       
       /*-----------------------------------------------------------------------
         average of the averages, as seen on the front page Average line
         (avg per sample)
       -----------------------------------------------------------------------*/
       
       ,((sum(BSG_avg_times_ratio)            over (partition by t85stk.sample_id)) / ratio.ratio_summ_pct) as T85_Stk_Avg_of_all_BSG
       ,((sum(SSDSG_avg_times_ratio)          over (partition by t85stk.sample_id)) / ratio.ratio_summ_pct) as T85_Stk_Avg_of_all_SSDSG
       ,((sum(ASG_avg_times_ratio)            over (partition by t85stk.sample_id)) / ratio.ratio_summ_pct) as T85_Stk_Avg_of_all_ASG
       ,((sum(Absorption_Pct_avg_times_ratio) over (partition by t85stk.sample_id)) / ratio.ratio_summ_pct) as T85_Stk_Avg_of_all_Abs_Pct
       
       /*-----------------------------------------------------------------------
         values from the stockpile_segment_evaluation, used for calculating
         the averages
       -----------------------------------------------------------------------*/
        
       ,t85eval.BSG_summation                                 as T85_Stk_summation_BSG
       ,t85eval.SSDSG_summation                               as T85_Stk_summation_SSDSG
       ,t85eval.ASG_summation                                 as T85_Stk_summation_ASG
       ,t85eval.Absorption_Percent_summation                  as T85_Stk_summation_Absorption_Pct
       ,t85eval.valid_segment_count_summ                      as T85_Stk_summation_valid_segment_count
       ,t85eval.valid_segment_count                           as T85_Stk_valid_segment_count       
       ,t85eval.BSG_denominator                               as T85_Stk_BSG_denominator -- not used
       ,t85eval.ASG_denominator                               as T85_Stk_ASG_denominator -- not used
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                      smpl
       join Test_T85                                 t85 on t85.sample_id      = smpl.sample_id
       join Test_T85_Stockpile                    t85stk on t85.sample_id      = t85stk.sample_id
       
       join stockpile_segment_evaluation         t85eval on t85stk.sample_id   = t85eval.sample_id
                                                        and t85stk.stockpile   = t85eval.stockpile
                                                        and t85stk.segment_nbr = t85eval.segment_nbr
       
       join ratio_summation                        ratio on t85.sample_id      = ratio.sample_id
       
       /*-----------------------------------------------------------------------
         calculated averages
       -----------------------------------------------------------------------*/
       
       cross apply (select
        case when (t85eval.BSG_summation > 0 and t85eval.valid_segment_count_summ > 0)
             then (t85eval.BSG_summation / t85eval.valid_segment_count_summ)
             else -1 end as BSG_avg from dual) bsgavg
             
       cross apply (select
        case when (t85eval.SSDSG_summation > 0 and t85eval.valid_segment_count_summ > 0)
             then (t85eval.SSDSG_summation / t85eval.valid_segment_count_summ)
             else -1 end as SSDSG_avg from dual) ssdsgavg
             
       cross apply (select
        case when (t85eval.ASG_summation > 0 and t85eval.valid_segment_count_summ > 0)
             then (t85eval.ASG_summation / t85eval.valid_segment_count_summ)
             else -1 end as ASG_avg from dual) asgavg
       
       cross apply (select
        case when (t85eval.Absorption_Percent_summation > 0 and t85eval.valid_segment_count_summ > 0)
             then (t85eval.Absorption_Percent_summation / t85eval.valid_segment_count_summ)
             else -1 end as Absorption_Pct_avg from dual) pctavg
       
       /*-----------------------------------------------------------------------
         averages * ratio * 0.01 <-- render the ratio as a decimal
       -----------------------------------------------------------------------*/
       
       cross apply (select case when (BSG_avg > 0 and t85stk.ratio > 0)
                                then (BSG_avg * t85stk.ratio * 0.01)
                                else 0 end as BSG_avg_times_ratio from dual) bsg_ratio
       
       cross apply (select case when (SSDSG_avg > 0 and t85stk.ratio > 0)
                                then (SSDSG_avg * t85stk.ratio * 0.01)
                                else 0 end as SSDSG_avg_times_ratio from dual) ssd_ratio
       
       cross apply (select case when (ASG_avg > 0 and t85stk.ratio > 0)
                                then (ASG_avg * t85stk.ratio * 0.01)
                                else 0 end as ASG_avg_times_ratio from dual) asg_ratio
       
       cross apply (select case when (Absorption_Pct_avg > 0 and t85stk.ratio > 0) 
                                then (Absorption_Pct_avg * t85stk.ratio * 0.01)
                                else 0 end as Absorption_Pct_avg_times_ratio from dual) pct_ratio
       
       
       order by 
       T85_Stk_Sample_ID, 
       T85_Stk_stockpile, 
       T85_Stk_segment_nbr
       ;









/***********************************************************************************

 T85 T85 Combined SGs & T85 RAP - Recycled Asphalt Pavement
 W-19-0719-AC, W-19-0728-AC, W-19-0862-AC, W-19-0955-AC
 W-18-0036-AC, W-18-0391-AC

***********************************************************************************/

select * from V_WL800_sieve_segments_grid where WL800_sample_id = 'W-20-0323';

select seg.sample_id

       ,case when seg.pct_binder = -1 then ' '
             else to_char(seg.pct_binder, '990.99') 
             end as pct_binder -- Pb       
       
       ,case when seg.pct_binder_absorbed = -1 then ' '
             else to_char(seg.pct_binder_absorbed, '990.99') 
             end as pct_binder_absorbed -- Pba
       
       ,case when seg.specific_gravity_binder = -1 then ' '
             else to_char(seg.specific_gravity_binder, '99990.999')
             end as specific_gravity_binder -- Gb
       
       ,case when seg.max_specific_gravity = -1 then ' '
             else to_char(seg.max_specific_gravity, '99990.999') 
             end as max_specific_gravity -- Gmm
       
       ,case when seg.pct_recycled_asphalt_pavement = -1 then ' '
             else to_char(seg.pct_recycled_asphalt_pavement, '990.99') 
             end as pct_rap -- pct RAP
       
  from Test_T85_RAP         seg  
  join Test_T85             hdr on seg.sample_id = hdr.sample_id 
  join MLT_1_WL900_Sample smpl on hdr.sample_id = smpl.sample_id
  
 --where smpl.sample_id  = 'W-60-0011-AG'
  -- and smpl.sample_year = '1985'
  
 --order by smpl.sample_year, smpl.sample_id
 --order by smpl.sample_year, smpl.sample_id desc
 order by smpl.sample_year desc, smpl.sample_id
 --order by smpl.sample_year desc, smpl.sample_id desc
 ;









