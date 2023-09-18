


-- DL11 Sieve Analysis, fine wash T11/T27     (2020)
-- DL27 Sieve Analysis, Complete Dry/Washed   (2020)
-- T30  Sieve Analysis of Extracted Aggregate (2020)
-- T37  Sieve Analysis of Mineral Filler      (1994)



select * from V_T30_Sieve_Analysis_Extracted_Aggregate order by T30_Sample_Year desc, T30_Sample_ID, T30_segment_nbr 
;



select * from V_T30_Sieve_Analysis_Extracted_Aggregate
 where T30_Sample_Year >= 2000
 order by T30_Sample_Year desc, T30_Sample_ID, T30_segment_nbr 
;



select * from V_T30_Sieve_Analysis_Extracted_Aggregate
 where T30_Sample_ID in (
 'W-20-0002',    'W-20-0003',    'W-20-0710-AC', 'W-20-0890-AC',
 'W-19-0695-AC', 'W-19-0720-AC', 'W-18-1063-AC', 'W-18-1097-AC',
 'W-17-0949-AC', 'W-17-0998-AC', 'W-16-1021-AC', 'W-16-1022-AC'
 );



-- samples since 2000 where the percent difference > 0.2
select * from V_T30_Sieve_Analysis_Extracted_Aggregate
 where T30_Sample_Year >= 2000
   and T30_percent_difference > 0.2
   ;
   
/**** 22 samples

W-02-1266-AC
W-06-0699-ACA
W-09-0546-AC
W-09-1058-AC
W-10-0829-AC
W-10-1503-AC
W-12-0381-AC
W-12-0407-AC
W-14-0657-AC
W-16-0462-AC
W-17-0712-AC
W-17-1152-AC
W-17-1154-AC
W-17-1464-AC
W-17-1790-AC
W-19-1137-AC
W-19-1138-AC
W-19-1253-AC
W-19-1560-AC
W-19-1733-AC
W-20-0889-AC
W-20-0897-AC

****/



----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T30 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 3700	    1986	2020
-- 3704 including 1960



select * from Test_T30 order by sample_year desc, sample_id;



   select sample_year, count(sample_year) from Test_T30
 group by sample_year
 order by sample_year desc
 ;
/*
2020	 89
2019	103
2018	 78
2017	105
2016	 78
2015	102
2014	 56
2013	112
2012	 76
2011	114
2010	128
2009	153
2008	131
2007	 96
2006	 94
2005	113
2004	157
2003	102
2002	163
2001	 84
2000	112
1999	 23
1998	110
1997	 79
1996	 95 
1995	141
1994	166
1993	 53
1992	 73
1991	122
1990	152
1989	134
1988	208
1987	 78
1986	 20
1960	  4
*/
 
 

   select Asphalt_Content_Method, count(Asphalt_Content_Method) from test_t30
 group by Asphalt_Content_Method
 --order by Asphalt_Content_Method
 ;
/*
I	    2243/3704    60%     T308 Asphalt Content (Ignition)    2020 <-- most recent year (one in 1999, and then >= 2000)
V	    642 /3704    17%    WL164 Asphalt Content (Vacuum)      2006 <-- two in 2006, then 1999 and before
R	    3           negl    CL164 Asphalt Content (Reflux)      1993
' ' 	815 /3704    22%    -- source determined by finding the alternate method (all but ten records)
113.4	1                   -- W-87-0594-AC, this is nonsense, alternate method was set to 'V'
*/



select * from test_t30 where Asphalt_Content_Method = 'I' or asphalt_content_alternate = 'I' -- T308 (formerly WL464)
 order by sample_year desc, sample_id;


select * from test_t30 where Asphalt_Content_Method = 'V' or asphalt_content_alternate = 'V' -- WL164
 order by sample_year desc, sample_id; 
-- two samples in 2006; W-06-0698-ACA, W-06-0699-ACA, then 1999 and before


select * from test_t30 where Asphalt_Content_Method = 'R' or asphalt_content_alternate = 'R'  -- CL164
 order by sample_year desc, sample_id;
-- three samples in total; W-93-0806-AC, W-93-0807-AC, W-93-0809-AC
-- this is so weird; in these cases, the labtest available to T30 is WL164
-- but all the screens say CL164 (Reflux), and they also reference T164, 
-- which is not one of our labtests, but likely the precursor for WL164


select * from test_t30 where Asphalt_Content_Method = ' '
 order by sample_year desc, sample_id;
