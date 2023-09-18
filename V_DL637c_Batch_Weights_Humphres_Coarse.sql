 


/***********************************************************************************

                                                                count   minYr   maxYr
DL608-c Batch Weights for Coarse Specific Gravity, T85          444	    1988	2020
DL608-f Batch Weights for Fine Specific Gravity, T84            450	    1988	2020
DL632   Batch Weights for Asphalt Mix Design                    388	    1988	2020
DL633   Batch Weights for I.C. (Immersion Compression) T165     510	    1988	2011
DL634   Batch Weights for Gauge Calibration                       6	    1993	1999
DL636-c Batch Weights recast to Coarse - generic                  5	    2001	2003
DL637-c Batch Weights for Humphres Compaction, WL360 - Coarse   115	    2001	2020
DL637-f Batch Weights for Humphres Compaction, WL360 - Fine     115	    2001	2020

***********************************************************************************/


select count(*), min(sample_year), max(sample_year) from Test_DL637C where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 115	    2001	2020



select * from Test_DL637C;



select gradation_source, count(gradation_source)
  from Test_DL637C
 group by gradation_source
 order by gradation_source
 ;
-- WL800	115




select sample_year, count(sample_year)
  from Test_DL637C
 group by sample_year
 order by sample_year desc
 ;

/*
2020	5
2019	2
2018	6
2017	5
2015	8
2014	4
2013	2
2012	7
2011	8
2010	3
2009	4
2008	11
2007	8
2006	1
2005	9
2004	7
2003	6
2002	11
2001	8
*/



-- find samples with >1 stockpile

select wl800.sample_id, wl800.sample_year, wl800.stockpile1_pct_used, wl800.stockpile2_pct_used, wl800.stockpile3_pct_used
  from test_wl800   wl800,
       test_dl637c  dl637c
 where wl800.stockpile2_pct_used > 0
   and wl800.sample_id = dl637c.sample_id
 order by wl800.sample_year desc
;

-- sample ID        year    S1 used     S2 used     S3 used
-- W-11-0157-AG	    2011	70	        30	        -1

-- sole sample with two stockpiles
-- there are no samples with three or more stockpiles associated with DL637-c




/***********************************************************************************

 DL637-c Batch Weights for Humphres Compaction, WL360 - Coarse
 
 W-20-0313,     W-20-0314,     W-20-0984-AG,  W-20-0348,     W-20-0347
 W-19-0758-AG,  W-19-0911-AG,  W-18-0483-AG,  W-18-0576-AG,  W-18-0865-AG, 
 W-18-0865-AGB, W-18-1570-AG,  W-18-1571-AG,  W-17-0494-AG,  W-17-0968-AG
 W-15-0662-AG,  W-14-0926-AG,  W-13-0017-AG,  W-12-0621-AG,  W-11-0157-AG
 W-10-0584-AG,  W-09-0368-AG,  W-08-0592-AG,  W-07-0068-AG,  W-06-0170-AG
 W-05-0421-AG,  W-04-1357-AG,  W-03-0159-AG,  W-02-0281-AG,  W-01-1555-AG

***********************************************************************************/


select * from V_DL637c_Batch_Weights_Humphres_Coarse
;



select * from V_DL637c_Batch_Weights_Humphres_Coarse where sample_id  = 'W-20-0314'
;



create or replace view V_DL637c_Batch_Weights_Humphres_Coarse as 

