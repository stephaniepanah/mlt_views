


-- D5821 Fractured Particles       (current)
-- FL506 Fractured Faces, Multiple (1995)
-- FL507 Fractured Particles       (2016)
-- FL508 Flakiness Index           (2001)


select * from V_FL506_Fractured_Faces_Multiple;



select count(*), min(sample_year), max(sample_year) from Test_FL506 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 1         1995    1995



/***********************************************************************************

* FL506 Fractured Faces, Multiple
* W-95-1297-AG sole sample, status - not completed
                    
***********************************************************************************/


create or replace view V_FL506_Fractured_Faces_Multiple as

select  fl506.sample_id
       ,fl506.sample_year
       ,fl506.test_status
       ,fl506.tested_by
       
       ,case when to_char(fl506.date_tested, 'yyyy') = '1959' then ' '
             else to_char(fl506.date_tested, 'mm/dd/yyyy')
             end as date_tested
       
       ,fl506.date_tested as date_tested_DATE
       ,fl506.date_tested_orig as date_tested_orig
       
       ,case when fl506.mass_fractured_multi_face >= 0 then to_char(fl506.mass_fractured_multi_face)
        else ' ' end as mass_fractured_multi_face
        
       ,case when fl506.mass_fractured_one_face   >= 0 then to_char(fl506.mass_fractured_one_face)
        else ' ' end as mass_fractured_one_face
        
       ,case when fl506.mass_not_fractured        >= 0 then to_char(fl506.mass_not_fractured)
        else ' ' end as mass_not_fractured
       
       ,fl506.remarks
       
  from MLT_1_Sample_WL900       smpl
  join Test_FL506              fl506 on smpl.sample_id = fl506.sample_id
 ;









