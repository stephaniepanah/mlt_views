

-- T100 Specific Gravity of Soils (current)
-- WL100 Apparent Specific Gravity, Aggregate (current)



select * from V_T100_Specific_Gravity_of_Soils where T100_Sample_ID = 'W-19-0007-SO';



select * from V_T100_Specific_Gravity_of_Soils order by T100_sample_year desc, T100_sample_ID;



desc V_T100_Specific_Gravity_of_Soils;



select count(*), min(sample_year), max(sample_year) from Test_T100 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 9019	    1983	2021



select customary_metric, count(customary_metric), min(sample_year), max(sample_year) 
  from Test_T100
 where sample_year not in ('1960','1966')
 group by (customary_metric)
 order by (customary_metric)
 ;

/*-------------------------------------
        count   minYr   maxYr
' ' 	4569	1983	2003
C	     646	2000	2011
M	    3804	2001	2021
-------------------------------------*/


/*--------------------------------------------------------------------------------

 I will have to make some assumptions, based upon temperature, I guess

 I chose 40 as that seemed to be a good place to make the distinction
 between celsius & fahrenheit when looking at T100 temperatures
 
 Celsius is in the range of 18-30 degrees
 Fahrenheit temperatures are 70-ish

 W-11-1455-SO	M	140  <--- these two temperatures are not even in the range of Fahrenheit,
 W-01-0372-SO	M	110  <--- so use the ternary operation, below, because they are M(etric)

 if (fcalor < 18.0 || fcalor > 30.0) 
     calor = (fcalor < 18.0) ? 18 : 30; // force the value into range

--------------------------------------------------------------------------------*/



select * from test_t100 where temperature = -1 order by sample_year; 
-- 2695 samples
-- when blank (-1) default celsius temperature is 20C
-- why even bother with customary_metric? just use the temperature



select * from MLT_Relative_Density;



/***********************************************************************************

 T100 Specific Gravity of Soils
 W-19-1460-SO, W-18-0124-SO, W-18-0125-SO, W-18-0196-SO, W-18-0204-SO
 
 CustomaryOrMetric
 -----------------
 
 [0]: M: metric (Centigrade) | C customary (Fahrenheit)
 W-18-0124-SO |M| Metric,    Temperature, Celsius
 W-11-0023-SO |C| Customary, Temperature, Fahrenheit

 ---------------------------------------------------------------

 using W-19-1460-SO |M| in the following example
 for Mass of Displaced Water and Apparent Specific Gravity

 ---------------------------------------------------------------

 from MTest, Lt_T100_B9.cpp

 -----------------------------
  Mass of Displaced Water
 -----------------------------

 if (flaskwater > 0.0 && soil > 0.0 && flasksoil > soil)
 {
  if (!ismetric) // convert fahrenheit to centigrade
      fcalor = (5.0*(fcalor - 32.0) / 9.0);
     
  fcalor = roundEven(fcalor);

  if (fcalor < 18.0 || fcalor > 30.0)
      calor = (fcalor < 18.0) ? 18 : 30; // force the value into range
  else
      calor = (int)fcalor;

  // default temperature (celsius), if blank
  calor = 20;

  displaced = (flaskwater + soil  - flasksoil)
       9.21 = (177.03     + 25.22 - 193.04)
   --- 9 (on the screen) not 9.21, but 9.21 is used in the calculation

 -----------------------------
  Apparent Specific Gravity
 -----------------------------

  if (displaced != 0.0)
     asg   = ( soil / displaced) * relative density   (temperature in C)
     2.736 = (25.22 / 9.21)      * 0.9993             (see 23.0, in the table below)

 } // end --- if (flaskwater > 0.0 && soil > 0.0 && flasksoil > soil)


 if customary_metric is |C| (customary) then temperature is Fahrenheit
 convert to metric centigrade
 centigrade = (Fahrenheit - 32.0) * 5/9

 using temperature_centigrade, select the relative_density from MLT_Relative_Density;

 temperature_centigrade relative_density
    18	                1.0004
    19                  1.0002
    20                  1.0000 <---- 1.0
    21                  0.9998
    22                  0.9996
    23                  0.9993 <---- example above
    24                  0.9991
    25                  0.9989
    26                  0.9986
    27                  0.9983
    28                  0.9980
    29                  0.9977
    30                  0.9974

 four samples, precision to 2 decimal places. is this right?
 W-09-0629-SO	75.02
 W-14-1505-SO	20.08
 W-19-1615-SO	22.01
 W-19-1822-SO	21.02

***********************************************************************************/