select  dl637c.sample_id as sample_id
       ,dl637c.sample_year
       ,dl637c.test_status
       ,dl637c.tested_by
       
       ,case when to_char(dl637c.date_tested, 'yyyy') = '1959' then ' '
             else to_char(dl637c.date_tested, 'mm/dd/yyyy')
            end as date_tested
            
       --,dl637c.date_tested as date_tested_DATE
       --,dl637c.date_tested_orig
       
       /*-----------------------------------------------------------
         Gradation source
         WL800 Sieve specifications -- all 115 samples are WL800
         WL367 Adjusted gradation (IW)
       -----------------------------------------------------------*/
       
       ,dl637c.gradation_source
       
       ,dl637c.Proposed_Batch_Weight -- not sure the source of Proposed_Batch_Weight, CHECKTHIS

       ,dl637c.exclude_stockpile1
       ,dl637c.exclude_stockpile2
       ,dl637c.exclude_stockpile3
       ,dl637c.exclude_stockpile4
       ,dl637c.exclude_stockpile5
       ,dl637c.exclude_stockpile6
       
       ,dl637c.remarks
              
  /*--------------------------------------------------------------------------
    table relationships
  --------------------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900          smpl
  join Test_DL637C               dl637c on dl637c.sample_id = smpl.sample_id
    
 --where smpl.sample_id  = 'W-20-0170'
  
 -- order by smpl.sample_year, smpl.sample_id
 -- order by smpl.sample_year, smpl.sample_id desc
  order by smpl.sample_year desc, smpl.sample_id
 --order by smpl.sample_year desc, smpl.sample_id desc
 ;





/***********************************************************************************
 
 DL637-c Sieves grid (front page, not a segment)
 
 the WL800 stockpile previous.segment pct passing - this.segment pct passing
 becomes the pct retained on DL637-c for this.segment
 
 pct retained = previous pct passing - pct passing
 
 from MTest, Lt_DL630c_B4.cpp, mtDL630_B4::SpData::getExtWL800()
 // WL800 grad comes in as Pct Passing: must convert to Pct retained
 val = oldpp - pp; // convert to pct retained
 
***********************************************************************************/


select * from V_DL637c_Batch_Weights_Humphres_gradation_source_grid 
 where sample_id  = 'W-01-0130-AG'
--'W-20-0314'
;



create or replace view V_DL637c_Batch_Weights_Humphres_gradation_source_grid as 

