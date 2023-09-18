


-- T59-rd Residue and Oil Distillate by Distillation (current)
-- T59-re Residue by Evaporation -- T59-re segments  (current) (the only T59 test with segments)
-- T59-pc Particle Charge                            (2010)
-- T59-sv Sieve Test (Liquid Asphalt)                (2010)
-- T59-cm Cement Mixing Test (Liquid Asphalt)        (1960)
 


select * from V_T59CM_Cement_Mixing_Liquid_Asphalt order by sample_year desc
;



select count(*), min(sample_year), max(sample_year) from Test_T59cm;
-- count    minYr   maxYr
-- 2	    1960	1960



select * from test_t59cm;



/***********************************************************************************

  T59-cm Cement Mixing Test (Liquid_Asphalt)
  
  from MTest, Lt_T59cm_BB.cpp, void LtT59cm_BB::CorGrpRoot::calc()
  
  The quantities are set up so that the wt (grams) of residue = % break
  
  if (tare >= 0.0 && gross >= 0.0)
      pct = (gross - tare);
  
  Sample ID     tare        gross     percent break
  W-60-1830-AB	114.65      114.93	  0.280
  W-60-0200-AB	127         127.14	  0.140	 	 
  
***********************************************************************************/


create or replace view V_T59CM_Cement_Mixing_Liquid_Asphalt as

select  t59cm.sample_id
       ,t59cm.sample_year
       ,t59cm.test_status
       ,t59cm.tested_by
       
       ,case when to_char(t59cm.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t59cm.date_tested, 'mm/dd/yyyy')
             end as date_tested
            
       ,t59cm.date_tested as date_tested_DATE
       ,t59cm.date_tested_orig
       
       ,t59cm.mass_sieve_and_pan             -- tare
       ,t59cm.mass_sieve_pan_residue -- gross
       
       -- pct break = (gross - tare)
       ,case when t59cm.mass_sieve_and_pan >= 0 and t59cm.mass_sieve_pan_residue >= 0
             then to_char(((t59cm.mass_sieve_pan_residue - t59cm.mass_sieve_and_pan)), '990.999')
             else ' '
             end as calc_pct_break
       
       ,case when t59cm.maximum_spec >= 0 then to_char(t59cm.maximum_spec)
             else ' ' end as max_spec
       
       ,t59cm.remarks
  
  from MLT_1_Sample_WL900         smpl
  join Test_T59CM                t59cm on t59cm.sample_id = smpl.sample_id
 ;









