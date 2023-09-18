 


select * from V_DL608C_Batch_Weights_Coarse_Specific_Gravity_T85
 order by DL608C_Sample_Year desc, DL608C_Sample_ID
;




select * from V_DL608C_Batch_Weights_Coarse_Specific_Gravity_T85 
 where DL608C_Sample_ID = 'W-19-1041-AC'
--'W-19-0728-AC' 
;




select * from V_DL632_batch_weights_grid where DL632_Sample_ID = 
'W-19-1041-AC' 
;



----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_DL632 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 390	    1988	2020





/***********************************************************************************

 DL608C Batch Weights for Coarse Specific Gravity, T85

***********************************************************************************/

create or replace view V_DL608C_Batch_Weights_Coarse_Specific_Gravity_T85 as

select  dl608c.sample_year                      as DL608C_Sample_Year
       ,dl608c.sample_id                        as DL608C_Sample_ID
       
       ,dl608c.test_status                      as DL608C_Test_Status
       ,dl608c.tested_by                        as DL608C_Tested_by
       
       ,case when to_char(dl608c.date_tested, 'yyyy') = '1959'
             then ' '
             else to_char(dl608c.date_tested, 'mm/dd/yyyy')
             end                                as DL608C_date_tested
            
       ,dl608c.date_tested                      as DL608C_date_tested_DATE
       ,dl608c.date_tested_orig                 as DL608C_date_tested_orig
       
       ,dl608c.gradation_source                 as DL608C_Gradation_Source
       ,dl608c.proposed_batch_weight            as DL608C_Proposed_Batch_Weight
       
       ,dl608c.exclude_stockpile1               as DL608C_Exclude_Stockpile1
       ,dl608c.exclude_stockpile2               as DL608C_Exclude_Stockpile2
       ,dl608c.exclude_stockpile3               as DL608C_Exclude_Stockpile3
       ,dl608c.exclude_stockpile4               as DL608C_Exclude_Stockpile4
       ,dl608c.exclude_stockpile5               as DL608C_Exclude_Stockpile5
       ,dl608c.exclude_stockpile6               as DL608C_Exclude_Stockpile6
       
       ,dl608c.remarks                          as DL608C_Remarks
       
  /*----------------------------------------------------------------
    table relationships
  ----------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                       smpl
  join Test_DL608C                             dl608c on dl608c.sample_id = smpl.sample_id
 ;


  
select * from test_dl608c
 where exclude_stockpile6 = 'X'
 ;
  
  select * from mlt_sieve_size;
  
  select * from test_dl608c;
  
/***********************************************************************************
 
 V_DL608C_batch_weights_grid
 
 Exclude_stockpile1 - W-11-0857-AC, sole sample, source: WL367
 Exclude_stockpile2 - W-11-0857-AC, sole sample, source: WL367
 Exclude_stockpile3 - W-17-1019-AC, W-16-0190-AC (09 samples, total), source: WL367, except W-10-1982-AC (no gradation listed)
 Exclude_stockpile4 - W-19-0955-AC, W-19-1041-AC (29 samples, total), source: WL367, except W-11-0079-AC (no gradation listed)
 Exclude_stockpile5 - W-18-0391-AC, W-18-0631-AC (14 samples, total), source: WL367, except W-11-0079-AC (no gradation listed)
 Exclude_stockpile6 - W-16-0835-AC - sole sample, source: WL367
 
***********************************************************************************/


select  v_wl800stk.WL800_Sample_ID,
       
        sum (
        case when dl608c.exclude_stockpile1 = 'X' and v_wl800stk.WL800_stockpile_nbr = '1' then v_wl800stk.wl800_pct_used else 0 end +
        case when dl608c.exclude_stockpile2 = 'X' and v_wl800stk.WL800_stockpile_nbr = '2' then v_wl800stk.wl800_pct_used else 0 end +
        case when dl608c.exclude_stockpile3 = 'X' and v_wl800stk.WL800_stockpile_nbr = '3' then v_wl800stk.wl800_pct_used else 0 end +
        case when dl608c.exclude_stockpile4 = 'X' and v_wl800stk.WL800_stockpile_nbr = '4' then v_wl800stk.wl800_pct_used else 0 end +
        case when dl608c.exclude_stockpile5 = 'X' and v_wl800stk.WL800_stockpile_nbr = '5' then v_wl800stk.wl800_pct_used else 0 end +
        case when dl608c.exclude_stockpile6 = 'X' and v_wl800stk.WL800_stockpile_nbr = '6' then v_wl800stk.wl800_pct_used else 0 end 
        )
        as sum_excluded
        
  from V_WL800_Stockpiles_grid   v_wl800stk
  join test_DL608C               dl608c on v_wl800stk.WL800_Sample_ID = dl608c.sample_id
 group by v_wl800stk.WL800_Sample_ID
 ;



--W-15-0599-AC
--W-16-0190-AC

select * from test_dl608c where Sample_ID in ( 'W-15-0599-AC' );


