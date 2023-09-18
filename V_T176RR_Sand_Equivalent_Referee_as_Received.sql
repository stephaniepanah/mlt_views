


/***********************************************************************************

                                                                count   minYr   maxYr
 T176-ad Sand Equivalent: Air Dry, Alternate 1                    10	1992	2001
 T176-pf Sand Equivalent: Pre Wet Field Moist                    789	1986	2001
 T176-pc Sand Equivalent: Pre Wet, Alternate 1 (lab crushed)     311	1986	2008
 T176-pr Sand Equivalent: Pre Wet, Alternate 2 (as received)    4536	1986	2019
 T176-rc Sand Equivalent: Referee (lab crushed)                  505	1991	2020
 T176-rr Sand Equivalent: Referee (as received)                 5603	1991	2020

***********************************************************************************/



select * from V_T176RR_Sand_Equivalent_Referee_as_Received 

 where t176hdr.sample_id in (
       'W-20-0179', 'W-20-0590', 'W-20-1158-AG',       -- DL11
       'W-20-0036', 'W-20-0138', 'W-20-0660',          -- DL27
       'W-20-0687-AG', 'W-20-0888-AG', 'W-20-0980-AG'  -- WL413
       )
       
 order by T176RR_Sample_Year, T176RR_Sample_ID, T176RR_segment_nbr
;




/***********************************************************************************

page 242 of the Fp-14

(2) SEP (SE/P200 (SE/P75) Index) is a measure of a material’s ability to perform 
based on the quality and quantity of fines present

Quality  is represented by the sand equivalent (SE) and 
quantity is represented by the percent passing the No. 200 (75-µm) sieve (P200 (75))

SEP is computed as follows: 

For SE >= 29, SEP = SE/(P200 (75) + 25) 
For SE  < 29, SEP = (SE + 4)/(SE + P200 (75))

Where: 
SE = Plastic fines in graded aggregates and soils by using the sand equivalent test
See AASHTO T 176, Alternate Method No.2, Reference Method

P200 (75) = Material finer than the No. 200 (75 µm) sieve in mineral aggregates by washing
See AASHTO T 11

-------------------------------------------------------
-------------------------------------------------------

 
 CustomaryOrMetric 
 [0] D = Disable calculations, E = Enable calculations
 W-18-0078-AG |D|
 W-18-0732-AG |E|
 W-17-0337-AG |E|
 W-17-0338-AG |D|
 
 
 from MTest, Lt_T176_B1.cpp
 --------------------------
 
 void calcAll(){ doCalcs(-1); }
 void calcSep(){ doCalcs(-2); }
 void doCalcs(int xrow);
 double calcTrial(double sr, double cr);
 
 if( calcsEnabled() )
     calcAll(); // autocalcs
 
 if( val && calcsEnabled() )
     calcSep(); // autocalc SEP
 
 
 void mtT176_lo::CorGrpRoot::doCalcs(int xrow)
 { 
    * ARGUMENTS
    *  xrow:
    *    >= 0: row of SA table
    *    -1: calc all
    *    -2: calc SEP
    *
    * Calculate the sand equivalent for a single trial, display & store the result
    *
    * equiv = 100.0 * sand reading / clay reading
    * if equiv has a fractional part >= 0.1, round up to the next integer
    
    * 1-89: JJ talked to AASHTO and says the raw result should
    * first be rounded to the nearest tenth, and if this rounded result
    * is .1 or more, round up. The effect is to round up from .05
    
    
    bool dosep = _mtm->isSepEnabled(); what are the circumstances where dosep is enabled?
    
    if( xrow == -2 ) // SEP only
    {
      if( dosep )
         se = <get data>
    }  
    else
    {
      if( xrow == -1  ) // calc all
	  {
         for(each row)
         {
            sr = <get data>
            cr = <get data>
            se = calcTrial(sr, cr);
         }
      }
      
      //average SE
      if (se >= 0.0)
      {
        sum += (int)se; // add all rows over 0
        ++nr;           // increment number of rows
      }
      
      avse = sum / nr;
      if (sum%nr) avse += 1; // round up if any fraction, aka, ceiling      
      se = avse;
    }
    
    double sep = FLT_BLANK;
    
    if( dosep ) // (sand equivalent pct passing #200)
    {
       double pass200 = getPass200(); // GET % passing 0.075mm (#200 = 75µm = 0.075mm)
       pass200 = roundEven(pass200,1); <--- my revision 09/2021, which was not implemented
          
       if( se > 0.0 && pass200 > 0.0 )
       {
          if( se >= 29.0 )
             sep = se / (25.0 + pass200);
          else
             sep = (se + 4.0) / (se + pass200);
       }
          
      } // else will blank out any existing SEP

   double mtT176_lo::CorGrpRoot::calcTrial(double sr, double cr)
   {
     if (sr < 0.0 || cr < 1.0)
         return;
         
     double raw = 100.0*sr / cr;
     double trunc = floor(raw);
     
     if (raw >= trunc + 0.05)
         return trunc += 1.0;
   }
   

   D:\cu\lut_F9\lut_F9.sln\fromD8a.cpp
   -----------------------------------
   double NM_LUT_F9::roundEven(double num)
   double NM_LUT_F9::roundEven(double num, int places)
   
   Round a floating point number to the specified number of decimal places
   ASTM E29 prescribes: if a nr is exactly halfway between two rounding targets, round to the even target
   eg: 1.5 => 2 (not 1) but 2.5 => 2 (not 3)
   
   
 *  T176 (til 10-92: 050, 051, 052) : Sand Equivalence
 *                                                     JCU 12-88
 *  6-91 JCU: combined old m050, m051, m052 into one test & added a
 *    'test type' field. added 'tested by' and 'test date' fields
 * 11-93 JCU: restructured and revised order
 *
 *    cse: calculate sand equivalent trial
 *    cavse: calculate average sand equivalent
 * mt176: sand equivalent
 *
 *    Former tests:
 *       050 (SU 17): As Received
 *       051 (SU 18): Lab Crushed
 *       052 (SU 19): Field Moist
 *  SUs
 *    017: Pre Wet as rcvd        PR
 *    018: Pre Wet Lab Crushed    PC
 *    120: Referee as rcvd        RR
 *    121: Referee Lab Crushed    RC
 *    122: Air Dry                AD
 *    019: Pre Wet Field Moist    PF
 *
 
 
***********************************************************************************/



