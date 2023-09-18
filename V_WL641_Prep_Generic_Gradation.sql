


--                                                  count    minYr   maxYr
-- WL640 Raw Gradation                    (current)  9392	 1999	 2020
-- WL641 Prep Generic Gradation           (current)   14	 2003	 2020
-- WL642 Prep for Coarse Wash             (current)  239     2002    2019
-- WL643 Prep for Hydrometer Analysis     (current) 8666     1985    2019
-- WL644 Prep for R-Value (T190)          (current)  764     2002    2019
-- WL645 Prep for Moisture Determinations (current)  196     2002    2019



select * from V_WL641_Prep_Generic_Gradation
 order by WL641_sample_year desc, WL641_sample_id, WL641_WL640_segment_nbr
 ;
 
 
 
 
----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_WL641 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 14	    2003	2020



select * from Test_WL641 order by sample_year desc, sample_id;

/** 15 samples
                                                    batch wt    fines   total mass
W-20-0314	    2020	COM	 	01-JAN-59	 	        1500	0	    -1	 
W-18-1852-SO	2018	COM	 	01-JAN-59	 	        1500	0	    -1	 
W-17-0001-AG	2017	COM	EW	06-JAN-17	01062017	1000	0	    23621.9	 
W-17-0006-AG	2017	COM	wfs	10-JAN-17	01102017	1000	0	    11763.2	 
W-17-1940-AG	2017	COM	cm	01-NOV-17	110117	    2700	54244.2	120756.4	 
W-16-0464-SO	2016	COM	cm	28-JUN-16	062816	    3000	6880.7	21559.5	 
W-11-0141-AG	2011	COM	BRR	13-JUN-11	061311	    2700	1720.6	6033.8	 
W-10-1851-AG	2010	COM	BRR	02-NOV-10	11022010	2700	237.8	12133.9	 
W-10-1935-AG	2010	COM	BRR	09-NOV-10	110910	    2700	247.8	11257.5	 
W-06-0112-AG	2006	COM	CM	15-MAY-06	51506	    2700	7683.2	27298.5	 
W-06-0296-AG	2006	COM	cm	25-JUL-06	072506	    2700	162.7	10730.3	 
W-06-0322-AG	2006	COM	 	01-JAN-59	 	        -1	    447.2	9937.8	 
W-06-0726-SO	2006	COM	wfs	18-SEP-06	091806	    3200	20717	20718.2	 
W-03-0887-SO	2003	COM	WS	07-OCT-03	100703	    6000	33080	34221.5	 
W-60-0011-AG	1960	NC	 	01-JAN-59	 	        1075	6616.4	30794.8	 
**/



   select sample_year, count(sample_year) from Test_WL641
 group by sample_year
 order by sample_year desc
 ;
/**
2020	1
2018	1
2017	3
2016	1
2011	1
2010	2
2006	4
2003	1
1960	1
**/



/***********************************************************************************

 WL641 Prep Generic Gradation
 
 15 samples
 W-20-0314,    W-18-1852-SO, W-17-1940-AG, W-17-0006-AG, W-17-0001-AG
 W-16-0464-SO, W-11-0141-AG, W-10-1851-AG, W-10-1935-AG, W-06-0322-AG
 W-06-0296-AG, W-06-0112-AG, W-06-0726-SO, W-03-0887-SO, W-60-0011-AG
 
 
 from MTest, Lt_WL64d_BC.cpp
 ---------------------------
 
 WL641, WL642, WL645 use the same form
 WL641: generic batch       no distinct calcs
 WL642: prep for WL411      no distinct calcs
 WL645: prep for T99/T180   specific calcs
 
 void doCalcs(){ _useOveradjCalcs? calcsOveradj() : calcsStd(); }
 
 void LtWL64d_BC::CorGrpRoot::calcsStd() { // Calcs for WL641, WL642

   // calculate batch wts
   double cumwt = 0.0;   
   double factor = batwt / totwtsummed;    // batch weight / WL640 total mass, or WL640 coarse mass if fines are 0

   for( xr = 0; xr < nBat; ++xr )
   {
      val = (arawwts[xr] > 0.0)? arawwts[xr]*factor : 0.0;
      if( val > 0.0 ) cumwt += val;
      awts[xr] = val;
      acumwts[xr] = cumwt;
   }
 
 
 -- from MTest: all files associated to the WL640 series
 Lt_WL640_BC.cpp, Lt_WL643_BC.cpp, Lt_WL644_BC.cpp, Lt_WL64d_BC.cpp (for 641,642,645), svPrep.h 
 mtForms02_E3: WL640Form_BC.cs, WL643Form_BC.cs, WL644Form_BC.cs, WL64dForm_BC.cs
 

***********************************************************************************/



/***********************************************************************************

 V_WL641_Prep_Generic_Gradation
 
***********************************************************************************/



