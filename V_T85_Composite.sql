


select * from V_T85_Header_SG_Absorption_Coarse order by T85_Sample_Year desc, T85_Sample_ID;



select * from V_T85_Stockpile_Composite
 order by T85_STK_SAMPLE_YEAR desc, T85_Stk_Sample_ID, T85_Stk_stockpile, T85_Stk_segment_nbr;



select * from V_T85_Stockpile
 order by T85_Stk_Sample_Year desc, T85_Stk_Sample_ID, T85_Stk_stockpile, T85_Stk_segment_nbr;



  
            
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  --from MLT_1_WL900_Sample                     smpl
  --join Test_T85                                t85 on t85.sample_id = smpl.sample_id 
  --left outer join V_T85_Stockpile_Composite        on t85.sample_id = T85_STK_SAMPLE_ID 
  
  





/*-------------------------------------------------------------
  V_T85_Stockpile_Composite
-------------------------------------------------------------*/


create or replace view V_T85_Stockpile_Composite as 

select 
 T85_STK_SAMPLE_YEAR
,T85_STK_SAMPLE_ID
,T85_STK_STOCKPILE
,T85_STK_SEGMENT_NBR
,T85_STK_DESCRIPTION
,T85_STK_RATIO

,T85_STK_AVG_BSG
,T85_STK_AVG_SSDSG
,T85_STK_AVG_ASG
,T85_STK_AVG_ABSORPTION_PCT

,case when avg(case when T85_STK_AVG_BSG > 0 then T85_STK_AVG_BSG end) over (partition by T85_STK_SAMPLE_ID) is not null
      then round(avg(case when T85_STK_AVG_BSG > 0 then T85_STK_AVG_BSG end) over (partition by T85_STK_SAMPLE_ID),3)
      else -1 end
      as T85_Sample_Avg_BSG

,case when avg(case when T85_STK_AVG_SSDSG > 0 then T85_STK_AVG_SSDSG end) over (partition by T85_STK_SAMPLE_ID) is not null
      then round(avg(case when T85_STK_AVG_SSDSG > 0 then T85_STK_AVG_SSDSG end) over (partition by T85_STK_SAMPLE_ID),3)
      else -1 end
      as T85_Sample_Avg_SSDSG

,case when avg(case when T85_STK_AVG_ASG > 0 then T85_STK_AVG_ASG end) over (partition by T85_STK_SAMPLE_ID) is not null
      then round(avg(case when T85_STK_AVG_ASG > 0 then T85_STK_AVG_ASG end) over (partition by T85_STK_SAMPLE_ID),3)
      else -1 end
      as T85_Sample_Avg_ASG

,case when avg(case when T85_STK_AVG_ABSORPTION_PCT > 0 then T85_STK_AVG_ABSORPTION_PCT end) over (partition by T85_STK_SAMPLE_ID) is not null
      then round(avg(case when T85_STK_AVG_ABSORPTION_PCT > 0 then T85_STK_AVG_ABSORPTION_PCT end) over (partition by T85_STK_SAMPLE_ID),3)
      else -1 end
      as T85_Sample_Avg_ABSORPTION_PCT

 from V_T85_Stockpile
where T85_STK_SEGMENT_NBR = 1
;









