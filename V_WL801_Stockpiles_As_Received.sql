


select * from V_WL801_Stockpiles_As_Received order by WL801_sample_year desc;



select * from V_WL801_Stockpiles_grid;



select * from V_WL801_Sieve_Segments_grid;


 

select count(*), min(sample_year), max(sample_year) from Test_WL801 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 87	    2002	2016



select * from Test_WL801 order by sample_year desc;


select * from Test_WL801_Stockpile;


select * from Test_WL801_segments;




/***********************************************************************************

 WL801 Stockpiles as Received
 W-18-0036-AC, W-18-0080-AG, W-18-0134-AG, W-18-0391-AC, W-17-0036-AG, W-17-1882-AG

 -- samples good for testing
 W-19-0297-AC, W-19-0297-AC, W-19-0719-AC, W-19-0728-AC, 
 W-19-0759-AC, W-19-0862-AC, W-19-1041-AC, W-19-1041-ACA


 from MTest, Lt_WL801_BC.cpp, LtWL801_BC::CorGrpRoot::doCalcs()

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

***********************************************************************************/



create or replace view V_WL801_Stockpiles_As_Received as

select  wl801.sample_year                      as WL801_Sample_Year
       ,wl801.sample_id                        as WL801_Sample_ID
       
       ,wl801.test_status                      as WL801_Test_Status
       ,wl801.tested_by                        as WL801_Tested_by
       
       ,case when to_char(wl801.dt_tested, 'yyyy') = '1959' 
             then ' '
             else to_char(wl801.dt_tested, 'mm/dd/yyyy')
             end                               as WL801_dt_tested
            
       ,wl801.dt_tested                        as WL801_dt_tested_DATE
       ,wl801.dt_tested_orig                   as WL801_dt_tested_orig
       
       ,wl801.remarks                          as WL801_Remarks
       
  /*----------------------------------------------------------------
    table relationships
  ----------------------------------------------------------------*/
       
  from MLT_1_WL900_Sample                       smpl
  join Test_WL801                              wl801 on wl801.sample_id = smpl.sample_id
 ;









/***********************************************************************************
 
 WL801 Stockpiles
 
***********************************************************************************/
       

create or replace view V_WL801_Stockpiles_grid as

select  wl801stk.sample_id                        as WL801_Sample_ID   -- key
       ,wl801stk.stockpile_nbr                    as WL801_stockpile_nbr -- key              
       ,wl801stk.stockpile_description            as WL801_stockpile_description       
       ,wl801stk.pct_used                         as WL801_pct_used
       
  /*----------------------------------------------------------------
    table relationships
  ----------------------------------------------------------------*/
  
  from MLT_1_WL900_Sample                       smpl
  join Test_WL801                              wl801 on wl801.sample_id = smpl.sample_id
  left outer join Test_WL801_Stockpile      wl801stk on wl801.sample_id = wl801stk.sample_id
  ;
  
  
  
  





/***********************************************************************************
 
 WL801 segments (sieves)
 
***********************************************************************************/
       

create or replace view V_WL801_Sieve_Segments_grid as

with stockpile_sql as (

     -- cross tab method functionality
     -- taking the 0 to many records in Test_WL801_Stockpile and rendering them as a single record
     -- not really "summing" values, since there is only one row per stockpile_nbr
     -- but, the crosstab method requires an aggregate function, hence, "summing" one row

     select  sample_id
            ,sum( case Stockpile_nbr when '1' then (pct_used * 0.01) else 0 end ) as SP1_pctused
            ,sum( case Stockpile_nbr when '2' then (pct_used * 0.01) else 0 end ) as SP2_pctused
            ,sum( case Stockpile_nbr when '3' then (pct_used * 0.01) else 0 end ) as SP3_pctused
            ,sum( case Stockpile_nbr when '4' then (pct_used * 0.01) else 0 end ) as SP4_pctused
            ,sum( case Stockpile_nbr when '5' then (pct_used * 0.01) else 0 end ) as SP5_pctused
            ,sum( case Stockpile_nbr when '6' then (pct_used * 0.01) else 0 end ) as SP6_pctused
            
       from Test_WL801_Stockpile
      group by sample_id
)

