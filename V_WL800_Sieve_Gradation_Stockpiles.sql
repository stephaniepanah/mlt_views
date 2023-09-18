


select * from V_WL800_Sieve_Gradation_Stockpiles where WL800_Sample_ID = 'W-20-0170';

select * from V_WL800_Stockpiles_grid            where WL800_Sample_ID = 'W-20-0170';

select * from V_WL800_Sieve_Segments_grid        where WL800_Sample_ID = 'W-20-0170';
 


select * from Test_WL800                         order by sample_year desc, sample_id;

select * from test_wl800_Stockpile               order by sample_id, stockpile_nbr;

select * from test_wl800_Segments                order by sample_id, segment_nbr;




----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_WL800 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 7608	    1985	2020



   select sample_year, count(sample_year) from Test_WL800
 group by sample_year
 order by sample_year desc
 ;
/**
2020	26
2019	26
2018	40
2017	39
2016	25
2015	39
2014	18
2013	17
2012	29
2011	33
2010	26
2009	40
2008	26
2007	63
2006	184
2005	130
2004	175
2003	143
2002	236
2001	356
2000	443
1999	324
1998	376
1997	429
1996	360
1995	685
1994	554
1993	377
1992	443
1991	525
1990	578
1989	480
1988	182
1987	118
1986	61
1985	2
1960	4
**/



/***********************************************************************************

 WL800 Sieve Gradation Specs and Stockpiles
 W-18-0036-AC, W-18-0080-AG, W-18-0134-AG, W-18-0391-AC, W-17-0036-AG, W-17-1882-AG

 -- samples good for testing
 W-19-0297-AC, W-19-0297-AC, W-19-0719-AC, W-19-0728-AC, 
 W-19-0759-AC, W-19-0862-AC, W-19-1041-AC, W-19-1041-ACA


 from MTest, Lt_WL800_BC.cpp, LtWL800_BC::CorGrpRoot::doCalcs(){

 for (xp = 0; xp < l_MaxStockpiles; ++xp)
 {
   aratios[xp] = getNum(aPortionX[xp]);
   if (aratios[xp] > 0.0) tot += aratios[xp];
 }

 for (xp = 0; xp < l_MaxStockpiles; ++xp)
 {
   if (aratios[xp] > 0.0)
     aratios[xp] /= tot;
   else
     aratios[xp] = 0.0;
 }
  
 // for each row, multiply by ratio, sum, and place the result in Blend

 for (xr = 0; xr < nrows; ++xr)
 {
   for (xp = 0; xp < l_MaxStockpiles; ++xp)
   {
     if (aratios[xp] > 0.0 && val > 0.0)
     {
       if (gradBlends[xr] < 0.0)
           gradBlends[xr] = val*aratios[xp]; 
       else
           gradBlends[xr] += val*aratios[xp];
     }
   }
 }
 
 
 void LtWL800_BC::CorGrpRoot::maxNominalSv() 
 {
 find the maximum nominal sieve if there is one, and save it to SU 34:-40
 2010-09-24. Conversation with Walt Stong
 Walt says that the Nominal Sieve is the largest sieve retaining more than 10%
 The maximum Nominal sieve is the smallest sieve larger than the Nominal sieve
 What is wanted here may not be the Maximum Nominal sieve, but just the smallest sieve passing 100%

 Original notes (before 2010-09-24):
 PROCEDURE: first try to find a lo/hispec pair where hispec is 100, and lospec is a nr less than 100
 (beware of blank fields which are common)
 If appropriate lo/hispec values are not found, look for the smallest TV = 100
 If this is not found, leave it blank


***********************************************************************************/


create or replace view V_WL800_Sieve_Gradation_Stockpiles as

select  wl800.sample_id                        as WL800_Sample_ID
       ,wl800.sample_year                      as WL800_Sample_Year
       
       ,wl800.test_status                      as WL800_Test_Status
       ,wl800.tested_by                        as WL800_Tested_by
       
       ,case when to_char(wl800.date_tested, 'yyyy') = '1959' then ' '
             else to_char(wl800.date_tested, 'mm/dd/yyyy')
             end                               as WL800_date_tested
            
       ,wl800.date_tested                      as WL800_date_tested_DATE
       ,wl800.date_tested_orig                 as WL800_date_tested_orig
       
       ,wl800.gradation_type                   as WL800_gradation_type
       ,wl800.do_not_report                    as WL800_do_not_report
       --,wl800.Max_Nominal_Sieve                as WL800_Max_Nominal_Sieve
       
       ,wl800.remarks                          as WL800_Remarks
       
  /*----------------------------------------------------------------
    table relationships
  ----------------------------------------------------------------*/
       
  from MLT_1_Sample_WL900                       smpl
  join Test_WL800                              wl800 on wl800.sample_id = smpl.sample_id
 ;









