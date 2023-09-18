

/*--------------------------------------------------------------------------------

 this needs a little work
 
 determine the the significance of batch fines only, X
 
 determine the the significance of percent fines, esp >95% 
 if( result >= 95.0 ) isadjustable = true;
 
 also, need to add the WL640 Raw Gradation grid to the Window, but that
 is easy enough to do. the reason that the entire WL640 coarse sieves 
 were not pulled in, is that only sieves < 3/4" (19.0 mm) are used
 in the Batch grid

--------------------------------------------------------------------------------*/



select * from V_WL644_Prep_for_Resistance_Value where WL644_sample_id = 

 'W-21-0112-SO'
-- 'W-21-0902-GS'
-- 'W-20-0015'
-- 'W-20-0267'
-- 'W-20-0760-SO'
-- 'W-19-1509-SO'
-- 'W-18-2392-SO'
-- 'W-17-0317-SO'
-- 'W-16-0463-SO'
-- 'W-15-0012-SO'
;

 
 

----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_WL644 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
--  803	    2002	2021



select * from test_wl644 order by sample_year desc, sample_id;




 select * from test_wl644 where batch_weight <= 0 
  order by sample_year desc, sample_id
  ;
 
 -- 20 records, all are -1, no records have a batch weight of 0
 
/**
W-15-0203-SO -- only sample with batch_fines_only that is checked
W-13-1167-SO -- no batch wt sieves listed
W-10-0710-SO
W-08-0329-SO
W-06-0029-SO
W-06-0134-SO
W-06-0781-SO
W-05-1015-SO
W-05-1017-SO
W-05-1023-SO
W-04-0758-SO
W-04-0759-SO
W-04-0782-SO
W-03-0896-SO
W-03-1274-SO
W-02-0808-SO
W-02-0811-SO
W-02-0814-SO
W-02-0816-SO
W-02-0818-SO
**/
 
 

 select * from test_wl644 where batch_fines_only = 'X'
  order by sample_year desc, sample_id
  ;
  
 -- 9 records, 3 situations
 
 -- only Pan is in the batch wt grid and is the batch wt
 -- W-18-1861-SO, W-18-1865-SO, W-18-1872-SO
 -- W-14-1538-SO, W-14-1546-SO, W-14-1547-SO, W-14-1548-SO
 
 -- W-15-0203-SO - batch wt is not listed, no sieves are in the grid
 -- (I do not think that anything can be done with this)
 
 -- W-08-0174-SO - batch wt is listed, but no sieves are in the grid
 -- (I do not think that anything can be done with this)
 
 
 

select * from mlt_sieve_size;