select  smpl.sample_id                  as sample_id
       ,wl800seg.segment_nbr            as segment_nbr
       ,wl800seg.sieve_size             as sieve_size
       
       /*--------------------------------------
         Stockpile 1
       --------------------------------------*/
       
       ,wl800.stockpile1                as S1_
       ,wl800.stockpile1_description    as S1_descr
       ,wl800.stockpile1_pct_used       as S1_pct_used
       ,wl800seg.stockpile1_pct_pass    as S1_pct_pass
       
       ,case when wl800.stockpile1_pct_used >= 0 then
        lag(wl800seg.stockpile1_pct_pass,1,0) over (partition by smpl.sample_id order by wl800seg.segment_nbr)
        else -1 end                     as S1_prev_pct_pass
        
       ,case when wl800.stockpile1_pct_used >= 0 then
        lag(wl800seg.stockpile1_pct_pass,1,100) over (partition by smpl.sample_id order by wl800seg.segment_nbr) - wl800seg.stockpile1_pct_pass
        else -1 end                     as S1_calc_pct_retained
       
       /*--------------------------------------
         Stockpile 2
       --------------------------------------*/
               
       ,wl800.stockpile2                as S2_
       ,wl800.stockpile2_description    as S2_descr
       ,wl800.stockpile2_pct_used       as S2_pct_used
       ,wl800seg.stockpile2_pct_pass    as S2_pct_pass
       
       ,case when wl800.stockpile2_pct_used >= 0 then
        lag(wl800seg.stockpile2_pct_pass,1,0) over (partition by smpl.sample_id order by wl800seg.segment_nbr)
        else -1 end                     as S2_prev_pct_pass
        
       ,case when wl800.stockpile2_pct_used >= 0 then
        lag(wl800seg.stockpile2_pct_pass,1,100) over (partition by smpl.sample_id order by wl800seg.segment_nbr) - wl800seg.stockpile2_pct_pass
        else -1 end                     as S2_calc_pct_retained
       
       /*--------------------------------------
         Stockpile 3
       --------------------------------------*/
               
       ,wl800.stockpile3                as S3_
       ,wl800.stockpile3_description    as S3_descr
       ,wl800.stockpile3_pct_used       as S3_pct_used
       ,wl800seg.stockpile3_pct_pass    as S3_pct_pass
       
       ,case when wl800.stockpile3_pct_used >= 0 then
        lag(wl800seg.stockpile3_pct_pass,1,0) over (partition by smpl.sample_id order by wl800seg.segment_nbr)
        else -1 end                     as S3_prev_pct_pass
        
       ,case when wl800.stockpile3_pct_used >= 0 then
        lag(wl800seg.stockpile3_pct_pass,1,100) over (partition by smpl.sample_id order by wl800seg.segment_nbr) - wl800seg.stockpile3_pct_pass
        else -1 end                     as S3_calc_pct_retained
       
       /*--------------------------------------
         Stockpile 4
       --------------------------------------*/
               
       ,wl800.stockpile4                as S4_
       ,wl800.stockpile4_description    as S4_descr
       ,wl800.stockpile4_pct_used       as S4_pct_used
       ,wl800seg.stockpile4_pct_pass    as S4_pct_pass
       
       ,case when wl800.stockpile4_pct_used >= 0 then
        lag(wl800seg.stockpile4_pct_pass,1,0) over (partition by smpl.sample_id order by wl800seg.segment_nbr)
        else -1 end                     as S4_prev_pct_pass
        
       ,case when wl800.stockpile4_pct_used >= 0 then
        lag(wl800seg.stockpile4_pct_pass,1,100) over (partition by smpl.sample_id order by wl800seg.segment_nbr) - wl800seg.stockpile4_pct_pass
        else -1 end                     as S4_calc_pct_retained
       
       /*--------------------------------------
         Stockpile 5
       --------------------------------------*/
                      
       ,wl800.stockpile5                as S5_
       ,wl800.stockpile5_description    as S5_descr
       ,wl800.stockpile5_pct_used       as S5_pct_used
       ,wl800seg.stockpile5_pct_pass    as S5_pct_pass
       
       ,case when wl800.stockpile5_pct_used >= 0 then
        lag(wl800seg.stockpile5_pct_pass,1,0) over (partition by smpl.sample_id order by wl800seg.segment_nbr)
        else -1 end                     as S5_prev_pct_pass
        
       ,case when wl800.stockpile5_pct_used >= 0 then
        lag(wl800seg.stockpile5_pct_pass,1,100) over (partition by smpl.sample_id order by wl800seg.segment_nbr) - wl800seg.stockpile5_pct_pass
        else -1 end                     as S5_calc_pct_retained
       
       /*--------------------------------------
         Stockpile 6
       --------------------------------------*/
                      
       ,wl800.stockpile6                as S6_
       ,wl800.stockpile6_description    as S6_descr
       ,wl800.stockpile6_pct_used       as S6_pct_used
       ,wl800seg.stockpile6_pct_pass    as S6_pct_pass
       
       ,case when wl800.stockpile6_pct_used >= 0 then
        lag(wl800seg.stockpile6_pct_pass,1,0) over (partition by smpl.sample_id order by wl800seg.segment_nbr)
        else -1 end                     as S6_prev_pct_pass
        
       ,case when wl800.stockpile6_pct_used >= 0 then
        lag(wl800seg.stockpile6_pct_pass,1,100) over (partition by smpl.sample_id order by wl800seg.segment_nbr) - wl800seg.stockpile6_pct_pass
        else -1 end                     as S6_calc_pct_retained
          
  /*--------------------------------------------------------------------------
    table relationships
  --------------------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900          smpl
  join Test_DL637C               dl637c on dl637c.sample_id = smpl.sample_id
  join Test_WL800                 wl800 on  wl800.sample_id = smpl.sample_id
  join Test_WL800_segments     wl800seg on  wl800.sample_id = wl800seg.sample_id

union

select  smpl.sample_id                  as sample_id
       ,wl800seg.segment_nbr + 1        as segment_nbr
       ,'Pan'                           as sieve_size
              
       ,wl800.stockpile1                as S1
       ,wl800.stockpile1_description    as S1_descr
       ,wl800.stockpile1_pct_used       as S1_pct_used
       ,0                               as S1_pct_pass
       ,0                               as calc_S1_prev_pct_pass        
       ,wl800seg.stockpile1_pct_pass    as calc_S1_pct_retained
       
       ,wl800.stockpile2                as S2
       ,wl800.stockpile2_description    as S2_descr
       ,wl800.stockpile2_pct_used       as S2_pct_used
       ,0                               as S2_pct_pass
       ,0                               as calc_S2_prev_pct_pass        
       ,wl800seg.stockpile2_pct_pass    as calc_S2_pct_retained
       
       ,wl800.stockpile3                as S3
       ,wl800.stockpile3_description    as S3_descr
       ,wl800.stockpile3_pct_used       as S3_pct_used
       ,0                               as S2_pct_pass
       ,0                               as calc_S2_prev_pct_pass        
       ,wl800seg.stockpile2_pct_pass    as calc_S2_pct_retained
       
       ,wl800.stockpile4                as S4
       ,wl800.stockpile4_description    as S4_descr
       ,wl800.stockpile4_pct_used       as S4_pct_used
       ,0                               as S4_pct_pass
       ,0                               as calc_S4_prev_pct_pass        
       ,wl800seg.stockpile4_pct_pass    as calc_S4_pct_retained
       
       ,wl800.stockpile5                as S5
       ,wl800.stockpile5_description    as S5_descr
       ,wl800.stockpile5_pct_used       as S5_pct_used
       ,0                               as S5_pct_pass
       ,0                               as calc_S5_prev_pct_pass        
       ,wl800seg.stockpile5_pct_pass    as calc_S5_pct_retained
       
       ,wl800.stockpile6                as S6
       ,wl800.stockpile6_description    as S6_descr
       ,wl800.stockpile6_pct_used       as S6_pct_used
       ,0                               as S6_pct_pass
       ,0                               as calc_S6_prev_pct_pass        
       ,wl800seg.stockpile6_pct_pass    as calc_S6_pct_retained
  
  /*--------------------------------------------------------------------------
    table relationships
  --------------------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900          smpl
  join Test_DL637C               dl637c on dl637c.sample_id = smpl.sample_id
  join Test_WL800                 wl800 on  wl800.sample_id = smpl.sample_id
  
  join Test_WL800_segments     wl800seg on  wl800.sample_id = wl800seg.sample_id    
   and wl800seg.segment_nbr = (select max(seg2.segment_nbr)
                                 from Test_WL800_segments seg2
                                where seg2.sample_id = wl800seg.sample_id)

 order by sample_id, segment_nbr
 ;
  






/***********************************************************************************
 
 DL637-c segments
 
 W-20-0314, W-17-1881-AG, W-12-0492-AG, W-11-0113-AG (contain three batches)
 W-19-0911-AG, W-18-1571-AG, W-17-1359-AG
 
***********************************************************************************/


