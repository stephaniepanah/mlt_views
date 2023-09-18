


/*---------------------------------------------------------------------------------------
  V_WL190_Segments diagnostics
---------------------------------------------------------------------------------------*/



select * from V_WL190_Segments where WL190seg_Sample_ID = 
 'W-21-0112-SO'
 --'W-21-1055-GS'
 --'W-21-1172-GS'
 --'W-20-0737-SO'
 --'W-20-1505-SO'
 --'W-19-1506-SO'
 --'W-19-1822-SO'
;




select * from Test_WL190_Segments;




/****************************************************************************************

 V_WL190_Segments

****************************************************************************************/


create or replace view V_WL190_Segments as 


/*---------------------------------------------------------------------------------------
  supporting_sql
---------------------------------------------------------------------------------------*/

with supporting_sql as (

     /*---------------------------------------------------------------------------------------
       
       https://keisan.casio.com/ (a very nice tool)
       https://keisan.casio.com/exec/system/1228460515 (Area of a circle Calculator)
       
       area = PI * r^2
       circumference = 2 * PI * r (or PI * diameter) not used
       
       from MTest, Lt_BWL190_B6.cpp, calcDens()
       
       mould diameter is specified as 4", so the radius is 2"
       1 inch   =  25.4 mm
       2 inches =  50.8 mm
       4 inches = 101.6 mm
       
     -----------------------------------------------------------*/

     select  MLT_1_Sample_WL900.sample_id
     
            ,3.1415926535                                      as PI
            ,453.592                                           as grams_per_pound
            ,0.0220462                                         as pounds_per_gram        -- 1 lb / 453.592 gm/lb = 0.0220462 (1 gm = 0.0220462 lbs)
            ,0.001                                             as kg_per_gram
            ,25.4                                              as mm_per_inch
            
            ,round((1 / power(12,3)),7)                        as cu_ft_per_cu_inch      -- 1/12^3 = 1/1728 = 0.0005787
            ,power(0.001,3)                                    as cu_mt_per_cu_mm        -- 0.001^3 = 0.000000001 (1 cu mm = 1/B cubic metre)
            
            ,2                                                 as mould_radius_inches
            ,50.8                                              as mould_radius_mm
            ,round((3.1415926535 * power(2,2)),7)              as mould_area_sq_inches   --   12.5663706
            ,round((3.1415926535 * power(50.8,2)),7)           as mould_area_sq_mm       -- 8107.3196655
            
            ,6.894757                                          as psi_to_kpa             -- pound force per sq inch to Kilo-pascal
            ,4.4482216526                                      as pounds_force_to_Newtons
            ,5000                                              as bar_factor             -- (10,000 / 2)
            
       from  MLT_1_Sample_WL900
)

/*---------------------------------------------------------------------------------------
  density_sql
---------------------------------------------------------------------------------------*/

,density_sql as (

     select sample_id                                          as density_sample_id
           ,segment_nbr                                        as density_segment_nbr
           
           ,density_final_height                               as density_final_height
           ,density_final_height - 2.5                         as density_ht_minus_2pt5 -- from ((dens_final_height - 2.5) / (dens_height_idx - 2.5))))
           
           -- const static double hvals[5] = { 2.5, 2.3, 2.4, 2.6, 2.7 }; (in inches)
           -- constant values used in calculations
           ,2.5                                                as density_hvals_idx0
           ,2.3                                                as density_hvals_idx1
           ,2.4                                                as density_hvals_idx2
           ,2.6                                                as density_hvals_idx3
           ,2.7                                                as density_hvals_idx4
           
           -- set the height index
           ,case when density_final_height >= 2.70 then  4     -- >= 2.7
                 when density_final_height  > 2.60 then -1     -- 2.60 to 2.70
                 when density_final_height  > 2.55 then  3     -- 2.55 to 2.60
                 when density_final_height  > 2.45 then  0     -- 2.45 to 2.55 -- the goldilocks
                 when density_final_height  > 2.40 then  2     -- 2.40 to 2.45
                 when density_final_height  > 2.30 then -1     -- 2.30 to 2.40
                 when density_final_height  >    0 then  1     -- <= 2.30
                 else -99                                      -- -99 will only occur when density_final_height is -1 (aka, null)
                 end                                           as density_height_idx
           
           -- set the high index where the height index is -1
           ,case when density_final_height  > 2.60 and density_final_height < 2.70 then 4
                 when density_final_height  > 2.30 and density_final_height < 2.40 then 1
                 else -99 end                                  as density_high_idx
           
           -- set the low index where the height index is -1
           ,case when density_final_height  > 2.60 and density_final_height < 2.70 then 3
                 when density_final_height  > 2.30 and density_final_height < 2.40 then 2
                 else -99 end                                  as density_low_idx
                 
       from Test_WL190_Segments
)

