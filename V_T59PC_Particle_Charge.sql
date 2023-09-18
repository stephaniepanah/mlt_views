


-- T59-rd Residue and Oil Distillate by Distillation (current)
-- T59-re Residue by Evaporation -- T59-re segments  (current) (the only T59 test with segments)
-- T59-pc Particle Charge                            (2010)
-- T59-sv Sieve Test (Liquid Asphalt)                (2010)
-- T59-cm Cement Mixing Test (Liquid Asphalt)        (1960)



select * from V_T59PC_Particle_Charge order by sample_year desc
;



select count(*), min(sample_year), max(sample_year) from Test_T59pc where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 44       2006    2010





/***********************************************************************************

  T59-pc Particle Charge
  W-10-0661-AB, W-10-0724-AB, W-10-1140-AB, W-09-0357-AB, W-06-0358-AB
  
***********************************************************************************/


create or replace view V_T59PC_Particle_Charge as 

select t59pc.sample_id,
       t59pc.sample_year,
       t59pc.test_status,
       t59pc.tested_by,
       
       case when to_char(t59pc.date_tested, 'yyyy') = '1959' then ' '
            else to_char(t59pc.date_tested, 'mm/dd/yyyy')
            end as date_tested
            
       ,t59pc.date_tested as date_tested_DATE
       ,t59pc.date_tested_orig
       
       ,t59pc.particle_charge -- no entry, positive, negative
       
       ,case when t59pc.starting_current >= 0 then to_char(t59pc.starting_current)
             else ' ' end as starting_current
       
       ,t59pc.remarks  
       
  from MLT_1_Sample_WL900         smpl
  join Test_T59PC                t59pc on t59pc.sample_id = smpl.sample_id
 ;









