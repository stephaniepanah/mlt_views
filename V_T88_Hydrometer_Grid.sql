


select * from V_T88_Hydrometer_Grid where T88_Hydrometer_sample_id 
    in ( 'W-20-0785-SO' ,'W-19-0007-SO', 'W-21-0010-SO', 'W-18-0124-SO')
 order by 
 T88_Hydrometer_sample_id,
 T88_Hydrometer_segment_nbr
;



select * from V_T88_Hydrometer_grid 
--'W-19-0007-SO'
;

-- ORA-01428: argument '-.0019810188456' is out of range
-- 01428. 00000 -  "argument '%s' is out of range"



/***********************************************************************************

 Test_T88_Hydrometer
  
 snippets from MTest, LT_T88ut_BC.cpp           // my notes 
 
 HydroCalcs::run()                              // driver function for the Hydrometer grid
 {
    doCalcsPrelim(ffactor, xten);               // ffactor (fine factor?), index of #10
    
    double pfactor = _tblPp[xten].pp / _ds;     // pfactor (passing factor?) = (pp#10 / soil DS)
    
    doCalcsHydroTbl(pfactor, eh);               // passing factor, last valid hydrometer calc
    
    doCalcsGrad(ffactor, eh, xten + 1);         // used for the pct passing grid
 }
 
 HydroCalcs::doCalcsPrelim(double &ffactor, int &xten)
 {
    adjten = _tenret * _cpan / _thw;            // adjusted #10, sieved from the total hydr wt subsample
    
    adjfwt = _moisture * (_cpan - adjten);      // adjust fine weight to total sample size
    
    double factor = adjten + adjfwt;            // poor variable name, really is adjusted total sample weight
    
    for (xr = 0; xr < _nrCse; ++xr)             // add total coarse sieves mass retained to adjten and adjfwt
		 factor += _tblCse[xr].mr;              // to obtain the adjusted total sample weight (aka factor, but it isn't)
    
    factor = 100.0 / factor;                    // NOW it is factor, and = 100 / adjusted total sample weight
                                                // I am naming this t88_calc_factor
    
    tmp = 100.0;                                // used for calculating percent passing, begin at 100%
    tmp -= (_tblCse[xpp].mr * factor);          // find pct passing for each coarse mass retained
                                                // not doing this here, will do so in the Pct Passing grid
                                               
    pp#4 =                                      // to calculate pct passing #4, simply use total coarse mass, so...
    (100 - (sum coarse mass * t88_calc_factor)) // <--- my calculation
                                                // tmp, at this point, is equivalent to pp#4
                                                
    xten = xpp;                                 // set index of 10 to xpp + 1 (from the for loop, not shown here)
    _tblPp[xten].pp = tmp - (adjten * factor);  // pct passing #10 (from #10+ of Total hydrometer sample, recast)
                                                // pp#10 = pp#4 - (adjten * t88_calc_factor) <-- my calculation
                                                
    ffactor = factor * adjfwt / _ds;            // factor for fines, hydrometer does not uses this, but what the heck
                                                // used for the percent passing grid
                                                
    // these notes below are from the code
    // percents passing below #10: sieving is of 'jar' soil, so results must be recast to total
    // factor for fines = (100.0/totalAdjustedSampleWt)* (totalAdj#10-/wtJar
    // ffactor = factor * adjfwt / _ds;
 }
 
 
 HydroCalcs::doCalcsHydroTbl(double pfactor, int &eh)
 {
    // afactor = (((2.65 - 1)/2.65) * SG) / (SG - 1)
	afactor = 0.622642*_sg / (_sg - 1.0);       // calculate A-Factor
    
	pfactor *= afactor;                         // why this? very confusing. no need for an additional step
                                                // this is only used for recast, so using
                                                // recast = pfactor * afactor * corrected HR (see recast below)
                                                // recall that pfactor is pp#10 / _ds (not changing this)
    
    factor = (30.0 / (980.0*(_sg - 1.0)));      // for calc'ing diameter <-- notes from the code
                                                // another poor variable name. using diameter_factor = ....
                                                // Until I figured it out, I thought that this factor was 
                                                // the same factor as in doCalcsPrelim. good grief
    
    
	for (xh = 0; xh < _nrHydro; xh++)           // For loop to begin assembling the Hydrometer row
    {
      _tblHydro[xr].time = time;                // user entered values
      _tblHydro[xr].temp = temp;
      _tblHydro[xr].hr = reading;
    
      double fahren = _tblHydro[xh].temp;
      if (Celsius) fahren = 32.0 + 1.8*fahren;  // convert to Fahrenheit if in celsius
      double vis = viscosity(fahren);
      
      _tblHydro[xh].len                         // hydrometer length, calculated     
      = (16.294 - (0.164 * _tblHydro[xh].hr));
      
      _tblHydro[xh].diam =                      // particle diameter = sqrt( 30nL / (980*T*(SG - SGf)) )
      sqrt ( factor * vis * _tblHydro[xh].len / _tblHydro[xh].time ); // factor is diameter_factor
      
      _tblHydro[xh].cc = getHydrocorr(fahren);  // composite correction
      
      _tblHydro[xh].chr =                       // corrected hydrometer reading
      _tblHydro[xh].hr - _tblHydro[xh].cc;
      
      _tblHydro[xh].recast =                    // recast = corrected HR * pfactor * afactor
      _tblHydro[xh].chr * pfactor;              // see pfactor, above
 }
 
 
 -- doCalcsGrad is for the percent passing grid, not hydrometer
 
 HydroCalcs::doCalcsGrad(double factor, int eh, int bPpFine) // how utterly confusing, passing ffactor
                                                             // but naming it factor in the arguments
                                                             // btw, bPpFine is 'beginning pct passing fines'
                                                             // which is pp#10 + 1. ...good freakin' grief
 
***********************************************************************************/


