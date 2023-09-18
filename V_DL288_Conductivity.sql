


-- T288 Minimum Resistivity (2020, 14 samples)
-- DL288 Conductivity       (2015, two samples)



select * from V_DL288_Conductivity order by DL288_Sample_Year desc;



select * from V_DL288_Conductivity where DL288_Sample_ID = 'W-15-0273-SO';



select * from V_DL288_Conductivity where DL288_Sample_ID in ( -- all 34 samples

'W-15-0273-SO', 'W-15-0275-SO', 'W-07-0615-SO', 'W-07-0616-SO', 'W-06-0989-SO', 
'W-02-0943-SO', 'W-02-0944-SO', 'W-02-0945-SO', 'W-01-0009-AG', 
'W-99-0150-SO', 'W-99-0151-SO', 'W-99-0152-SO', 'W-99-0289-SO', 'W-98-1302-SO', 
'W-97-0153-SO', 'W-97-0160-SO', 'W-97-0419-SO', 'W-97-0420-SO', 'W-97-0421-SO', 
'W-97-0422-SO', 'W-97-0423-SO', 'W-97-0424-SO', 'W-97-0425-SO', 'W-97-0426-SO', 
'W-97-0427-SO', 'W-97-0428-SO', 'W-97-1707-SO', 
'W-95-1920-SO', 'W-95-1921-SO', 'W-95-2182-SO', 'W-95-2183-SO', 'W-95-2252-SO', 
'W-95-2254-SO', 'W-95-2258-SO', 
'W-60-1242-SO'

);



-----------------------------------------------------------------------
-- some diagnostics
-----------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_DL288 where sample_year not in ('1960','1966');
-- count   min   max
--    34   1995  2015



select sample_year, count(*) from Test_DL288
 group by sample_year
 order by sample_year desc
 ;



select * from test_dl288 order by sample_year desc, sample_id;
 


/***********************************************************************************

 DL288 Conductivity
 
 34 samples 
 
 W-15-0273-SO, W-15-0275-SO, W-07-0615-SO, W-07-0616-SO, W-06-0989-SO
 W-02-0943-SO, W-02-0944-SO, W-02-0945-SO, W-01-0009-AG
 
 W-99-0150-SO, W-99-0151-SO, W-99-0152-SO, W-99-0289-SO, W-98-1302-SO
 W-97-0153-SO, W-97-0160-SO, W-97-0419-SO, W-97-0420-SO, W-97-0421-SO
 W-97-0422-SO, W-97-0423-SO, W-97-0424-SO, W-97-0425-SO, W-97-0426-SO
 W-97-0427-SO, W-97-0428-SO, W-97-1707-SO
 W-95-1920-SO, W-95-1921-SO, W-95-2182-SO, W-95-2183-SO, W-95-2252-SO
 W-95-2254-SO, W-95-2258-SO
 W-60-1242-SO

***********************************************************************************/


create or replace view V_DL288_Conductivity as 

select  dl288.sample_year                                     as DL288_Sample_Year
       ,dl288.sample_id                                       as DL288_Sample_ID
       ,dl288.test_status                                     as DL288_Test_Status
       ,dl288.tested_by                                       as DL288_Tested_by
       
       ,case when to_char(dl288.date_tested, 'yyyy') = '1959' then ' '
             else to_char(dl288.date_tested, 'mm/dd/yyyy')    end 
                                                              as DL288_date_tested
            
       ,dl288.date_tested                                     as DL288_date_tested_DATE
       ,dl288.date_tested_orig                                as DL288_date_tested_orig
       
       ,dl288.conductivity                                    as DL288_conductivity 
       
       ,dl288.remarks                                         as DL288_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                    smpl
  join Test_DL288                           dl288 on dl288.sample_id = smpl.sample_id
  ;
  