/***********************************************************************************
 
 WL800 Stockpiles
 
***********************************************************************************/


create or replace view V_WL800_Stockpiles_grid as

select  wl800.sample_id   as WL800_Sample_ID -- key

       ,wl800.sample_year as WL800_Sample_year

       ,case when wl800stk.stockpile_nbr         is not null then wl800stk.stockpile_nbr         else '-1' end
        as WL800_stockpile_nbr -- key
        
       ,case when wl800stk.stockpile_description is not null then wl800stk.stockpile_description else  ' ' end
        as WL800_stockpile_description
        
       ,case when wl800stk.pct_used              is not null then wl800stk.pct_used              else   -1 end
        as WL800_pct_used
        
       ,case when wl800stk.pct_used              is not null then (wl800stk.pct_used * 0.01)     else   -1 end
        as WL800_pct_used_decimal
        
       ,sum(case when wl800stk.pct_used          is not null then wl800stk.pct_used else 0 end) over (partition by wl800.sample_id)
        as WL800_pct_used_summation
        
       /*----------------------------------------------------------------------
         table relationships
       ----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                       smpl
       join Test_WL800                              wl800 on wl800.sample_id = smpl.sample_id
       left join Test_WL800_Stockpile            wl800stk on wl800.sample_id = wl800stk.sample_id
        
       order by 
       wl800.sample_id,
       wl800stk.stockpile_nbr
       ;
  


  
  
  
  


/***********************************************************************************
 
 WL800 segments (sieves)
 
***********************************************************************************/


create or replace view V_WL800_Sieve_Segments_grid as 

with v_wl800_stockpile as (

/*------------------------------------------------------------------------------
  cross tab method functionality
  taking the 0 to many records in Test_WL800_Stockpile and rendering them as a single record
  not really "summing" the values, since there is only one row per stockpile_nbr
  but, the crosstab method requires an aggregate function, hence, "summing" one row
------------------------------------------------------------------------------*/

select  WL800_Sample_ID

       ,sum( case WL800_stockpile_nbr when '1' then WL800_pct_used_decimal else 0 end ) as SP1_pctused
       ,sum( case WL800_stockpile_nbr when '2' then WL800_pct_used_decimal else 0 end ) as SP2_pctused
       ,sum( case WL800_stockpile_nbr when '3' then WL800_pct_used_decimal else 0 end ) as SP3_pctused
       ,sum( case WL800_stockpile_nbr when '4' then WL800_pct_used_decimal else 0 end ) as SP4_pctused
       ,sum( case WL800_stockpile_nbr when '5' then WL800_pct_used_decimal else 0 end ) as SP5_pctused
       ,sum( case WL800_stockpile_nbr when '6' then WL800_pct_used_decimal else 0 end ) as SP6_pctused
            
  from V_WL800_Stockpiles_grid
 group by WL800_Sample_ID
)