----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------



select count(*), min(sample_year), max(sample_year) from Test_T176RR where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 5610	    1991	2020



-- find samples without segments -- 98 samples

select hdr.sample_id hdr from test_t176rr hdr
 where hdr.sample_id not in ( select seg.sample_id from test_t176rr_segments seg
                               where seg.sample_id = hdr.sample_id)
;



-- find segments without headers (should be none) -- 0 samples

select seg.sample_id from test_t176rr_segments seg
 where seg.sample_id not in ( select hdr.sample_id from test_t176rr hdr
                               where hdr.sample_id = seg.sample_id)
;





create or replace view V_T176RR_Sand_Equivalent_Referee_as_Received as 

/*-------------------------------------------------------------
  Test_T176RR_segments, data & calculations
-------------------------------------------------------------*/

with T176_segment_sql as (

     select  sample_id     as sample_id
            ,segment_nbr   as segment_nbr
            ,sand_reading  as sand_reading
            ,clay_reading  as clay_reading
            ,captured_se   as captured_se
            
            ,case when (sand_reading > 0 and clay_reading > 0) then      ((sand_reading / clay_reading) * 100) else -1 end as SE_Raw
            ,case when (sand_reading > 0 and clay_reading > 0) then floor((sand_reading / clay_reading) * 100) else -1 end as SE_floor
            ,case when (sand_reading > 0 and clay_reading > 0) then  ceil((sand_reading / clay_reading) * 100) else -1 end as SE_ceiling
            
            ,case when (sand_reading > 0 and clay_reading > 0)
                  then case -- when ( SE_Raw                      >= SE_floor + 0.05 ) then (floor + 1) else floor
                       when ((sand_reading / clay_reading) * 100) >= (floor((sand_reading / clay_reading) * 100) + 0.05)
                       then (floor((sand_reading / clay_reading) * 100) + 1.0) -- really the ceiling, but using floor, as the code does
                       else (floor((sand_reading / clay_reading) * 100))
                       end
                  else -1 end as Sand_Equivalent
                  
       from Test_T176RR_segments
      order by sample_id, segment_nbr
)