-- six samples post 2000, then many in 1993 and before
-- assign them to the alternate method
-- W-20-0716-AC, W-20-0841-AC (T308)
-- W-18-0631-AC, W-14-0904-AG (no data, incomplete, but would be T308 at this late date)
-- W-09-0296-AC, W-09-0338-AC (T308)
-- 1993 and before (source is WL164)
-- after analysis, ten samples remain unassigned, the two above and eight in 1986 (DL907)


select * from test_t30 where Asphalt_Content_Method = '113.4'; -- W-87-0594-AC, set to 'V' WL164



   select customary_metric, count(customary_metric) from test_t30
 group by customary_metric
 order by customary_metric
 ;
/*
' ' 	1578/3704   43%
C	    1933/3704   52%
M	     193/3704    5%
*/



/***********************************************************************************

 T30 Sieve Analysis of Extracted Aggregate
 
 Asphalt_Content_Method
 ----------------------
 
 -- T308 (Ignition)
 W-20-0002,    W-20-0003,    W-20-0710-AC, W-20-0890-AC
 W-19-0695-AC, W-19-0720-AC, W-18-1063-AC, W-18-1097-AC
 W-17-0949-AC, W-17-0998-AC, W-16-1021-AC, W-16-1022-AC
 
 -- WL164 (Vacuum)
 W-06-0698-ACA, W-06-0699-ACA, W-99-0710-AC, W-98-2446-AC
 
 -- CL164 (Reflux) (the data is actually from the WL164 screen)
 W-93-0806-AC, W-93-0807-AC, W-93-0809-AC
 
 
 CustomaryOrMetric
 -----------------
 W-18-0569-AC |C| sieve units; Customary
 W-13-0367-AC |M| sieve units; Metric
 W-06-0312-AC |M| sieve units; Metric
 
 
 from MTest, Lt_T30_BC.cpp
 =========================
 
 void LtT30_BC::CorGrpRoot::calcWash()
 {
   pre  = getNum(CorX::xWpre);
   post = getNum(CorX::xWpost);
   
   if( post >= 0.0 && pre >= post )
   {
      lossm = pre - post;
      lossp = 100.0*lossm/pre;
   }
 }
 
 
 void LtT30_BC::CorGrpRoot::calcPP()
 {
   int xr, nr;                            // row index, nbr of rows
   double loss, mr = 0.0;                 // mr - mass retained
   double  totpan = 0.0;
   double msieved = 0.0;                  // cumulative mass retained
   double    diff = 0.0;
   double extagg = getNum(CorX::xAccAgg); // T308 Mass residual agg / WL164 mass extracted agg
   double pan = getNum(CorX::xPan);

   // % passing section
   if( extagg >= 0.0 )
   {
      if( nr > 0 ) // get sieves
	  {
         for( xr = 0; xr < nr; xr++ )
		 {
            mr = row->getColAsDatum(1)->getFltValue();    // mass retained
            if( mr < 0.0 ) mr = 0.0;                      // in case 0 ret was left blank
            msieved += mr;                                // mass retained cumulative
            aRows[xr].val = 100.0*(1.0 - msieved/extagg); // pct passing
         }

         // total pan 
         if( pan < 0.0 ) pan = 0.0;
         totpan = pan;
         loss = getNum(CorX::xWlossWt); // mass loss

         if( loss < 0.0 )
		 {         
            if( chMethod == 'V' )
			{
               // wash is optional for WL164, not for the others
               loss = 0.0;
            }
			else
			{                  
               totpan = FLT_BLANK;
               msieved = FLT_BLANK;
            }
         }
		 else
		 {
            totpan += loss;

            if( chMethod == 'V' )
			{
               // fines is valid only with WL164
               double VacFines = getNum(CorX::xAccFines);
               if( VacFines < 0.0 ) VacFines = 0.0;
               totpan += VacFines;
            }
            
            msieved += totpan;
         }
      }
   }

   if( msieved > 0.0 && extagg > 0.0 )
   {
      diff = 100.0*(extagg - msieved)/extagg;
      diff = fabs(diff); // absolute value
   }
   
   if( diff > 0.2 )
   {
      sprintf(pmsg,"Difference between extracted mass (%8.1f) and sieved mass (%8.1f) is greater than 0.2%%", extagg, msieved);
   }
 }
       
***********************************************************************************/



