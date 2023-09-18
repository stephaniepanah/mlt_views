


-- T59-rd Residue and Oil Distillate by Distillation (current)
-- T59-re Residue by Evaporation -- T59-re segments  (current) (the only T59 test with segments)
-- T59-pc Particle Charge                            (2010)
-- T59-sv Sieve Test (Liquid Asphalt)                (2010)
-- T59-cm Cement Mixing Test (Liquid Asphalt)        (1960)
 


select * from V_T59RD_Residue_and_Oil_Distillate order by sample_year desc
;



select count(*), min(sample_year), max(sample_year) from Test_T59rd where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 186	    2006	2020





/***********************************************************************************

  T59-rd Residue and Oil Distillate by Distillation
  
  from MTest, Lt_T59rd_BB.cpp, void LtT59rd_BB::CorGrpRoot::calc
    
  Wt emulsion is required always to be 200 mL
  The base formula is:
  pct residue = 100 * (Ante - Post ) / Wt Emulsion
  Since Wt emulsion is always 200, this reduces to:

 pct residue = (Ante - Post)/2
 200 mL of emulsion is required
 % distillate = 100% * amount of distillate/200 mL
 which reduces to:
 % distillate = amount of distillate/2
 
 if (post >= 0.0) cor = post + 1.5;
 
 if (cor >= 0.0 && cor >= ante) residue = (cor - ante) / 2.0;
 
 if (vol > 0.0) oil = vol / 2.0;
  
***********************************************************************************/


create or replace view V_T59RD_Residue_and_Oil_Distillate as 

select  t59rd.sample_id
       ,t59rd.sample_year
       ,t59rd.test_status
       ,t59rd.tested_by
       
       ,case when to_char(t59rd.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t59rd.date_tested, 'mm/dd/yyyy')
             end as date_tested
            
       ,t59rd.date_tested as date_tested_DATE
       ,t59rd.date_tested_orig
       
       /*-------------------------------------------------------------
         percent residue by distillation
       -------------------------------------------------------------*/
       
       ,case when t59rd.mass_assembly_before >= 0 then to_char(t59rd.mass_assembly_before, '99990.99')
             else ' ' end as mass_assembly_before
             
       ,case when t59rd.mass_emulsion        >= 0 then to_char(t59rd.mass_emulsion, '9990.99')
             else ' ' end as mass_emulsion
       
       ,case when t59rd.mass_assembly_after  >= 0 then to_char(t59rd.mass_assembly_after, '99990.99')
             else ' ' end as mass_assembly_after
       
       ,case when calc_corrected_wt_after    >= 0 then to_char(calc_corrected_wt_after)
             else ' ' end as corrected_wt_after
       
       ,case when calc_percent_residue       >= 0 then to_char(calc_percent_residue)
             else ' ' end as percent_residue
       
       ,case when t59rd.minimum_spec             >= 0 then to_char(t59rd.minimum_spec, '90.99')
             else ' ' end as min_spec
       
       /*-------------------------------------------------------------
         percent oil distillate by distillation
       -------------------------------------------------------------*/
       
       ,case when t59rd.amount_oil_distillate >= 0
             then to_char(t59rd.amount_oil_distillate, '990.99')
             else ' ' end as amount_oil_distillate
       
       ,case when calc_percent_oil_distillate >= 0 
             then to_char((calc_percent_oil_distillate / 2.0), '990.999')
             else ' ' end as percent_oil_distillate
       
       ,case when t59rd.maximum_spec              >= 0 then to_char(t59rd.maximum_spec, 90.99)
             else ' ' end as max_spec
       
       ,t59rd.remarks
       
  from MLT_1_Sample_WL900         smpl
  join Test_T59RD                t59rd on t59rd.sample_id = smpl.sample_id
  
  /*-------------------------------------------------------------
    from MTest, Lt_T59rd_BB.cpp, void LtT59rd_BB::CorGrpRoot::calc
    if (post >= 0.0) cor = post + 1.5;
    
    my calculation
    if (mass_assembly_after >= 0.0)
        calc_corrected_wt_after = mass_assembly_after + 1.5
  -------------------------------------------------------------*/
  
  cross apply (select case when t59rd.mass_assembly_after >= 0
                           then t59rd.mass_assembly_after + 1.5
                           else -1
                           end as calc_corrected_wt_after from dual
  ) wt_after
 
 /*-------------------------------------------------------------
    from MTest, Lt_T59rd_BB.cpp, void LtT59rd_BB::CorGrpRoot::calc
    if (cor >= 0.0 && cor >= ante)
        residue = (cor - ante) / 2.0
  -------------------------------------------------------------*/
  
  cross apply (select case when calc_corrected_wt_after >= 0 and 
                                calc_corrected_wt_after >= t59rd.mass_assembly_before
                           then ((calc_corrected_wt_after - t59rd.mass_assembly_before) / 2)
                           else -1
                           end as calc_percent_residue from dual
  ) pct_residue
 
 /*-------------------------------------------------------------
    from MTest, Lt_T59rd_BB.cpp, void LtT59rd_BB::CorGrpRoot::calc
    percent oil distillate by distillation
    if (vol > 0.0) oil = vol / 2.0;
  -------------------------------------------------------------*/
  
  cross apply (select case when t59rd.amount_oil_distillate > 0 
                           then t59rd.amount_oil_distillate / 2.0
                           else -1 
                           end as calc_percent_oil_distillate from dual
  ) pct_distillate
 ;






 
 
 
 