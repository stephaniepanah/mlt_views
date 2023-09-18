


--                                      count       minYr   maxYr
-- WL411 Sieve Analysis, Coarse Wash    1754	    1986	2016
-- WL412 Sieve Analysis, Dry             201	    1986	2015
-- WL413 Sieve Analysis, Field Method   8010	    1986	2019




select * from V_WL412_Sieve_Analysis_Dry 
 where WL412_sample_ID in
 (
 'W-15-0416-AG', 'W-09-0572-AG', 'W-09-0573-AG', 'W-07-0613-AG', 'W-07-0802-SO', 
 'W-03-0737-AG', 'W-03-0744-AG', 'W-03-0748-AG', 'W-02-0079-AG', 'W-02-0084-AG'
 )
 order by WL412_sample_year desc, WL412_sample_ID, WL412_segment_nbr
 ;




select * from V_WL412_Sieve_Analysis_pct_passing_grid 
 where sample_id in 
 (
 'W-15-0416-AG', 'W-09-0572-AG', 'W-09-0573-AG', 'W-07-0613-AG', 'W-07-0802-SO', 
 'W-03-0737-AG', 'W-03-0744-AG', 'W-03-0748-AG', 'W-02-0079-AG', 'W-02-0084-AG'
 )
 ;



----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------



select count(*), min(sample_year), max(sample_year) from Test_WL412 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 201	    1986	2015



select * from test_wl412 order by sample_year desc, sample_id;



select * from test_wl412 where sample_id in 
(
'W-15-0416-AG', 'W-09-0572-AG', 'W-09-0573-AG', 'W-07-0613-AG', 'W-07-0802-SO', 
'W-03-0737-AG', 'W-03-0744-AG', 'W-03-0748-AG', 'W-02-0079-AG', 'W-02-0084-AG'
);




/*----------------------------------------------------------------------

  the query below searches the accounting table (the cross-match between
  a sample and its associated labtests) and produced the following results:
  
  -the earliest appearance of WL640 associated to WL411 is W-02-1440-AG
  -the   latest appearance of DL907 associated to WL412 is W-02-0084-AG
  (there is no crossover time period)

----------------------------------------------------------------------*/

select acct.sample_year, acct.sample_id, acct.labtest 
  from mlt_2_wl901_accounting acct
  
 where acct.sample_id in (select wl412.sample_id from test_wl412 wl412
                           where wl412.sample_id = acct.sample_id)
                           
   and acct.labtest in ('WL412', 'DL907', 'WL640', 'WL642')
   
 order by acct.sample_year, acct.sample_id, acct.labtest 
;




select * from mlt_sieve_size;



   select sample_year, count(sample_year) from test_wl412
 group by sample_year
 order by sample_year desc
 ;
/**

2015	1
2009	2
2007	4
2006	1
2005	5
2003	20
2002	7
2001	84
2000	2
1998	7
1997	4
1996	8
1995	3
1994	1
1988	42
1987	9
1986	1
1960	1

**/



select customary_metric, count(customary_metric) from test_wl412
 group by customary_metric
 order by customary_metric
 ;
 /**
 ' ' 	80
 C	    122
 **/



-- find headers without segments
select hdr.sample_id from test_wl412 hdr
 where hdr.sample_id not in (select seg.sample_id from test_wl412_segments seg
                              where seg.sample_id = hdr.sample_id)
;
-- 136 samples without segments



-- find segments without headers (none should be found)
select seg.sample_id from test_wl412_segments seg
 where seg.sample_id not in (select hdr.sample_id from test_wl412 hdr
                              where hdr.sample_id = seg.sample_id)
;
-- none found




/***********************************************************************************

  WL412 Sieve Analysis, Dry
  
  from MTest, Lt_WL412_BC.cpp, void LtWL412_BC::CorGrpRoot::doCalcs()
  {
  
  these calculations are similar to WL411
  it works with the WL640 association, I have not worked upon DL907, yet
                    
***********************************************************************************/


create or replace view V_WL412_Sieve_Analysis_Dry as 

