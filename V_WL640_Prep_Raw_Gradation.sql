


--                                                  count    minYr   maxYr
-- WL640 Raw Gradation                    (2020)    9392	 1999	 2020
-- WL641 Prep Generic Gradation           (current)   13     2003    2018
-- WL642 Prep for Coarse Wash             (current)  239     2002    2019
-- WL643 Prep for Hydrometer Analysis     (current) 8666     1985    2019
-- WL644 Prep for R-Value (T190)          (current)  764     2002    2019
-- WL645 Prep for Moisture Determinations (current)  196     2002    2019



select * from V_WL640_Prep_Raw_Gradation order by WL640_Sample_Year desc, WL640_Sample_ID, WL640_segment_nbr
;



select * from V_WL640_Prep_Raw_Gradation where WL640_Sample_ID in ( 
 'W-20-1471-SO', 'W-19-0004-SO', 'W-18-0732-AG', 'W-20-0718-AG',
 'W-16-0192-SO', 'W-02-0785-SO', 'W-16-0198-SO' 
)
order by WL640_Sample_Year desc, WL640_Sample_ID, WL640_segment_nbr
;
 


----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_WL640 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 9392	    1999	2020



select * from Test_WL640 order by sample_year desc;



select * from Test_WL640_segments order by sample_id, segment_nbr;



select * from Test_WL640_segments where sample_id like '%-19-%'
 order by sample_id, segment_nbr;




   select sample_year, count(sample_year) from Test_WL640
 group by sample_year
 order by sample_year desc
 ;
/**
2020	383
2019	421
2018	631
2017	649
2016	510
2015	403
2014	610
2013	260
2012	435
2011	490
2010	498
2009	505
2008	585
2007	604
2006	411
2005	419
2004	487
2003	824
2002	326
1999	1
1960	3
**/



/***********************************************************************************

 WL640 Raw Gradation, as a single SQL statement; header, segments, summation
 
 the CPan, aka the Fines, was added to the segments table, as well as being a 
 stand-alone field, mass_of_fines, in the header table. this is because it 
 is sometimes needed as a segment for calculation purposes,
 eg; WL413 pct passing grid, WL641 Prep Generic Gradation
 
 the Fines are excluded from this View, V_WL640_Prep_Raw_Gradation, by the statement:
 where wl640seg.sieve_size <> '#4-' -- exclude the fines
 
 W-20-0997-AG, W-20-0831-SO, W-20-0832-SO, W-20-0699-SO, W-20-0717-AG
 W-19-0001-AG, W-19-0014-SO, W-19-0032-SO, W-19-0186-SO, W-19-0346-SO
 W-18-0048-SO, W-18-0050-SO, W-17-0001-AG, W-17-1940-AG
 W-16-0058-SO, W-16-0082-SO, W-15-0446-AG, W-15-0473-AG, W-14-0530-AC


 -- from MTest: all files associated to the WL640 series
 Lt_WL640_BC.cpp, Lt_WL643_BC.cpp, Lt_WL644_BC.cpp, Lt_WL64d_BC.cpp (for 641,642,645), svPrep.h 
 mtForms02_E3: WL640Form_BC.cs, WL643Form_BC.cs, WL644Form_BC.cs, WL64dForm_BC.cs


***********************************************************************************/



create or replace view V_WL640_Prep_Raw_Gradation as 

with summation_sql as (

     select  seg.sample_id as sample_id
     
            ,sum(case when seg.mass_retained >= 0 then seg.mass_retained else 0 end)
             as wl640_calc_sum_coarse
            
            /*----------------------------------------------------------------------------
              the following four values are used in WL645
              obtain the sum of the mass and the count for sieve values >= 3/4", 19.0mm
              obtain the sum of the mass and the count for sieve values  < 3/4", 19.0mm
            ----------------------------------------------------------------------------*/
            
            ,sum(case when seg.mass_retained >= 0 and ss.sieve_metric_in_mm >= 19
                      then seg.mass_retained else 0 end) as wl640_calc_mass_GTE_19mm
            
            ,sum(case when seg.mass_retained >= 0 and ss.sieve_metric_in_mm >= 19
                      then 1 else 0 end)                 as wl640_calc_count_GTE_19mm
                      
            ,sum(case when seg.mass_retained >= 0 and ss.sieve_metric_in_mm  < 19
                      then seg.mass_retained else 0 end) as wl640_calc_mass_LT_19mm -- also used in WL644
            
            ,sum(case when seg.mass_retained >= 0 and ss.sieve_metric_in_mm  < 19
                      then 1 else 0 end)                 as wl640_calc_count_LT_19mm
                      
       from Test_WL640_segments   seg
       join MLT_Sieve_Size         ss on seg.sieve_size = ss.sieve_customary
                                      or seg.sieve_size = ss.sieve_metric
      
      where seg.sieve_size <> '#4-' -- exclude the fines
      group by seg.sample_id
)

