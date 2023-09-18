



select * from V_Annual_Sample_File where SCN like 'W-21%';



select * from V_Annual_Sample_File where SCN like 'W-88%';



select count(*) from V_Annual_Sample_File;




create or replace view V_Annual_Sample_File as 


select rpad(smpl.Sample_ID,          14) as SCN 
,case when length(smpl.Sample_ID)   > 9  then rpad(substr(smpl.Sample_ID, 11),4) else rpad(' ',4) end as SUFF
,rpad (proj.Project_Name,            45) as PROJECT_NAME
,rpad (proj.Project_Nbr,             30) as PROJECT_NUMBER
,rpad (proj.Agency,                   6) as AGENC
,rpad (proj.project_county,          12) as COUNTY
,rpad (proj.project_state,            2) as ST
,rpad (smpl.sample_type,             50) as SAMPLE_TYPE
,rpad (smpl.material_description,    45) as MATERIAL_DESCRIPTION
,rpad (smpl.qlpay_item,              12) as ITEM_NUMBER
,rpad (subm.Submitter_Name,          24) as SUBMITTED_BY
,rpad (smpl.sample_sampled_by,       20) as SAMPLED_BY
,rpad (smpl.material_sample_location,40) as SAMPLE_LOCATION
,rpad (smpl.material_contractor,     40) as OWNER_CONTRACTOR
,rpad (smpl.source_name,             65) as SOURCE_NAME
,rpad (smpl.source_number,            8) as source_number
,rpad (smpl.source_location,         65) as SOURCE_LOCATION
,rpad (smpl.sample_intended_use,     25) as Intended_Use

,case when to_char(smpl.date_received,       'yyyy') = '1959' then rpad(' ',10) else to_char(smpl.date_received,       'mm/dd/yyyy') end as date_received
,case when to_char(smpl.sample_date_sampled, 'yyyy') = '1959' then rpad(' ',10) else to_char(smpl.sample_date_sampled, 'mm/dd/yyyy') end as date_sampled
,case when to_char(smpl.sample_date_shipped, 'yyyy') = '1959' then rpad(' ',10) else to_char(smpl.sample_date_shipped, 'mm/dd/yyyy') end as date_shipped
,case when to_char(smpl.date_billed,         'yyyy') = '1959' then rpad(' ',10) else to_char(smpl.date_billed,         'mm/dd/yyyy') end as date_billed

 from MLT_1_Sample_WL900                 smpl
 join MLT_Project_Sample_Xref            proj on smpl.Sample_ID = proj.Sample_ID
 join MLT_Submitter_Sample_Xref          subm on smpl.Sample_ID = subm.Sample_ID
 
order by smpl.Sample_ID
;









