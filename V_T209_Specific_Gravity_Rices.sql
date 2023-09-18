


/*------------------------------------------------------------------------------
  when trying to create the overall Gse field, the order of the segments
  is not correct and I cannot figure out why.
  when that line is commented out, the View displays correctly
  see: T209_overall_average_Gse
------------------------------------------------------------------------------*/




select * from V_T209_Specific_Gravity_Rices where T209_Sample_ID = 

-- 'W-21-0153-AC' -- DL906 specific gravity -1, one segment
-- 'W-21-0154-AC' -- DL906 specific gravity -1, one segment
-- 'W-21-0362-AC' -- DL906 specific gravity -1, one segment
 
 'W-20-0170' -- DL906 specific gravity >0 and multiple segments 
-- 'W-20-0287' -- DL906 specific gravity >0 and multiple segments 
-- 'W-20-0323' -- DL906 specific gravity >0 and multiple segments 

-- 'W-19-0297-AC' -- DL906 specific gravity >0 and multiple segments 
-- 'W-19-0759-AC' -- DL906 specific gravity >0 and multiple segments 
-- 'W-19-1041-AC' -- DL906 specific gravity >0 and multiple segments 

-- 'W-07-0180-AC' -- DL906 specific gravity -1, one segment, two trials
-- 'W-00-0600-AC' -- DL906 specific gravity available, but not displayed(why?), two segments, each with two trials
-- 'W-00-0600-AC' 

 order by T209_Sample_Year desc, T209_Sample_ID
;



--------------------------------------------------------------------------------
-- some diagnostics
--------------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T209 where sample_year not in ('1960','1966');
-- count    min     max
-- 1686	    1986	2021



select * from test_t209 order by sample_year desc, sample_id
;



select * from test_t209_segments order by sample_id, segment_nbr
;



select distinct(customary_metric), count(customary_metric)
  from test_t209
 group by customary_metric
 order by customary_metric
 ;
/*
' ' 	750 
A   	431 --- pct asphalt by aggregate 
M	    508 --- pct asphalt by mixture 
*/



-- not all of the samples contain segments, find some recent ones
select * from test_t209_segments where sample_id like 'W-21%';
/*
W-21-0153-AC -- each sample contains only one segment
W-21-0154-AC
W-21-0362-AC
*/
select * from test_t209_segments where sample_id like 'W-20%';
/*
W-20-0170 -- all samples contain >1 segment
W-20-0287
W-20-0323
*/
select * from test_t209_segments where sample_id like 'W-19%';
/*
W-19-0297-AC -- all samples contain >1 segment
W-19-0759-AC
W-19-1041-AC
*/




select -- find sample segments with two trials 
/*
W-07-0180-AC
W-00-0600-AC
*/

 seg.SAMPLE_ID
,seg.SEGMENT_NBR
,seg.PCT_ASPHALT
,seg.INCLUDE_INDICATOR

,seg.MASS_MIX_trial1
,seg.MASS_CALIBRATED_trial1
,seg.MASS_MEASURED_trial1

,seg.MASS_MIX_trial2
,seg.MASS_CALIBRATED_trial2
,seg.MASS_MEASURED_trial2

from test_t209_segments seg
join test_t209          hdr on hdr.sample_id = seg.sample_id

where MASS_MIX_trial2 > 0 

order by 
hdr.sample_year desc,
hdr.sample_id
;


select -- find count of samples with segments of two trials (163 samples, ~10%, 2 samples post 2000)
/*
W-07-0180-AC
W-00-0600-AC
*/

count(distinct(hdr.SAMPLE_ID)) as sample_count

from test_t209_segments seg
join test_t209          hdr on hdr.sample_id = seg.sample_id

where seg.MASS_MIX_trial2 > 0 
;