select * from V_WL800_Stockpiles_grid where WL800_Sample_ID = 'W-15-0599-AC';
/*
2015	W-15-0599-AC	1	A	44.5	0.445	100
2015	W-15-0599-AC	2	B	13.6	0.136	100
2015	W-15-0599-AC	3	C	40.5	0.405	100 x
2015	W-15-0599-AC	4	D	1.4	    0.014	100 x
*/

select * from V_WL367_Stockpiles_grid where WL367_Sample_ID = 'W-11-0857-AC';

select * from test_dl608c order by sample_year desc, sample_id;


--create or replace view V_DL608C_batch_weights_grid as 

with WL800_source as (

     select  v_sieve.WL800_SAMPLE_ID                as sample_id
            ,'WL800'                                as source_gradation
            ,v_stock.WL800_STOCKPILE_NBR            as stockpile_nbr
            ,v_stock.WL800_STOCKPILE_DESCRIPTION    as stockpile_description
            ,v_sieve.WL800_SEGMENT_NBR              as segment_nbr
            ,v_sieve.WL800_SIEVE_SIZE               as sieve_size
            ,v_stock.WL800_PCT_USED                 as pct_used
            ,v_stock.WL800_PCT_USED_SUMMATION       as WL800_PCT_USED_summ
            
            ,case when v_stock.WL800_STOCKPILE_NBR = '1' then v_sieve.SP1_PCT_RETAINED
                  when v_stock.WL800_STOCKPILE_NBR = '2' then v_sieve.SP2_PCT_RETAINED
                  when v_stock.WL800_STOCKPILE_NBR = '3' then v_sieve.SP3_PCT_RETAINED
                  when v_stock.WL800_STOCKPILE_NBR = '4' then v_sieve.SP4_PCT_RETAINED
                  when v_stock.WL800_STOCKPILE_NBR = '5' then v_sieve.SP5_PCT_RETAINED
                  when v_stock.WL800_STOCKPILE_NBR = '6' then v_sieve.SP6_PCT_RETAINED
                  else -1 end                       as pct_retained
            
       from V_WL800_Sieve_Segments_grid v_sieve
       join V_WL800_Stockpiles_grid     v_stock on v_stock.WL800_SAMPLE_ID = v_sieve.WL800_SAMPLE_ID
      where v_sieve.sieve_metric_in_mm >= 4.75
      order by v_stock.WL800_STOCKPILE_NBR, v_sieve.WL800_SEGMENT_NBR
)

,WL367_source as (

     select  WL367_Sample_ID                        as sample_id
            ,'WL367'                                as source_gradation
            ,WL367_STOCKPILE_NBR                    as stockpile_nbr
            ,WL800_STOCKPILE_DESCRIPTION            as stockpile_description
            ,WL367_SEGMENT_NBR                      as segment_nbr
            ,WL800_SIEVE_Size                       as sieve_size
            ,WL800_PCT_USED                         as pct_used
            ,WL800_PCT_USED_SUMMATION               as WL800_PCT_USED_summ
            ,WL367_ADJUSTED_BATCH_PCT_RETAINED_CALC as pct_retained
            
       from V_WL367_Stockpiles
      where sieve_metric_in_mm >= 4.75
      order by WL367_STOCKPILE_NBR, WL367_SEGMENT_NBR
)

select  dl608c.sample_id                            as DL608C_Sample_ID
       ,dl608c.gradation_source                     as DL608C_Gradation_Source
       
       /*----------------------------------------------------------------
         DL608C Batches
       ----------------------------------------------------------------*/
       
       ,case when dl608cseg.batch_nbr         is not null then dl608cseg.batch_nbr         else -1  end as DL608C_batch_number
       ,case when dl608cseg.batch_description is not null then dl608cseg.batch_description else ' ' end as DL608C_batch_description
       ,case when dl608cseg.batch_weight      is not null then dl608cseg.batch_weight      else -1  end as DL608C_batch_weight
       
       ,case when dl608c.gradation_source = 'WL800' then wl800_source.stockpile_nbr
             when dl608c.gradation_source = 'WL367' then wl367_source.stockpile_nbr        else ' ' end as stockpile_number
       
       ,case when dl608c.gradation_source = 'WL800' then wl800_source.segment_nbr
             when dl608c.gradation_source = 'WL367' then wl367_source.segment_nbr          else -1  end as segment_nbr
       
       ,case when dl608c.gradation_source = 'WL800' then wl800_source.sieve_size
             when dl608c.gradation_source = 'WL367' then wl367_source.sieve_size           else ' ' end as sieve_size
             
             
       --,case when dl608cseg.segment_nbr       is not null then dl608cseg.segment_nbr       else -1  end as DL608C_segment_nbr       
       --,case when dl608cseg.sieve_size        is not null then dl608cseg.sieve_size        else ' ' end as DL608C_sieve_size
       
       /*----------------------------------------------------------------
         DL608C Batch Weight calculations
       ----------------------------------------------------------------*/
       