with summation_sql as (
     select  sample_id as sample_id
            ,sum(case when mass_retained >= 0 then mass_retained else 0 end) as mass_ret_summation
       from Test_WL412_segments
      --where sieve_type = 'Fine' 
      group by sample_id 
)

,cumulative_sql as (

     select  sample_id   as sample_id
            ,segment_nbr as segment_nbr
             
            ,sum(case when mass_retained >= 0 then mass_retained else 0 end) 
                 over (partition by sample_id order by sample_id, segment_nbr) as mass_ret_cumulative

       from Test_WL412_segments
      --where sieve_type = 'Fine' 
      order by sample_id, segment_nbr
)

,view_wl640 as (

     select  WL640_sample_id                 as WL640_sample_id
            ,WL640_mass_retained_summ_coarse as WL640_summ_coarse
            ,WL640_Mass_Total                as WL640_Mass_Total
            ,WL640_mass_of_fines             as WL640_mass_of_fines
            
            ,case when WL640_PCT_PASSING_NBR4 > 0 then (WL640_PCT_PASSING_NBR4) else 0 end 
                                             as WL640_pct_pass_nbr4
            
       from V_WL640_Prep_Raw_Gradation
      where WL640_segment_nbr = 1
)

select  wl412.sample_id                        as WL412_Sample_ID
       ,wl412.sample_year                      as WL412_Sample_Year
       
       ,wl412.test_status                      as WL412_Test_Status
       ,wl412.tested_by                        as WL412_Tested_by
       
       ,case when to_char(wl412.date_tested, 'yyyy') = '1959' then ' '
             else to_char(wl412.date_tested, 'mm/dd/yyyy')
             end                               as WL412_date_tested
            
       ,wl412.date_tested                        as WL412_date_tested_DATE
       ,wl412.date_tested_orig                   as WL412_date_tested_orig
       
       ,wl412.customary_metric                 as WL412_customary_metric -- for sieve units, but, I think are not used
       
       ,case when wl412.mass_fine_sieves_pan >= 0 then wl412.mass_fine_sieves_pan else -1  end as WL412_mass_pan
       
       /*-------------------------------------------------------
         segments
       -------------------------------------------------------*/
       
       ,case when wl412seg.segment_nbr   is not null then wl412seg.segment_nbr    else  -1 end as WL412_segment_nbr
       ,case when wl412seg.sieve_size    is not null then wl412seg.sieve_size     else ' ' end as WL412_sieve_size
       ,case when wl412seg.mass_retained is not null then wl412seg.mass_retained  else  -1 end as WL412_mass_retained
       
       ,case when cumulative_sql.mass_ret_cumulative is not null then cumulative_sql.mass_ret_cumulative else -1 end 
        as WL412_mass_ret_cumulative_fine
        
       ,case when summation_sql.mass_ret_summation   is not null then summation_sql.mass_ret_summation   else -1 end
        as WL412_mass_ret_summation_fine
       
       /*-------------------------------------------------------
         WL640 values
       -------------------------------------------------------*/
       
       ,case when view_wl640.WL640_summ_coarse       is not null then view_wl640.WL640_summ_coarse       else -1 end
        as WL640_summ_coarse
       
       ,case when view_wl640.WL640_Mass_Total        is not null then view_wl640.WL640_Mass_Total        else -1 end
        as WL640_Mass_Total
       
       ,case when view_wl640.WL640_mass_of_fines     is not null then view_wl640.WL640_mass_of_fines     else -1 end
        as WL640_mass_of_fines
       
       ,case when view_wl640.WL640_pct_pass_nbr4     is not null then view_wl640.WL640_pct_pass_nbr4     else -1 end
        as WL640_pct_pass_nbr4
       
       ,wl412.remarks as WL412_Remarks
       
  /*----------------------------------------------------------------------------
    table relationships
  ----------------------------------------------------------------------------*/
       
  from MLT_1_Sample_WL900                    smpl
  join Test_WL412                           wl412 on wl412.sample_id      = smpl.sample_id
  
  left join Test_WL412_segments          wl412seg on wl412.sample_id      = wl412seg.sample_id
  
  left join summation_sql                         on wl412seg.sample_id   = summation_sql.sample_id
  
  left join cumulative_sql                        on wl412seg.sample_id   = cumulative_sql.sample_id
                                                 and wl412seg.segment_nbr = cumulative_sql.segment_nbr
                                                 
  left join view_wl640                            on wl412.sample_id      = view_wl640.WL640_Sample_ID

  order by wl412.sample_id, wl412seg.segment_nbr
 ;