,cumulative_sql as (

     select   sample_id    as sample_id
             ,segment_nbr  as segment_nbr
             ,sieve_size   as sieve_size
             
             ,sum(case when mass_retained >= 0 then mass_retained else 0 end) 
                  over (partition by sample_id order by segment_nbr) as WL640_mass_ret_cumulative

       from Test_WL640_segments
      
      where sieve_size <> '#4-' -- exclude the fines
      order by sample_id, segment_nbr
)

--------------------------------------------------
--  main sql
--------------------------------------------------

select  wl640.sample_id                                        as WL640_Sample_ID
       ,wl640.sample_year                                      as WL640_Sample_Year
       
       ,wl640.test_status                                      as WL640_Test_Status
       ,wl640.tested_by                                        as WL640_Tested_by       
       
       ,case when to_char(wl640.date_tested, 'yyyy') = '1959'  then ' '
             else to_char(wl640.date_tested, 'mm/dd/yyyy')     end
                                                               as WL640_date_tested
            
       ,wl640.date_tested                                      as WL640_date_tested_DATE
       ,wl640.date_tested_orig                                 as WL640_date_tested_orig
       
       /*----------------------------------------------------
         Summation values: Fine, Coarse, Total
       ----------------------------------------------------*/
       
       ,wl640.mass_of_fines                                    as WL640_mass_of_fines
             
       -- not for display, used in other WL640 calculations  
       ,case when wl640_calc_sum_coarse is not null then wl640_calc_sum_coarse
             else -1 end                                       as WL640_mass_retained_summ_coarse
             
       ,wl640_calc_total_mass                                  as WL640_Mass_Total
       
       /*----------------------------------------------------
         WL640 Coarse Sieves
       ----------------------------------------------------*/
       
       ,case when wl640seg.segment_nbr      is not null then wl640seg.segment_nbr      else  -1 end
        as WL640_segment_nbr
       
       ,case when wl640seg.sieve_size       is not null then wl640seg.sieve_size       else ' ' end
        as WL640_sieve_size

       ,case when wl640seg.mass_retained    is not null then wl640seg.mass_retained    else  -1 end
        as WL640_mass_retained
        
       ,case when WL640_mass_ret_cumulative is not null then WL640_mass_ret_cumulative else  -1 end
        as WL640_mass_retained_cumulative
        
       ,case when WL640_mass_ret_cumulative is not null and wl640_calc_total_mass > 0
             then round(100 - ((WL640_mass_ret_cumulative / wl640_calc_total_mass) * 100),6)
             else -1 end
        as WL640_pct_passing
        
       ,case when wl640_calc_sum_coarse     is not null and wl640_calc_total_mass > 0
             then round((100 - ((wl640_calc_sum_coarse / wl640_calc_total_mass) * 100)),6)
             else -1 end
        as WL640_pct_passing_nbr4 -- #4, 4.75mm
             
       /*----------------------------------------------------
         from MLT_Sieve_Size
       ----------------------------------------------------*/
       
       ,case when sieve.sieve_customary     is not null then sieve.sieve_customary     else ' ' end as sieve_customary
       ,case when sieve.sieve_metric        is not null then sieve.sieve_metric        else ' ' end as sieve_metric
       ,case when sieve.sieve_metric_in_mm  is not null then sieve.sieve_metric_in_mm  else  -1 end as sieve_metric_in_mm
       
       /*----------------------------------------------------
         other calculations
       ----------------------------------------------------*/
       
       -- used in WL644
       ,wl640_calc_pct_fines
       
       -- used in WL645 (also WL644?? not sure)
       ,case when wl640_calc_mass_GTE_19mm  is not null then wl640_calc_mass_GTE_19mm  else  -1 end as wl640_calc_mass_GTE_19mm
       ,case when wl640_calc_count_GTE_19mm is not null then wl640_calc_count_GTE_19mm else  -1 end as wl640_calc_count_GTE_19mm
       ,case when wl640_calc_mass_LT_19mm   is not null then wl640_calc_mass_LT_19mm   else  -1 end as wl640_calc_mass_LT_19mm
       ,case when wl640_calc_count_LT_19mm  is not null then wl640_calc_count_LT_19mm  else  -1 end as wl640_calc_count_LT_19mm
       ,wl640_calc_overadj
       
       ,'Coarse' as WL640_sieve_type
              
       ,wl640.remarks as WL640_Remarks
       
       /*----------------------------------------------------------------
         table relationships
       ----------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       
       join Test_WL640                                   wl640 on wl640.sample_id            = smpl.sample_id
       
       left join Test_WL640_segments                  wl640seg on wl640.sample_id            = wl640seg.sample_id
       
       left join summation_sql                                 on wl640.sample_id            = summation_sql.sample_id
       
       left join cumulative_sql                                on cumulative_sql.sample_id   = wl640seg.sample_id
                                                              and cumulative_sql.segment_nbr = wl640seg.segment_nbr
                                                              
       left join MLT_Sieve_Size                          sieve on sieve.sieve_customary      = wl640seg.sieve_size
                                                               or sieve.sieve_metric         = wl640seg.sieve_size
       
       /*----------------------------------------------------------------
         obtain the total mass of the WL640 sieves
       ----------------------------------------------------------------*/
       
       cross apply (select case when wl640_calc_sum_coarse is not null 
                           then case when wl640.mass_of_fines >= 0 
                                     then wl640_calc_sum_coarse + wl640.mass_of_fines
                                     else wl640_calc_sum_coarse end
                           
                           else case when wl640.mass_of_fines >= 0 
                                     then wl640.mass_of_fines
                                     else 0 end
                                     
                           end as wl640_calc_total_mass from dual) total_mass
    
  /*----------------------------------------------------------------
    percent fines: from MTest, Lt_WL644_BC.cpp, calcPctFines()
    used in WL644
    result = 100.0*totfines / (totfines + totcse)
  ----------------------------------------------------------------*/
  
  cross apply (select case when wl640.mass_of_fines > 0 and wl640_calc_total_mass > 0
                      then round(((wl640.mass_of_fines / wl640_calc_total_mass) * 100), 6)
                      else -1 
                      end as wl640_calc_pct_fines from dual) pct_fines
  
  /*----------------------------------------------------------------
    from MTest, LT_WL64d_BC.cpp, void LtWL64d_BC::CorGrpRoot::calcsOveradj()
    used in WL645
    overadj = Oversize / nr
    
    my code: overadj = wl640_calc_mass_GTE_19mm / wl640_calc_count_LT_19mm
    
    in WL645: take the total mass of sieves >= 3/4" (19mm) 
    and divide by the number of sieves < 3/4" to produce 
    a mass that will be added to each sieve size < 3/4"
  ----------------------------------------------------------------*/
  
  cross apply (select case when wl640_calc_mass_GTE_19mm > 0 and wl640_calc_count_LT_19mm > 0 
                           then round((wl640_calc_mass_GTE_19mm / wl640_calc_count_LT_19mm),6)
                           else 0
                           end as wl640_calc_overadj from dual) overadj
 
 where wl640seg.sieve_size <> '#4-' -- exclude the fines
 
 order by wl640.sample_id, wl640seg.segment_nbr
 ;