create or replace view V_T30_Sieve_Analysis_Extracted_Aggregate as 

with ac_method_sql as (

       /*-------------------------------------------------------------
         extracted aggregate asphalt content method
         ------------------------------------------
         There are approximately 3700 T30 samples as of 2020.
         Of these, 815 (22%) contain no designation for the Asphalt_Content_Method.
         Those 815 samples were evaluated for corresponding labtests (T308, WL164, CL164)
         If found, those labtests were assigned to the Asphalt_Content_alternate field, 
         as I did not want to overwright the original field
         
         Those two fields; Asphalt_Content_Method and Asphalt_Content_alternate
         are evaluated in this SQL clause to produce asphalt_content_method_tmp,
         a single field to be used for evaluations in this View
       -------------------------------------------------------------*/

     select sample_id,
     
            case when Asphalt_Content_Method = 'I' or Asphalt_Content_alternate = 'I' then 'I' -- T308 (Ignition)
                 when Asphalt_Content_Method = 'V' or Asphalt_Content_alternate = 'V' then 'V' -- WL164 (Vacuum)
                 when Asphalt_Content_Method = 'R' or Asphalt_Content_alternate = 'R' then 'R' -- CL164 (Reflux)
                 else ' ' -- ten records remain unassigned, and could not be determined
                 end as asphalt_content_method_tmp
                 
            from Test_T30
)

,cumulative_sql as ( -- establishes a running total of mass_retained over the sample

     select  sample_id   as sample_id
            ,segment_nbr as segment_nbr
            
            ,sum(case when mass_retained >= 0 then mass_retained else 0 end) 
                 over (partition by sample_id order by segment_nbr) as mass_ret_cumulative

       from Test_T30_segments
      order by sample_id, segment_nbr
)

,summation_sql as (

     select  sample_id as sample_id
            ,sum(case when mass_retained >= 0 then mass_retained else 0 end) as mass_ret_summation
             
       from Test_T30_segments
      group by sample_id 
)