/***********************************************************************************

 V_WL644_Prep_for_Resistance_Value
 
 from MTest, Lt_WL644_BC.cpp
 
 bool LtWL644_BC::CorGrpRoot::calcPctFines()
 {
   // calculate percent fines in raw gradation
   if( totfines >= 0.0 )                                // already available in: 
       result = 100.0 * totfines / (totfines + totcse); // V_WL640_Prep_Raw_Gradation.WL640_calc_pct_fines
       if( result >= 95.0 ) isadjustable = true;
 
 void LtWL644_BC::CorGrpRoot::calcBat()
 {
   if( batwt <= 0.0 ) return;                           // "Batch weight" <= 0

   int xrr = 0;                                         // index to raw gradation row (WL640 coarse sieves)
   int xrb = 0;                                         // index to Batch row
   
   if( dofinesonly )                                    // "Batch fines only" box is checked
   {
      asvs = <array of one sieve size>                  // asvs is sieve size
      arawwts = <array of one weight>                   // arawwts is mass retained
   }
   else
   {
      <get WL640 coarse sieves>
      <get number of coarse sieves> nRaw
      
      if( nRaw > 0 )
      {
         asvs = <create new empty array of size nRaw+1> // nRaw+1: add one for the Fines
         arawwts = new double[nRaw+1];                  //array of sieve masses retained
      }
      
      for(;;++xrr)                                      // xrr, raw gradation row
      {
         //get coarse sieve values less than 3/4", 19.0mm
         if( sv >= 19.0 ) continue;                     // skip sieves >= 3/4" (19.0mm), sv is numeric(metric), not a string
         if( sv < SV_NR4 ) break;                       // #4 = 4.75mm, Raw Gradation should contain sieves >= #4
         sm = <get sieve size>                          // sieve_size, a string
         asvs[xrb] = sm;                                // add sieve size to the array, where sieve size < 3/4" (19.0mm)
         
         -----------------------------------------------------
         -- no need for the four statements above 
         -- simply capture the correct rows using SQL
         -- MLT_sieve_size Oracle table, below
         -----------------------------------------------------
         desc MLT_sieve_size;                 example
         SIEVE_CUSTOMARY       VARCHAR2(10)   #4
         SIEVE_METRIC          VARCHAR2(10)   4.75mm
         SIEVE_METRIC_IN_MM    NUMBER(6,3)    4.75
         
         wt = <get sieve mass retained>                 // where sieve size < 3/4" (19.0mm)
         if( wt < 0.0 ) wt = 0.0;
         if( wt > 0.0 ) totwtsummed += wt;              // total wt of material available for batching
         
         arawwts[xrb++] = wt;                           // I do not like [xrb++], break this into two steps
                                                        // [xrb] and THEN xrb++ (increment AFTER the assignment to arawwts, 
                                                        // not in the same step, most annoying) 
                                                        // so, 
                                                        // arawwts[xrb] = wt;
                                                        // xrb++;
      }
      if( xrb == 0 )                                    // No appropriate coarse sieves in the raw gradation
          return;                                       // no sieves < 3/4"
   }

   cda = <get WL640 Fines>
   wt  = <get WL640 Fines>
   if( wt < 0.0 )                                       // WL640 Fines must be >= 0
       return;
   
   asvs[xrb] = gcnew String("Pan");                    // add 'Pan' to the array of sieve sizes
   arawwts[xrb] = wt;                                  // add mass of Fines to the array of sieve masses -- 36075
   totwtsummed += wt;                                  // add mass of Fines to totwtsummed               -- 36832.4
   nBat = xrb + 1;                                     // in case not all table rows were used

   if( batwt > totwtsummed )                           // "Batch weight" > totwtsummed
   {
      return;

   awts = new double[nBat];
   acumwts = new double[nBat];
   
   // calculate batch wts
   double cumwt = 0.0;
   double factor = batwt / totwtsummed;
   
   for( xrb = 0; xrb < nBat; ++xrb )
   {
      wt = (arawwts[xrb] > 0.0) ? arawwts[xrb]*factor : 0.0;
      
      if( wt > 0.0 ) cumwt += wt;
      awts[xrb] = wt;
      acumwts[xrb] = cumwt;
   }

 
***********************************************************************************/



create or replace view V_WL644_Prep_for_Resistance_Value as 

--------------------------------------------------------------------------------
-- V_WL640_Prep_Raw_Gradation segment values 
--------------------------------------------------------------------------------

with v_wl640_segments as (

         select  WL640_Sample_ID       as sample_id
                ,WL640_segment_nbr     as segment_nbr
                ,WL640_sieve_size      as sieve_size
                ,WL640_mass_retained   as mass_retained
                
           from  V_WL640_Prep_Raw_Gradation
          where  sieve_metric_in_mm < 19
          
         union
         
         select  WL640_Sample_ID       as sample_id
                ,99                    as segment_nbr
                ,'Pan'                 as sieve_size
                ,WL640_mass_of_fines   as mass_retained
                
           from  V_WL640_Prep_Raw_Gradation
)
 
--------------------------------------------------------------------------------
-- V_WL640_Prep_Raw_Gradation summation values
-- the variable, totwtsummed, is from MTest, Lt_WL644_BC.cpp, calcBat()
--------------------------------------------------------------------------------