create or replace view V_T88_Hydrometer_Grid as 

with T88_hydr_sql as (
 
     /*----------------------------------------------------------------------------------
      this Common Table Expression (CTE), t88_hydr_sql, will join Test_T88_hydrometer to itelf
      
      Using the Test_T88_hydrometer.temperature, obtain the:
      1- temperature in Fahrenheit
      2- viscosity index, which is used to obtain the MLT_Viscosity.viscosity_value
      3- hydrometer correction index, which is used to obtain the 
         MLT_Hydrometer_Corrections.correction_index, which returns the composite_correction
     ----------------------------------------------------------------------------------*/
            
          select sample_id    as sample_id
                ,segment_nbr  as segment_nbr
                
                ,case when temperature  = -1 then -1           -- no temperature listed
                      when temperature >= 40 then temperature  -- already Fahrenheit
                      else ((temperature * 1.8) + 32.0)        -- Celsius to Fahrenheit
                       end as temperature_fahrenheit
                      
                ,case when temperature  = -1 then -1
                
                      when temperature >= 40
                      then case when round(temperature) >= 65 and round(temperature) <= 75
                                then round(temperature) - 65.0
                                else -1 end
                 
                      else round(((temperature * 1.8) + 32.0) - 65) -- Celsius to Fahrenheit
                      
                      -- will need to make some corrections for outlier values
                      
                      end as viscosity_index
                      
                ,case when temperature  = -1 then -1
                      when temperature >= 40 then round((temperature - 65.0) * 2.0)
                      else round( ( ((temperature * 1.8) + 32.0) - 65) * 2.0)
                      end as correction_index
                   
            from Test_T88_hydrometer
 )

/*----------------------------------------------------------------------------------
  main sql
----------------------------------------------------------------------------------*/

