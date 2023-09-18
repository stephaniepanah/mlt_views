



select * from V_T88_sieves_Pct_Passing_Grid where sample_id in (

--'W-18-0124-SO' -- not good, weird data, largest sieve is #4
--'W-19-0007-SO' -- perfect
--'W-21-0011-SO'  -- not good, weird data, largest sieve is #4
--'W-21-0063-SO' 
--'W-21-0070-SO' 
'W-21-0080-SO' 
--'W-21-0084-SO' 
--'W-21-0085-SO' 
--'W-21-0086-SO'  -- perfect
--'W-21-0112-SO' 
--'W-21-0194-SO' 
--'W-21-0485-GS' -- perfect

);





/*---------------------------------------------------------------------

  V_T88_Sieves_Fine_Projected was created to 
  prepare for interpolation for the projected sieve sizes:
 
  0.02mm, 0.01mm, 0.005mm, 0.002mm, 0.001mm
    20µm,   10µm,     5µm,     2µm,     1µm
  
---------------------------------------------------------------------*/

create or replace view V_T88_Sieves_Fine_Projected as 

select  T88_sample_id                   as sample_id
       ,ROW_NUMBER() over (partition by T88_sample_id order by sieve_metric_in_mm desc) as segment_nbr
       ,sieve_customary                 as sieve_size
       ,sieve_metric_in_mm              as projsv_diameter
       ,log(10, sieve_metric_in_mm)     as projsv_log
              
  from V_T88_Analysis_Particle_Size_Soils  
       ,MLT_Sieve_Size
 
 where sieve_metric_in_mm between 0.001 and 0.02
 order by sieve_metric_in_mm desc
;




/*---------------------------------------------------------------------

  V_T88_Pct_Passing_Grid
  
  sample        group   segment     sieve   proj    pctPassing
  W-19-0007-SO	1	    1	        1 1/2"	' '     100.00
  W-19-0007-SO	1	    2	        1"	 	' '      99.15
  W-19-0007-SO	1	    3	        3/4"	' '      99.05
  W-19-0007-SO	1	    4	        1/2"	' '      98.09
  W-19-0007-SO	1	    5	        3/8"	' '      97.40
  W-19-0007-SO	1	    6	        #4	 	' '      92.96
  W-19-0007-SO	2	    1	        #10	 	' '      89.54
  W-19-0007-SO	3	    1	        #40	 	' '      81.63
  W-19-0007-SO	3	    2	        #200	' '      74.39
  W-19-0007-SO	4	    1	        20µm	*	     62.85
  W-19-0007-SO	4	    2	        10µm	*	     52.53
  W-19-0007-SO	4	    3	        5µm	    *	     40.61
  W-19-0007-SO	4	    4	        2µm	    *	     27.13
  W-19-0007-SO	4	    5	        1µm	    *	     19.14
  
  W-17-0318-SO, W-17-0319-SO, W-17-0321-SO do not equal 100% in the T-88 
  
  had to move group number 4, Projected Sieves, to the first statement, due to the With clause.
  the order by group_nbr places them at the bottom, so we are fine
  
  ORA-32034: unsupported use of WITH clause
  32034. 00000 -  "unsupported use of WITH clause"
  *Cause:    Inproper use of WITH clause because one of the following two reasons
             1. nesting of WITH clause within WITH clause not supported yet
             2. For a set query, WITH clause can't be specified for a branch.
             3. WITH clause cannot be specified within parenthesis.
  *Action:   correct query and retry
  
---------------------------------------------------------------------*/



create or replace view V_T88_Sieves_Pct_Passing_Grid as 

/*--------------------------------------------------
  group number 4, T88 Projected Fine Sieves
--------------------------------------------------*/

with T88_HYDROMETER_sql as (

select  T88_HYDROMETER_SAMPLE_ID      as sample_id
       ,T88_HYDROMETER_SEGMENT_NBR    as segment_nbr
       
       ---------------------
       -- Recast values
       ---------------------
       
       ,T88_HYDROMETER_PERCENT_RECAST
        as recast
       
       ,lead(T88_HYDROMETER_PERCENT_RECAST,1,0) over (partition by T88_HYDROMETER_SAMPLE_ID order by T88_HYDROMETER_SEGMENT_NBR)
        as recast_next
       
       ,T88_HYDROMETER_PERCENT_RECAST - 
       (lead(T88_HYDROMETER_PERCENT_RECAST,1,0) over (partition by T88_HYDROMETER_SAMPLE_ID order by T88_HYDROMETER_SEGMENT_NBR))
        as recast_subtract_recast_next
       
       ---------------------
       -- Diameter values
       ---------------------
       
       ,T88_HYDROMETER_PARTICLE_DIAMETER
        as particle_diameter
       
       ,lead(T88_HYDROMETER_PARTICLE_DIAMETER,1,0) over (partition by T88_HYDROMETER_SAMPLE_ID order by T88_HYDROMETER_SEGMENT_NBR)
        as particle_diameter_next
       
       ,log(10, T88_HYDROMETER_PARTICLE_DIAMETER)
        as diameter_log
       
       ,(lead(log(10, T88_HYDROMETER_PARTICLE_DIAMETER),1,0) over (partition by T88_HYDROMETER_SAMPLE_ID order by T88_HYDROMETER_SEGMENT_NBR))
        as diameter_log_next
       
       ,log(10, T88_HYDROMETER_PARTICLE_DIAMETER) - 
       (lead(log(10, T88_HYDROMETER_PARTICLE_DIAMETER),1,0) over (partition by T88_HYDROMETER_SAMPLE_ID order by T88_HYDROMETER_SEGMENT_NBR))
        as diameter_log_subtract_diameter_log_next -- the denominator
       
  from V_T88_Hydrometer_Grid
  
 order by 
 T88_HYDROMETER_SAMPLE_ID, 
 T88_HYDROMETER_SEGMENT_NBR
)