create or replace view V_T100_Specific_Gravity_of_Soils as 


with celsius_sql as (

/*------------------------------------------------------------------------------
  temperature_celsius, needed to obtain relative density and specific gravity
------------------------------------------------------------------------------*/
  
select sample_id as sampleid,
     
       case when temperature =  -1 then 20                 -- no temperature, default to 20 celsius
            when temperature = 140 then 30                 -- W-11-1455-SO	M, 140 is off the charts, max celsius is 30
            when temperature = 110 then 30                 -- W-01-0372-SO	M, 110 is off the charts, max celsius is 30
            when temperature <  40 then round(temperature) -- already celsius, round to a whole number
            else round((temperature - 32.0) * 5/9)         -- Fahrenheit to Celsius
            end as temperature_celsius
            
  from Test_T100
)

/*------------------------------------------------------------------------------
  main sql
------------------------------------------------------------------------------*/
select  t100.sample_id                                         as T100_Sample_ID
       ,t100.sample_year                                       as T100_Sample_Year
       ,t100.test_status                                       as T100_Test_Status
       ,t100.tested_by                                         as T100_Tested_by
       
       ,case when to_char(t100.date_tested, 'yyyy') = '1959'   then ' '
             else to_char(t100.date_tested, 'mm/dd/yyyy')      end
                                                               as T100_date_tested
            
       ,t100.date_tested                                       as T100_date_tested_DATE
       ,t100.date_tested_orig                                  as T100_date_tested_orig
       
       ,t100.customary_metric                                  as T100_customary_metric
       
       ,t100.mass_flask_and_water                              as T100_Mass_of_Flask_and_Water
       ,t100.mass_soil                                         as T100_Mass_of_Soil
       ,t100.mass_flask_and_soil                               as T100_Mass_of_Flask_and_Soil
       ,t100.temperature                                       as T100_Temperature
       ,mass_displaced_water                                   as T100_Mass_of_Displaced_Water
       ,apparent_specific_gravity                              as T100_Apparent_Specific_Gravity
       
       ,t100.remarks                                           as T100_Remarks
    
       ,celsius_sql.temperature_celsius                        as T100_temperature_celsius -- not for display, used for calculations
       ,rd.relative_density                                    as T100_relative_density    -- not for display, used for calculations
       
       /*-------------------------------------------------------------
         table relationships
       -------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       
       join Test_T100                                     t100 on t100.sample_id = smpl.sample_id
       
       join celsius_sql                                        on t100.sample_id = celsius_sql.sampleid
       
       join MLT_relative_density                            rd on rd.temperature_centigrade = celsius_sql.temperature_celsius
       
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T100_B9.cpp, doCalcs() Mass of Displaced Water
         if(flaskwater > 0.0 && soil > 0.0 && flasksoil > soil)
            displaced = (flaskwater + soil - flasksoil)
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when t100.mass_flask_and_water > 0 and 
                                     t100.mass_soil            > 0 and
                                     t100.mass_flask_and_soil  > t100.mass_soil
                                then (t100.mass_flask_and_water + t100.mass_soil - t100.mass_flask_and_soil)
                                else -1
                                 end as mass_displaced_water from dual) displaced
       
       /*---------------------------------------------------------------------------------
         from MTest, Lt_T100_B9.cpp, doCalcs() Apparent specific gravity
         if(displaced != 0.0)
            asg = (soil / displaced) * acorrs[x].corr;
             (mass_soil / displaced) * relative density
       ---------------------------------------------------------------------------------*/
       
       cross apply (select case when t100.mass_soil > 0 and mass_displaced_water > 0
                                then ((t100.mass_soil / mass_displaced_water) * rd.relative_density)
                                else -1
                                 end as apparent_specific_gravity from dual) ASG
 ;