select  t88hydr.sample_id                                      as T88_Hydrometer_sample_id   -- key
       ,t88hydr.segment_nbr                                    as T88_Hydrometer_segment_nbr -- key
       
       /*---------------------------------------------------------------------------------
         the Hydrometer Grid
       ---------------------------------------------------------------------------------*/
       
       ,t88hydr.hydrometer_scale                               as T88_Hydrometer_Scale -- Standard or WSDOT
       ,t88hydr.time_elapsed                                   as T88_Hydrometer_Time_elapsed
       ,t88hydr.temperature                                    as T88_Hydrometer_Temperature
       ,t88hydr.hydrometer_reading                             as T88_Hydrometer_Reading
       ,corrected_hydrometer_reading                           as T88_Hydrometer_Reading_Corrected
       ,composite_correction                                   as T88_Hydrometer_composite_correction
       ,Percent_Recast                                         as T88_Hydrometer_Percent_Recast
       ,particle_diameter                                      as T88_Hydrometer_Particle_diameter
       ,Hydrometer_length                                      as T88_Hydrometer_Length
       
       /*---------------------------------------------------------------------------------
         the values listed below are used in calculations
       ---------------------------------------------------------------------------------*/
       
       /*---------------------------------------------------------------------------------
         Diameter values
       ---------------------------------------------------------------------------------*/
       
       ,diameter_factor                                        as T88_Hydrometer_diameter_factor
       --,log10_particle_diameter                                as T88_Hydrometer_log10_particle_diameter
       
       /*---------------------------------------------------------------------------------
         from the t88_hydr_sql
       ---------------------------------------------------------------------------------*/
       
       ,t88_hydr_sql.temperature_fahrenheit                    as T88_Hydrometer_temperature_fahrenheit
       ,t88_hydr_sql.viscosity_index                           as T88_Hydrometer_viscosity_index
       ,vis.viscosity_value                                    as T88_Hydrometer_viscosity_K_value
       ,t88_hydr_sql.correction_index                          as T88_Hydrometer_correction_index
       
       /*---------------------------------------------------------------------------------
         from V_T88_Analysis_Particle_Size_Soils
       ---------------------------------------------------------------------------------*/
       
       ,V_T88.T100_Apparent_Specific_Gravity
       ,V_T88.T88_A_Factor       
       ,V_T88.T88_pfactor_for_recast
       
       /*---------------------------------------------------------------------------------
         Table relationships
       ---------------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       
       join V_T88_Analysis_Particle_Size_Soils           V_T88 on V_T88.T88_sample_id  = smpl.sample_id
       
       join Test_T88_hydrometer                        t88hydr on t88hydr.sample_id    = V_T88.T88_sample_id
       
       join T88_hydr_sql                                       on t88hydr.sample_id    = T88_hydr_sql.sample_id  
                                                              and t88hydr.segment_nbr  = T88_hydr_sql.segment_nbr
                                                                
       join MLT_Hydrometer_Corrections                     cor on cor.correction_index = t88_hydr_sql.correction_index
       
       join MLT_Viscosity                                  vis on vis.viscosity_index  = t88_hydr_sql.viscosity_index
       
       /*---------------------------------------------------------------------------------
         obtain the correct hydrometer correction value based upon
         the t88hydr.hydrometer_scale
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when t88hydr.hydrometer_scale = 'Standard' 
                                then cor.Standard
                                else cor.WSDOT
                                 end as composite_correction from dual) comp_corr
       
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T88ut_BC.cpp, doCalcsHydroTbl
         
         _tblHydro[xh].chr = _tblHydro[xh].hr - _tblHydro[xh].cc;
         
         if (_tblHydro[xh].chr < 0.0) _tblHydro[xh].chr = 0.0;
         
         corrected_hydr_reading = (t88hydr.hydrometer_reading - cor.hydrometer_value)
         hydrometer length is derived directly from the reading
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (t88hydr.hydrometer_reading - composite_correction >= 0)
                                then (t88hydr.hydrometer_reading - composite_correction)
                                else -1
                                 end as corrected_hydrometer_reading from dual) corr_HR
       
       cross apply (select  (16.294 - (0.164 * t88hydr.hydrometer_reading))
                   --round ((16.294 - (0.164 * t88hydr.hydrometer_reading)),2)
                        as Hydrometer_length from dual) hydr_length
  
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T88ut_BC.cpp, HydroCalcs::run()    
         double pfactor = _tblPp[xten].pp / _ds;
         doCalcsHydroTbl(pfactor, eh); used to calculate recast
         recast = corrected HR * pfactor * afactor
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when (corrected_hydrometer_reading > 0 and
                                      V_T88.T88_pfactor_for_recast > 0 and 
                                      V_T88.T88_A_Factor > 0)
                                      
                                then (corrected_hydrometer_reading * V_T88.T88_pfactor_for_recast * T88_A_Factor)
                                else -1 
                                 end as Percent_Recast from dual) pct_recast
  
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T88ut_BC.cpp, doCalcsHydroTbl
         factor = (30.0 / (980.0 * ( _sg - 1.0 )));
         _tblHydro[xh].diam = sqrt(factor * vis * _tblHydro[xh].len / _tblHydro[xh].time);
       ---------------------------------------------------------------------------------*/
       
       cross apply (select (30.0 / (980.0 * (V_T88.T100_Apparent_Specific_Gravity - 1.0)))
                        as diameter_factor from dual) diameterfactor
       
       cross apply (select sqrt((diameter_factor * vis.viscosity_value * Hydrometer_length / t88hydr.time_elapsed))
                        as particle_diameter from dual) particlediameter
       
       --cross apply (select log(10, particle_diameter) as log10_particle_diameter from dual) diameterlog
       
       order by 
       t88hydr.sample_id,  -- key
       t88hydr.segment_nbr -- key
;









select * from MLT_Viscosity;
/****
index   value
0	    0.01052
1	    0.01037
2	    0.01024
3	    0.01009
4	    0.00994
5	    0.00982
6	    0.00968
7	    0.00956
8	    0.00943
9	    0.00931
10	    0.00918
****/



select * from MLT_Hydrometer_Corrections;
/****
index   fahrenheit  standard    WSDOT
0	    65	        7.62	    4
1	    65.5	    7.51    	4
2	    66	        7.38    	4
3	    66.5	    7.29    	4
4	    67	        7.16    	4
5	    67.5	    7.07	    4
6	    68	        6.94	    4
7	    68.5	    6.85	    4.01
8	    69	        6.72	    4.01
9	    69.5	    6.63	    4.01
10	    70	        6.49	    4.01
11	    70.5	    6.41	    4.01
12	    71	        6.27	    4.01
13	    71.5	    6.19	    4.01
14	    72	        6.05	    4.01
15	    72.5	    5.97	    4.01
16	    73	        5.83	    4.01
17	    73.5	    5.75	    4.01
18	    74	        5.61	    4.01
19	    74.5	    5.53	    4.01
20	    75	        5.38	    4.01
****/





  
  


