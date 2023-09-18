



select * from V_T84_Stockpile where T84_Stk_Sample_ID = 'W-20-0035'; 

select * from V_T84_Stockpile where T84_Stk_Sample_ID = 'W-20-0170'; 

select * from V_T84_Stockpile where T84_Stk_Sample_ID = 'W-20-0323'; 

select * from V_T84_Stockpile where T84_Stk_Sample_ID = 'W-21-0090-AG'; 

select * from V_T84_Stockpile where T84_Stk_Sample_ID = 'W-21-0127-AG'; 

select * from V_T84_Stockpile where T84_Stk_Sample_ID = 'W-21-0164-AG'; 

select * from V_T84_Stockpile where T84_Stk_Sample_ID = 'W-09-0296-AC'; 

select * from V_T84_Stockpile where T84_Stk_Sample_ID = 'W-09-0338-AC'; 




select * from test_t84_stockpile where sample_id         = 'W-20-0323'; 

select * from V_T84_Stockpile    where T84_Stk_Sample_ID = 'W-20-0323'; 



-- there are cases (they tend to be older samples) where Actual SSD Mass is missing
-- and yet, the calculated fields are present. I believe that this is wrong

select * from Test_T84_Stockpile where mass_ssd_actual = -1;



select * from test_t84_stockpile where sample_id like 'W-21-%';



select sample_id from test_t84_stockpile where stockpile = 2
 --and sample_id like 'W-1%' -- samples 2010 to 2019     -- 14 samples post 2010 with two or more stockpiles
   and sample_id like 'W-2%' -- samples 2020 and greater --  0 samples
;
-- W-19-0084-AG  W-19-0085-AG  W-19-0759-AC  W-18-0881-AG
-- W-14-0657-AC  W-13-0312-AC  W-13-0312-AC  W-12-0196-AC
-- W-11-0857-AC  W-11-0035-AC  W-11-0035-AC 
-- W-10-0728-AC  W-10-0676-AC  W-10-0676-AC




select sample_id, stockpile from test_t84_stockpile where stockpile = 3;
/*

W-09-0865-AC	3
W-09-0296-AC	3
W-09-0338-AC	3
W-07-0289-AC	3
W-01-0005-AC	3
W-98-2307-AC	3
W-98-2307-ACWL	3
W-97-0859-AC	3
W-97-0859-ACSP	3
W-96-1098-ACS	3
W-60-0289-ACT	3
W-60-0289-ACT	3

*/