/*-------------------------------------------------------------
  Test_T176RR_segments, sand equivalent summation
-------------------------------------------------------------*/

,T176_SE_summation as (

     select  sample_id as sample_id
     
            ,sum(case when (sand_reading > 0 and clay_reading > 0)
                      then case 
                           when ((sand_reading / clay_reading) * 100) >= (floor((sand_reading / clay_reading) * 100) + 0.05)
                           then (floor((sand_reading / clay_reading) * 100) + 1.0)
                           else (floor((sand_reading / clay_reading) * 100))
                           end
                      else 0
                      end
                )
                as SE_summation
                  
       from Test_T176RR_segments
      group by sample_id
)

/*-------------------------------------------------------------
  Test_T176RR_segments, valid segment count
-------------------------------------------------------------*/

,T176_segment_count as (select sample_id, max(segment_nbr) as segment_count
                          from Test_T176RR_segments
                         where clay_reading > 0 and sand_reading > 0
                         group by sample_id
)

/*-------------------------------------------------------------
 Main SQL
-------------------------------------------------------------*/
       
select  t176hdr.sample_id                    as T176RR_Sample_ID
       ,t176hdr.sample_year                  as T176RR_Sample_Year
       
       ,t176hdr.test_status                  as T176RR_test_status
       ,t176hdr.tested_by                    as T176RR_tested_by
       
       ,case when to_char(t176hdr.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t176hdr.date_tested, 'mm/dd/yyyy')    end
                                             as T176RR_date_tested
            
       ,t176hdr.date_tested                    as T176RR_date_tested_DATE
       ,t176hdr.date_tested_orig               as T176RR_date_tested_original
       
       ,t176hdr.customary_metric             as T176RR_customary_metric
       
       /*-------------------------------------------------------------
         segments, Sand Equivalent
       -------------------------------------------------------------*/
       
       ,case when t176seg.segment_nbr        is not null  then t176seg.segment_nbr      else -1  end  as T176RR_segment_nbr
       ,case when t176seg.sand_reading       is not null  then t176seg.sand_reading     else -1  end  as T176RR_sand_reading
       ,case when t176seg.clay_reading       is not null  then t176seg.clay_reading     else -1  end  as T176RR_clay_reading
       
       ,case when t176seg.captured_se        is not null  then t176seg.captured_se      else -1  end  as T176RR_captured_SE
       ,case when t176hdr.captured_se_avg    is not null  then t176hdr.captured_se_avg  else -1  end  as T176RR_captured_SE_Avg
       
       ,case when t176seg.Sand_Equivalent    is not null  then t176seg.Sand_Equivalent  else -1  end  as T176RR_Sand_Equivalent
       ,case when t176sum.SE_summation       is not null  then t176sum.SE_summation     else -1  end  as T176RR_SE_summation
       ,case when SE_Average                 >= 0         then SE_Average               else -1  end  as T176RR_SE_Average
       
       ,case when T176_segment_count.segment_count is not null then T176_segment_count.segment_count else -1 end as T176RR_segment_count
       
       /*-------------------------------------------------------------
         SEP, Sand Equivalent percent passing #200
       -------------------------------------------------------------*/
       
       ,case when dl907.test_source          is not null  then dl907.test_source        else ' '  end  as DL907_Test_Source
       ,case when pct_passing_200            is not null  then pct_passing_200          else  -1  end  as T176RR_pct_passing_200_from_DL907
       ,case when pass200_RoundEven          is not null  then pass200_RoundEven        else  -1  end  as T176RR_pass200_RoundEven
       ,case when SEP                        >= 0         then SEP                      else  -1  end  as T176RR_SEP_calculated
       ,t176hdr.captured_sep                                                                           as T176RR_SEP_captured
       
       ,t176hdr.minimum_spec  as T176RR_min_spec
       
       ,t176hdr.remarks   as T176RR_remarks
       
       -- preliminary working values, per segment
       ,case when t176seg.SE_Floor           is not null  then t176seg.SE_Floor         else -1   end  as T176RR_SE_Floor   -- floor(SE_Raw)
       ,case when t176seg.SE_ceiling         is not null  then t176seg.SE_ceiling       else -1   end  as T176RR_SE_ceiling -- ceiling(SE_Raw)
       ,case when t176seg.SE_Raw             is not null  then t176seg.SE_Raw           else -1   end  as T176RR_SE_Raw     -- ((sr / cr) * 100)
       
       /*-------------------------------------------------------------
         compare calculated Sand_Equivalent to captured Sand_Equivalent
         two samples returned: W-96-0295-AC, W-96-1098-ACS 
         (not going to worry about them)
       -------------------------------------------------------------*/
       
       ,case when t176seg.Sand_Equivalent is not null and t176seg.captured_se is not null
             then case when t176seg.Sand_Equivalent <> t176seg.captured_se
                       then 'SE values are not equivalent'
                       else ' ' end
             else ' '  end as T176RR_SE_equiv_check
       
       /*----------------------------------------------------------------------------
         table relationships
       ----------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                       smpl
       join Test_T176RR                           t176hdr on t176hdr.sample_id = smpl.sample_id
       
       left join T176_segment_sql                 t176seg on t176hdr.sample_id = t176seg.sample_id
       
       left join T176_SE_summation                t176sum on t176hdr.sample_id = t176sum.sample_id
       
       left join T176_segment_count                       on t176hdr.sample_id = T176_segment_count.sample_id
       
       left join Test_DL907                         dl907 on t176hdr.sample_id = dl907.sample_id
       
       left join V_DL11_SIEVE_ANALYSIS_FINE_WASH  v_dl11 on t176hdr.sample_id = v_dl11.DL11_Sample_ID
                                                         and v_dl11.sieve_metric_in_mm = 0.075 -- #200
       
       left join V_DL27_Sieve_Analysis_Dry_Washed  v_dl27 on t176hdr.sample_id = v_dl27.DL27_Sample_ID
                                                         and v_dl27.sieve_metric_in_mm = 0.075 -- #200
       
       left join V_WL413_R10_Sieve_Analysis_pct_passing_grid 
                                                  V_WL413 on t176hdr.sample_id = V_WL413.sample_id
                                                         and V_WL413.sieve_metric_in_mm = 0.075 -- #200
       
       /*----------------------------------------------------------------------------
         calculations
       ----------------------------------------------------------------------------*/
       
       cross apply (select case when (t176sum.SE_summation >= 0 and T176_segment_count.segment_count > 0)
                                then ceil(t176sum.SE_summation / T176_segment_count.segment_count)
                                else -1
                                end as SE_Average from dual) SE_avg
       
       /*----------------------------------------------------------------------------
         capture pct_passing_200 from contributing lab tests
         DL11  - W-20-0179, W-20-0590, W-20-1158-AG
         DL27  - W-20-0036, W-20-0138, W-20-0660
         WL413 - W-20-0687-AG, W-20-0888-AG, W-20-0980-AG
       ----------------------------------------------------------------------------*/
       
       cross apply (select case when dl907.test_source = 'DL11'  then v_dl11.DL11_pct_passing
                                when dl907.test_source = 'DL27'  then v_dl27.DL27_pct_passing
                                when dl907.test_source = 'WL413' then V_WL413.pct_passing
                                else -1
                                end as pct_passing_200 from dual) pctpass200
       
       /*----------------------------------------------------------------------------
         roundEven(pct_passing_200)
       ----------------------------------------------------------------------------*/
       
       cross apply (select case when pct_passing_200 > 0 
                                then round_ties_to_even(pct_passing_200,1)
                                else -1
                                end as pass200_RoundEven from dual) roundEven
       
       /*----------------------------------------------------------------------------
         SEP, should only be calculated when customary_metric is E (Enabled),
         not D (disabled). calculating anyway
       ----------------------------------------------------------------------------*/
       
       cross apply (select case when (SE_Average > 0 and pass200_RoundEven > 0)
                                then case when (SE_Average >= 29.0)
                                          then (SE_Average / (pass200_RoundEven + 25.0))
                                          else (SE_Average + 4.0) / (SE_Average + pass200_RoundEven)
                                          end
                                else -1
                                end as SEP from dual) sep_calculated
       
       order by t176hdr.sample_id, t176seg.segment_nbr
       ;
  
  
  
  
  
  