/*---------------------------------------------------------------------------------------
  main SQL
---------------------------------------------------------------------------------------*/

select  wl190seg.sample_id                                     as WL190seg_Sample_ID    -- key
       ,wl190seg.segment_nbr                                   as WL190seg_segment_nbr  -- key 
       ,wl190seg.mold_number                                   as WL190seg_mold_number
       ,wl190seg.exclude_segment                               as WL190seg_exclude_segment
       ,wl190.customary_metric                                 as WL190seg_customary_metric -- not used, me thinks
       
       /*---------------------------------------------------------------------------------------
         Sample preparation and moisture determination
       ---------------------------------------------------------------------------------------*/
       
       ,wl190seg.prep_mass_wet_soil                            as WL190seg_prep_mass_wet_soil
       ,wl190seg.prep_mass_dry_soil                            as WL190seg_prep_mass_dry_soil
       ,wl190seg.prep_mass_tare                                as WL190seg_prep_mass_tare
       ,moisture_pct_calculated                                as WL190seg_prep_moisture_pct
       
       ,wl190seg.prep_initial_height                           as WL190seg_prep_initial_height
       ,wl190seg.prep_initial_mass_dry                         as WL190seg_prep_initial_mass_dry
       ,wl190seg.prep_initial_mass_wet                         as WL190seg_prep_initial_mass_wet
       ,wl190seg.prep_secondary_moisture_pct                   as WL190seg_prep_secondary_moisture_pct
       ,wl190seg.prep_water_added                              as WL190seg_prep_water_added
       ,mass_sample_used_calculated                            as WL190seg_prep_mass_sample_used
       ,wl190seg.prep_desired_moisture_pct                     as WL190seg_prep_desired_moisture_pct
       
       /*---------------------------------------------------------------------------------------
         Kneading Compaction and Exudation pressure
       ---------------------------------------------------------------------------------------*/
       
       ,wl190seg.kneading_compactor                            as WL190seg_kneading_compactor
       ,wl190seg.kneading_blows                                as WL190seg_kneading_blows
       ,wl190seg.kneading_exudation_pressure                   as WL190seg_kneading_exudation_pressure
       ,Exudation_pressure_psi_calculated                      as WL190seg_Exudation_pressure_psi
       ,Exudation_pressure_kpa_calculated                      as WL190seg_Exudation_pressure_kpa
       
       /*---------------------------------------------------------------------------------------
         Density
       ---------------------------------------------------------------------------------------*/
       
       ,wl190seg.density_mass_mold_soil                        as WL190seg_density_mass_mold_soil
       ,wl190seg.density_mass_mold                             as WL190seg_density_mass_mold
       ,wl190seg.density_final_height                          as WL190seg_density_final_height
       ,dry_density_lbs_cuft_calculated                        as WL190seg_dry_density_lbs_per_cuft -- calc is off by a factor of 10, eg; 1231.2 should be 123.1
       ,dry_density_kgs_cu_metre_calculated                    as WL190seg_dry_density_kgs_per_cu_metre
       
       /*---------------------------------------------------------------------------------------
         density_sql values - are used to determine the Corrected Resistance value
         the index will determine which values to use from the MLT_Resistance_Value_Nomograph table
         the values below are not displayed in the window
       ---------------------------------------------------------------------------------------*/
       
       --,density_sql.density_final_height -- see wl190seg.density_final_height, immediately above
       ,density.density_height_idx
       ,density.density_high_idx
       ,density.density_low_idx
       ,density.density_ht_minus_2pt5
       
       /*---------------------------------------------------------------------------------------
         Expansion
       ---------------------------------------------------------------------------------------*/
       
       ,wl190.bar_calibration_factor                           as WL190seg_bar_calibration_factor
       ,wl190seg.expansion_frame_nbr                           as WL190seg_expansion_frame_nbr
       ,wl190seg.expansion_amount                              as WL190seg_expansion_amount
       ,expansion_psi_calculated                               as WL190seg_expansion_psi
       ,expansion_kpa_calculated                               as WL190seg_expansion_kpa
       
       /*---------------------------------------------------------------------------------------
         Stabilometer: PV - vertical pressure, PH - horizontal pressure
         stabilometer fields 5-7 were never assigned
       ---------------------------------------------------------------------------------------*/
       
       ,wl190seg.stabilometer_pv1                              as WL190seg_stabilometer_pv1
       ,wl190seg.stabilometer_ph1                              as WL190seg_stabilometer_ph1
       
       ,wl190seg.stabilometer_pv2                              as WL190seg_stabilometer_pv2
       ,wl190seg.stabilometer_ph2                              as WL190seg_stabilometer_ph2
       
       ,wl190seg.stabilometer_pv3                              as WL190seg_stabilometer_pv3
       ,wl190seg.stabilometer_ph3                              as WL190seg_stabilometer_ph3
       
       ,wl190seg.stabilometer_pv4                              as WL190seg_stabilometer_pv4
       ,wl190seg.stabilometer_ph4                              as WL190seg_stabilometer_ph4
       
       ,wl190seg.stabilometer_pv5                              as WL190seg_stabilometer_pv5
       ,wl190seg.stabilometer_ph5                              as WL190seg_stabilometer_ph5
       
       ,wl190seg.stabilometer_pv6                              as WL190seg_stabilometer_pv6
       ,wl190seg.stabilometer_ph6                              as WL190seg_stabilometer_ph6
       
       ,wl190seg.stabilometer_pv7                              as WL190seg_stabilometer_pv7
       ,wl190seg.stabilometer_ph7                              as WL190seg_stabilometer_ph7
       
       /*---------------------------------------------------------------------------------------
         R values, Resistance values
         rawrv = 100.0 - ( 100.0 / ( (2.5 / dturns)*((pv / ph) - 1.0) + 1.0) )
         D-turns: a measure of the revolutions of the handle associated with the hydraulic pump
       ---------------------------------------------------------------------------------------*/
       
       ,wl190seg.resistance_values_distance_turns              as WL190seg_Resistance_values_distance_turns
       ,rval.resistance_value_raw                              as rval_Resistance_Value_Raw
       ,wl190seg.resistance_values_thickness                   as WL190seg_Resistance_values_thickness
       
       -- the following fields are not for display
       ,rval.max_stabilometer_pv -- max pv-ph pair after comparison
       ,rval.max_stabilometer_ph -- use this pair for calculations
       
       ,rval.ph_comparison_flag  -- ' **** '
       
       ,rval.max_pv_tmp
       ,rval.max_pv_tmp_corresponding_ph
       
       ,rval.max_ph_tmp
       ,rval.max_ph_tmp_corresponding_pv 
       
       /*---------------------------------------------------------------------------------------
         V_WL190_Segments_Combined_Resistance_Nomograph
         resistance_value_raw lies between Resistance_value_low and Resistance_value_high
       ---------------------------------------------------------------------------------------*/
       
       -- same value as rval.resistance_value_raw, above, but use this one
       ,combined.resistance_value_raw                          as WL190seg_Resistance_Value_Raw
       ,corrected_R_value_calculated                           as WL190seg_Resistance_Value_Corrected
       
       ,first_interpolation 
       
       ,combined.Resistance_value_low
       ,combined.Resistance_value_high
       ,combined.R_value_high_minus_rval
       
       ,combined.index_1_low
       ,combined.index_2_low
       ,combined.index_3_low
       ,combined.index_4_low
       
       ,combined.index_1_high
       ,combined.index_2_high
       ,combined.index_3_high
       ,combined.index_4_high
       
       -- one sample, W-88-0267-AG, segment 3, contains mass of sample used w/o supporting data
       ,case when wl190seg.prep_captured_mass_sample_used >= 0 then wl190seg.prep_captured_mass_sample_used else -1 end 
        as captured_mass_sample_used

       /*---------------------------------------------------------------------------------------
         table relationships
       ---------------------------------------------------------------------------------------*/
 
       from MLT_1_Sample_WL900                                   smpl
       join Test_WL190                                          wl190 on wl190.sample_id      = smpl.sample_id
       join Test_WL190_Segments                              wl190seg on wl190.sample_id      = wl190seg.sample_id
       
       join supporting_sql                                            on smpl.sample_id       = supporting_sql.sample_id
       
       join density_sql                                       density on wl190seg.sample_id   = density.density_sample_id
                                                                     and wl190seg.segment_nbr = density.density_segment_nbr
                                                              
       join V_WL190_Segments_Resistance_Values                   rval on wl190seg.sample_id   = rval.rval_Sample_ID
                                                                     and wl190seg.segment_nbr = rval.rval_segment_nbr
       
       join V_WL190_Segments_Combined_Resistance_Nomograph   combined on wl190seg.sample_id   = combined.rval_sample_id
                                                                     and wl190seg.segment_nbr = combined.rval_segment_nbr

       /*---------------------------------------------------------------------------------------
         sample preparation
         
         from MTest, Lt_BWL190_ca_B6.cpp
         
         void BWL190::CorTblPrep::calcPrep(int xrow)
         {
           moisture determination, from MTest, Lt_BWL190_ca_B6.cpp, calcMD() 
           {
             if( tare > 0.0 )
             {
               if( wet > tare ) wet -= tare;
               if( dry > tare ) dry -= tare;
             }
             double md = ( dry > 0.0 && wet >= dry ) ? 100.0 * (wet - dry)/dry : -1; (moisture_pct_calculated)
           }
         
           mass of sample used, from MTest, Lt_BWL190_ca_B6.cpp, calcPrepWtused() 
           {
             md = calcPrepWtused(drywt, desmoist);
             weight used = dry wt * (1 + % desired moisture/100)
             return drywt*(1.0 + moisture/100.0);
           }
         
       ---------------------------------------------------------------------------------------*/
       
       cross apply (select case when (wl190seg.prep_mass_tare     > 0)          then (wl190seg.prep_mass_tare)
                                else 0 end as mass_tare from dual) tare 
       
       
       cross apply (select case when (wl190seg.prep_mass_wet_soil > mass_tare)  then (wl190seg.prep_mass_wet_soil - mass_tare) 
                                else 0 end as mass_wet  from dual) wet
       
       
       cross apply (select case when (wl190seg.prep_mass_dry_soil > mass_tare)  then (wl190seg.prep_mass_dry_soil - mass_tare) 
                                else 0 end as mass_dry  from dual) dry
       
       
       cross apply (select case when (mass_dry > 0 and mass_wet >= mass_dry)    then (((mass_wet - mass_dry) / mass_dry) * 100)
                                else -1 end as moisture_pct_calculated from dual) md
       
       
       cross apply (select case when (wl190seg.prep_initial_mass_dry > 0 and wl190seg.prep_desired_moisture_pct > 0)
                                then (wl190seg.prep_initial_mass_dry * (1.0 + (wl190seg.prep_desired_moisture_pct * 0.01)))
                                else -1 end as mass_sample_used_calculated from dual) mass_sample

       /*---------------------------------------------------------------------------------------
         Kneading Compaction and Exudation pressure
       ---------------------------------------------------------------------------------------*/
       
       cross apply (select case when (wl190seg.kneading_exudation_pressure >= 0) 
                                then (wl190seg.kneading_exudation_pressure / supporting_sql.mould_area_sq_inches)
                                else -1 end as Exudation_pressure_psi_calculated from dual) pressure_psi
       
       
       cross apply (select case when (wl190seg.kneading_exudation_pressure >= 0) 
                                then ((wl190seg.kneading_exudation_pressure / supporting_sql.mould_area_sq_inches) * psi_to_kpa)
                                else -1 end as Exudation_pressure_kpa_calculated from dual) pressure_kpa
       
       /*---------------------------------------------------------------------------------------
         Dry density calculations
         
         mass of soil = density_mass_mold_soil - density_mass_mold (in grams)
         height in mm = density_final_height * mm_per_inch (25.4 mm / inch)
         
         Dry Density from MTest, Lt_BWL190_ca_B6.cpp, calcDens()
         
         mMS,g: mass of mold + soil, grams
         mM, g: mass of mold, grams
         ht,in: final height, inches
         ht,mm: final height, mm
         DesiredMoisture: fractional %desired moisture, == (input%DesiredMoisture / 100)
         moldarea,in2: mold area, square mm (mold diameter is specified as 4")            PI * 4     ==> 12.56637
         moldarea,mm2: mold area, square mm (mold diameter is specified as 4" = 101.6mm)  PI * 101.6 ==> 319.1858136
         
         Customary: lbs/cuft = ((mmMs,g - mM,g)  * Kc ) / ( Kd * ht,in * moldarea,in2 * ( 1 + DesiredMoisture ) )
    
               Kc: a constant to convert grams to lbs ==> 1 lb  / 453.59 g   == 0.0220462 (lbs/gm)
               Kd: a constant to convert in3 to ft3   ==> 1 ft3 / (12^3 in3) == (1 / 1728)
               lbs/ft3 = ( (1/453.592) / (1/12^3 * 12.56637)) * (mMS,g - mM,g) / ( ht,in * (1 + DesiredMoisture) )
               lbs/ft3 = 0.303158 * (mMS,g - mM,g) / ( ht,in * (1 + DesiredMoisture))
               
         Metric: kg/m3 = (mass_of_soil_grams * ( kg/gm)) / (ht,mm * (101.6*PI)mm2 * 0.001^3 * (1 + moisture_pct)
       
               Ka: a constant to convert g to kg: g*0.001 ==> kg;
               Kb: a constant to convert mm3 to m3: mm * 0.001 ==> m, mm3 * 0.000000001 ==> m3; // 1 cu mm = 1/B cu M
               kg/m3 = (mMS,g - mM,g) * 0.001 / (ht,mm * (101.6*PI)mm2 * 0.001^3 * ( 1 + Desired Moisture )
         
         Dry Density, my calculations:
         Customary: lbs/cuft = (mass_of_soil_grams * pounds_per_gram) / ((ht,in * cu_ft_per_cu_inch) * (mould_area_sq_inches) * (1 + prep_desired_moisture_pct/100))    
         Metric:       kg/m3 = (mass_of_soil_grams * kg_per_gram)     / ((ht,mm * cu_mt_per_cu_mm)   * (mould_area_sq_mm)     * (1 + prep_desired_moisture_pct/100))
       
       ---------------------------------------------------------------------------------------*/
       
       cross apply (select case when (wl190seg.density_mass_mold_soil  > 0)     then wl190seg.density_mass_mold_soil
                                else 0 end as mass_mold_and_soil                from dual) mass1
       
       
       cross apply (select case when (wl190seg.density_mass_mold       > 0)     then wl190seg.density_mass_mold
                                else 0 end as mass_mold                         from dual) mass2
       
       
       cross apply (select case when (mass_mold_and_soil >= mass_mold)          then (mass_mold_and_soil - mass_mold)
                                else 0 end as mass_of_soil_grams_calculated     from dual) mass3
       
       /*---------------------------------------------------------------------------------
         RE: mass_of_soil_grams_calculated (above)
         why would mass_mold be > mass mass_mold_and_soil?
         there are approx 2700 of 12700 records where mass_mold > mass mass_mold_and_soil (~21%) 
         this cannot be right
         W-02-0061-SO and W-04-0991-SO are the only two post 2000, 
         the others are 1991 and before, so not going to worry about it, for now
       ---------------------------------------------------------------------------------*/
       
       --- this calculation is off by a factor of 10
       cross apply (select case when mass_of_soil_grams_calculated      > 0 and 
                                     wl190seg.density_final_height      > 0 and 
                                     wl190seg.prep_desired_moisture_pct > 0
       
                                then  (mass_of_soil_grams_calculated * supporting_sql.pounds_per_gram) / 
                                     ((wl190seg.density_final_height * supporting_sql.cu_ft_per_cu_inch) * 
                                      (supporting_sql.mould_area_sq_inches) * (1 + (wl190seg.prep_desired_moisture_pct * 0.01)))
                                
                                else -1 end as dry_density_lbs_cuft_calculated  from dual) density_customary
       
       
       cross apply (select case when wl190seg.density_final_height > 0 
                                then wl190seg.density_final_height * mm_per_inch
                                else -1 end as density_final_height_in_mm       from dual) final_ht_mm
       
       
       cross apply (select case when mass_of_soil_grams_calculated      > 0 and 
                                     density_final_height_in_mm         > 0 and 
                                     wl190seg.prep_desired_moisture_pct > 0
       
                                then (mass_of_soil_grams_calculated * supporting_sql.kg_per_gram) / 
                                     ((density_final_height_in_mm * supporting_sql.cu_mt_per_cu_mm) * 
                                      (supporting_sql.mould_area_sq_mm) * (1 + (wl190seg.prep_desired_moisture_pct * 0.01)))
                                
                                else -1 end as dry_density_kgs_cu_metre_calculated from dual) density_metric
       
       /*---------------------------------------------------------------------------------------
       
         Expansion - from MTest, Lt_BWL190_ca_B6.cpp, calcExpan()
         
         expansion in PSI = expansion in inches * 10,000 / 2
         For every unit of upward movement, it will take one inch of cover soil weighing 130 lbs/cuft 
         to counterbalance the upward movement
         
         P = k * d 
         
         where: 
         P = expansion pressure, PSI
         
         k = a constant (10,000 / 2) related to the stiffness of the steel bar that is bowed upward by the upward pressure
         the 10,000 converts the input 'd' from inches to ten thousandths of an inch
         the 2 indicates that the steel bar has been calibrated so that two ten-thousandths of an inch is 'one unit of upward movement'
         
         d = the upward movement of the bowed bar, in inches. The gage reads in ten thousandths of an inch
         If d is in mm, a constant 13572.35630 gives a kPa to RS's constant with English input and output
         
         Valid Dial readings (expansion_amount) are 0.0 and up
         Values < 0.0004 are considered "No Expansion"
         -1.0 is taken as a legal value (giving "N/Exp") because it is the RADB flag value for "N/Exp"
         
         -100 is the valid value for 'null', no expansion amount was assigned. this is my addition
         
         if (dial >= limit) // 0.0004 inches or 0.01016 mm (0.0004 * 25.4 mm/inch)
         I have not found any samples that have been designated as metric
         
         select distinct(bar_calibration_factor), count(bar_calibration_factor) 
           from Test_WL190
          group by (bar_calibration_factor) -- this is the 'k' from above
         
         bar_calibration_factor  count(bar_calibration_factor)
         5000	                    4001
         10000.02	                   2
         0	                          34
       ---------------------------------------------------------------------------------------*/
       
       cross apply (select case when wl190seg.expansion_amount >= 0.0004 
                                then to_char(round(wl190seg.expansion_amount * supporting_sql.bar_factor))
                                when wl190seg.expansion_amount  = -1     then 'N/Exp'
                                when wl190seg.expansion_amount  = -100   then ' '
                                else '0' end as expansion_psi_calculated from dual) expansion_psi
       
       
       cross apply (select case when wl190seg.expansion_amount >= 0.0004 
                                then to_char(round(wl190seg.expansion_amount * supporting_sql.bar_factor * supporting_sql.psi_to_kpa))
                                when wl190seg.expansion_amount  = -1     then 'N/Exp'
                                when wl190seg.expansion_amount  = -100   then ' '
                                else '0' end as expansion_kpa_calculated from dual) expansion_kpa
       
       /*---------------------------------------------------------------------------------------
         find Resistance Value first interpolation
         from MTest, Lt_BWL190_ca_B6.cpp, rvnomograph()
           calc += 25.0 * (height - 2.5) * sin(PI * rawrv / 100.0);
         R value = R value + ( 25.0 * (height - 2.5) * sin(PI * rawrv / 100.0));
         
         (first_interpolation - (
         (corr[cx][hx] - ( (corr[cx][hx] - corr[px][hx]) * (corr[cx][0] - rawrv) / (corr[cx][0] - corr[px][0]) ) ) * (height - 2.5) / (hvals[hx] - 2.5))
   
       ---------------------------------------------------------------------------------------*/
       
       cross apply (select case
        when density.density_height_idx = 0 then combined.resistance_value_raw
        else (combined.resistance_value_raw + (25.0 * (density.density_ht_minus_2pt5) * sin(PI * combined.resistance_value_raw * 0.01) ) )
         end as first_interpolation from dual) first_interp
       
       /*---------------------------------------------------------------------------------------
         from MTest, Lt_BWL190_ca_B6.cpp, rvnomograph()
       
         double interpolation
         --------------------
         hiadj = corr[cx][hix] - (corr[cx][hix] - corr[px][hix]) * (corr[cx][0] - rawrv) / (corr[cx][0] - corr[px][0]);
         loadj = corr[cx][lox] - (corr[cx][lox] - corr[px][lox]) * (corr[cx][0] - rawrv) / (corr[cx][0] - corr[px][0]);
         adj = loadj + (hiadj - loadj) * (height - hvals[lox]) / (hvals[hix] - hvals[lox]);
         first_interpolation - adj
         
         from density_sql:
         
         ,case when density_final_height  > 2.60 and density_final_height < 2.70 then 4
               when density_final_height  > 2.30 and density_final_height < 2.40 then 1
               else -99 end as dens_high_idx
         
         ,case when density_final_height  > 2.60 and density_final_height < 2.70 then 3
               when density_final_height  > 2.30 and density_final_height < 2.40 then 2
               else -99 end as dens_low_idx
        
         because dens_high_idx and dens_low_idx are based upon density_final_height,
         they pair as index 4 high with index 3 low, and index 1 high with index 2 low
       ---------------------------------------------------------------------------------------*/
      
       cross apply (select 
       case when density.density_high_idx = 4 then (combined.index_4_high - ((combined.index_4_high - combined.index_4_low) * combined.R_value_high_minus_rval / 5))
            when density.density_high_idx = 1 then (combined.index_1_high - ((combined.index_1_high - combined.index_1_low) * combined.R_value_high_minus_rval / 5))
            else -99 end as calc_hi_adj from dual) hiadj
      
      
       cross apply (select 
       case when density.density_low_idx = 3 then (combined.index_3_high - ((combined.index_3_high - combined.index_3_low) * combined.R_value_high_minus_rval / 5))
            when density.density_low_idx = 2 then (combined.index_2_high - ((combined.index_2_high - combined.index_2_low) * combined.R_value_high_minus_rval / 5))
            else -99 end as calc_lo_adj from dual) loadj
      
      
       cross apply (select 
       case when density.density_high_idx = 4 and density.density_low_idx = 3 
            then  calc_lo_adj + (calc_hi_adj - calc_lo_adj) * (wl190seg.density_final_height - density.density_hvals_idx3) / (density.density_hvals_idx4 - density.density_hvals_idx3)  
        
            when density.density_high_idx = 1 and density.density_low_idx = 2 
            then  calc_lo_adj + (calc_hi_adj - calc_lo_adj) * (wl190seg.density_final_height - density.density_hvals_idx2) / (density.density_hvals_idx1 - density.density_hvals_idx2)
        
            else -99 end as adjusted_calc from dual) calcadj
       
       /*---------------------------------------------------------------------------------------
         
         from MTest, Lt_BWL190_ca_B6.cpp, rvnomograph()
         
         find corrected Resistance Value (R-value)
         when dens_height_idx = 0        // no corrections are necessary
         when dens_height_idx = 1,2,3,4  // single interpolation
         when dens_height_idx = -1       // double interpolation
         
         double interpolation:
         hiadj = corr[cx][hix] - (corr[cx][hix] - corr[px][hix]) * (corr[cx][0] - rawrv) / (corr[cx][0] - corr[px][0]);
         loadj = corr[cx][lox] - (corr[cx][lox] - corr[px][lox]) * (corr[cx][0] - rawrv) / (corr[cx][0] - corr[px][0]);
         adj = loadj + (hiadj - loadj) * (height - hvals[lox]) / (hvals[hix] - hvals[lox]);
         first_interpolation - adj
       ---------------------------------------------------------------------------------------*/
       
       cross apply (select case
       
       when density.density_height_idx =  0 then combined.resistance_value_raw -- no correction
       
       when density.density_height_idx =  1 then 
       (first_interpolation - 
        ( (index_1_high - ( (index_1_high - index_1_low) * combined.R_value_high_minus_rval / 5) ) * (density.density_ht_minus_2pt5  / (density.density_height_idx - 2.5) ) )
       )
  
       when density.density_height_idx =  2 then 
       (first_interpolation -
        ( (index_2_high - ( (index_2_high - index_2_low) * combined.R_value_high_minus_rval / 5) ) * (density.density_ht_minus_2pt5 / (density.density_height_idx - 2.5) ) )
       )
  
       when density.density_height_idx =  3 then 
       (first_interpolation - 
        ( (index_3_high - ( (index_3_high - index_3_low) * combined.R_value_high_minus_rval / 5) ) * ( density.density_ht_minus_2pt5 / (density.density_height_idx - 2.5) ) )
       )
  
       when density.density_height_idx =  4 then 
       (first_interpolation - 
        ( (index_4_high - ( (index_4_high - index_4_low) * combined.R_value_high_minus_rval / 5) ) * ( density.density_ht_minus_2pt5 / (density.density_height_idx - 2.5) ) )
       )
       
       -- double interpolation
       when density.density_height_idx = -1 then (first_interpolation - adjusted_calc)
       
       else -1 end 
       
       as corrected_R_value_calculated from dual) corr_rvalue  
         
  order by 
  wl190seg.sample_id, 
  wl190seg.segment_nbr
 ;









