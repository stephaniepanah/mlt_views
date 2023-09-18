 


select * from V_DL632_Batch_Weights_for_Asphalt_Mix_Design
 order by DL632_Sample_Year desc, DL632_Sample_ID
;




select * from V_DL632_Batch_Weights_for_Asphalt_Mix_Design where DL632_Sample_ID = 
--'W-19-0728-AC' 
'W-19-1041-AC'
;




select * from V_DL632_batch_weights_grid where DL632_Sample_ID = 
'W-19-1041-AC' 
;

-- V_DL608c_Batch_Weights_Coarse_Specific_Gravity



/***********************************************************************************

 DL632 Batch Weights for Asphalt Mix Design

***********************************************************************************/


create or replace view V_DL632_Batch_Weights_for_Asphalt_Mix_Design as


select  dl632.sample_year                                       as DL632_Sample_Year
       ,dl632.sample_id                                         as DL632_Sample_ID
       
       ,dl632.test_status                                       as DL632_Test_Status
       ,dl632.tested_by                                         as DL632_Tested_by
       
       
       ,case when to_char(dl632.date_tested, 'yyyy') = '1959'   then ' ' 
        else to_char(dl632.date_tested, 'mm/dd/yyyy') end       as DL632_date_tested
            
       ,dl632.date_tested                                       as DL632_date_tested_DATE
       ,dl632.date_tested_orig                                  as DL632_date_tested_orig
       
       ,dl632.gradation_source                                  as DL632_Gradation_Source
       ,dl632.proposed_batch_weight                             as DL632_Proposed_Batch_Weight
       
       ,dl632.exclude_stockpile1                                as DL632_Exclude_Stockpile1
       ,dl632.exclude_stockpile2                                as DL632_Exclude_Stockpile2
       ,dl632.exclude_stockpile3                                as DL632_Exclude_Stockpile3
       ,dl632.exclude_stockpile4                                as DL632_Exclude_Stockpile4
       ,dl632.exclude_stockpile5                                as DL632_Exclude_Stockpile5
       ,dl632.exclude_stockpile6                                as DL632_Exclude_Stockpile6
       
       ,dl632.remarks                                           as DL632_Remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                             smpl
       join Test_DL632                                    dl632 on dl632.sample_id = smpl.sample_id
       ;


  
  
  
  
  
  
  
/***********************************************************************************
 
 V_DL632_batch_weights_grid
 
***********************************************************************************/


create or replace view V_DL632_batch_weights_grid as 


with WL800_source as (

     select  v_sieve.WL800_SAMPLE_ID                as sample_id
            ,'WL800'                                as source_gradation
            ,v_stock.WL800_STOCKPILE_NBR            as stockpile_nbr
            ,v_stock.WL800_STOCKPILE_DESCRIPTION    as stockpile_description
            ,v_sieve.WL800_SEGMENT_NBR              as segment_nbr
            ,v_sieve.WL800_SIEVE_SIZE               as sieve_size
            
            ,case when v_stock.WL800_STOCKPILE_NBR = '1' then v_sieve.SP1_PCT_RETAINED
                  when v_stock.WL800_STOCKPILE_NBR = '2' then v_sieve.SP2_PCT_RETAINED
                  when v_stock.WL800_STOCKPILE_NBR = '3' then v_sieve.SP3_PCT_RETAINED
                  when v_stock.WL800_STOCKPILE_NBR = '4' then v_sieve.SP4_PCT_RETAINED
                  when v_stock.WL800_STOCKPILE_NBR = '5' then v_sieve.SP5_PCT_RETAINED
                  when v_stock.WL800_STOCKPILE_NBR = '6' then v_sieve.SP6_PCT_RETAINED
                  else -1 end                       as pct_retained
            
            ,v_stock.WL800_PCT_USED                 as pct_used
            ,v_stock.WL800_PCT_USED_SUMMATION       as WL800_PCT_USED_summ
            
       from V_WL800_Sieve_Segments_grid     v_sieve
       join V_WL800_Stockpiles_grid         v_stock on v_stock.WL800_SAMPLE_ID = v_sieve.WL800_SAMPLE_ID
)

,WL367_source as (

     select  WL367_Sample_ID                        as sample_id
            ,'WL367'                                as source_gradation
            ,WL367_STOCKPILE_NBR                    as stockpile_nbr
            ,WL800_STOCKPILE_DESCRIPTION            as stockpile_description
            ,WL367_SEGMENT_NBR                      as segment_nbr
            ,WL800_SIEVE_size                       as sieve_size
            ,WL367_ADJUSTED_BATCH_PCT_RETAINED      as pct_retained
            ,WL800_PCT_USED                         as pct_used
            ,WL800_PCT_USED_SUMMATION               as WL800_PCT_USED_summ
            
       from V_WL367_Stockpiles_grid
)

--------------------------------------------------------------------------------
-- main sql
--------------------------------------------------------------------------------