--       ,batch_wt_calc as DL608C_batch_weight_sieve
--       
--       ,case when dl632.gradation_source = 'WL800' 
--             then sum(batch_wt_calc) over (partition by dl632.sample_id, dl632seg.batch_nbr
--                  order by dl632.sample_id, dl632seg.batch_nbr, WL800_source.stockpile_nbr, dl632seg.segment_nbr)
--       
--             when dl632.gradation_source = 'WL367' 
--             then sum(batch_wt_calc) over (partition by dl632.sample_id, dl632seg.batch_nbr
--                  order by dl632.sample_id, dl632seg.batch_nbr, WL367_source.stockpile_nbr, dl632seg.segment_nbr)
--             
--             else -1 end as DL632_batch_weight_cumulative
--             
--       ,case when dl632.gradation_source = 'WL800' 
--             then sum(batch_wt_calc) over (partition by dl632.sample_id, dl632seg.batch_nbr, WL800_source.stockpile_nbr
--                  order by dl632.sample_id, dl632seg.batch_nbr, WL800_source.stockpile_nbr, dl632seg.segment_nbr)
--       
--             when dl632.gradation_source = 'WL367' 
--             then sum(batch_wt_calc) over (partition by dl632.sample_id, dl632seg.batch_nbr, WL367_source.stockpile_nbr
--                  order by dl632.sample_id, dl632seg.batch_nbr, WL367_source.stockpile_nbr, dl632seg.segment_nbr)
--             
--             else -1 end as DL632_batch_weight_cum_per_SP
             
       /*----------------------------------------------------------------
         not for display, used in calculations
       ----------------------------------------------------------------*/
       
       ,case when dl608c.gradation_source = 'WL800' then WL800_source.pct_retained
             when dl608c.gradation_source = 'WL367' then WL367_source.pct_retained
             else -1 end as percent_retained
       
       ,case when dl608c.gradation_source = 'WL800' then WL800_source.pct_used
             when dl608c.gradation_source = 'WL367' then WL367_source.pct_used
             else -1 end as percent_used
             
       ,case when dl608c.gradation_source = 'WL800' then WL800_source.WL800_PCT_USED_summ
             when dl608c.gradation_source = 'WL367' then WL367_source.WL800_PCT_USED_summ
             else -1 end as percent_used_summ
       
  /*----------------------------------------------------------------
    table relationships
  ----------------------------------------------------------------*/
  
  from MLT_1_WL900_Sample                       smpl
  join Test_DL608C                            dl608c on dl608c.sample_id = smpl.sample_id
  
  left outer join Test_DL608C_segments     dl608cseg on dl608c.sample_id = dl608cseg.sample_id
  
  left outer join WL800_source                       on dl608c.sample_id        = WL800_source.sample_id
                                                    and dl608c.gradation_source = WL800_source.source_gradation
                                                    and dl608cseg.segment_nbr   = WL800_source.segment_nbr
  
  left outer join WL367_source                       on dl608c.sample_id        = WL367_source.sample_id
                                                    and dl608c.gradation_source = WL367_source.source_gradation
                                                    and dl608cseg.segment_nbr   = WL367_source.segment_nbr


  cross apply (select case when dl608c.gradation_source = 'WL367'
                           then case when dl608c.exclude_stockpile1 = 'X' then WL367_source.pct_used else 0 end +
                                case when dl608c.exclude_stockpile2 = 'X' then WL367_source.pct_used else 0 end +
                           
                           when dl608c.gradation_source = 'WL800'
  
  )
                                                    
  /*----------------------------------------------------------------
    batch weight calculations per sieve, per stockpile
    batch weight * (pct_retained * 0.01)* (pct_used / WL800_PCT_USED_summ) <-- returns true sum of pcts used
  --batch weight * (pct_retained * 0.01)* (pct_used * 0.01)                    (does not assume 100%)
  ----------------------------------------------------------------*/
  
--  cross apply (
--  
--  select case 
--  
--  when dl632.gradation_source = 'WL800' and WL800_source.WL800_PCT_USED_summ > 0
--  then round((dl632seg.batch_weight * (WL800_source.pct_retained * 0.01) * (WL800_source.pct_used / WL800_source.WL800_PCT_USED_summ)),1)
----            DL608C   3000                                                ( 40                   / 100 )
----then round((dl632seg.batch_weight * (WL800_source.pct_retained * 0.01) * (WL800_source.pct_used * 0.01)),1)
--  
--  when dl632.gradation_source = 'WL367' and WL367_source.WL800_PCT_USED_summ > 0
--  then round((dl632seg.batch_weight * (WL367_source.pct_retained * 0.01) * (WL367_source.pct_used / WL367_source.WL800_PCT_USED_summ)),1)    
----then round((dl632seg.batch_weight * (WL367_source.pct_retained * 0.01) * (WL367_source.pct_used * 0.01)),1)
--  
--  else -1
--  end as batch_wt_calc from dual
--  ) calc_weight
  
  
  where dl608c.sample_id = 'W-19-1041-AC'
  
  --and dl632seg.batch_nbr = 1
  --and stockpile_number = '1'
  
  order by 
  dl608c.sample_id
  --,dl608c.batch_nbr
  --,stockpile_number
  --,dl632seg.segment_nbr
 ;









