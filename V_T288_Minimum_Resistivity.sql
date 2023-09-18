


-- T288 Minimum Resistivity (2020, 14 samples)
-- DL288 Conductivity       (2015, two samples)



select * from V_T288_Minimum_Resistivity order by T288_Sample_Year desc;



select * from V_T288_Minimum_Resistivity where T288_Sample_ID = 'W-20-0556';



select * from V_T288_Minimum_Resistivity where T288_Sample_ID in (
'W-20-1074-SO', 'W-19-0838-SO', 'W-17-1987-SO', 'W-16-1470-SO'
);



-----------------------------------------------------------------------
-- some diagnostics
-----------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T288 where sample_year not in ('1960','1966');
-- count   min   max
--   307   1994  2020


select count(*) from Test_T288_segments; -- 1154


select * from Test_T288_segments where sample_id = 'W-16-1470-SO';


select sample_year, count(*) from Test_T288
 group by sample_year
 order by sample_year desc
 ;


select * from test_t288 order by sample_year desc;



select * from test_t288_segments 
 --where sample_id like 'W-20%'
 order by sample_id, segment_nbr
 ;
 
 
 select distinct(water_added) from test_t288_segments;
 select distinct(resistivity) from test_t288_segments;
 
 
 
 -- T288 parent samples without child segments
 -- 70 records
 select t288.sample_id, t288.sample_year from test_t288 t288
 
  where t288.sample_id not in (select t288seg.sample_id from test_t288_segments t288seg
                                where t288seg.sample_id = t288.sample_id)
                                
  order by t288.sample_year desc, t288.sample_id
  ;
  
  /****
  W-16-0731-SO, W-16-0732-SO, W-16-1329-SO, W-16-1330-SO, W-16-1331-SO, W-16-1332-SO, W-16-1333-SO
  W-16-1334-SO, W-16-1335-SO, W-16-1336-SO, W-16-1337-SO, W-16-1338-SO, W-16-1339-SO, W-16-1340-SO
  
  W-14-0680-SO, W-14-0681-SO, W-14-0682-SO, W-14-0683-SO, W-14-0684-SO  
  W-12-0164-SO, W-12-0542-SO, W-11-0634-SO, W-10-0404-SO, W-10-1812-SO
  W-08-0732-SO, W-08-0733-SO, W-08-0734-SO
  W-07-0067-AG, W-07-0102-AG, W-07-0103-AG, W-07-0301-SO
  W-06-0986-SO, W-01-1284-SO, W-00-0092-AG
  
  W-98-1264-SO, W-98-2440-SO, W-98-2441-SO, W-98-2442-SO, W-98-2444-SO, W-98-2445-SO
  W-97-0015-SO, W-97-0065-SO, W-97-0066-SO, W-97-0067-SO, W-97-0068-SO, W-97-1336-SO, W-97-1337-SO
  W-97-1338-SO, W-97-1339-SO, W-97-1340-SO, W-97-1351-SO, W-97-1352-SO, W-97-1408-SO, W-97-1574-SO
  W-97-1575-SO, W-97-1576-SO, W-97-1577-SO, W-97-1578-SO, W-97-1579-SO, W-97-1580-SO, W-97-1581-SO
  W-97-1582-SO, W-97-1583-SO, W-97-1705-SO, W-97-1706-SO, W-97-1707-SO, W-97-1708-SO, W-97-1709-SO
  W-66-9001-GEO, W-66-9011-GEO
  ****/
 
 
 
 -- T288 child segments without parent samples (this should never be)
 -- 0 records
 select t288seg.sample_id from test_t288_segments t288seg 
  where t288seg.sample_id not in (select t288.sample_id from test_t288 t288
                                   where t288.sample_id = t288seg.sample_id)
  ;
 


/***********************************************************************************

 T288 Minimum Resistivity
 
 W-20-0060, W-20-0064, W-20-0294, W-20-0295, W-20-0555, W-20-0556
 W-20-1069-SO, W-20-1070-SO, W-20-1073-SO, W-20-1074-SO
 W-20-1212-SO, W-20-1227-SO, W-20-1228-SO, W-20-1296-SO
 W-17-0408-SO, W-17-0409-SO, W-17-1987-SO, W-17-1988-SO

***********************************************************************************/


create or replace view V_T288_Minimum_Resistivity as 

with min_sql as (select sample_id, min(resistivity) as min_resistivity
                   from Test_T288_segments
                  group by sample_id 
)

select  t288.sample_year                         as T288_Sample_Year
       ,t288.sample_id                           as T288_Sample_ID
       ,t288.test_status                         as T288_Test_Status
       ,t288.tested_by                           as T288_Tested_by
       
       ,case when to_char(t288.date_tested, 'yyyy') = '1959'
             then ' '
             else to_char(t288.date_tested, 'mm/dd/yyyy')
             end                                 as T288_date_tested
            
       ,t288.date_tested                           as T288_date_tested_DATE
       ,t288.date_tested_orig                      as T288_date_tested_orig
       
       ,t288.mass_soil                           as T288_mass_soil
       
       /*-------------------------------------------------------------
         segments
       -------------------------------------------------------------*/
       
       ,case when t288seg.segment_nbr is not null then to_char(t288seg.segment_nbr)     else ' ' end as T288seg_segment_nbr
       ,case when t288seg.water_added >= 0        then to_char(t288seg.water_added)     else ' ' end as T288seg_water_added
       ,case when t288seg.resistivity >= 0        then to_char(t288seg.resistivity)     else ' ' end as T288seg_resistivity
       ,case when min_sql.min_resistivity >= 0    then to_char(min_sql.min_resistivity) else ' ' end as T288seg_minimum_resistivity
       
       ,t288.remarks                             as T288_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T288                               t288 on t288.sample_id = smpl.sample_id
  left join Test_T288_segments        t288seg on t288.sample_id = t288seg.sample_id
  left join min_sql                           on t288.sample_id = min_sql.sample_id
  
  order by T288_Sample_ID, T288seg.segment_nbr
  ;
    
  
  
  
  
  
  
  
  
  