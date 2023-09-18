



select * from V_WL645_Prep_for_Moisture_Determination where wl645_sample_id = 

-- 'W-21-0139-AG'
 'W-21-0224-SO'
-- 'W-21-0304-SAA'
-- 'W-21-0441-SA' 
-- 'W-20-0682-SO'
-- 'W-20-0721-SO'
-- 'W-20-0737-SO'
-- 'W-19-0346-SO'
-- 'W-19-0397-SO' 
-- 'W-18-0763-AG'
-- 'W-17-0443-SO'
-- 'W-16-0464-SO'

order by WL645_sample_id, WL645_Batch_segment_nbr
;


-- 'W-07-0063-SO' a good example


select * from V_WL645_Prep_Moisture_Determination
 order by wl645_sample_year desc, wl645_sample_id, wl640_segment_nbr
;





--                                                  count    minYr   maxYr
-- WL640 Raw Gradation                    (current) 9062     1999    2019
-- WL641 Prep Generic Gradation           (current)   14     2003    2020
-- WL642 Prep for Coarse Wash             (current)  239     2002    2019
-- WL643 Prep for Hydrometer Analysis     (current) 8666     1985    2019
-- WL644 Prep for R-Value (T190)          (current)  764     2002    2019
-- WL645 Prep for Moisture Determinations (current)  221	 2002	 2020


----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_WL645 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 233	    2002	2021
 


select sample_year, count(sample_year) 
  from Test_WL645
 group by sample_year
 order by sample_year desc
 ;
/****

2021	11
2020	26
2019	13
2018	15
2017	11
2016	6
2015	10
2014	22
2013	7
2012	9
2011	16
2010	11
2009	10
2008	8
2007	15
2006	8
2005	10
2004	18
2003	2
2002	5
1960	1

****/



select * from test_wl645 order by sample_year desc, sample_id;



/***********************************************************************************

 V_WL645_Prep_Moisture_Determination
 
 from MTest, Lt_WL64d_BC.cpp
 ---------------------------
 WL641, WL642, WL645 use the same form
 WL641: generic batch       no distinct calcs
 WL642: prep for WL411      no distinct calcs
 WL645: prep for T99/T180   specific calcs
 
 
 int LtWL64d_BC::getExternalData(bool initial) {
 // Get raw gradation data (from WL640)
 
 
 void LtWL64d_BC::CorGrpRoot::calcsOveradj() {
 //WL645 uses this version to calculate the batch wts:
 
 Get the raw gradation data, the requested batch wt...
 Calculations as of 2005-01-20
     
 Oversize = sum of weights retained on sieves >= 3/4", 19.0mm
 aselwts  = an array of wts retained < 3/4", 19.0mm
 nr       = number of elements in aselwts
     
 overadj  = Oversize / nr
   (overadj is an adjustment for the excluded oversize material:
    the amount of oversize material is distributed equally among the
    non-pan sieves -- i.e, additional material from the sieve sizes
    used is added, to make up the quantity of oversize material not used)
     
 Adjust aselwts by adding overadj to each element
 
 sumadjsel    = sum of aselwts after adjustment + Mass of Fines     (my notes: this is total mass)
 batch factor = batch wt / sumadjsel
 
 -------------------------------------------------------------------------------
 
 getTblRaw();                         // WL640 raw gradation coarse sieves
 nRaw = cdt->getnRows();              // nbr of coarse sieve rows
 asvs = gcnew array<String^>(nRaw+1); // add the mass of fines ('Pan') to the sieve array
 awts = new double[nRaw+1];           // add the mass of fines to the mass array
 
 if (sv >= 19.0)
    if (wt > 0.0) hugewt += wt;       // accumulate wt of sample >= 3/4" or 19.0mm
 else
    if (wt > 0.0) totwtadj += wt;     // accumulate wt of sample  < 3/4" or 19.0mm
    
 totwtadj += awts[xr];                // add mass of fines (Pan) to totwtadj
 
 if( nBat > 1 && hugewt > 0.0 ) 
     overage = hugewt/(nBat-1);       // divide mass >= 3/4" by nbr of sieves < 3/4" (but exclude counting the Pan)
     awts[xr] += overage;             // add this overage to each sieve < 3/4" (but not the Pan, aka mass of fines)
 
 factor = batwt / totwtadj            // WL645 batch weight / WL640 total mass
 
 for( xr = 0; xr < nBat; ++xr )       // for each sieve (including the Pan)
      awts[xr] * factor               // multiply by the factor to achieve the mass retained in the Batch grid
      cumwt += wt;                    // obtain cumulative mass
      acumwts[xr] = cumwt;            // display cumulative mass
 
     
***********************************************************************************/


 
create or replace view V_WL645_Prep_for_Moisture_Determination as 

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
--------------------------------------------------------------------------------

