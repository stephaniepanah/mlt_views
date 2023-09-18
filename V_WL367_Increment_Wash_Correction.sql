


/*---------------------------------------------------------------------
 notes:

 need to be able to discern the WL800 from WL801 when associated with WL367 (yes? no?)

 While sieve size is on the Test_WL367_Stockpile table, 
 the view, V_WL367_Stockpiles, uses the sieves from WL800

---------------------------------------------------------------------*/



select * from V_WL367_Increment_Wash_Correction 
 order by WL367_sample_year desc, WL367_sample_id, WL800_stockpile_nbr
 ;




select * from V_WL367_Stockpiles 
 where WL367_Sample_ID in ('W-19-1041-AC' --, 'W-19-0862-AC'
 );




select count(*), min(sample_year), max(sample_year) from Test_WL367 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 407	    1988	2020



select * from test_wl367 order by sample_year desc, sample_id;




select * from test_wl367_stockpile order by sample_id, stockpile, segment_nbr;




/***********************************************************************************

 WL367 USFS Increment Wash Correction and Stockpiles

***********************************************************************************/


create or replace View V_WL367_Increment_Wash_Correction as 

--------------------------------------------------------------------------------
-- main SQL
--------------------------------------------------------------------------------

select  wl367.sample_id                                          as WL367_Sample_ID
       ,wl367.sample_year                                        as WL367_sample_year
       ,wl367.test_status                                        as WL367_test_status
       ,wl367.tested_by                                          as WL367_tested_by
       
       ,case when to_char(wl367.date_tested, 'yyyy') = '1959'    then ' '
             else to_char(wl367.date_tested, 'mm/dd/yyyy') end   as WL367_date_tested
       
       ,wl367.date_tested                                        as WL367_date_tested_DATE
       ,wl367.date_tested_orig                                   as WL367_date_orig
       
       ,v_wl800stk.WL800_stockpile_nbr                           as WL800_stockpile_nbr -- used for sorting, not display
       
       ,'(' || v_wl800stk.WL800_stockpile_nbr || ') ' || v_wl800stk.WL800_stockpile_description
                                                                 as WL800_Stockpiles
       
       ,wl367.remarks                                            as WL367_Remarks
       
       /*--------------------------------------------------------------------------------
         table relationships
       --------------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                              smpl 
       join Test_WL367                                     wl367 on wl367.sample_id = smpl.sample_id
       
       left join V_WL800_Sieve_Gradation_Stockpiles      v_wl800 on wl367.sample_id = v_wl800.WL800_Sample_ID
       left join V_WL800_Stockpiles_grid              v_wl800stk on v_wl800.WL800_Sample_ID = v_wl800stk.WL800_Sample_ID
       
       order by 
       wl367.sample_id, 
       v_wl800stk.WL800_stockpile_nbr
       ;
  
  
  






----------------------------------------------------
----------------------------------------------------
----------------------------------------------------


-- this union will not work, need to be able to discern the WL800 from WL801 associated with WL367


select * from (

select  wl367.sample_id      as sample_ID
       ,'WL800'              as Labtest_source
       ,wl367.sample_year    as sample_year
       ,wl367.test_status    as test_status
       ,wl367.tested_by      as tested_by
       
       ,case when to_char(wl367.dt_tested, 'yyyy') = '1959' then ' '
             else to_char(wl367.dt_tested, 'mm/dd/yyyy')
             end as dt_tested
            
       ,wl367.dt_tested      as dt_tested_DATE
       ,wl367.dt_tested_orig as dt_orig
       
       ,'(1) ' || wl800.stockpile1_description as S1
       ,'(2) ' || wl800.stockpile2_description as S2
       ,'(3) ' || wl800.stockpile3_description as S3
       ,'(4) ' || wl800.stockpile4_description as S4
       ,'(5) ' || wl800.stockpile5_description as S5
       ,'(6) ' || wl800.stockpile6_description as S6
             
       ,wl367.remarks        as remarks
       
  from MLT_1_WL900_Sample    smpl
  join Test_WL367           wl367 on smpl.sample_id = wl367.sample_id
  join Test_WL800           wl800 on smpl.sample_id = wl800.sample_id
  
union

select  wl367.sample_id      as sample_ID
       ,'WL801'              as Labtest_source
       ,wl367.sample_year    as sample_year
       ,wl367.test_status    as test_status
       ,wl367.tested_by      as tested_by
       
       ,case when to_char(wl367.dt_tested, 'yyyy') = '1959' then ' '
             else to_char(wl367.dt_tested, 'mm/dd/yyyy')
             end as dt_tested
            
       ,wl367.dt_tested      as dt_tested_DATE
       ,wl367.dt_tested_orig as dt_orig
       
       ,'(1) ' || wl801.stockpile1_description as S1
       ,'(2) ' || wl801.stockpile2_description as S2
       ,'(3) ' || wl801.stockpile3_description as S3
       ,'(4) ' || wl801.stockpile4_description as S4
       ,'(5) ' || wl801.stockpile5_description as S5
       ,'(6) ' || wl801.stockpile6_description as S6
             
       ,wl367.remarks        as Remarks
       
  from MLT_1_Sample_WL900    smpl
  join Test_WL367           wl367 on smpl.sample_id = wl367.sample_id
  join Test_WL801           wl801 on smpl.sample_id = wl801.sample_id

)
order by sample_year desc, sample_id
;