select  t30.sample_id                              as T30_Sample_ID
       ,t30.sample_year                            as T30_Sample_Year
       ,t30.test_status                            as T30_Test_Status
       ,t30.tested_by                              as T30_Tested_by
       
       ,case when to_char(t30.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t30.date_tested, 'mm/dd/yyyy')    end
                                                   as T30_date_tested
            
       ,t30.date_tested                              as T30_date_tested_DATE
       ,t30.date_tested_orig                         as T30_date_tested_orig
       
       ,t30.customary_metric                       as T30_customary_metric

       /*-------------------------------------------------------------
         extracted aggregate asphalt content method
       -------------------------------------------------------------*/
       
       ,t30.asphalt_content_method                 as T30_AC_method_original  -- not displayed
       ,t30.asphalt_content_alternate              as T30_AC_method_alternate -- not displayed
       ,ac_method_sql.asphalt_content_method_tmp   as T30_AC_method_temporary -- not displayed
       
       ,extracted_aggregate_method                 as T30_extracted_aggregate_method
       
       ,mass_extracted_aggregate                   as T30_mass_extracted_aggregate -- or mass_residual_aggregate
       
       ,case when mass_extracted_aggregate_nbr     is not null then mass_extracted_aggregate_nbr else -1 end
                                                   as T30_mass_extracted_aggregate_nbr
                                                   
       ,mass_of_fines                              as T30_mass_of_fines -- only V or R
       
       /*-------------------------------------------------------------
         Wash
       -------------------------------------------------------------*/
       
       ,'Mass before wash ' || mass_before_wash    as T30_mass_before_wash       
       ,t30.mass_after_wash                        as T30_mass_after_wash
       ,mass_loss                                  as T30_mass_loss
       ,round(percent_loss,2)                      as T30_percent_loss
       
       /*-------------------------------------------------------------
         Results
       -------------------------------------------------------------*/
       
       ,t30.mass_pan                               as T30_mass_pan
       ,total_mass_in_pan                          as T30_total_mass_in_pan
       ,total_mass_sieved                          as T30_total_mass_sieved
       ,round(percent_difference,4)                as T30_percent_difference
       ,pct_diff_msg                               as T30_pct_diff_msg

       /*-------------------------------------------------------------
         segments
         W-20-0716-AC, W-20-0841-AC examples of null segments
       -------------------------------------------------------------*/
       
       ,case when t30seg.segment_nbr         is not null then to_char(t30seg.segment_nbr) else ' ' end as T30_segment_nbr
        
       ,case when t30seg.sieve_size          is not null then t30seg.sieve_size           else ' ' end as T30_sieve_size
       ,case when t30seg.sieve_size_original is not null then t30seg.sieve_size_original  else ' ' end as T30_sieve_size_original
       
       ,case when t30seg.mass_retained       is not null then t30seg.mass_retained        else -1  end as T30_mass_retained
       
       ,case when cumulative_sql.mass_ret_cumulative is not null 
             then cumulative_sql.mass_ret_cumulative                                      else -1 end as T30_mass_ret_cumulative
       
       ,case when summation_sql.mass_ret_summation   is not null 
             then summation_sql.mass_ret_summation                                        else -1 end as T30_mass_ret_summation
       
       ,round(percent_passing,3)                                                                      as T30_percent_passing
       
       /*---------------------------------------------------------------------------
         MLT_sieve_size (sieve)
       ---------------------------------------------------------------------------*/
              
       ,sieve.sieve_customary
       ,sieve.sieve_metric
       ,sieve.sieve_metric_in_mm
       
       ,t30.remarks as T308_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                            smpl
  join Test_T30                                       t30 on t30.sample_id = smpl.sample_id
  
  join ac_method_sql                                      on t30.sample_id = ac_method_sql.sample_id
  
  left join Test_T30_segments                      t30seg on t30.sample_id = t30seg.sample_id
  
  left join cumulative_sql                                on cumulative_sql.sample_id   = t30seg.sample_id
                                                         and cumulative_sql.segment_nbr = t30seg.segment_nbr

  left join summation_sql                                 on summation_sql.sample_id    = t30seg.sample_id
  
  left join V_T308_Asphalt_Content_Ignition        v_t308 on t30.sample_id = v_t308.T308_Sample_ID
  
  left join V_WL164_Asphalt_Content_Vacuum        v_wl164 on t30.sample_id = v_wl164.WL164_Sample_ID
                                               
  join mlt_sieve_size sieve                               on t30seg.sieve_size = sieve.sieve_customary 
                                                          or t30seg.sieve_size = sieve.sieve_metric
  
  /*-------------------------------------------------------------
    calculations
  -------------------------------------------------------------*/
  
  /*-------------------------------------------------------------
    extracted_aggregate_method
     T308 (Ignition)
    WL164 (Vacuum)
    CL164 (Reflux)
  -------------------------------------------------------------*/
  
  cross apply (select case when ac_method_sql.asphalt_content_method_tmp = 'I' then 'T308 (Ignition)'
                           when ac_method_sql.asphalt_content_method_tmp = 'V' then 'WL164 (Vacuum)'
                           when ac_method_sql.asphalt_content_method_tmp = 'R' then 'CL164 (Reflux)'
                           else '(none)' 
                           end as extracted_aggregate_method from dual) ac_method
  
  /*-------------------------------------------------------------
    mass_extracted_aggregate (for display) and
    mass_extracted_aggregate_nbr (to be used in calculations)
  -------------------------------------------------------------*/
  
  cross apply (select case when ac_method_sql.asphalt_content_method_tmp = 'I' 
                           then 'T308 Mass residual agg '  || to_char(v_t308.T308_mass_residual_aggregate)
                           
                           when ac_method_sql.asphalt_content_method_tmp = 'V' 
                           then 'T164 Mass extracted agg ' || v_wl164.WL164_mass_of_extracted_aggregate
                           
                           when ac_method_sql.asphalt_content_method_tmp = 'R' 
                           then 'T164 Mass extracted agg ' || v_wl164.WL164_mass_of_extracted_aggregate
                           
                           else ' '
                           end as mass_extracted_aggregate from dual) extagg
  
  cross apply (select case when ac_method_sql.asphalt_content_method_tmp = 'I' 
                           then v_t308.T308_mass_residual_aggregate
                           
                           when ac_method_sql.asphalt_content_method_tmp = 'V' 
                           then v_wl164.WL164_mass_of_extracted_aggregate_nbr
                           
                           when ac_method_sql.asphalt_content_method_tmp = 'R' 
                           then v_wl164.WL164_mass_of_extracted_aggregate_nbr
                           
                           else -1
                           end as mass_extracted_aggregate_nbr from dual) extagg_nbr
  
  /*-------------------------------------------------------------
    mass_of_fines - WL164 and CL164 (CL164 data is from WL164)
  -------------------------------------------------------------*/
  
  cross apply (select case when ac_method_sql.asphalt_content_method_tmp = 'V' -- WL164
                           then 'WL164 fines ' || v_wl164.WL164_mass_of_fines_in_filter
                           
                           when ac_method_sql.asphalt_content_method_tmp = 'R' -- CL164
                           then v_wl164.WL164_mass_of_fines_in_filter
                           
                           else ' ' 
                           end as mass_of_fines from dual) massfines
  
  /*-------------------------------------------------------------
    percent_passing
  -------------------------------------------------------------*/
  
  cross apply (select case when (mass_extracted_aggregate_nbr > 0) and (cumulative_sql.mass_ret_cumulative is not null)  
                           then (1.0 - (cumulative_sql.mass_ret_cumulative / mass_extracted_aggregate_nbr)) * 100.0
                           else -1 
                           end as percent_passing from dual) pctpass
  
  /*-------------------------------------------------------------
    mass_before_wash
  -------------------------------------------------------------*/
  
  cross apply (select case when ac_method_sql.asphalt_content_method_tmp = 'I' 
                           then v_t308.T308_mass_residual_aggregate
                           
                           when ac_method_sql.asphalt_content_method_tmp = 'V' 
                           then v_wl164.WL164_mass_aggregate_after_extraction
                           
                           when ac_method_sql.asphalt_content_method_tmp = 'R' 
                           then v_wl164.WL164_mass_aggregate_after_extraction
                           
                           else -1
                           end as mass_before_wash from dual) pre_wash
  
  /*-------------------------------------------------------------
    mass_loss
  -------------------------------------------------------------*/
  
  cross apply (select case when (mass_before_wash >= t30.mass_after_wash) and t30.mass_after_wash >= 0
                           then (mass_before_wash  - t30.mass_after_wash)
                           else -1
                           end as mass_loss from dual) massloss
  
  /*-------------------------------------------------------------
    percent_loss
  -------------------------------------------------------------*/
  
  cross apply (select case when mass_loss >= 0 and mass_before_wash > 0
                           then (mass_loss / mass_before_wash) * 100.0
                           else -1
                           end as percent_loss from dual) percentloss
  
  /*-------------------------------------------------------------
    mass_pan_nbr - render -1 (null values) as 0
  -------------------------------------------------------------*/
  
  cross apply (select case when t30.mass_pan >= 0 then t30.mass_pan else 0 end as mass_pan_nbr from dual) masspan
  
  /*-------------------------------------------------------------
    total_mass_in_pan
  -------------------------------------------------------------*/
  
  cross apply (select case when mass_loss >= 0 
                           then case when ac_method_sql.asphalt_content_method_tmp = 'I'
                                          then mass_loss + mass_pan_nbr
                                          
                                     when ac_method_sql.asphalt_content_method_tmp = 'R'
                                          then mass_loss + mass_pan_nbr
                                          
                                     when ac_method_sql.asphalt_content_method_tmp = 'V' 
                                          then mass_loss + mass_pan_nbr + WL164_mass_of_fines_in_filter_nbr
                                          
                                     else -1 end
                           else -1
                           end as total_mass_in_pan from dual) totpan
                           
  /*-------------------------------------------------------------
    total_mass_sieved
  -------------------------------------------------------------*/
  
  cross apply (select case when (total_mass_in_pan >= 0) and 
                                (summation_sql.mass_ret_summation is not null)
                           then (total_mass_in_pan + summation_sql.mass_ret_summation)
                           else -1
                           end as total_mass_sieved from dual) msieved
                           
  /*-------------------------------------------------------------
    percent_difference
  -------------------------------------------------------------*/
  
  cross apply (select case when (total_mass_sieved >= 0) and (mass_extracted_aggregate_nbr > 0)
                           then abs(((mass_extracted_aggregate_nbr - total_mass_sieved) / mass_extracted_aggregate_nbr) * 100.0)
                           else -1
                           end as percent_difference from dual) pct_diff
  
  cross apply (select case when (percent_difference >= 0.2)
                           then 'Difference between extracted mass, ' || mass_extracted_aggregate_nbr || 
                                ', and sieved mass, ' || total_mass_sieved || ', is greater than 0.2% '
                           else ' '
                           end as pct_diff_msg from dual) pctdiffmsg
                           
  order by t30.sample_id, t30seg.segment_nbr
 ;









