


select * from V_DL906_Asphalt_Binder_Information
 order by DL906_sample_year desc, DL906_Sample_ID
;




select count(*), min(sample_year), max(sample_year) from Test_DL906 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 756	    1985	2020


select * from test_dl906 where specific_gravity > 0 -- used in T209
 order by sample_year desc, sample_id
;



/***********************************************************************************

 DL906 Asphalt Binder Information
 
 W-20-0170,    W-20-0287,    W-20-0323,    W-20-0323-ACA, W-20-1008-AC, 
 W-19-0297-AC, W-19-0719-AC, W-19-0728-AC, W-19-0759-AC,  W-19-0862-AC
 W-18-0036-AC, W-18-0391-AC, W-18-0631-AC, W-18-1290-AC,  W-17-0509-AC
 W-87-0792-AC, W-87-1072-AC, W-85-0272-AC, W-85-0272-ACA

***********************************************************************************/


create or replace view V_DL906_Asphalt_Binder_Information as 


select  dl906.sample_id                                        as DL906_Sample_ID
       ,dl906.sample_year                                      as DL906_sample_year
       ,dl906.test_status                                      as DL906_test_status
       ,dl906.tested_by                                        as DL906_tested_by
       
       ,case when to_char(dl906.date_tested, 'yyyy') = '1959' then ' '
            else to_char(dl906.date_tested, 'mm/dd/yyyy') end
                                                               as DL906_date_tested
            
       ,dl906.date_tested                                      as DL906_date_tested_DATE
       ,dl906.date_Tested_Original                             as DL906_Date_Tested_Original
       
       ,dl906.supplier                                         as DL906_supplier
       ,dl906.Grade                                            as DL906_Grade
       ,dl906.specific_gravity_gb                              as DL906_specific_gravity_Gb
       ,dl906.refinery_location                                as DL906_refinery_location
       ,dl906.Type_Of_Asphalt                                  as DL906_Type_Of_Asphalt
       
       ,dl906.remarks                                          as DL906_Remarks
       
       /*------------------------------------------------------------
         original values, for cross checking if necessary
       ------------------------------------------------------------*/
       
       ,dl906.Supplier_Original                                as DL906_Supplier_Original
       ,dl906.Grade_Original                                   as DL906_Grade_Original
       ,dl906.refinery_location_original                       as DL906_refinery_location_original
       ,dl906.Type_Of_Asphalt_Original                         as DL906_Type_Of_Asphalt_Original
       
       /*-----------------------------------------------------------------------
       table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_DL906                                   dl906 on dl906.sample_id = smpl.sample_id
       
       ;