/***********************************************************************************

 T84 Specific Gravity and Absorption of Fine Aggregate

 W-19-0085-AG, W-19-0585-AG, W-19-0719-AC, W-19-0728-AC
 W-18-0036-AC, W-18-0078-AG, W-18-0391-AC, W-17-0338-AG, W-17-0998-AC

 CustomaryOrMetric
 -----------------
 [0] reporting units 'M' = metric, 'C' = customary
 W-18-0036-AC |C| Customary - temperature: Fahrenheit
 W-17-0509-AC |M| Metric    - temperature: Celsius


 from MTest, Lt_T84_B5_da.cpp, void LtT84::CorTblSp::calcRow(int xRow)

 Calculations assume that volume of flask = mass of water (X ml water = X grams water)
  
 CALCULATIONS
 -------------------------------------------------------------

 bulk specific gravity: BSG + dry wt  / (vol flask - (wtsamp+water - SSDwt) )

 SSD  specific gravity: SSDSG = SSDwt / (vol flask - (wtsamp&water - SSDwt) )

 apparent specific gravity:
     ASG = dry wt / ((vol flask - (wtsamp&water - SSDwt)) - (SSDwt - dry wt) )
         = dry wt /  (vol flask + dry wt - wtsamp&water)

 fine percent absorption: Absorption = 100 * (SSDwt - dry wt) / dry wt
 
 calculate the wt water + sample
 wt water & sample = wt flask & water & sample - wt flask
 wt flask is allowed to equal 0 in case wtwater&sample is pre-tared
 
 Do not allow blank tare = 0; wt flask MUST be entered. (DW 12-93)
 
 1-98 (JCU): NOTES:
  Vol flask (ml) converts to wt of water
  AASHTO's formula for ASG is:
    ASG = wtDrySample / ( wtFlask&Water - wtFlask&Sample&water + wtSSDsample)
    The version here drops wtFlask from the middle two entries
 
 NOTE: AASHTO (1993) gives a conversion of ml water to gms: gms = 0.9975 * volume, ml
 
 -------------------------------------------------------------
 Calculate summary averages
 Use ASG of mineral filler as a standin for BSG, SSDSG of mineral filler
 ("Mix Design Methods", MS-2 6th ed (1993), p. 48)
 Average of SG uses the formula: sum(part[i]) / sum( (part[i]/SG[i]) ) (ibid, p. 47)
 Average for Pba (absorbed asphalt) does NOT include portion of mineral filler

 from MTest, Lt_T84_B5_da.cpp, void LtT84::CorTblSp::calcRow(int xRow)
 {
                                               // my notes
 if (mw > 0.0)                                 // mass of water (volume of flask)
 {
    if (mssd > 0.0)                            // mass SSD
    {
        if (ms > 0.0)                          // mass dry sample
        {
            if (mswf > 0.0)                    // mass sample water flask
                cancalc = true;
        
    
 if (cancalc)
 {
	if (mf >= 0.0)                             // mass flask
	{ 
		// don't allow tared wt flask + sample + water

		msw    = mswf - mf;                    // mass sample water = mass sample water flask – mass flask
		denbsg = mw - msw + mssd;              // denominator for bsg
		denasg = mw - msw + ms;	               // denominator for asg

		if (denbsg > 0.0 && denasg > 0.0)
		{
			bsg   = ms   / denbsg;             // or (ms   / (mw - msw + mssd))  Bulk SG
			ssdsg = mssd / denbsg;             // or (mssd / (mw - msw + mssd))  SSD SG
			asg   = ms   / denasg;             // or (ms   / (mw - msw + ms))    Apparent SG
			abs   = 100.0 * (mssd - ms) / ms;  //                                Absorption pct
		}
	}
 }


  T84 Stockpiles
  ==============
  
  select count(distinct(sample_id)) from test_t84_stockpile where stockpile = 1; (511 samples)
  select count(distinct(sample_id)) from test_t84_stockpile where stockpile = 2; ( 66 samples)
  select count(distinct(sample_id)) from test_t84_stockpile where stockpile = 3; ( 11 samples)
  
  select distinct(sample_id) from test_t84_stockpile where stockpile = 3;
  W-09-0865-AC,   W-09-0338-AC, W-09-0296-AC,   W-07-0289-AC, W-01-0005-AC 
  W-98-2307-ACWL, W-98-2307-AC, W-97-0859-ACSP, W-97-0859-AC, W-96-1098-ACS
  W-60-0289-ACT
  
  
  mass of water and sample    = mass_flask_water_sample - mass_flask
  
  Bulk SG denominator         = (volume_flask + mass_ssd_actual - mass_of_water_and_sample) or
                                (volume_flask + mass_ssd_actual - (mass_flask_water_sample - mass_flask))

  Bulk Specific Gravity (BSG) = mass_dry_sample / denominator_bsg
  
  Saturated Surface Dry SG    = mass_ssd_actual / denominator_bsg
  
  ASG denominator             = (volume_flask + mass_dry_sample - mass_of_water_and_sample) or
                                (volume_flask + mass_dry_sample - (mass_flask_water_sample - mass_flask))
  
  Apparent Spec Gravity (ASG) = mass_dry_sample / denominator_asg
  
  Absorption Percent          = (((mass_ssd_actual - mass_dry_sample) / mass_dry_sample) * 100)
  
  
  from MTest, Lt_T84_B5_da.cpp, void LtT84::CorGrpRoot::calc()
  {
    if( ratio > 0.0 && bsg > 0.0 )
    {
      -- multiply each stockpile average by its ratio
      -- then add to obtain the average for all the stockpiles
      
      avbsg += BsgAv * ratio;
      avssg += SsgAv * ratio;
      avasg += AsgAv * ratio;
      avabs += AbsAv * ratio;
      
      parts += ratio;
      partsnomf += ratio; // nomf -> no mineral filler
   }
   if( parts > 0.0 )
   {
      asg = avasg / parts;
      bsg = avbsg / parts;
      ssg = avssg / parts;
   }
   if( partsnomf > 0.0 )
   {
      abs = avabs / partsnomf;
   }
   
  
***********************************************************************************/