select  projsv.sample_id                                       as sample_id
       ,4                                                      as group_nbr
       ,projsv.segment_nbr                                     as segment_nbr
       ,projsv.sieve_size                                      as sieve_size
       ,'*'                                                    as projected
       ,percent_passing                                        as pct_passing
       
       from MLT_1_Sample_WL900                            smpl
       
       join V_T88_Analysis_Particle_Size_Soils           v_T88 on v_T88.T88_sample_id = smpl.sample_id
       
       join V_T88_Sieves_Fine_Projected                 projsv on v_T88.T88_sample_id = projsv.sample_id
       
       join T88_HYDROMETER_sql                        tblHydro on v_T88.T88_sample_id = tblHydro.sample_id
       and (projsv.projsv_diameter between tblHydro.particle_diameter_next and tblHydro.particle_diameter)
       
       /*----------------------------------------------------------------------------------
         from MTest, Lt_T88ut_BC.cpp, HydroCalcs::doCalcsGrad(double factor, int eh, int bPpFine)
         
         interpolation for pp (pct passing)
         
         tblPp[xpp].pp = 
         tblHydro[xh].recast + 
         ( log(projsv) - log(tblHydro[xh].diam) ) * (tblHydro[xh].recast - tblHydro[xh + 1].recast)
         / (log(tblHydro[xh].diam) - log(tblHydro[xh + 1].diam))
       
       ----------------------------------------------------------------------------------*/
  
  cross apply (
  
  select 
  case when tblHydro.diameter_log_subtract_diameter_log_next <> 0 
       then ((((projsv.projsv_log - tblHydro.diameter_log) * (tblHydro.recast_subtract_recast_next)) / tblHydro.diameter_log_subtract_diameter_log_next) + tblHydro.recast)
       else -1 
        end as percent_passing from dual
               
  ) pct_passing
  
union

/*--------------------------------------------------
  group number 1, WL640 coarse sieves
--------------------------------------------------*/

select  v_wl643.WL643_sample_id                                as sample_id
       ,1                                                      as group_nbr
       ,v_wl643.wl640_segment_nbr                              as segment_nbr
       ,v_wl643.wl640_sieve_size                               as sieve_size
       ,' '                                                    as projected
       ,(100 - (v_wl643.WL640_mass_retained_cumulative * v_T88.T88_percent_pass_factor))
                                                               as pct_passing
       
       from MLT_1_Sample_WL900                            smpl
       join V_T88_Analysis_Particle_Size_Soils           v_T88 on v_T88.T88_sample_id = smpl.sample_id
       join V_WL643_Prep_for_Hydrometer_Analysis       v_wl643 on v_T88.T88_sample_id = v_wl643.WL643_sample_id
       
union

/*--------------------------------------------------
  group number 2, Percent Passing #10
--------------------------------------------------*/

select  v_T88.T88_sample_id                                    as sample_id
       ,2                                                      as group_nbr
       ,1                                                      as segment_nbr
       ,'#10'                                                  as sieve_size
       ,' '                                                    as projected
       ,v_T88.T88_percent_pass_Nbr10                           as pct_passing
       
       from MLT_1_Sample_WL900                            smpl
       join V_T88_Analysis_Particle_Size_Soils           v_T88 on v_T88.T88_sample_id = smpl.sample_id
 
union

/*--------------------------------------------------
  group number 3, V_T88_Sieves_Fine_Grid
--------------------------------------------------*/

select  t88fine.T88_Sieves_Fine_sample_id                      as sample_id
       ,3                                                      as group_nbr
       ,t88fine.T88_Sieves_Fine_segment_nbr                    as segment_nbr
       ,t88fine.T88_Sieves_Fine_sieve_size                     as sieve_size
       ,' '                                                    as projected
       ,(V_T88.T88_percent_pass_nbr10 - (t88fine.T88_Sieves_Fine_mass_retained_cumulative * V_T88.T88_fines_factor))   
                                                               as pct_passing
       
       from MLT_1_Sample_WL900                            smpl
       join V_T88_Analysis_Particle_Size_Soils           v_T88 on v_T88.T88_sample_id = smpl.sample_id
       join V_T88_Sieves_Fine_Grid                     t88fine on V_T88.T88_sample_id = t88fine.T88_Sieves_Fine_sample_id
 
 
 order by 
 sample_id, 
 group_nbr, 
 segment_nbr
 ;




   