select * from V_DL637c_Batch_Weights_Humphres_Sieve_batches
 where sample_id = 
 --'W-17-1881-AG'
 'W-11-0157-AG'
 --'W-14-0702-AG'
 --'W-20-0314'
 --'W-19-0758-AG'
 ;
 
 
 
 
 
 

create or replace view V_DL637c_Batch_Weights_Humphres_Sieve_batches as

with cumulative_sql as (

     select  sample_id as sampleid
            ,batch_nbr as batchnbr            
            ,sum (case when s1_batchwt > 0 then s1_batchwt else 0 end) as S1_calc_sum
            ,sum (case when s2_batchwt > 0 then s2_batchwt else 0 end) as S2_calc_sum
            ,sum (case when s3_batchwt > 0 then s3_batchwt else 0 end) as S3_calc_sum
            ,sum (case when s4_batchwt > 0 then s4_batchwt else 0 end) as S4_calc_sum
            ,sum (case when s5_batchwt > 0 then s5_batchwt else 0 end) as S5_calc_sum
            ,sum (case when s6_batchwt > 0 then s6_batchwt else 0 end) as S6_calc_sum
            
       from Test_DL637C_segments
      group by sample_id, batch_nbr
)

select  dl637c_seg.sample_id   -- key
       ,dl637c_seg.batch_nbr   -- key
       ,dl637c_seg.segment_nbr -- key
       
       ,dl637c_seg.batch_description
       ,dl637c_seg.batch_weight
       ,dl637c_seg.sieve_size
       
       /*-------------------------------
         stockpile 1
       -------------------------------*/
  
       ,dl637c_seg.s1_batchwt
       ,dl637c_seg.s1_cumwt -- user entered, may get rid of this
       
       ,sum(case when dl637c_seg.s1_batchwt > 0 then dl637c_seg.s1_batchwt else 0 end)
        over (partition by dl637c_seg.sample_id, dl637c_seg.batch_nbr
        order by dl637c_seg.sample_id, dl637c_seg.batch_nbr, dl637c_seg.segment_nbr)
        as S1_calc_incremental
        
       ,S1_calc_sum
       
       /*-------------------------------
         stockpile 2
       -------------------------------*/
       
       ,dl637c_seg.s2_batchwt
       ,dl637c_seg.s2_cumwt
       
       ,case when dl637c_seg.s2_batchwt >= 0
             then sum(dl637c_seg.s2_batchwt) over (partition by dl637c_seg.sample_id, dl637c_seg.batch_nbr
                      order by dl637c_seg.sample_id, dl637c_seg.batch_nbr, dl637c_seg.segment_nbr)
                  + S1_calc_sum
             else -1
             end as S2_calc_incremental
                     
       ,S2_calc_sum
       
       /*-------------------------------
         stockpile 3
       -------------------------------*/
       
       ,dl637c_seg.s3_batchwt
       ,dl637c_seg.s3_cumwt
       
       ,case when dl637c_seg.s3_batchwt >= 0
             then sum(dl637c_seg.s3_batchwt) over (partition by dl637c_seg.sample_id, dl637c_seg.batch_nbr
                      order by dl637c_seg.sample_id, dl637c_seg.batch_nbr, dl637c_seg.segment_nbr)
                  + S1_calc_sum
                  + S2_calc_sum
             else -1
             end as S3_calc_incremental
                
       ,S3_calc_sum
       
       /*-------------------------------
         stockpile 4
       -------------------------------*/
       
       ,dl637c_seg.s4_batchwt
       ,dl637c_seg.s4_cumwt
       
       ,case when dl637c_seg.s4_batchwt >= 0
             then sum(dl637c_seg.s4_batchwt) over (partition by dl637c_seg.sample_id, dl637c_seg.batch_nbr
                      order by dl637c_seg.sample_id, dl637c_seg.batch_nbr, dl637c_seg.segment_nbr)
                  + S1_calc_sum
                  + S2_calc_sum
                  + S3_calc_sum
             else -1
             end as S4_calc_incremental
        
       ,S4_calc_sum
       
       /*-------------------------------
         stockpile 5
       -------------------------------*/
       
       ,dl637c_seg.s5_batchwt
       ,dl637c_seg.s5_cumwt
       
       ,case when dl637c_seg.s5_batchwt >= 0
             then sum(dl637c_seg.s5_batchwt) over (partition by dl637c_seg.sample_id, dl637c_seg.batch_nbr
                      order by dl637c_seg.sample_id, dl637c_seg.batch_nbr, dl637c_seg.segment_nbr)
                  + S1_calc_sum
                  + S2_calc_sum
                  + S3_calc_sum
                  + S4_calc_sum
             else -1
             end as S5_calc_incremental
        
       ,S5_calc_sum
       
       /*-------------------------------
         stockpile 6
       -------------------------------*/
       
       ,dl637c_seg.s6_batchwt
       ,dl637c_seg.s6_cumwt
       
       ,case when dl637c_seg.s6_batchwt >= 0
             then sum(dl637c_seg.s6_batchwt) over (partition by dl637c_seg.sample_id, dl637c_seg.batch_nbr
                      order by dl637c_seg.sample_id, dl637c_seg.batch_nbr, dl637c_seg.segment_nbr)
                  + S1_calc_sum
                  + S2_calc_sum
                  + S3_calc_sum
                  + S4_calc_sum
                  + S5_calc_sum
             else -1
             end as S6_calc_incremental
        
       ,S6_calc_sum
              
  /*--------------------------------------------------------------------------
    table relationships
  --------------------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900          smpl
  join Test_DL637C               dl637c on dl637c.sample_id = smpl.sample_id
  join Test_DL637C_segments  dl637c_seg on dl637c.sample_id = dl637c_seg.sample_id
  
  join cumulative_sql                   on dl637c_seg.sample_id = cumulative_sql.sampleid
                                       and dl637c_seg.batch_nbr = cumulative_sql.batchnbr
 
 order by smpl.sample_year desc
          ,dl637c_seg.sample_id
          ,dl637c_seg.batch_nbr
          ,dl637c_seg.segment_nbr
 ;
  








select * from Test_DL637C_segments
 --where sample_id = 'W-11-0157-AG'
 order by sample_id desc, batch_nbr, segment_nbr
;

--truncate table Test_DL637C_segments;
--truncate table Test_DL637C;