---------------------------------------------------------------
-- diagnostics
---------------------------------------------------------------



select count(*) from Test_WL190_Segments; -- approx 12700




select wl190.sample_id, 
       wl190.sample_year, 
       seg.segment_nbr,
       seg.resistance_values_distance_turns
  from Test_WL190_Segments seg, Test_WL190 wl190
 where seg.sample_id = wl190.sample_id
   and seg.resistance_values_distance_turns < 0
 order by 
 wl190.sample_year desc,
 wl190.sample_id,
 seg.segment_nbr
;



select * from Test_WL190_Segments where density_mass_mold_soil < density_mass_mold;



select count(*) from Test_WL190_Segments where density_mass_mold_soil < density_mass_mold; -- 2727



select count(*) from Test_WL190_Segments where prep_mass_tare <= 0;



select * from Test_WL190_Segments where prep_water_added <= 0;
 



select wl190.sample_id, wl190.sample_year, wl190seg.expansion_amount, wl190.bar_calibration_factor, substr(wl190.customary_metric,6,1)

  from Test_WL190            wl190
  join Test_WL190_Segments   wl190seg on wl190.sample_id = wl190seg.sample_id
  
  --where wl190seg.expansion_amount > 0.001
  --where wl190seg.expansion_amount < 0 and wl190seg.expansion_amount <> -1
  --where wl190.bar_calibration_factor < 100
  
  order by wl190.sample_year desc
;




select distinct(bar_calibration_factor), count(bar_calibration_factor) from Test_WL190
 group by (bar_calibration_factor)
;
/**
factor      count
5000	    4013
10000.02	2
0	        34
**/




select count(*) from Test_WL190_Segments where expansion_amount = -1; -- 5876



select distinct(expansion_amount) from Test_WL190_Segments order by expansion_amount;




select distinct(expansion_frame_nbr) from Test_WL190_Segments order by expansion_frame_nbr;