/***********************************************************************************

 T209 Specific Gravity, Rice's
 
 from MTest, Lt_T209_C1.cpp
 
 enum class CorX : int {
   b,
   xMtmStatus = b,
   xTestBy,
   xTestDate,
   xUnits,
   xRemarks,
   xGb,  // from DL906
   xGse, // overall average
   xTblTrials,
   n
 };
 
 enum class LaufX : int {
   // table columns
   b,
   xRatio = b, // pct asphalt by mix or agg
   xInclude,
   xMix1,
   xCal1,
   xMeas1,
   xSg1,
   xMix2,
   xCal2,
   xMeas2,
   xSg2,
   xAvSg,
   xAvGse,
   n
 };

 void LtT209_C1::CorRowLauf::doCalcs() // my notes
 {
   double ar = getNum(LaufX::xRatio);  // pct asphalt by mix or agg
                                       // ar ....asphalt ratio ? I guess...
   if( _isbymix )
   {
      pb = ar;                         // Pb is percent binder by mix
   }                                   // pb = ar = xRatio
   else if( ar >= 0.0 )
   {
      // convert As/Agg to As/Mix
      pb = ar / (1.0 + ar/100.0);
   }   
   
   // individual trial
   if( mix < 0.0 || meas < 0.0 || cal < 0.0 )
       gmm = FLT_BLANK;
   else
   {
       tmp = mix + cal - meas;

       if( tmp > 0.0 )
           gmm = mix/tmp;              // Gmm - maximum specific gravity
   }                                   // mix / (mix + cal - meas)


   // averages of the two trials
   gmm = FLT_BLANK;                    // maximum specific gravity
   gse = FLT_BLANK;                    // effective specific gravity
 
   if( nt > 0 )                        // number of trials
   {
      meas = summeas/nt;               // avg measure
      cal = sumcal/nt;                 // avg calibration
      mix = summix/nt;                 // avg mix

      tmp = mix + cal - meas;          // avg mix + avg calibration - avg measure

      if( tmp > 0.0 )
	  {
         gmm = mix/tmp;                // avg mix / (avg mix + avg calibration - avg measure)

         if( gmm > 0.0 && pb >= 0.0 && _gb > 0.0 )
		 {
            tmp = 100.0/gmm - pb/_gb;  // (percent binder by mix / specific gravity of binder from DL906) ...I think
            
            if( tmp > 0.0 )
			{
               gse = (100.0 - pb)/tmp; // effective specific gravity
            }
         }
      }

 void LtT209_C1::CorGrpRoot::calcOverallGse()
 { 
   gse = cum/n; // cumulative / count 
 
 
 
 
,(first_value(LLavg.liquid_limit_floor_to_avg) over (partition by wl89seg.sample_id order by wl89seg.sample_id, wl89seg.segment_nbr))

-
************ use this!!
(last_value(PLavg.plastic_limit_floor_to_avg) over (partition by wl89seg.sample_id order by wl89seg.sample_id, wl89seg.segment_nbr
                                                     rows between unbounded preceding and unbounded following))

as Plasticity_Index


              FV   LV   PI
W-07-0187-AG  32   19   13
W-11-1275-AG  19   12   7


 
***********************************************************************************/



create or replace view V_T209_Specific_Gravity_Rices  as 