create or replace view V_WL641_Prep_Generic_Gradation as 

with v_wl640 as (
    
         select  WL640_Sample_ID
                ,WL640_mass_of_fines
                ,WL640_Mass_Total
                ,WL640_mass_retained_summ_coarse -- not displayed in WL641
             
           from  V_WL640_Prep_Raw_Gradation
          where  WL640_segment_nbr = 1
)

--------------------------------------------------
--  main sql
--------------------------------------------------

select  wl641.sample_id                         as WL641_sample_id
       ,wl641.sample_year                       as WL641_sample_year
       ,wl641.test_status                       as WL641_test_status
       ,wl641.tested_by                         as WL641_tested_by
       
       ,case when to_char(wl641.date_tested, 'yyyy') = '1959' then ' '
             else to_char(wl641.date_tested, 'mm/dd/yyyy') end
                                                as WL641_date_tested
            
       ,wl641.date_tested                       as WL641_date_tested_DATE
       ,wl641.date_tested_orig                  as WL641_date_orig
       
       ,wl641.wl640_mass_of_fines               as WL641_WL640_mass_of_fines -- source WL640
       ,wl641.wl640_mass_total                  as WL641_WL640_mass_total    -- source WL640
       
       /*----------------------------------------------------
         WL640 summation calculations
       ----------------------------------------------------*/
       
       ,v_wl640.WL640_mass_of_fines             as WL640_mass_of_fines
       ,v_wl640.WL640_Mass_Total                as WL640_Mass_Total
       ,v_wl640.WL640_mass_retained_summ_coarse as WL640_mass_retained_summ_coarse
       
       /*----------------------------------------------------
         WL641 batch weight and factor
         factor = batch weight / WL640 total mass, or WL640 coarse mass if fines are 0
       ----------------------------------------------------*/
       
       ,wl641.batch_weight                      as WL641_batch_weight                                                
       ,WL641_factor                            as WL641_factor
       
       /*----------------------------------------------------
         WL640 Raw Gradation and WL641 Batch sieves
       ----------------------------------------------------*/
       
       ,wl640seg.segment_nbr                    as WL641_WL640_segment_nbr
       ,wl640seg.sieve_size                     as WL641_WL640_sieve_size
       ,wl640seg.mass_retained                  as WL641_WL640_mass_retained
       
       ,calc_batch_mass_retained                as WL641_batch_weight_mass_retained
       
       ,sum(case when calc_batch_mass_retained > 0 then calc_batch_mass_retained else 0 end)
            over (partition by wl641.sample_id order by wl641.sample_id, wl640seg.segment_nbr)
                                                as WL641_batch_weight_mass_cumulative
                                              
       ,wl641.remarks                           as WL641_remarks
       
  /*----------------------------------------------------------------
    table relationships
  ----------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                  smpl
  join Test_WL641                         wl641 on wl641.sample_id = smpl.sample_id
  join v_wl640                                  on wl641.sample_id = v_wl640.WL640_Sample_ID
  left join Test_WL640_segments        wl640seg on wl641.sample_id = wl640seg.sample_id
    
  /*----------------------------------------------------------------
    factor: factor = batwt / totwtsummed;
  ----------------------------------------------------------------*/
  
  cross apply (select case when wl641.batch_weight > 0 and v_wl640.WL640_Mass_Total > 0
  
                           then case when (wl641.wl640_mass_of_fines > 0) 
                                     then (wl641.batch_weight / v_wl640.WL640_Mass_Total)
                                     
                                     when (wl641.wl640_mass_of_fines = 0 and v_wl640.WL640_mass_retained_summ_coarse > 0) 
                                     then (wl641.batch_weight / v_wl640.WL640_mass_retained_summ_coarse)
                           
                                     else -1
                                     end 
                                     
                           else -1 -- W-06-0322-AG (sole sample)
                           end as WL641_factor from dual  
  ) calc_factor
    
  /*----------------------------------------------------------------
    for each sieve size: 
    batch wt mass retained = factor * raw gradation mass retained
  ----------------------------------------------------------------*/
  
  cross apply (select case when wl640seg.sieve_size is not null and wl641_factor > 0
  
                           then case when wl640seg.sieve_size <> '#4-' -- coarse sieves
                                     then case when wl640seg.mass_retained > 0 
                                               then (wl641_factor * wl640seg.mass_retained) 
                                               else 0 end
                                     
                                     -- wl640seg.sieve_size = '#4-' fine sieves
                                     else case when wl641.wl640_mass_of_fines > 0 
                                               then (wl641_factor * wl641.wl640_mass_of_fines) 
                                               else 0 end
                                     end
                           
                           else -1
                           end as calc_batch_mass_retained from dual 
  ) calc_batch_mass_ret
  
  order by 
  wl641.sample_id, 
  wl640seg.segment_nbr
  ;
              
              







