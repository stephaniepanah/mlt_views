


 --,calc_avg_percent_residue -- this running average is not working ****


-- T59-rd Residue and Oil Distillate by Distillation (current)
-- T59-re Residue by Evaporation -- T59-re segments  (current) (the only T59 test with segments)
-- T59-pc Particle Charge                            (2010)
-- T59-sv Sieve Test (Liquid Asphalt)                (2010)
-- T59-cm Cement Mixing Test (Liquid Asphalt)        (1960)




select * from V_T59RE_Residue_By_Evaporation where sample_id in
 ('W-20-0704-AB', 'W-19-0154-AB', 'W-15-0343-AB'
 )
 order by sample_year desc, sample_id, segment_nbr
;



select * from V_T59RE_Residue_By_Evaporation where sample_id in
 ('W-20-0040',    'W-20-0704-AB', 'W-19-0154-AB', 'W-19-1950-AB', 
  'W-18-0452-AB', 'W-17-1444-AB', 'W-16-0810-AB', 'W-15-0343-AB', 
  'W-14-0592-AB', 'W-13-0352-AB', 'W-12-0364-AB', 'W-11-0270-AB', 
  'W-10-0944-AB', 'W-09-0282-AB', 'W-08-0493-AB'
 )
 order by sample_year desc, sample_id, segment_nbr
;



select * from V_T59RE_Residue_By_Evaporation order by sample_year desc, sample_id, segment_nbr
;



select count(*), min(sample_year), max(sample_year) from Test_T59re where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 406	    2008	2020




select * from test_t59re;



select * from test_t59re_segments
 where mass_tare <= 0 or mass_tare_and_residue <= 0
;




/***********************************************************************************

  T59-re Residue by Evaporation
  
  from MTest, Lt_T59re_BB.cpp, void LtT59re_BB::CorRow::calc(){
  
  Wt emulsion is required to be 50. 
  The base formula is % residue = 100% * (wt Tare & Residue - tare ) / 50
  which reduces to: % Residue = (wt tare & residue - tare)*2
  
  if (tare >= 0.0 && all >= tare)
      residue = (all - tare)*2.0;
  
  Sample ID     segment tare        residue     pct residue     avg pct residue
  ------------  ------- -------     -------     -----------     ---------------
  W-20-0704-AB	1       421.950	    454.180	    64.460	        64.435
  W-20-0704-AB	2	    318.660	    350.860	    64.400	        64.435
  W-20-0704-AB	3	    424.470	    456.680	    64.420	        64.435
  W-20-0704-AB	4	    414.520	    446.750	    64.460	        64.435
  
  W-19-0154-AB	1	    329.780	    361.670	    63.780	        63.790
  W-19-0154-AB	2	    414.630	    446.600	    63.940	        63.790
  W-19-0154-AB	3	    334.210	    366.070	    63.720	        63.790
  W-19-0154-AB	4	    416.490	    448.350	    63.720          63.790
  
  W-15-0343-AB	1	    327.900	    356.900	    58.000          58.100
  W-15-0343-AB	2	    322.400	    351.500	    58.200	        58.100
  W-15-0343-AB	3	    338.900	    367.900	    58.000          58.100
  W-15-0343-AB	4	    326.000	    355.100	    58.200	        58.100
  
  W-11-0270-AB	1	    323.190	    354.780	    63.180	        63.147
  W-11-0270-AB	2	    325.580	    357.100	    63.040	        63.147
  W-11-0270-AB	3	    322.150	    353.760	    63.220	        63.147
  
***********************************************************************************/

create or replace view V_T59RE_Residue_By_Evaporation as 

with t59re_seg_cte as (

     /*---------------------------------------------------------------------------
       A Common Table Expression (CTE) is the result set of a query which exists 
       temporarily and for use only within the context of a larger query. 
       Much like a derived table, the result of a CTE is not stored and exists 
       only for the duration of the query
     ---------------------------------------------------------------------------*/
     
     select  sample_id as sample_id
     
            ,sum(case when mass_tare >= 0 then mass_tare else 0 end) as sum_mass_tare
             
            ,sum(case when mass_tare_residue >= 0 then mass_tare_residue else 0 end) as sum_mass_tare_and_residue
             
            ,sum(case when mass_tare_residue >= 0 then 1 else 0 end) as count_residue
                      
       from Test_T59RE_segments
      group by sample_id
)

select  t59re.sample_id          as sample_id
       ,t59re.sample_year        as sample_year
       ,t59re_seg.segment_nbr    as segment_nbr
       ,t59re.test_status
       ,t59re.tested_by
       
       ,case when to_char(t59re.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t59re.date_tested, 'mm/dd/yyyy')
             end as date_tested
            
       ,t59re.date_tested as date_tested_DATE
       ,t59re.date_tested_orig
       
       -- tare
       ,case when t59re_seg.mass_tare >= 0 then trim(to_char(t59re_seg.mass_tare, '9990.999'))
             else ' ' end as mass_tare
       
       -- all
       ,case when t59re_seg.mass_tare_residue >= 0 then trim(to_char(t59re_seg.mass_tare_residue, '9990.999'))
             else ' ' end as mass_tare_residue
       
       ,to_char(calc_percent_residue, '9990.999') as calc_pct_residue
       
       ,to_char((((sum_mass_tare_and_residue - sum_mass_tare) / count_residue) * 2), '9990.999') as avg_pct_residue
       
       --,calc_avg_percent_residue -- this running average is not working (see below)
       
       ,t59re.remarks
       
       /*------------------------------------
         from t59re_seg_cte
       ------------------------------------*/
  
       ,sum_mass_tare
       ,sum_mass_tare_and_residue
       ,count_residue
              
  /*------------------------------------
    table relationships
  ------------------------------------*/
  
  from MLT_1_Sample_WL900         smpl
  join Test_T59RE                t59re on t59re.sample_id = smpl.sample_id
  join Test_T59RE_segments   t59re_seg on t59re.sample_id = t59re_seg.sample_id
  join t59re_seg_cte                   on t59re.sample_id = t59re_seg_cte.sample_id
  
  /*---------------------------------------------------------------
    from MTest, Lt_T59re_BB.cpp, void LtT59re_BB::CorRow::calc()
    if (tare >= 0.0 && all >= tare)
        percent residue = (all - tare)*2.0;
  ---------------------------------------------------------------*/
  
  cross apply (select case when t59re_seg.mass_tare >= 0 and 
                                t59re_seg.mass_tare_residue >= t59re_seg.mass_tare
                           then (t59re_seg.mass_tare_residue - t59re_seg.mass_tare) * 2.0
                           else -1
                           end as calc_percent_residue from dual
  ) pct_residue
    
  /*---------------------------------------------------------------
    this running average is not working
  ---------------------------------------------------------------*/
  
  cross apply (select case when calc_percent_residue >= 0 
                      then avg(calc_percent_residue) over (partition by t59re.sample_id order by t59re_seg.segment_nbr)
                      else -1
                      end as calc_avg_percent_residue from dual
  ) avg_residue
  
  order by t59re.sample_id, segment_nbr
 ;
 
 





     