select  wl801seg.sample_id                        as WL801_Sample_ID   -- key
       ,wl801seg.segment_nbr                      as WL801_segment_nbr -- key              
       ,wl801seg.exclude_segment                  as WL801_exclude_segment       
       ,wl801seg.sieve_size                       as WL801_sieve_size
       
       ,case when wl801seg.pct_passing         >= 0 then to_char(wl801seg.pct_passing, '990.99')         else ' ' end as WL801_pct_passing
       ,case when wl801seg.lo_spec             >= 0 then to_char(wl801seg.lo_spec, '990.99')             else ' ' end as WL801_lo_spec
       ,case when wl801seg.hi_spec             >= 0 then to_char(wl801seg.hi_spec, '990.99')             else ' ' end as WL801_hi_spec
       ,case when wl801seg.stockpile1_pct_pass >= 0 then to_char(wl801seg.stockpile1_pct_pass, '990.99') else ' ' end as WL801_Stk1_pct_pass       
       ,case when wl801seg.stockpile2_pct_pass >= 0 then to_char(wl801seg.stockpile2_pct_pass, '990.99') else ' ' end as WL801_Stk2_pct_pass
       ,case when wl801seg.stockpile3_pct_pass >= 0 then to_char(wl801seg.stockpile3_pct_pass, '990.99') else ' ' end as WL801_Stk3_pct_pass
       ,case when wl801seg.stockpile4_pct_pass >= 0 then to_char(wl801seg.stockpile4_pct_pass, '990.99') else ' ' end as WL801_Stk4_pct_pass
       ,case when wl801seg.stockpile5_pct_pass >= 0 then to_char(wl801seg.stockpile5_pct_pass, '990.99') else ' ' end as WL801_Stk5_pct_pass
       ,case when wl801seg.stockpile6_pct_pass >= 0 then to_char(wl801seg.stockpile6_pct_pass, '990.99') else ' ' end as WL801_Stk6_pct_pass
       
       ,case when calc_blend.Blend             >= 0 then to_char(calc_blend.blend, '990.99')             else ' ' end as WL801_Blend
       
       /*----------------------------------------------------------------
         not for display, used for calulating Blend
       ----------------------------------------------------------------*/
       
       ,wl801stk.sample_id   -- from Test_WL801_Stockpile
       ,wl801stk.SP1_pctused -- (pct_used * 0.01)
       ,wl801stk.SP2_pctused
       ,wl801stk.SP3_pctused
       ,wl801stk.SP4_pctused
       ,wl801stk.SP5_pctused
       ,wl801stk.SP6_pctused
       
  /*----------------------------------------------------------------
    table relationships
  ----------------------------------------------------------------*/
  
  from MLT_1_WL900_Sample                       smpl
  join Test_WL801                              wl801 on wl801.sample_id = smpl.sample_id
  left outer join Test_WL801_Segments       wl801seg on wl801.sample_id = wl801seg.sample_id
  left outer join stockpile_sql             wl801stk on wl801.sample_id = wl801stk.sample_id
      
  /*----------------------------------------------------------------
    calculate Blend
    Take each sieve_segment's stockpile's percent passing and 
    multiply that by its corresponding stockpile's percent used. 
    Add the results and place that in Blend
    multiplying pct_used by 0.01, eg; 40.5% * 0.01 = 0.405 (decimal pct)
  ----------------------------------------------------------------*/
  
  cross apply (select
  case when wl801seg.stockpile1_pct_pass > 0 then wl801seg.stockpile1_pct_pass * wl801stk.SP1_pctused else 0 end +
  case when wl801seg.stockpile2_pct_pass > 0 then wl801seg.stockpile2_pct_pass * wl801stk.SP2_pctused else 0 end +
  case when wl801seg.stockpile3_pct_pass > 0 then wl801seg.stockpile3_pct_pass * wl801stk.SP3_pctused else 0 end +
  case when wl801seg.stockpile4_pct_pass > 0 then wl801seg.stockpile4_pct_pass * wl801stk.SP4_pctused else 0 end +
  case when wl801seg.stockpile5_pct_pass > 0 then wl801seg.stockpile5_pct_pass * wl801stk.SP5_pctused else 0 end +
  case when wl801seg.stockpile6_pct_pass > 0 then wl801seg.stockpile6_pct_pass * wl801stk.SP6_pctused else 0 end
  as Blend from dual
  ) calc_blend
  
  order by
  wl801seg.sample_id,
  wl801seg.segment_nbr
  ;
  