create or replace view V_T84_Stockpile as 

--------------------------------------------------------------------------------
-- obtain the calculated values per segment
--------------------------------------------------------------------------------

with stockpile_segment_evaluation as (

     select  sample_id   -- used in the join clause
            ,stockpile   -- used in the join clause
            ,segment_nbr -- used in the join clause
            
            ,case when volume_flask                      > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0
                  then 'true'
                  else 'false' end
                  as cancalc -- not sure that I need this, but, it is from the code, so at least we have it
            
            ,case when volume_flask                      > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0
                  then 1
                  else 0 end
                  as valid_segment_count
            
            ,sum(case when volume_flask                  > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0
                  then 1
                  else 0 end) over (partition by sample_id, stockpile)
                  as valid_segment_count_summ
            
            ,case when (mass_flask > 0) and (mass_flask_water_sample > mass_flask)
                  then (mass_flask_water_sample - mass_flask)
                  else -1 end
                  as mass_water_and_sample
                 
            ,case when volume_flask                      > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0 and
                      (mass_flask_water_sample > mass_flask)
                  then (volume_flask + Mass_saturated_surface_dry_Actual - (mass_flask_water_sample - mass_flask))
                  else -1 end
                  as BSG_denominator -- not used
            
            ,case when volume_flask                      > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0
                  then mass_dry_sample / (volume_flask + Mass_saturated_surface_dry_Actual - (mass_flask_water_sample - mass_flask))
                  else -1 end
                  as BSG -- bulk_specific_gravity
            
            ,sum(case when volume_flask                  > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0 and 
                       ((volume_flask + Mass_saturated_surface_dry_Actual - (mass_flask_water_sample - mass_flask)) > 0) -- denominator
                  then (mass_dry_sample / (volume_flask + Mass_saturated_surface_dry_Actual - (mass_flask_water_sample - mass_flask)))
                  else 0 end) over (partition by sample_id, stockpile)
                  as BSG_summation
            
            ,case when volume_flask                      > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0
                  then Mass_saturated_surface_dry_Actual / (volume_flask + Mass_saturated_surface_dry_Actual - (mass_flask_water_sample - mass_flask))
                  else -1 end
                  as SSDSG -- saturated_surface_dry_specific_gravity
            
            ,sum(case when volume_flask                  > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0 and
                       ((volume_flask + Mass_saturated_surface_dry_Actual - (mass_flask_water_sample - mass_flask)) > 0) -- denominator
                  then (Mass_saturated_surface_dry_Actual / (volume_flask + Mass_saturated_surface_dry_Actual - (mass_flask_water_sample - mass_flask)))
                  else 0 end) over (partition by sample_id, stockpile)
                  as SSDSG_summation                 
                 
            ,case when volume_flask                      > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0 and 
                      (mass_flask_water_sample > mass_flask )
                  then (volume_flask + mass_dry_sample - (mass_flask_water_sample - mass_flask))
                  else -1 end
                  as ASG_denominator -- not used
            
            ,case when volume_flask                      > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0
                  then mass_dry_sample / (volume_flask + mass_dry_sample - (mass_flask_water_sample - mass_flask))
                  else -1 end
                  as ASG -- apparent_specific_gravity
            
            ,sum(case when volume_flask                  > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0 and
                       ((volume_flask + mass_dry_sample - (mass_flask_water_sample - mass_flask)) > 0) -- denominator
                  then (mass_dry_sample / (volume_flask + mass_dry_sample - (mass_flask_water_sample - mass_flask)))
                  else 0 end) over (partition by sample_id, stockpile)
                  as ASG_summation
            
            ,case when volume_flask                      > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0
                  then (((Mass_saturated_surface_dry_Actual - mass_dry_sample) / mass_dry_sample) * 100)
                  else -1 end
                  as Absorption_Percent
            
            ,sum(case when volume_flask                  > 0 and 
                       Mass_saturated_surface_dry_Actual > 0 and 
                       mass_dry_sample                   > 0 and 
                       mass_flask_water_sample           > 0 and
                       mass_flask                        > 0
                  then (((Mass_saturated_surface_dry_Actual - mass_dry_sample) / mass_dry_sample) * 100)
                  else 0 end) over (partition by sample_id, stockpile)
                  as Absorption_Percent_summation
                  
       from Test_T84_Stockpile
)
--------------------------------------------------------------------------------
-- obtain the sum of the ratios, and render it as a decimal percent, ie; * 0.01
--------------------------------------------------------------------------------

