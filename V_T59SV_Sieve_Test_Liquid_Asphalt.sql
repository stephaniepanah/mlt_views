


-- T59-rd Residue and Oil Distillate by Distillation (current)
-- T59-re Residue by Evaporation -- T59-re segments  (current) (the only T59 test with segments)
-- T59-pc Particle Charge                            (2010)
-- T59-sv Sieve Test (Liquid Asphalt)                (2010)
-- T59-cm Cement Mixing Test (Liquid Asphalt)        (1960)
 


select * from V_T59SV_Sieve_Test_Liquid_Asphalt order by sample_year desc
;



select count(*), min(sample_year), max(sample_year) from Test_T59sv where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 2        2010    2010




select * from test_t59sv;



/***********************************************************************************

  T59-sv Sieve Test (Liquid Asphalt)
  
  from MTest, Lt_T59sv_BB.cpp, void LtT59sv_BB::CorGrpRoot::calc()
  
  if (tare >= 0.0 && gross >= 0.0)
      pct = (gross - tare) / 10.0;
  
  Sample ID     tare        gross     percent
  W-10-0661-AB	233.24	    233.75	  0.051
  W-10-0723-AB	212.746	    213.145	  0.040
  W-60-0200-AB	115	        115.63	  0.063
  W-60-1830-AB	114.23	    115.76	  0.153
  
***********************************************************************************/


create or replace view V_T59SV_Sieve_Test_Liquid_Asphalt as 

select  t59sv.sample_id
       ,t59sv.sample_year
       ,t59sv.test_status
       ,t59sv.tested_by
       
       ,case when to_char(t59sv.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t59sv.date_tested, 'mm/dd/yyyy')
             end as date_tested
            
       ,t59sv.date_tested as date_tested_DATE
       ,t59sv.date_tested_orig
       
       ,t59sv.mass_sieve_and_pan             -- tare
       ,t59sv.mass_sieve_pan_residue -- gross
       
       -- pct = (gross - tare) / 10.0
       ,case when t59sv.mass_sieve_and_pan >= 0 and t59sv.mass_sieve_pan_residue >= 0
             then to_char(((t59sv.mass_sieve_pan_residue - t59sv.mass_sieve_and_pan) / 10.0), '90.999')
             else ' '
             end as calc_pct_sample_retained
       
       ,case when t59sv.maximum_spec >= 0 then to_char(t59sv.maximum_spec)
             else ' ' end as max_spec
       
       ,t59sv.remarks
  
  from MLT_1_Sample_WL900         smpl
  join Test_T59SV                t59sv on t59sv.sample_id = smpl.sample_id
 ;