,v_wl640_summation as (

         select  WL640_Sample_ID
                ,WL640_Mass_Total
                ,WL640_mass_retained_summ_coarse
                
                ,WL640_mass_of_fines
                ,WL640_calc_pct_fines 
                ,WL640_calc_mass_LT_19mm                
                
                ,case when (WL640_mass_of_fines > 0 and WL640_calc_mass_LT_19mm > 0)
                      then (WL640_mass_of_fines + WL640_calc_mass_LT_19mm)
                      else -1 end 
                      as totwtsummed
                      
                ,sieve_customary
                ,sieve_metric
                ,sieve_metric_in_mm
                
           from  V_WL640_Prep_Raw_Gradation
          where  WL640_segment_nbr = 1
)
 
--------------------------------------------------------------------------------
-- main SQL
--------------------------------------------------------------------------------

select  wl644.sample_id                                        as WL644_sample_id
       ,wl644.sample_year                                      as WL644_sample_year
       ,wl644.test_status                                      as WL644_test_status
       ,wl644.tested_by                                        as WL644_tested_by
       
       ,case when to_char(wl644.date_tested, 'yyyy') = '1959'  then ' '
             else to_char(wl644.date_tested, 'mm/dd/yyyy') end as WL644_date_tested
       
       ,wl644.date_tested                                      as WL644_date_tested_DATE
       ,wl644.date_tested_orig                                 as WL644_date_orig
       
       /*----------------------------------------------------
         WL644 Batch weight values
       ----------------------------------------------------*/
       
       ,wl644.batch_weight                                     as WL644_batch_weight
       ,wl644.batch_fines_only                                 as WL644_batch_fines_only
       ,factor                                                 as WL644_factor
       
       /*----------------------------------------------------
         WL644 Batch weight sieves (from WL640)
       ----------------------------------------------------*/
       
       ,v_wl640_segments.segment_nbr                           as WL644_Batch_segment_nbr
       ,v_wl640_segments.sieve_size                            as WL644_Batch_sieve_size
       ,v_wl640_segments.mass_retained                         as WL640_mass_retained
       ,Batch_mass_retained                                    as WL644_Batch_weight_mass_retained
       
       ,sum(case when Batch_mass_retained > 0 then Batch_mass_retained else 0 end)
            over (partition by wl644.sample_id order by wl644.sample_id, v_wl640_segments.segment_nbr)
                                                               as WL644_batch_weight_cumulative_mass
       
       /*----------------------------------------------------
         WL640 summation calculations
       ----------------------------------------------------*/
       
       ,v_wl640_summation.totwtsummed                          as WL644_totwtsummed
       ,v_wl640_summation.WL640_mass_of_fines                  as WL640_mass_of_fines
       ,v_wl640_summation.wl640_calc_pct_fines                 as WL640_percent_fines 
       
       ,v_wl640_summation.WL640_Mass_Total                     as WL640_Mass_Total
       ,v_wl640_summation.WL640_mass_retained_summ_coarse      as WL640_Mass_summ_coarse
        
       ,wl644.remarks                                          as wl644_remarks
       
       /*----------------------------------------------------
         table relationships
       ----------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_WL644                                   wl644 on wl644.sample_id = smpl.sample_id
       join v_wl640_segments                                   on wl644.sample_id = v_wl640_segments.sample_id
       join v_wl640_summation                                  on wl644.sample_id = v_wl640_summation.WL640_Sample_ID
       
       /*----------------------------------------------------
         calculations
       ----------------------------------------------------*/
       
       cross apply 
       (select case when (v_wl640_summation.totwtsummed > wl644.batch_weight and wl644.batch_weight > 0)
                    then (wl644.batch_weight / v_wl640_summation.totwtsummed)
                    else 0 end as factor from dual) batchfactor
       
       cross apply 
       (select (v_wl640_segments.mass_retained * factor) as Batch_mass_retained from dual) batch_massret
       
       
       order by 
       wl644.sample_id,
       v_wl640_segments.segment_nbr
;

 