,ratio_summation as (

     select  sample_id
            ,(sum(case when ratio > 0 then ratio else 0 end) * 0.01) as ratio_summ_pct
       from Test_T84_Stockpile
      group by sample_id
)

--------------------------------------------------------------------------------
-- main sql
--------------------------------------------------------------------------------

select  t84stk.sample_id                                      as T84_Stk_Sample_ID   -- key
       ,t84stk.stockpile                                      as T84_Stk_Stockpile   -- key
       ,t84stk.segment_nbr                                    as T84_Stk_segment_nbr -- key
       
       ,t84eval.cancalc                                       as T84_Stk_cancalc     -- not used
       
       /*-----------------------------------------------------------------------
         Description and Ratio
       -----------------------------------------------------------------------*/
       
       ,t84stk.description_T84                                as T84_Stk_Description       
       ,t84stk.ratio                                          as T84_Stk_Ratio
       ,ratio.ratio_summ_pct                                  as T84_Stk_ratio_summ_pct
       
       /*-----------------------------------------------------------------------
         user entered fields (per segment)
       -----------------------------------------------------------------------*/
       
       ,t84stk.volume_flask                                   as T84_Stk_volume_of_flask       
       ,t84stk.Mass_saturated_surface_dry_Actual              as T84_Stk_mass_ssd_actual       
       ,t84stk.mass_dry_sample                                as T84_Stk_mass_of_dry_sample       
       ,t84stk.mass_flask_water_sample                        as T84_Stk_mass_flask_water_and_sample       
       ,t84stk.mass_flask                                     as T84_Stk_mass_of_flask
       
       /*-----------------------------------------------------------------------
         calculated fields, from stockpile_segment_evaluation (per segment)
       -----------------------------------------------------------------------*/
       
       ,t84eval.mass_water_and_sample                         as T84_Stk_mass_of_water_and_sample
       ,t84eval.BSG                                           as T84_Stk_Bulk_SG
       ,t84eval.SSDSG                                         as T84_Stk_SSD_SG
       ,t84eval.ASG                                           as T84_Stk_Apparent_SG
       ,t84eval.Absorption_Percent                            as T84_Stk_Absorption_Pct
       
       /*-----------------------------------------------------------------------
         calculated averages (per stockpile, that are also displayed upon the front page)
       -----------------------------------------------------------------------*/
       
       ,BSG_avg                                               as T84_Stk_Avg_BSG
       ,SSDSG_avg                                             as T84_Stk_Avg_SSDSG
       ,ASG_avg                                               as T84_Stk_Avg_ASG
       ,Absorption_Pct_avg                                    as T84_Stk_Avg_Absorption_Pct
       
       /*-----------------------------------------------------------------------
         averages * ratio * 0.01 <-- render the ratio as a decimal (per stockpile)
         - these calculation are are not displayed, but an intermediate step
         - they are used to produce the sum of the averages, as seen on the front page
       -----------------------------------------------------------------------*/
       
       ,BSG_avg_times_ratio                                   as T84_Stk_Avg_BSG_times_ratio
       ,SSDSG_avg_times_ratio                                 as T84_Stk_Avg_SSDSG_times_ratio
       ,ASG_avg_times_ratio                                   as T84_Stk_Avg_ASG_times_ratio
       ,Absorption_Pct_avg_times_ratio                        as T84_Stk_Avg_Absorption_Pct_times_ratio
       
       /*-----------------------------------------------------------------------
         average of the averages, as seen on the front page Average line
         (avg per sample)
       -----------------------------------------------------------------------*/
       
       ,((sum(BSG_avg_times_ratio)            over (partition by t84stk.sample_id)) / ratio.ratio_summ_pct) as T84_Stk_Avg_of_all_BSG
       ,((sum(SSDSG_avg_times_ratio)          over (partition by t84stk.sample_id)) / ratio.ratio_summ_pct) as T84_Stk_Avg_of_all_SSDSG
       ,((sum(ASG_avg_times_ratio)            over (partition by t84stk.sample_id)) / ratio.ratio_summ_pct) as T84_Stk_Avg_of_all_ASG
       ,((sum(Absorption_Pct_avg_times_ratio) over (partition by t84stk.sample_id)) / ratio.ratio_summ_pct) as T84_Stk_Avg_of_all_Abs_Pct
       
       /*-----------------------------------------------------------------------
         values from the stockpile_segment_evaluation, used for calculating
         the averages
       -----------------------------------------------------------------------*/
        
       ,t84eval.BSG_summation                                 as T84_Stk_summation_BSG
       ,t84eval.SSDSG_summation                               as T84_Stk_summation_SSDSG
       ,t84eval.ASG_summation                                 as T84_Stk_summation_ASG
       ,t84eval.Absorption_Percent_summation                  as T84_Stk_summation_Absorption_Pct
       ,t84eval.valid_segment_count_summ                      as T84_Stk_summation_valid_segment_count
       ,t84eval.valid_segment_count                           as T84_Stk_valid_segment_count       
       ,t84eval.BSG_denominator                               as T84_Stk_BSG_denominator -- not used
       ,t84eval.ASG_denominator                               as T84_Stk_ASG_denominator -- not used
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                           smpl
       join Test_T84                                      t84 on t84.sample_id      = smpl.sample_id
       join Test_T84_Stockpile                         t84stk on t84.sample_id      = t84stk.sample_id
       
       join stockpile_segment_evaluation              t84eval on t84stk.sample_id   = t84eval.sample_id
                                                             and t84stk.stockpile   = t84eval.stockpile
                                                             and t84stk.segment_nbr = t84eval.segment_nbr
       
       join ratio_summation                             ratio on t84.sample_id      = ratio.sample_id
       
       /*-----------------------------------------------------------------------
         calculated averages
       -----------------------------------------------------------------------*/
       
       cross apply (select
        case when (t84eval.BSG_summation > 0 and t84eval.valid_segment_count_summ > 0)
             then (t84eval.BSG_summation / t84eval.valid_segment_count_summ)
             else -1 end as BSG_avg from dual) bsgavg
             
       cross apply (select
        case when (t84eval.SSDSG_summation > 0 and t84eval.valid_segment_count_summ > 0)
             then (t84eval.SSDSG_summation / t84eval.valid_segment_count_summ)
             else -1 end as SSDSG_avg from dual) ssdsgavg
             
       cross apply (select
        case when (t84eval.ASG_summation > 0 and t84eval.valid_segment_count_summ > 0)
             then (t84eval.ASG_summation / t84eval.valid_segment_count_summ)
             else -1 end as ASG_avg from dual) asgavg
       
       cross apply (select
        case when (t84eval.Absorption_Percent_summation > 0 and t84eval.valid_segment_count_summ > 0)
             then (t84eval.Absorption_Percent_summation / t84eval.valid_segment_count_summ)
             else -1 end as Absorption_Pct_avg from dual) pctavg
       
       /*-----------------------------------------------------------------------
         averages * ratio * 0.01 <-- render the ratio as a decimal
       -----------------------------------------------------------------------*/
       
       cross apply (select case when (BSG_avg > 0 and t84stk.ratio > 0)
                                then (BSG_avg * t84stk.ratio * 0.01)
                                else 0 end as BSG_avg_times_ratio from dual) bsg_ratio
       
       cross apply (select case when (SSDSG_avg > 0 and t84stk.ratio > 0)
                                then (SSDSG_avg * t84stk.ratio * 0.01)
                                else 0 end as SSDSG_avg_times_ratio from dual) ssd_ratio
       
       cross apply (select case when (ASG_avg > 0 and t84stk.ratio > 0)
                                then (ASG_avg * t84stk.ratio * 0.01)
                                else 0 end as ASG_avg_times_ratio from dual) asg_ratio
       
       cross apply (select case when (Absorption_Pct_avg > 0 and t84stk.ratio > 0) 
                                then (Absorption_Pct_avg * t84stk.ratio * 0.01)
                                else 0 end as Absorption_Pct_avg_times_ratio from dual) pct_ratio
       
       
       order by 
       T84_Stk_Sample_ID, 
       T84_Stk_stockpile, 
       T84_Stk_segment_nbr
       ;









