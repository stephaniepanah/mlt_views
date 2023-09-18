


select count(*), min(sample_year), max(sample_year) from Test_T313 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 1571	    2000	2020



select * from V_T313_Creep_Stiffness order by sample_id desc
;




select * from V_T313_Creep_Stiffness
 where sample_id in ( 
 'W-20-0821-AB', 'W-20-0820-AB', 'W-20-0651',    'W-20-0650',
 'W-19-1630-AB', 'W-19-1629-AB', 'W-19-1597-AB', 'W-19-1596-AB',
 'W-18-0006-AB', 'W-18-0862-AB', 'W-18-1206-AB', 'W-17-0326-AB', 'W-17-1759-AB'
 )
 order by sample_id desc
;




select * from V_T313_Segments
 where sample_id in ( 
 'W-20-0821-AB', 'W-20-0820-AB', 'W-20-0651',    'W-20-0650',
 'W-19-1630-AB', 'W-19-1629-AB', 'W-19-1597-AB', 'W-19-1596-AB',
 'W-18-0006-AB', 'W-18-0862-AB', 'W-18-1206-AB', 'W-17-0326-AB', 'W-17-1759-AB'
 )
 order by sample_id desc, segment_nbr
 ;



/***********************************************************************************

 T313 Creep Stiffness
 
 W-20-0821-AB, W-20-0820-AB, W-20-0651, W-20-0650
 W-19-1630-AB, W-19-1629-AB, W-19-1597-AB, W-19-1596-AB
 W-18-0006-AB, W-18-0862-AB, W-18-1206-AB, W-17-0326-AB, W-17-1759-AB
 
 TP1 Creep Stiffness of Asphalt Binder, BBR (Bending Beam Ratio)
 W-02-0089-AB
   
***********************************************************************************/


create or replace view V_T313_Creep_Stiffness as 

select  t313.sample_id
       ,t313.sample_year
       ,t313.test_status
       ,t313.tested_by
       
       ,case when to_char(t313.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t313.date_tested, 'mm/dd/yyyy')
             end as date_tested
            
       ,t313.date_tested as date_tested_DATE
       ,t313.date_tested_orig
       
       ,t313.temperature as temperature_celsius
       
       ,t313.remarks
       
  from MLT_1_Sample_WL900     smpl
  join Test_T313              t313 on t313.sample_id = smpl.sample_id
  
 ;







/***********************************************************************************

 T313_Segments (and averages)
 
 from MTest, Lt_T313_BB.cpp, void LtT313_BB::CorGrpRoot::calcAvs()
 
 if (!skip)              --- t313seg.exclude_segment
 {
    stiffcum += val;     --- t313seg.stiffness_mpa
    ++nstiffcum;
    stiff = (stiffcum/nstiffcum);
    
    mvalcum += val;      --- t313seg.m_value
    ++nmvalcum;
    mval = (mvalcum/nmvalcum);
 }
 
***********************************************************************************/



create or replace view V_T313_Segments as 

with t313seg_sql as (

     select  sample_id as sample_id
            ,avg(case when stiffness_mpa >= 0 then stiffness_mpa else 0 end) as t313_calc_avg_stiffness
            ,avg(case when m_value       >= 0 then m_value       else 0 end) as t313_calc_avg_m_value
       from Test_T313_Segments
      where exclude_segment <> 'X'
      group by sample_id
)

select  t313seg.sample_id    -- key
       ,t313seg.segment_nbr  -- key
       
       ,t313seg.stiffness_mpa
       ,t313seg.m_value
       ,t313seg.exclude_segment
       
       ,t313_calc_avg_stiffness
       ,t313_calc_avg_m_value
       
  from MLT_1_Sample_WL900     smpl
  join Test_T313              t313 on t313.sample_id = smpl.sample_id  
  join Test_T313_Segments  t313seg on t313.sample_id = t313seg.sample_id
  join t313seg_sql                 on t313seg_sql.sample_id = t313seg.sample_id
 
 ;
 
 