with T209_Trials_sql as (

--------------------------------------------------------------------------------
-- obtain the summations and averages of each Trial per each segment
-- and the specific gravity per Trial
--------------------------------------------------------------------------------

select  sample_id
       ,segment_nbr 
       
       ,case when (mass_mix_trial1 >= 0 and mass_mix_trial2 >= 0) then (mass_mix_trial1 + mass_mix_trial2)
             when (mass_mix_trial1 >= 0 and mass_mix_trial2  < 0) then (mass_mix_trial1)
             when (mass_mix_trial1  < 0 and mass_mix_trial2 >= 0) then (mass_mix_trial2)
             else -1 end as mass_mix_summ
       
       ,case when (mass_calibrated_trial1 >= 0 and mass_calibrated_trial2 >= 0) then (mass_calibrated_trial1 + mass_calibrated_trial2)
             when (mass_calibrated_trial1 >= 0 and mass_calibrated_trial2  < 0) then (mass_calibrated_trial1)
             when (mass_calibrated_trial1  < 0 and mass_calibrated_trial2 >= 0) then (mass_calibrated_trial2)
             else -1 end as mass_calibrated_summ
       
       ,case when (mass_measured_trial1 >= 0 and mass_measured_trial2 >= 0) then (mass_measured_trial1 + mass_measured_trial2)
             when (mass_measured_trial1 >= 0 and mass_measured_trial2  < 0) then (mass_measured_trial1)
             when (mass_measured_trial1  < 0 and mass_measured_trial2 >= 0) then (mass_measured_trial2)
             else -1 end as mass_measured_summ
       
       ,case when (mass_mix_trial1  > 0 and mass_mix_trial2  > 0) then ((mass_mix_trial1 + mass_mix_trial2)/2)
             when (mass_mix_trial1 >= 0 and mass_mix_trial2  < 0) then  (mass_mix_trial1)
             when (mass_mix_trial1  < 0 and mass_mix_trial2 >= 0) then  (mass_mix_trial2)
             else -1 end as mass_mix_avg
       
       ,case when (mass_calibrated_trial1  > 0 and mass_calibrated_trial2  > 0) then ((mass_calibrated_trial1 + mass_calibrated_trial2)/2)
             when (mass_calibrated_trial1 >= 0 and mass_calibrated_trial2  < 0) then (mass_calibrated_trial1)
             when (mass_calibrated_trial1  < 0 and mass_calibrated_trial2 >= 0) then (mass_calibrated_trial2)
             else -1 end as mass_calibrated_avg
       
       ,case when (mass_measured_trial1  > 0 and mass_measured_trial2  > 0) then ((mass_measured_trial1 + mass_measured_trial2)/2)
             when (mass_measured_trial1 >= 0 and mass_measured_trial2  < 0) then (mass_measured_trial1)
             when (mass_measured_trial1  < 0 and mass_measured_trial2 >= 0) then (mass_measured_trial2)
             else -1 end as mass_measured_avg
       
       ,case when ((mass_mix_trial1 >= 0 and mass_calibrated_trial1 >= 0 and mass_measured_trial1 >= 0) and 
                  ((mass_mix_trial1 + mass_calibrated_trial1 - mass_measured_trial1) > 0)) 
             then (mass_mix_trial1 / (mass_mix_trial1 + mass_calibrated_trial1 - mass_measured_trial1))
             else -1 end as maximum_specific_gravity1_gmm
       
       ,case when ((mass_mix_trial2 >= 0 and mass_calibrated_trial2 >= 0 and mass_measured_trial2 >= 0) and 
                  ((mass_mix_trial2 + mass_calibrated_trial2 - mass_measured_trial2) > 0)) 
             then (mass_mix_trial2 / (mass_mix_trial2 + mass_calibrated_trial2 - mass_measured_trial2))
             else -1 end as maximum_specific_gravity2_gmm
       
       from  Test_T209_Segments
)

--------------------------------------------------------------------------------
-- summation of Include indicators, used for the overal average Gse
--------------------------------------------------------------------------------

,T209_Include_count as (

select  sample_id
       ,sum(case when include_indicator = 'X' then 1 else 0 end) as Include_count_summ
       
  from  Test_T209_Segments
 group by sample_id 
)             

--------------------------------------------------------------------------------
-- main sql
--------------------------------------------------------------------------------