,pct_retained_sql as (

/*------------------------------------------------------------------------------
 pct retained = (lag pct passing – current pct passing) lag is the previous segment
------------------------------------------------------------------------------*/

select  sample_id   as sample_id
       ,segment_nbr as segment_nbr
       ,sieve_size  as sieve
     
,case when stockpile1_pct_pass >= 0 then 
      case when (lag(stockpile1_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) > 0
           then (lag(stockpile1_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) - stockpile1_pct_pass
           else (100 - stockpile1_pct_pass)  end --- not sure if this 'else' is correct beyond the first segment
      else -1 end as SP1_pct_retained
      
,case when stockpile2_pct_pass >= 0 then 
      case when (lag(stockpile2_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) > 0
           then (lag(stockpile2_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) - stockpile2_pct_pass
           else (100 - stockpile2_pct_pass)  end --- ditto
      else -1 end as SP2_pct_retained
      
,case when stockpile3_pct_pass >= 0 then
      case when (lag(stockpile3_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) > 0
           then (lag(stockpile3_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) - stockpile3_pct_pass
           else (100 - stockpile3_pct_pass)  end --- ditto
      else -1 end as SP3_pct_retained
      
,case when stockpile4_pct_pass >= 0 then
      case when (lag(stockpile4_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) > 0
           then (lag(stockpile4_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) - stockpile4_pct_pass
           else (100 - stockpile4_pct_pass)  end
      else -1 end as SP4_pct_retained
      
,case when stockpile5_pct_pass >= 0 then
      case when (lag(stockpile5_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) > 0
           then (lag(stockpile5_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) - stockpile5_pct_pass
           else (100 - stockpile5_pct_pass)  end
      else -1 end as SP5_pct_retained
      
,case when stockpile6_pct_pass >= 0 then
      case when (lag(stockpile6_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) > 0
           then (lag(stockpile6_pct_pass, 1) over (partition by sample_id order by sample_id, segment_nbr)) - stockpile6_pct_pass
           else (100 - stockpile6_pct_pass)  end
      else -1 end as SP6_pct_retained
      
from Test_WL800_Segments
)

--------------------------------------------------------------------------------
--  main sql
--------------------------------------------------------------------------------

select  wl800.sample_year                         as WL800_Sample_year
       ,wl800.sample_id                           as WL800_Sample_ID   -- key
       ,wl800seg.segment_nbr                      as WL800_segment_nbr -- key              
       ,wl800seg.exclude_segment                  as WL800_exclude_segment       
       ,wl800seg.sieve_size                       as WL800_sieve_size
       
       ,case when wl800seg.pct_passing         >= 0 then wl800seg.pct_passing         else -1 end as WL800_pct_passing
       ,case when wl800seg.lo_spec             >= 0 then wl800seg.lo_spec             else -1 end as WL800_lo_spec
       ,case when wl800seg.hi_spec             >= 0 then wl800seg.hi_spec             else -1 end as WL800_hi_spec
       ,case when wl800seg.stockpile1_pct_pass >= 0 then wl800seg.stockpile1_pct_pass else -1 end as WL800_Stk1_pct_pass      
       ,case when wl800seg.stockpile2_pct_pass >= 0 then wl800seg.stockpile2_pct_pass else -1 end as WL800_Stk2_pct_pass
       ,case when wl800seg.stockpile3_pct_pass >= 0 then wl800seg.stockpile3_pct_pass else -1 end as WL800_Stk3_pct_pass
       ,case when wl800seg.stockpile4_pct_pass >= 0 then wl800seg.stockpile4_pct_pass else -1 end as WL800_Stk4_pct_pass
       ,case when wl800seg.stockpile5_pct_pass >= 0 then wl800seg.stockpile5_pct_pass else -1 end as WL800_Stk5_pct_pass
       ,case when wl800seg.stockpile6_pct_pass >= 0 then wl800seg.stockpile6_pct_pass else -1 end as WL800_Stk6_pct_pass
       
       ,case when calc_blend.pctPassBlend      >= 0 then calc_blend.pctPassBlend      else -1 end as WL800_percent_passing_Blend
       ,wl800seg.Pct_Pass_Blend_captured                                                          as WL800_Pct_Pass_Blend_captured
       
       /*-----------------------------------------------------------------------
         not for display, used for calculating pecent passing blend
         (pct_used * 0.01) from Test_WL800_Stockpile
       -----------------------------------------------------------------------*/
       
       ,case when v_wl800stk.SP1_pctused is not null then v_wl800stk.SP1_pctused else -1 end as SP1_pctused
       ,case when v_wl800stk.SP2_pctused is not null then v_wl800stk.SP2_pctused else -1 end as SP2_pctused
       ,case when v_wl800stk.SP3_pctused is not null then v_wl800stk.SP3_pctused else -1 end as SP3_pctused
       ,case when v_wl800stk.SP4_pctused is not null then v_wl800stk.SP4_pctused else -1 end as SP4_pctused
       ,case when v_wl800stk.SP5_pctused is not null then v_wl800stk.SP5_pctused else -1 end as SP5_pctused
       ,case when v_wl800stk.SP6_pctused is not null then v_wl800stk.SP6_pctused else -1 end as SP6_pctused
       
       /*-----------------------------------------------------------------------
         percent retained, per segment, per stockpile
         percent retained, cumulative
         percent retained, summation
         check W-19-0719-AC #200 -0.5
       -----------------------------------------------------------------------*/
       
       -------------------
       -- Stockpile 1
       -------------------
       ,SP1_pct_retained
       
       ,sum(case when SP1_pct_retained >= 0 then SP1_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id, wl800seg.segment_nbr)
        as SP1_pct_retained_cumulative
        
       ,sum(case when SP1_pct_retained >= 0 then SP1_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id)
        as SP1_pct_retained_summ
        
       -------------------
       -- Stockpile 2
       -------------------
       ,SP2_pct_retained
       
       ,sum(case when SP2_pct_retained >= 0 then SP2_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id, wl800seg.segment_nbr)
        as SP2_pct_retained_cumulative
        
       ,sum(case when SP2_pct_retained >= 0 then SP2_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id)
        as SP2_pct_retained_summ
        
       -------------------
       -- Stockpile 3
       -------------------
       ,SP3_pct_retained
       
       ,sum(case when SP3_pct_retained >= 0 then SP3_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id, wl800seg.segment_nbr)
        as SP3_pct_retained_cumulative
        
       ,sum(case when SP3_pct_retained >= 0 then SP3_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id)
        as SP3_pct_retained_summ
        
       -------------------
       -- Stockpile 4
       -------------------
       ,SP4_pct_retained
       
       ,sum(case when SP4_pct_retained >= 0 then SP4_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id, wl800seg.segment_nbr)
        as SP4_pct_retained_cumulative
        
       ,sum(case when SP4_pct_retained >= 0 then SP4_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id)
        as SP4_pct_retained_summ
        
       -------------------
       -- Stockpile 5
       -------------------
       ,SP5_pct_retained
       
       ,sum(case when SP5_pct_retained >= 0 then SP5_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id, wl800seg.segment_nbr)
        as SP5_pct_retained_cumulative
        
       ,sum(case when SP5_pct_retained >= 0 then SP5_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id)
        as SP5_pct_retained_summ
        
       -------------------
       -- Stockpile 6
       -------------------
       ,SP6_pct_retained
       
       ,sum(case when SP6_pct_retained >= 0 then SP6_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id, wl800seg.segment_nbr)
        as SP6_pct_retained_cumulative
        
       ,sum(case when SP6_pct_retained >= 0 then SP6_pct_retained else 0 end)
            over (partition by wl800seg.sample_id order by wl800seg.sample_id)
        as SP6_pct_retained_summ
       
       /*-----------------------------------------------------------------------
         MLT_Sieve_Size
       -----------------------------------------------------------------------*/
       
       ,sieve_customary
       ,sieve_metric
       ,sieve_metric_in_mm
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                       smpl
       join Test_WL800                              wl800 on wl800.sample_id      = smpl.sample_id
       
       left join Test_WL800_Segments             wl800seg on wl800.sample_id      = wl800seg.sample_id
       
       left join v_wl800_stockpile             v_wl800stk on wl800.sample_id      = v_wl800stk.WL800_Sample_ID
       
       left join pct_retained_sql                         on wl800seg.sample_id   = pct_retained_sql.sample_id
                                                         and wl800seg.segment_nbr = pct_retained_sql.segment_nbr
                                                        
       left join MLT_Sieve_Size                           on (wl800seg.sieve_size = MLT_Sieve_Size.sieve_customary or
                                                              wl800seg.sieve_size = MLT_Sieve_Size.sieve_metric)
       
       /*-----------------------------------------------------------------------
         calculate Percent Passing Blend
         Take each sieve_segment's stockpile's percent passing and 
         multiply that by its corresponding stockpile's percent used. 
         Add the results and place that in percent passing Blend. 
         multiplying pct_used by 0.01, eg; 40.5% * 0.01 = 0.405 (decimal pct)
      ------------------------------------------------------------------------*/
      
      cross apply (select
      
      case when (wl800seg.stockpile1_pct_pass > 0 and v_wl800stk.SP1_pctused  is not null)
           then (wl800seg.stockpile1_pct_pass     *   v_wl800stk.SP1_pctused) else 0 end 
      +
      case when (wl800seg.stockpile2_pct_pass > 0 and v_wl800stk.SP2_pctused  is not null)
           then (wl800seg.stockpile2_pct_pass     *   v_wl800stk.SP2_pctused) else 0 end 
      +
      case when (wl800seg.stockpile3_pct_pass > 0 and v_wl800stk.SP3_pctused  is not null)
           then (wl800seg.stockpile3_pct_pass     *   v_wl800stk.SP3_pctused) else 0 end 
      +
      case when (wl800seg.stockpile4_pct_pass > 0 and v_wl800stk.SP4_pctused  is not null)
           then (wl800seg.stockpile4_pct_pass     *   v_wl800stk.SP4_pctused) else 0 end 
      +
      case when (wl800seg.stockpile5_pct_pass > 0 and v_wl800stk.SP5_pctused  is not null)
           then (wl800seg.stockpile5_pct_pass     *   v_wl800stk.SP5_pctused) else 0 end 
      +
      case when (wl800seg.stockpile6_pct_pass > 0 and v_wl800stk.SP6_pctused  is not null)
           then (wl800seg.stockpile6_pct_pass     *   v_wl800stk.SP6_pctused) else 0 end
      
      as pctPassBlend from dual
      ) calc_blend
      
      order by
      wl800.sample_id,
      wl800seg.segment_nbr
      ;
  