-- find samples without segments -- 31 samples

select hdr.sample_id hdr from Test_WL640 hdr
 where hdr.sample_id not in (select seg.sample_id from Test_WL640_segments seg
                              where seg.sample_id = hdr.sample_id)
 order by hdr.sample_year desc, sample_id
;
/**

W-15-0552-AG, W-14-1184-AC, W-14-1427-SO, W-14-1428-SO, W-14-1429-SO, 
W-14-1430-SO, W-14-1431-SO, W-14-1432-SO, W-14-1433-SO, W-14-1434-SO, 
W-14-1435-SO, W-14-1436-SO, W-14-1437-SO, W-14-1438-SO, W-14-1439-SO, 
W-14-1440-SO, W-14-1442-SO, W-14-1444-SO, W-14-1446-SO, 
W-10-1681-AG, W-09-0232-AG, W-08-0191-SO, W-08-0192-SO, W-06-0771-SOA, W-06-0773-SOA, 
W-04-0052-SO, W-04-0792-SO, W-03-0870-AG, W-03-1230-SO, W-03-1233-SO,  W-02-1374-AG

**/





-- find segments without headers (should be none) -- 0 samples

select seg.sample_id from Test_WL640_segments seg
 where seg.sample_id not in (select hdr.sample_id from Test_WL640 hdr
                              where hdr.sample_id = seg.sample_id)
;