select  t209.sample_id                                          as T209_Sample_ID
       ,t209.sample_year                                        as T209_Sample_Year
       ,t209.test_status                                        as T209_Test_Status
       ,t209.tested_by                                          as T209_Tested_by
       
       ,case when to_char(t209.date_tested, 'yyyy') = '1959'    then ' '
             else to_char(t209.date_tested, 'mm/dd/yyyy')       end
                                                                as T209_date_tested
            
       ,t209.date_tested                                        as T209_date_tested_DATE
       ,t209.date_tested_orig                                   as T209_date_orig
       
       ,t209.customary_metric                                   as T209_customary_metric
       
       -- per my observation, this description seems to default to Agg, even if no other data is present
       ,case when t209.customary_metric = 'M' then '% Asphalt by Mix' 
             else '% Asphalt by Agg' end as T209_pct_asphalt_description
       
       ,case when v_dl906.DL906_specific_gravity_Gb is not null 
             then v_dl906.DL906_specific_gravity_Gb else -1 end as DL906_specific_gravity_Gb
       
       ,case when t209.gbfromdl906_captured is not null 
             then t209.gbfromdl906_captured         else ' ' end as DL906_specific_gravity_Gb_captured
       
       /*-----------------------------------------------------------------------
         front page segment display
       -----------------------------------------------------------------------*/
       
       -- not doing this, draw the data from the segments themselves,
       -- especially when displaying in the window
       
       /*-----------------------------------------------------------------------
         segments -- each segment may contain two trials
       -----------------------------------------------------------------------*/
       
       ,case when t209seg.segment_nbr            is not null then t209seg.segment_nbr            else  -1 end as T209_segment_nbr
       
       ,case when t209seg.Pct_Asphalt            is not null then t209seg.Pct_Asphalt            else  -1 end as T209_Pct_Asphalt
       
       ,case when t209seg.include_indicator      is not null then t209seg.include_indicator      else ' ' end as T209_include_indicator
       ,case when Include_count_summ             is not null then Include_count_summ             else  -1 end as T209_Include_count
       
       ,case when t209seg.mass_mix_trial1        is not null then t209seg.mass_mix_trial1        else  -1 end as T209_mass_mix_trial1
       ,case when t209seg.mass_calibrated_trial1 is not null then t209seg.mass_calibrated_trial1 else  -1 end as T209_mass_calibrated_trial1
       ,case when t209seg.mass_measured_trial1   is not null then t209seg.mass_measured_trial1   else  -1 end as T209_mass_measured_trial1
       ,case when t209seg.captured_sg_1          is not null then t209seg.captured_sg_1          else ' ' end as T209_captured_sg1 
       
       ,case when t209seg.mass_mix_trial2        is not null then t209seg.mass_mix_trial2        else  -1 end as T209_mass_mix_trial2
       ,case when t209seg.mass_calibrated_trial2 is not null then t209seg.mass_calibrated_trial2 else  -1 end as T209_mass_calibrated_trial2
       ,case when t209seg.mass_measured_trial2   is not null then t209seg.mass_measured_trial2   else  -1 end as T209_mass_measured_trial2
       ,case when t209seg.captured_sg_2          is not null then t209seg.captured_sg_2          else ' ' end as T209_captured_sg2 
       
       /*-----------------------------------------------------------------------
         T209_Trials_sql -- summations and averages
       -----------------------------------------------------------------------*/
       
       ,case when T209_Trials_sql.mass_mix_summ        is not null then T209_Trials_sql.mass_mix_summ        else  -1 end as T209_mass_mix_summ
       ,case when T209_Trials_sql.mass_mix_avg         is not null then T209_Trials_sql.mass_mix_avg         else  -1 end as T209_mass_mix_avg
       
       ,case when T209_Trials_sql.mass_calibrated_summ is not null then T209_Trials_sql.mass_calibrated_summ else  -1 end as T209_mass_calibrated_summ
       ,case when T209_Trials_sql.mass_calibrated_avg  is not null then T209_Trials_sql.mass_calibrated_avg  else  -1 end as T209_mass_calibrated_avg
       
       ,case when T209_Trials_sql.mass_measured_summ   is not null then T209_Trials_sql.mass_measured_summ   else  -1 end as T209_mass_measured_summ
       ,case when T209_Trials_sql.mass_measured_avg    is not null then T209_Trials_sql.mass_measured_avg    else  -1 end as T209_mass_measured_avg     
       
       /*-----------------------------------------------------------------------
         T209_Trials_sql -- maximum_specific_gravity_gmm
       -----------------------------------------------------------------------*/
       
       ,case when T209_Trials_sql.maximum_specific_gravity1_gmm is not null then T209_Trials_sql.maximum_specific_gravity1_gmm    
             else -1 end         as T209_maximum_specific_gravity1_gmm
       
       ,case when T209_Trials_sql.maximum_specific_gravity2_gmm is not null then T209_Trials_sql.maximum_specific_gravity2_gmm    
             else -1 end         as T209_maximum_specific_gravity2_gmm
       
       ,avg_specific_gravity_gmm as T209_avg_specific_gravity_gmm
       
       ,case when t209seg.avg_sg_captured     is not null then t209seg.avg_sg_captured      else ' ' end as T209_avg_sg_captured
       ,case when t209seg.avg_eff_sg_captured is not null then t209seg.avg_eff_sg_captured  else ' ' end as T209_avg_eff_sg_captured
       
       /*-----------------------------------------------------------------------
         percent binder is an intermediate step and is not displayed
         Average Gse, effective specific gravity
       -----------------------------------------------------------------------*/
       
       ,percent_binder_Pb                                       as T209_percent_binder_Pb
       ,avg_effective_specific_gravity_gse                      as T209_Avg_GSE_per_segment
       
       ,sum ( case when avg_effective_specific_gravity_gse >= 0 and t209seg.include_indicator = 'X'
                   then avg_effective_specific_gravity_gse else 0 end  /Include_count_summ )
                   
              over (partition by t209.sample_id order by t209.sample_id, t209seg.segment_nbr) -- /Include_count_summ )
                                                                as T209_overall_average_Gse
       
       ,t209.overallavggse_captured                             as T209_overall_avg_Gse_captured
       
       -- W-88-0350-AC (one sample)
       ,case when t209seg.captured_specific_gravity is not null 
             then t209seg.captured_specific_gravity else ' ' end as T209_captured_specific_gravity
       
       ,t209.remarks                                            as T209_remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_T209                                     t209 on t209.sample_id = smpl.sample_id
       
       left join V_DL906_Asphalt_Binder_Information    v_dl906 on t209.sample_id = v_dl906.DL906_Sample_ID
       
       left join Test_T209_Segments                    t209seg on t209.sample_id = t209seg.sample_id
       
       left join T209_Trials_sql                               on t209seg.sample_id   = T209_Trials_sql.sample_id 
                                                              and t209seg.segment_nbr = T209_Trials_sql.segment_nbr 
       
       left join T209_Include_count                            on t209seg.sample_id   = T209_Include_count.sample_id 
       
       /*-----------------------------------------------------------------------
         average specific gravity
         avg gmm = avg mix /(avg mix + avg cal - avg meas) ...where denom > 0
       -----------------------------------------------------------------------*/
       
       cross apply (select 
         case when ( T209_Trials_sql.maximum_specific_gravity1_gmm  > 0 and T209_Trials_sql.maximum_specific_gravity2_gmm  > 0)
              then ((T209_Trials_sql.maximum_specific_gravity1_gmm + T209_Trials_sql.maximum_specific_gravity2_gmm)/2)
            
              when (T209_Trials_sql.maximum_specific_gravity1_gmm  > 0 and T209_Trials_sql.maximum_specific_gravity2_gmm <= 0)
              then (T209_Trials_sql.maximum_specific_gravity1_gmm)
            
              when (T209_Trials_sql.maximum_specific_gravity1_gmm <= 0 and T209_Trials_sql.maximum_specific_gravity2_gmm  > 0)
              then (T209_Trials_sql.maximum_specific_gravity2_gmm)
            
              else -1 end as avg_specific_gravity_gmm from dual) avgsg
       
       /*-----------------------------------------------------------------------
         percent binder - an intermediate step, not displayed
         
         double ar = getNum(LaufX::xRatio); (percent asphalt from segment)
         
         if( _isbymix )
            pb = ar;
         else if( ar >= 0.0 )
            pb = ar / (1.0 + ar/100.0); // convert As/Agg to As/Mix
         else
            pb = FLT_BLANK;         
       -----------------------------------------------------------------------*/
       
       cross apply (select case when (t209.customary_metric = 'M' and t209seg.Pct_Asphalt > 0) 
                                then t209seg.Pct_Asphalt 
         
                                when (t209seg.Pct_Asphalt > 0) 
                                then (t209seg.Pct_Asphalt / (1.0 + (t209seg.Pct_Asphalt * 0.01)))
                                
                                else -1 end as percent_binder_Pb from dual) pb 
       
       /*-----------------------------------------------------------------------
         gse, effective specific gravity, per segment
         
         if( gmm > 0.0 && pb >= 0.0 && _gb > 0.0 )
		 {
            tmp = 100.0/gmm - pb/_gb;

            if( tmp > 0.0 )
               gse = (100.0 - pb)/tmp;
         }
       -----------------------------------------------------------------------*/
       
       cross apply (select 
       
         case when ( v_dl906.DL906_specific_gravity_Gb is not null and 
                     v_dl906.DL906_specific_gravity_Gb         > 0 and 
                     percent_binder_Pb                        >= 0 and 
                     avg_specific_gravity_gmm                  > 0
                     )
              
              then case when ((100.0/avg_specific_gravity_gmm) - (percent_binder_Pb/v_dl906.DL906_specific_gravity_Gb)) > 0
              
                        then ((100.0 - percent_binder_Pb) / 
                             ((100.0/avg_specific_gravity_gmm) - (percent_binder_Pb/v_dl906.DL906_specific_gravity_Gb)))
                        
                        else -1 end
                                
              else -1 end as avg_effective_specific_gravity_gse from dual) gse 
       
       
       order by
       t209.sample_id,
       t209seg.segment_nbr
       ;