select ROUND_TIES_TO_EVEN(16.0500000000000000000000000000, 1) AS point05 
      ,ROUND_TIES_TO_EVEN(16.5400000000000000000000000000, 1) AS point54
      ,ROUND_TIES_TO_EVEN(16.5600000000000000000000000000, 1) AS point56
      ,ROUND_TIES_TO_EVEN(16.5500007000000000000000000000, 1) AS point55
      ,ROUND_TIES_TO_EVEN(16.5540007000000000000000000000, 1) AS point554 
      from dual;


select ROUND_TIES_TO_EVEN(16.0500000000000000000000000000, 1) AS point05
      ,ROUND_TIES_TO_EVEN(16.1500000000000000000000000000, 1) AS point15
      ,ROUND_TIES_TO_EVEN(16.2500000000000000000000000000, 1) AS point25
      ,ROUND_TIES_TO_EVEN(16.3500000000000000000000000000, 1) AS point35
      ,ROUND_TIES_TO_EVEN(16.4500000000000000000000000000, 1) AS point45
      ,ROUND_TIES_TO_EVEN(16.5500000000000000000000000000, 1) AS point55
      ,ROUND_TIES_TO_EVEN(16.6500000000000000000000000000, 1) AS point65
      from dual;


select ROUND_TIES_TO_EVEN(16.0500000000000000000200000000, 1) AS point05
      ,ROUND_TIES_TO_EVEN(16.1500000000000000000200000000, 1) AS point15
      ,ROUND_TIES_TO_EVEN(16.2500000000000000000200000000, 1) AS point25
      ,ROUND_TIES_TO_EVEN(16.3500000000000000000200000000, 1) AS point35
      ,ROUND_TIES_TO_EVEN(16.4500000000000000000200000000, 1) AS point45
      ,ROUND_TIES_TO_EVEN(16.5500000000000000000200000000, 1) AS point55
      ,ROUND_TIES_TO_EVEN(16.6500000000000000000200000000, 1) AS point65
      from dual;
      