,v_wl640_summation as (

         select  WL640_Sample_ID
                ,WL640_Mass_Total
                ,WL640_mass_retained_summ_coarse
                
                ,WL640_mass_of_fines        -- Pan
                ,WL640_calc_pct_fines 
                
                ,WL640_calc_mass_GTE_19mm   -- hugewt
                ,WL640_calc_count_GTE_19mm
                
                ,WL640_calc_mass_LT_19mm    -- totwtadj, preliminary
                ,WL640_calc_count_LT_19mm
                
                ,WL640_calc_overadj         -- overadj = Oversize / nr
                                            -- = WL640_calc_mass_GTE_19mm / WL640_calc_count_LT_19mm
                
           from  V_WL640_Prep_Raw_Gradation
          where  WL640_segment_nbr = 1
)
 
--------------------------------------------------------------------------------
-- main SQL
--------------------------------------------------------------------------------

select  WL645.sample_id                                        as WL645_sample_id
       ,WL645.sample_year                                      as WL645_sample_year
       ,WL645.test_status                                      as WL645_test_status
       ,WL645.tested_by                                        as WL645_tested_by
       
       ,case when to_char(wl645.date_tested, 'yyyy') = '1959' then ' '
             else to_char(wl645.date_tested, 'mm/dd/yyyy') end as WL645_date_tested
       
       ,wl645.date_tested                                      as WL645_date_tested_DATE
       ,wl645.date_tested_orig                                 as WL645_date_orig
       
       /*----------------------------------------------------
         WL645 Batch weight values
       ----------------------------------------------------*/
       
       ,wl645.batch_weight                                     as WL645_batch_weight
       ,factor                                                 as WL644_factor_batwt_over_totalmass
                                                               --(wl645.batch_weight / WL640_Mass_Total)
       
       /*----------------------------------------------------
         WL645 Batch weight sieves (from WL640)
       ----------------------------------------------------*/
       
       ,v_wl640_segments.segment_nbr                           as WL645_Batch_segment_nbr
       ,v_wl640_segments.sieve_size                            as WL645_Batch_sieve_size
       ,v_wl640_segments.mass_retained                         as WL640_mass_retained
       
       ,v_wl640_summation.wl640_calc_overadj                   as WL640_overage
       
       ,v_wl640_segments.mass_retained + v_wl640_summation.wl640_calc_overadj
                                                               as WL645_mass_ret_plus_overage
                                                               
       ,Batch_mass_retained                                    as WL645_Batch_weight_mass_retained
                                                               --(WL645_mass_ret_plus_overage * factor)
       
       ,sum(case when Batch_mass_retained > 0 then Batch_mass_retained else 0 end)
            over (partition by wl645.sample_id order by wl645.sample_id, v_wl640_segments.segment_nbr)
                                                               as WL645_batch_weight_cumulative_mass
       
       ,WL645.remarks                                          as WL645_remarks
       
       /*----------------------------------------------------
         WL640 summation calculations
       ----------------------------------------------------*/
       
       ,v_wl640_summation.WL640_Mass_Total                     as WL640_Mass_Total
       ,v_wl640_summation.WL640_mass_retained_summ_coarse      as WL640_Mass_summ_coarse
       ,v_wl640_summation.WL640_mass_of_fines                  as WL640_mass_of_fines
       ,v_wl640_summation.wl640_calc_pct_fines                 as WL640_percent_fines 
       
       ,v_wl640_summation.wl640_calc_mass_GTE_19mm             as wl640_oversize_mass
       ,v_wl640_summation.wl640_calc_count_GTE_19mm            as wl640_oversize_count
       ,v_wl640_summation.wl640_calc_mass_LT_19mm              as wl640_LT_19mm_mass
       ,v_wl640_summation.wl640_calc_count_LT_19mm             as wl640_LT_19mm_count
       
       /*----------------------------------------------------
         table relationships
       ----------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_WL645                                   wl645 on wl645.sample_id = smpl.sample_id
       join v_wl640_segments                                   on wl645.sample_id = v_wl640_segments.sample_id
       join v_wl640_summation                                  on wl645.sample_id = v_wl640_summation.WL640_Sample_ID
  
       /*----------------------------------------------------
         calculations
       ----------------------------------------------------*/
       
       cross apply 
       (select case when (v_wl640_summation.WL640_Mass_Total > wl645.batch_weight and wl645.batch_weight > 0)
                    then (wl645.batch_weight / v_wl640_summation.WL640_Mass_Total)
                    else 0 end as factor from dual) batchfactor
                    
       cross apply (select case when v_wl640_segments.sieve_size <> 'Pan'
                                
                                then case when (v_wl640_segments.mass_retained       > 0 and 
                                                v_wl640_summation.WL640_calc_overadj > 0)
                                          then ((v_wl640_segments.mass_retained + v_wl640_summation.WL640_calc_overadj) * factor)
                                          else 0 
                                          end
                                          
                                else (v_wl640_summation.WL640_mass_of_fines * factor) -- Pan
                                end
                                as Batch_mass_retained from dual) batch_massret
       
       order by 
       wl645.sample_id,
       v_wl640_segments.segment_nbr
;









