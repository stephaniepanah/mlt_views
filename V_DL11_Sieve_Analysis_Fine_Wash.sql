


----------------------------------------------------------------------------
-- DL11 Sieve Analysis, fine wash T11/T27     (2021)
-- DL27 Sieve Analysis, Complete Dry/Washed   (2020)
-- T30  Sieve Analysis of Extracted Aggregate (2020)
-- T37  Sieve Analysis of Mineral Filler      (1994)
----------------------------------------------------------------------------




select * from V_DL11_Sieve_Analysis_Fine_Wash where DL11_Sample_ID = 
'W-19-0004-SO'
--'W-20-0179' 
--'W-20-0590' 
--'W-20-1158-AG' 
--'W-20-0681-SO' 

;



select * from V_DL11_sieve_segments where sample_id in ('W-19-0004-SO');




----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_DL11 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 3784	    1986	2021
-- 3605 including 1960



   select sample_year, count(sample_year) from Test_DL11
 group by sample_year
 order by sample_year desc
 ;
/**
2020	158
2019	198
2018	288
2017	222
2016	127
2015	66
2014	212
2013	28
2012	48
2011	65
2010	138
2009	64
2008	68
2007	35
2006	82
2005	54
2004	32
2003	100
2002	107
2001	80
2000	48
1999	124
1998	71
1997	67
1996	70
1995	170
1994	85
1993	61
1992	82
1991	145
1990	82
1989	150
1988	153
1987	95
1986	28
1960	2
**/



/***********************************************************************************

 DL11 Sieve Analysis, fine wash T11/T27
 
 W-20-0010,    W-20-0018,    W-20-0056,    W-20-0208
 W-20-0681-SO, W-20-0760-SO, W-20-0948-SO, W-20-1342-SO
 W-19-0004-SO, W-19-0005-SO, W-19-0006-SO, W-19-0009-SO
 W-18-0048-SO, W-18-0053-SO, W-17-0001-AG, W-17-0002-AG

 CustomaryOrMetric
 W-18-0048-SO |C| Sieve Units, Customary
 W-07-0165-AG |M| Sieve Units, Metric <-- most recent occurrence of metric
 W-06-0310-AG |M| Sieve Units, Metric
 
 from MTest, Lt_DL11_BC.cpp
 Get raw gradation data (from WL640 Raw Gradation) and display in appropriate fields
 
 see DL11 segment processing calculations, below

***********************************************************************************/


create or replace view V_DL11_Sieve_Analysis_Fine_Wash as 