/***********************************************************************************
  
  V_WL412_Sieve_Analysis_pct_passing_grid
  
***********************************************************************************/



create or replace view V_WL412_Sieve_Analysis_pct_passing_grid as 

select sample_id
       ,groupnbr
       ,segment_nbr
       ,sieve_size
       ,pct_passing
       ,mass_retained
       ,mass_ret_cumulative
       ,mass_sum_coarse
       ,mass_total
       ,pct_pass_nbr4
       
  from (
         with cumulative_sql as (
         
              select  WL412_Sample_ID   as sample_id
                     ,WL412_segment_nbr as segment_nbr
                     ,sum(case when WL412_mass_retained >= 0 then WL412_mass_retained else 0 end) 
                          over (partition by WL412_Sample_ID order by WL412_Sample_ID, WL412_segment_nbr)
                          as mass_ret_cumulative
                          
                from V_WL412_Sieve_Analysis_Dry
               order by WL412_Sample_ID, WL412_segment_nbr
         )
         select  v_wl412.wl412_sample_id                       as sample_id
                ,2                                             as groupnbr
                ,v_wl412.wl412_segment_nbr                     as segment_nbr
                ,v_wl412.wl412_sieve_size                      as sieve_size
                
                ,round(100 - (((cumulative_sql.mass_ret_cumulative + v_wl412.WL640_summ_coarse) / v_wl412.WL640_Mass_Total) * 100),2)
                                                               as pct_passing
                
                ,v_wl412.wl412_mass_retained                   as mass_retained
                ,cumulative_sql.mass_ret_cumulative            as mass_ret_cumulative
                ,v_wl412.WL640_summ_coarse                     as mass_sum_coarse
                ,v_wl412.WL640_Mass_Total                      as mass_total
                ,v_wl412.WL640_pct_pass_nbr4                   as pct_pass_nbr4
                
           from MLT_1_Sample_WL900                        smpl
           join V_WL412_Sieve_Analysis_Dry             v_wl412 on v_wl412.wl412_sample_id   = smpl.sample_id
          
           join cumulative_sql                                 on v_wl412.wl412_sample_id   = cumulative_sql.sample_id
                                                              and v_wl412.wl412_segment_nbr = cumulative_sql.segment_nbr
                                                              
         union
         
         select  v_wl640.WL640_Sample_ID                       as sample_id
                ,1                                             as groupnbr
                ,v_wl640.wl640_segment_nbr                     as segment_nbr
                ,v_wl640.wl640_sieve_size                      as sieve_size
                
                ,round((100 - ((v_wl640.WL640_mass_retained_cumulative / v_wl640.WL640_Mass_Total) * 100)),2) -- oldval
                                                               as pct_passing
                                                              
                ,v_wl640.WL640_mass_retained                   as mass_retained
                ,v_wl640.WL640_mass_retained_cumulative        as mass_ret_cumulative
                ,v_wl640.WL640_mass_retained_summ_coarse       as mass_sum_coarse
                ,v_wl640.WL640_Mass_Total                      as mass_total
                ,v_wl640.WL640_pct_passing_nbr4                as pct_pass_nbr4
               
           from MLT_1_Sample_WL900                        smpl
           join V_WL640_Prep_Raw_Gradation             v_wl640 on v_wl640.WL640_Sample_ID = smpl.sample_id 
  )
 
 order by 1, 2, 3
 ;
 
 
 
 
 
 
 
 
 