select ROUND_TIES_TO_EVEN(16.0500000000000000000200000000, 3) AS point05
      ,ROUND_TIES_TO_EVEN(16.1500000000000000000200000000, 3) AS point15
      ,ROUND_TIES_TO_EVEN(16.2500000000000000000200000000, 3) AS point25
      ,ROUND_TIES_TO_EVEN(16.3500000000000000000200000000, 3) AS point35
      ,ROUND_TIES_TO_EVEN(16.4500000000000000000200000000, 3) AS point45
      ,ROUND_TIES_TO_EVEN(16.5500000000000000000200000000, 3) AS point55
      ,ROUND_TIES_TO_EVEN(16.6500000000000000000200000000, 3) AS point65
      from dual;
      
      
select ROUND_TIES_TO_EVEN(16.0500000000000000000000000000, 2) AS point05
      ,ROUND_TIES_TO_EVEN(16.1555500000000000000000000000, 2) AS point15
      ,ROUND_TIES_TO_EVEN(16.2500000000000000000000000000, 2) AS point25
      ,ROUND_TIES_TO_EVEN(16.3500000000000000000000000000, 2) AS point35
      ,ROUND_TIES_TO_EVEN(16.4500000000000000000000000000, 2) AS point45
      ,ROUND_TIES_TO_EVEN(16.5500000000000000000000000000, 2) AS point55
      ,ROUND_TIES_TO_EVEN(16.6500000000000000000000000000, 2) AS point65
      from dual;
      
      
      
      
      
      
      
      
      