with v_wl640 as (
     
--------------------------------------------------------------------------------
-- WL640 summation values
-- WL640 is the source of the coarse sieves, and CPan (coarse pan, the Fines, #4-) as well
-- Use a single segment, otherwise, a cartesian join will result, and what a mess that would be
--------------------------------------------------------------------------------
    
select  WL640_Sample_ID
       ,WL640_mass_of_fines -- #4-
       ,WL640_Mass_Total    -- step 1
       ,WL640_mass_retained_summ_coarse as WL640_summ_coarse
       ,case when WL640_pct_passing_nbr4 >= 0 then WL640_pct_passing_nbr4 else 0 end as WL640_pct_passing_nbr4
                
  from V_WL640_Prep_Raw_Gradation
 where WL640_segment_nbr = 1
)

--------------------------------------------------------------------------------
-- main SQL
--------------------------------------------------------------------------------

select  dl11.sample_id                                         as DL11_Sample_ID
       ,dl11.sample_year                                       as DL11_sample_year
       ,dl11.test_status                                       as DL11_test_status
       ,dl11.tested_by                                         as DL11_tested_by
       
       ,case when to_char(dl11.date_tested, 'yyyy') = '1959'   then ' '
             else to_char(dl11.date_tested, 'mm/dd/yyyy') end  as DL11_date_tested
       
       ,dl11.date_tested                                       as DL11_date_tested_DATE
       ,dl11.date_tested_orig                                  as DL11_date_orig
       
       ,dl11.customary_metric                                  as DL11_customary_metric
       
       /*--------------------------------------------------------------------------------
         Fine Sieving values
       --------------------------------------------------------------------------------*/
       
       ,dl11.mass_dry_before_wash                              as DL11_mass_dry_before_wash        
       ,dl11.mass_dry_after_wash                               as DL11_mass_dry_after_wash        
       ,dl11.mass_pan                                          as DL11_mass_pan
       
       /*--------------------------------------------------------------------------------
         WL640 Summation values: Fine, Coarse, Total and other calculations
       --------------------------------------------------------------------------------*/
       
       ,v_wl640.WL640_mass_of_fines
       ,v_wl640.WL640_summ_coarse
       ,v_wl640.WL640_Mass_Total
       ,v_wl640.WL640_pct_passing_nbr4 -- ((WL640_summ_coarse / WL640_Mass_Total) * 100)
       
       ,T11_Factor                                             as DL11_T11_Factor  -- (WL640_pct_passing_nbr4 / dl11.mass_dry_before_wash)
       
       /*--------------------------------------------------------------------------------
         WL640 Coarse sieves, group_nbr 1
            DL11 Fine sieves, group_nbr 2
       --------------------------------------------------------------------------------*/
       
       ,v_dl11seg.group_nbr                                    as DL11_group_nbr
       ,v_dl11seg.seg_nbr                                      as DL11_segment_nbr
       ,v_dl11seg.sieve_size                                   as DL11_sieve_size
       ,v_dl11seg.mass_retained                                as DL11_mass_retained
       ,v_dl11seg.pct_passing                                  as DL11_pct_passing
        
       /*---------------------------------------------------------------------------
         MLT_sieve_size
       ---------------------------------------------------------------------------*/
       
       ,mlt_sieve_size.sieve_customary
       ,mlt_sieve_size.sieve_metric
       ,mlt_sieve_size.sieve_metric_in_mm
       
       ,dl11.remarks as DL11_remarks
       
       /*--------------------------------------------------------------------------------
         table relationships
       --------------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_DL11                                     dl11 on dl11.sample_id = smpl.sample_id
       
       left join v_wl640                                       on dl11.sample_id = v_wl640.WL640_Sample_ID
       
       left join V_DL11_sieve_segments               v_dl11seg on dl11.sample_id = v_dl11seg.sample_id
                                                    
       left join mlt_sieve_size                                on (v_dl11seg.sieve_size = mlt_sieve_size.sieve_customary or
                                                                   v_dl11seg.sieve_size = mlt_sieve_size.sieve_metric)
       
       /*---------------------------------------------------------------------------
         calculations
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when (v_wl640.WL640_pct_passing_nbr4 >= 0 and dl11.mass_dry_before_wash > 0) 
                                then (v_wl640.WL640_pct_passing_nbr4 / dl11.mass_dry_before_wash)
                                else 0 end as T11_Factor from dual) CALC_T11
       
       
       order by 
       dl11.sample_id, 
       v_dl11seg.group_nbr, 
       v_dl11seg.seg_nbr
       ;









/***********************************************************************************
 
 V_DL11_sieve_segments
 
***********************************************************************************/


create or replace view V_DL11_sieve_segments as 
  
  -- coarse sieves
  select  WL640_Sample_ID                      as sample_id
          ,1                                   as group_nbr
          ,WL640_segment_nbr                   as seg_nbr  
          ,WL640_sieve_size                    as sieve_size
          ,WL640_mass_retained                 as mass_retained
          ,WL640_pct_passing                   as pct_passing
          
    from  V_WL640_Prep_Raw_Gradation
      
   union

  -- fine sieves
  select  dl11seg.sample_id                    as sample_id
          ,2                                   as group_nbr
          ,dl11seg.segment_nbr                 as seg_nbr
          ,dl11seg.sieve_size                  as sieve_size
          ,dl11seg.mass_retained               as mass_retained
            
          ,v_wl640.WL640_pct_passing_nbr4 - 
           ((sum(dl11seg.mass_retained) over (partition by dl11seg.sample_id order by dl11seg.sample_id, dl11seg.segment_nbr)) * T11_Factor)
                                               as pct_passing
          
    from  Test_DL11_segments          dl11seg 
    join  Test_DL11                       dl11 on dl11.sample_id = dl11seg.sample_id
    
    join V_WL640_Prep_Raw_Gradation    v_wl640 on v_wl640.WL640_Sample_ID   = dl11seg.sample_id and 
                                                  v_wl640.WL640_segment_nbr = 1 
 
   cross apply (select case when (v_wl640.WL640_pct_passing_nbr4 >= 0 and dl11.mass_dry_before_wash > 0) 
                            then (v_wl640.WL640_pct_passing_nbr4 / dl11.mass_dry_before_wash)
                            else 0 end as T11_Factor from dual) t11factor
   
   order by sample_id, group_nbr, seg_nbr
   ;




/***********************************************************************************

 calculations for DL11 Results percent passing

 from MTest, Lt_DL11_BC.cpp, void LtDL11_BC::CorGrpRoot::doCalcs()

 MEASURED VALUES:
     
 Coarse Sieve: Check weight, weights retained, wt passing #4
   Fine Sieve: Weights retained, wt passing #200 sieve
 Wt before wash
 Wt after wash
 
 BASIC FORMULAS:
 
 Ctot       = #4-wt + sum { Cwt(i) } 
           --- if Ctot .NE. Ccheckwt +/- 0.3%, ERROR
           --- Ccheckwt is total mass, effectively
     
 C%ret[i]   = Cwt[i] * 100 / Ccheckwt   ---(100 / Ccheckwt is the factor)
 
 C%pass[0]  = 100 - C%ret[i]
            = 100 - (Cwt[i] * 100 / Ccheckwt)
            
 C%pass[i]  = C%pass[i-1] - C%ret[i]   Begin i = 1
     
 200-washed = Bwash - Awash
 200-tot    = #200-wt + 200-washed
 PP200      = 100 * 200-tot / Bwash
     
 Ftot       = sum { Fwt(i) } + 200-tot --- if Ftot .NE. Fcheckwt +/- 0.3%, ERROR
 
 T-11       = (C%pass(#4) - PP200) / Fcheckwt
     
 F%ret(i)   = T-11 * Fwt(i) 
 F%pass(1)  = C%pass(#4)  - F%ret(0)
 F%pass(i)  = F%pass(i-1) - F%ret(i) Begin i = 1
 
 if F%pass(#200) .NE. PP200 +/- 0.1%, ERROR
   
 CONDENSED FORMULAS:
 
 Cwt(i)     = Entered Coarse weights
 TOT        = #4-wt + sum { Cwt(i) } 
            --- if TOT .NE. CCheckwt +/- 0.3% ERROR
           
 Result(0)  = 100 - Cwt(0) * 100/Ccheckwt
 Result(i)  = Result(i-1) - Cwt(i) * 100/Ccheckwt     Begin i = 1
 Pass4      = Result(#4)
 
 Fwt(i)     = Entered Fine weights
 TOT        = #200-wt + Bwash - Awash + sum { Fwt(i) } 
            --- if TOT .NE. Fcheckwt +/- 0.3% ERROR
           
 T11        = Pass4 / Fcheckwt
              factor = pass4 / fdrywt;  // T-11 factor
     
         j  = index to Result(#4) + 1
 Result(j)  = (Pass4 - T11 * Fwt(0)
 Result(j)  = Result(j-1) - T11*Fwt(i) 
            --- if Result(#200) .NE. PP200 +/- 0.1 ERROR (NOT 0.1%)
 
 
***********************************************************************************/