select  dl632.sample_id                             as DL632_Sample_ID
       ,dl632.gradation_source                      as DL632_Gradation_Source
       
       /*-----------------------------------------------------------------------
         DL632 Batches
       -----------------------------------------------------------------------*/
       
       ,case when dl632seg.batch_nbr         is not null then dl632seg.batch_nbr         else -1  end as DL632_batch_number
       ,case when dl632seg.batch_description is not null then dl632seg.batch_description else ' ' end as DL632_batch_description
       ,case when dl632seg.batch_weight      is not null then dl632seg.batch_weight      else -1  end as DL632_batch_weight
       
       ,case when dl632.gradation_source = 'WL800' then wl800_source.stockpile_nbr
             when dl632.gradation_source = 'WL367' then wl367_source.stockpile_nbr
             else ' ' end as stockpile_number
             
       ,case when dl632seg.segment_nbr       is not null then dl632seg.segment_nbr       else -1  end as DL632_segment_nbr
       ,case when dl632seg.sieve_size        is not null then dl632seg.sieve_size        else ' ' end as DL632_sieve_size
       
       /*-----------------------------------------------------------------------
         DL632 Batch Weight calculations
       -----------------------------------------------------------------------*/
       
       ,batch_wt_calc as DL632_batch_weight_sieve
       
       ,case when dl632.gradation_source = 'WL800' 
             then sum(batch_wt_calc) over (partition by dl632.sample_id, dl632seg.batch_nbr
                  order by dl632.sample_id, dl632seg.batch_nbr, WL800_source.stockpile_nbr, dl632seg.segment_nbr)
       
             when dl632.gradation_source = 'WL367' 
             then sum(batch_wt_calc) over (partition by dl632.sample_id, dl632seg.batch_nbr
                  order by dl632.sample_id, dl632seg.batch_nbr, WL367_source.stockpile_nbr, dl632seg.segment_nbr)
             
             else -1 end as DL632_batch_weight_cumulative
             
       ,case when dl632.gradation_source = 'WL800' 
             then sum(batch_wt_calc) over (partition by dl632.sample_id, dl632seg.batch_nbr, WL800_source.stockpile_nbr
                  order by dl632.sample_id, dl632seg.batch_nbr, WL800_source.stockpile_nbr, dl632seg.segment_nbr)
       
             when dl632.gradation_source = 'WL367' 
             then sum(batch_wt_calc) over (partition by dl632.sample_id, dl632seg.batch_nbr, WL367_source.stockpile_nbr
                  order by dl632.sample_id, dl632seg.batch_nbr, WL367_source.stockpile_nbr, dl632seg.segment_nbr)
             
             else -1 end as DL632_batch_weight_cum_per_SP
             
       /*-----------------------------------------------------------------------
         not for display, used in calculations
       -----------------------------------------------------------------------*/
       
       ,case when dl632.gradation_source = 'WL800' then WL800_source.pct_retained
             when dl632.gradation_source = 'WL367' then WL367_source.pct_retained
             else -1 end as percent_retained
       
       ,case when dl632.gradation_source = 'WL800' then WL800_source.pct_used
             when dl632.gradation_source = 'WL367' then WL367_source.pct_used
             else -1 end as percent_used
             
       ,case when dl632.gradation_source = 'WL800' then WL800_source.WL800_PCT_USED_summ
             when dl632.gradation_source = 'WL367' then WL367_source.WL800_PCT_USED_summ
             else -1 end as percent_used_summ
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                       smpl
       join Test_DL632                              dl632 on dl632.sample_id = smpl.sample_id
       
       left join Test_DL632_segments             dl632seg on dl632.sample_id = dl632seg.sample_id
       
       left join WL800_source                             on dl632.sample_id        = WL800_source.sample_id
                                                         and dl632.gradation_source = WL800_source.source_gradation
                                                         and dl632seg.segment_nbr   = WL800_source.segment_nbr
       
       left join WL367_source                             on dl632.sample_id        = WL367_source.sample_id
                                                         and dl632.gradation_source = WL367_source.source_gradation
                                                         and dl632seg.segment_nbr   = WL367_source.segment_nbr
       
       /*-----------------------------------------------------------------------
         batch weight calculations per sieve, per stockpile
         batch weight * (pct_retained * 0.01)* (pct_used / WL800_PCT_USED_summ) <-- returns true sum of pcts used
         --batch weight * (pct_retained * 0.01)* (pct_used * 0.01)                    (does not assume 100%)
       ----------------------------------------------------------------*/
       
       cross apply (select case 
       
       when dl632.gradation_source = 'WL800' and WL800_source.WL800_PCT_USED_summ > 0
       then (dl632seg.batch_weight * (WL800_source.pct_retained * 0.01) * (WL800_source.pct_used / WL800_source.WL800_PCT_USED_summ))
       
       when dl632.gradation_source = 'WL367' and WL367_source.WL800_PCT_USED_summ > 0
       then (dl632seg.batch_weight * (WL367_source.pct_retained * 0.01) * (WL367_source.pct_used / WL367_source.WL800_PCT_USED_summ))
       
       else -1 end as batch_wt_calc from dual) calc_weight
       
       order by 
       dl632.sample_id,
       dl632seg.batch_nbr,
       stockpile_number,
       dl632seg.segment_nbr
       ;









