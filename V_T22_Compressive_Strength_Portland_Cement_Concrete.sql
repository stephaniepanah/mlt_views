


-- DL22 Compressive Strength, Rock Cores (current)
--  T22 Compressive Strength of PCC (Portland Cement Concrete) (current)



select * from V_T22_Compressive_Strength_Portland_Cement_Concrete
 where T22_Sample_ID in 
 (
 'W-20-0143',    'W-20-0144',    'W-20-0385',    'W-20-0386',
 'W-20-0973-CO', 'W-20-1019-CO', 'W-20-1020-CO', 'W-20-1098-CO',
 'W-19-0024-CO', 'W-19-0242-CO', 'W-19-0441-CO', 'W-19-0909-CO',
 'W-18-0082-CO', 'W-18-0478-CO',
 'W-17-0610-CO', 'W-17-0683-CO', 'W-16-0978-CO', 'W-16-0979-CO'
)
 order by T22_Sample_Year desc, T22_Sample_ID, T22_segment_nbr
 ;



----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------

-- need to take into consideration sizes 4x8 and 6x12


select count(*), min(sample_year), max(sample_year) from Test_T22 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 19864	1979	2020
-- 19878 including 1960



select * from test_t22 order by sample_year desc, sample_id;



select * from V_T22_Compressive_Strength_Portland_Cement_Concrete
 where T22_reporting_units = 'M' 
   and T22_cylinder_units_actual = 'lb' 
   and t22_mass_cylinder <> -1
 ; -- no rows returned
 
 

-- corrections -- this has since been corrected in the conversion code
select * from test_t22 where sample_id in ('W-19-0441-CO', 'W-19-0909-CO');

--update test_t22 set slump_inches = 8.0,  structure_mix = -1 -- these two were switched
-- where sample_id = 'W-19-0441-CO';
-- 
--update test_t22 -- these four items were switched
--set slump_inches = 5.75, structure_mix = -1, pct_air = 6.2, structure_water = -1
-- where sample_id = 'W-19-0441-CO';
--
--commit;



-- find the counts per year
select sample_year, count(sample_year) from test_t22
 group by (sample_year)
 order by (sample_year) desc
 ;
/****
2020	113
2019	696
2018	783
2017	758
2016	218
2015	331
2014	394
2013	578
2012	570
2011	941
2010	688
2009	464
2008	182
2007	80
2006	142
2005	218
2004	287
2003	208
2002	222
2001	785
2000	524
1999	266
1998	1229
1997	844
1996	752
1995	822
1994	1115
1993	666
1992	142
1991	289
1990	378
1989	268
1988	649
1987	226
1986	666
1985	253
1984	423
1983	254
1982	468
1981	245
1980	364
1979	363
1966	2
1960	12 
****/
 


select distinct(customary_metric), count(customary_metric) as count from test_t22
 group by (customary_metric)
 order by count desc
 ;
/**
' ' 	11301   W-19-0866-CO, W-19-1354-CO, W-18-2386-CO -- customary_metric was introduced in 2000
CMCC	6998    W-20-1140-CO, W-20-1246-CO, W-19-0414-CO
MMCC	1556    W-10-0252-CO, W-10-0432-CO, W-10-0672-CO
CCCC	15      W-13-1186-CO, W-13-1187-CO, W-13-1188-CO
MCCC	6       W-09-0112-CO, W-09-0113-CO, W-09-0158-CO
MMMC	1       W-03-0555-CO
MMMM	1       W-00-1400-CO
**/



/***********************************************************************************

 T22 Compressive Strength of PCC (Portland Cement Concrete)
 
 W-20-0143,    W-20-0144,    W-20-0385,    W-20-0386
 W-20-0973-CO, W-20-1019-CO, W-20-1020-CO, W-20-1098-CO
 W-19-0024-CO, W-19-0242-CO, W-18-0082-CO, W-18-0478-CO
 W-17-0610-CO, W-17-0683-CO, W-16-0978-CO, W-16-0979-CO

 CustomaryOrMetric, from lmtmspec_D8
 [0] reporting units  'M' metric      'C' customary
 [1] cylinder weight  'M' gm          'C' lbs           - mass of core should always be grams, regardless of the designation (not so!)
 [2] height           'M' mm          'C' inches        - working height and diameter
 [3] Load kN/lbf      'M' kilonewtons 'C' pounds-force  - working load
  
  from MTest, Lt_T22b_BA.cpp, Lt_T22_BA.h
  =========================================
  
  void LtT22::CorGrpRoot::doCalcs(unsigned idcode)
  {
  
  //
  // cross section, from average diameter
  //
  double section;
  if (av > 0.0)
  {
      if (uomrpt == uom_mm)         // units of measurement for reporting[0] vs
      {                             // units of measurement for working height and diameter[2]
          av *= 0.1;                // convert mm to cm
      }
      section =  av * 0.5;          // diameter to radius
      section *= section * PI;      // radius^2 * PI
  }
  
  
  //
  // reported max load from working max load
  //
  if(uomrpt != uomwrk)              // units of measurement for reporting[0] vs
  {                                 // units of measurement for working load[3]
     cnvtuom(&val, uomwrk, uomrpt); // lbf (pounds-force) to kN (kilonewtons)
  }
  
  
  //
  // compressive strength from max load (actually RptMaxload)
  //
  double load = getFltValue(CorX::xRptMaxload);
  double section = getFltValue(CorX::xSection);
  double stren;
  if(load > 0.0 && section > 0.0)   // RptMaxload and cross section
  {
    if( ismetric )                  // reporting units
    {
       section *= 0.0001;   // cm2 ==> m2
       stren = load/section;
       // load: kN, section: m2, stren now: kN/m2 == kPa
       // round to nearest 69 kPa
       stren = 69.0*roundEven(stren/69.0);
       // kPa => MPa (Megapascal)
       stren *= 0.001;
    }
    else
    {
       stren = load/section;
       stren = 10.0 * roundEven(stren/10.0); // psi(pound force per square inch), rounded to nearest 10
    }
  }
  
  
  //
  // unit weight
  //
  double uw;
  double ht = getChild((int)CorX::xRptHt)        // reported height
  double wt = getChild((int)CorX::xWtCore)       // mass of cylinder
  double section = getChild((int)CorX::xSection) // cross section
  
  if(ht > 0.0 && wt > 0.0 && section > 0.0)
  {
     FmtFldNum const *specwt = units->getFmtFldNum(UnitSettingsT22::IDF_WtCylinder);
     uint16 uomwt = specwt->getUOM();
     bool ismetric = units->ismetric_res(); // section, ht are in reporting units
     
     if (ismetric)                         // reporting units
     {
        if(uomwt != uom_g)                 // if mass of cylinder is not in grams
        {
          cnvtuom(&wt, uomwt, uom_g);
        }
        // gm=>kg: 0.001, cm3=>m3 100^3; /.001/(100^3) => 10000
        uw = 10000.0*wt/(section*ht);
     }
     else
     {
        if(uomwt != uom_lb )               // if mass of cylinder is not in pounds
        {
           cnvtuom(&wt, uomwt, uom_lb);
        }
        // ft3 => in3: 12^3 == 1728
        uw = 1728.0*wt/(section*ht);
     }
  }
  
  
  MTest, External Dependencies, lmUom_D8.h (d:\cm\include\lmUom_D8.h)
  LMAT_D8_API int cnvtuom(double *valarg, uint16 uomcur, uint16 uomtarg);
  
  lmat_D8.sln; lmUom.cpp and lmUom_D8.hlmUnits
  --------------------------------------------
  int cnvtuom(double *valarg, uint16 uomcur, uint16 uomtarg ){
  
  also; MTest, External Dependencies, lmUnits.h (d:\cm\include\lmUnits.h)

***********************************************************************************/


create or replace view V_T22_Compressive_Strength_Portland_Cement_Concrete as 

with average_sql as (

     select  sample_id as sample_id
            ,T22_type as T22_type
            
            ,round(avg(case when T22_type = 'Height'   then measurement else 0 end),4) as T22_Avg_Height
            ,round(avg(case when T22_type = 'Diameter' then measurement else 0 end),4) as T22_Avg_Diameter
            
       from Test_T22_segments
      group by sample_id, T22_type
)

,radius_sql as (

     -- radius was placed into its own query to be available across all segments

     select  sample_id as sample_id
            ,T22_type as T22_type
            ,round(((avg(case when T22_type = 'Diameter' then measurement else 0 end)) * 0.5),4) as T22_radius           
       from Test_T22_segments
      group by sample_id, T22_type
)

,units_of_measurement as (

     select  sample_id as sample_id
       -- if customary_metric is absent, all units will default to the customary 'C' values
       ,case when length(customary_metric) > 1 and substr(customary_metric,1,1) = 'M' then 'M'  else 'C'   end as reporting_units
       ,case when length(customary_metric) > 1 and substr(customary_metric,2,1) = 'M' then 'gm' else 'lb'  end as cylinder_units
       ,case when length(customary_metric) > 1 and substr(customary_metric,3,1) = 'M' then 'mm' else 'in'  end as height_diameter_units
       ,case when length(customary_metric) > 1 and substr(customary_metric,4,1) = 'M' then 'kN' else 'lbf' end as max_load_units
       
       from Test_T22
     -- group by sample_id -- error, not a group by expression
)

select  T22.sample_id                              as T22_Sample_ID
       ,T22.sample_year                            as T22_Sample_Year
       ,T22.test_status                            as T22_Test_Status
       ,T22.tested_by                              as T22_Tested_By
       
       ,case when to_char(T22.date_tested, 'yyyy') = '1959' then ' '
             else to_char(T22.date_tested, 'mm/dd/yyyy') end
                                                   as T22_date_tested
            
       ,T22.date_tested                              as T22_date_tested_DATE
       ,T22.date_tested_orig                         as T22_date_tested_orig
       
       ,T22.customary_metric                       as T22_customary_metric
       ,uom.reporting_units                        as T22_reporting_units
       
       ,T22.pct_air                                as T22_pct_air
       ,T22.slump_inches                           as T22_slump_inches
       ,T22.slump_mm                               as T22_slump_mm
       ,T22.age                                    as T22_age
       ,T22.capping_material                       as T22_capping_material
       
       ,T22.mass_cylinder                          as T22_mass_cylinder
       ,T22_cylinder_units_actual                  as T22_cylinder_units_actual
       ,uom.cylinder_units                         as T22_uom_cylinder_units
       
       ,T22.fracture_type                          as T22_fracture_type
       
       ,T22.maximum_load                           as T22_maximum_load
       ,uom.max_load_units                         as T22_Max_load_units
       ,case when T22_RptMaxload > 0               then to_char(T22_RptMaxload)            else ' '   end as T22_RptMaxload
       ,case when uom.reporting_units = 'C'        then 'lbf'                              else 'kN'  end as T22_RptMaxload_units
       
       ,case when T22_Compressive_Strength > 0     then to_char(T22_Compressive_Strength)  else ' '   end as T22_Compressive_Strength
       ,case when uom.reporting_units = 'C'        then 'psi'                              else 'MPa' end as T22_Compressive_Strength_units
       
       ,case when T22_Unit_Weight > 0              then to_char(T22_Unit_Weight)           else ' '     end as T22_Unit_Weight
       ,case when uom.reporting_units = 'C'        then 'pcf'                              else 'kg/m3' end as T22_Unit_Weight_units
       
       /*-------------------------------------------------------------
         T22 segments, height and diameter
       -------------------------------------------------------------*/
       
       ,case when T22seg.segment_nbr is not null    then to_char(T22seg.segment_nbr)  else ' '   end as T22_segment_nbr
       ,case when T22seg.T22_type    is not null    then T22seg.T22_Type              else ' '   end as T22_Type      -- Height or Diameter
       ,case when T22seg.measurement is not null    then to_char(T22seg.measurement)  else ' '   end as T22_measurement
       
       ,case when T22seg.T22_type = 'Height'        then to_char(T22_Avg_Height)      else ' '   end as T22_AvgHeight
       ,case when T22seg.T22_type = 'Diameter'      then to_char(T22_Avg_Diameter)    else ' '   end as T22_Avg_Diameter
       ,uom.height_diameter_units                                                                    as T22_Avg_units -- Height & Diameter
       
       ,case when T22seg.T22_type = 'Height'        then to_char(T22_RptAvgHt)        else ' '   end as T22_RptAvgHt
       ,case when T22seg.T22_type = 'Diameter'      then to_char(T22_RptAvgDiameter)  else ' '   end as T22_RptAvgDiameter
       ,case when uom.reporting_units = 'C'         then 'in'                         else 'mm'  end as T22_RptAvg_units
       
       -----------------------------------------------------------------------------------------------------
       -- need to have radius and cross section available across all segments, not dependent upon diameter
       -- (cross section is dependent upon the radius)
       -- because unit weight needs height, cross section and mass of cylinder
       -----------------------------------------------------------------------------------------------------
       
       ,case when radius_sql.T22_Radius is not null then radius_sql.T22_Radius        else -1    end as T22_Radius -- not displayed
       ,case when T22_Adjusted_Radius > 0           then to_char(T22_Adjusted_Radius) else ' '   end as T22_Adjusted_Radius 
       
       ,case when T22_Cross_Section > 0             then to_char(T22_Cross_Section)   else ' '   end as T22_Cross_Section       
       ,case when uom.reporting_units = 'C'         then 'in2'                        else 'cm2' end as T22_Cross_Section_units
       
       ,T22.remarks as T22_Remarks
       
       /*-------------------------------------------------------------
         the items below are no longer used
         two were corrected: W-19-0441-CO, W-19-0909-CO
       -------------------------------------------------------------*/
       
       -- W-19-0909-CO(should be pct_air, has been corrected)
       -- W-98-0362-CO(one in 1998), W-95-1390-CO(10 of >800 in 1995)
       ,T22.structure_water as T22_structure_water -- otherwise, not used since 1994
       
       -- W-19-0441-CO, W-19-0909-CO(should be slump_inches, has been corrected)
       -- W-04-0411-CO(0, okay), W-98-0321-CO, W-98-0320-CO, W-96-1043-CO
       ,T22.structure_mix   as T22_structure_mix   -- otherwise, not used since 1994
       
       -- W-18-2270-CO(11 in 2018), W-15-1009-CO(12 in 2015), W-13-1191-CO(15 in 2013), W-12-1293-CO(~20 in 2012)
       ,T22.cement_source   as T22_cement_source   -- otherwise, not used since 1995
       
       ,T22.water_source    as T22_water_source    -- not used since 1995
       ,T22.fine_aggregate        as T22_fine_agg        -- not used since 1995
       ,T22.coarse_aggregate      as T22_coarse_agg      -- not used since 1995
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T22                                T22 on T22.sample_id    = smpl.sample_id
  
  left join Test_T22_segments               T22seg on T22seg.sample_id = T22.sample_id
  
  left join average_sql                            on T22seg.sample_id = average_sql.sample_id
                                                  and T22seg.T22_type  = average_sql.T22_type
 
  join units_of_measurement                    uom on T22.sample_id    = uom.sample_id
  
  left join radius_sql                             on radius_sql.sample_id = T22.sample_id
                                                  and radius_sql.T22_radius <> 0
  
  /*-------------------------------------------------------------
    calculations
  -------------------------------------------------------------*/

  /*-------------------------------------------------------------
    Reported Average Height
    in reality, all height & diameter measurements are in inches
  -------------------------------------------------------------*/
  
  cross apply (select case when T22seg.T22_type = 'Height' 
                 then case when uom.reporting_units = 'C' and uom.height_diameter_units = 'in' then (T22_Avg_Height)        -- already in inches
                           when uom.reporting_units = 'C' and uom.height_diameter_units = 'mm' then (T22_Avg_Height / 25.4) -- mm to inches
                           when uom.reporting_units = 'M' and uom.height_diameter_units = 'mm' then (T22_Avg_Height)        -- already in mm
                           when uom.reporting_units = 'M' and uom.height_diameter_units = 'in' then (T22_Avg_Height * 25.4) -- inches to mm
                           else -1 end
                 else -1   end as T22_RptAvgHt from dual) RptAvgHt  
                 
  /*-------------------------------------------------------------
    Reported Average Diameter
  -------------------------------------------------------------*/
  
  cross apply (select case when T22seg.T22_type = 'Diameter' 
                 then case when uom.reporting_units = 'C' and uom.height_diameter_units = 'in' then (T22_Avg_Diameter)        -- already in inches
                           when uom.reporting_units = 'C' and uom.height_diameter_units = 'mm' then (T22_Avg_Diameter / 25.4) -- mm to inches
                           when uom.reporting_units = 'M' and uom.height_diameter_units = 'mm' then (T22_Avg_Diameter)        -- already in mm
                           when uom.reporting_units = 'M' and uom.height_diameter_units = 'in' then (T22_Avg_Diameter * 25.4) -- inches to mm
                           else -1 end
                 else -1   end as T22_RptAvgDiameter from dual) RptAvgDiameter  
                 
  /*-------------------------------------------------------------
    Adjusted Radius
  -------------------------------------------------------------*/
  
  cross apply (select case when uom.reporting_units = 'C' and uom.height_diameter_units = 'in' then (radius_sql.T22_Radius)        -- already in inches
                           when uom.reporting_units = 'C' and uom.height_diameter_units = 'mm' then (radius_sql.T22_Radius / 2.54) -- cm to inches
                           when uom.reporting_units = 'M' and uom.height_diameter_units = 'mm' then (radius_sql.T22_Radius * 10)   -- mm to cm
                           when uom.reporting_units = 'M' and uom.height_diameter_units = 'in' then (radius_sql.T22_Radius * 2.54) -- inches to cm
                           else -1 end as T22_Adjusted_Radius from dual) AdjustedRadius  
                 
  /*-------------------------------------------------------------
    Reported Maximum Load
    1 lbf(pound-force) = 0.0044822 kN = 4.44822 Newtons
    1 kN (kilonewton)  = 224.80894 lbf, 1 Newton = 0.224809 lbf
    in reality, all measurements are in lbf
  -------------------------------------------------------------*/
  
  cross apply (select case when uom.reporting_units = 'C' and uom.Max_load_units = 'lbf' -- no conversion necessary
                           then round(T22.maximum_load)
                           
                           when uom.reporting_units = 'C' and uom.Max_load_units = 'kN'  -- convert kN to lbf
                           then round(T22.maximum_load * 224.80894)
                           
                           when uom.reporting_units = 'M' and uom.Max_load_units = 'lbf' -- convert lbf to kN
                           then round(T22.maximum_load * 0.0044822)
                           
                           when uom.reporting_units = 'M' and uom.Max_load_units = 'kN'  -- no conversion necessary
                           then round(T22.maximum_load)
                           
                           else -1 end as T22_RptMaxload from dual) RptMaxload
  
  /*-------------------------------------------------------------
    Cross Section, in units squared
  -------------------------------------------------------------*/
  
  cross apply (select case when T22_Adjusted_Radius > 0
                           then round((POWER(T22_Adjusted_Radius, 2) * 3.1415926),2)
                           else -1 
                           end as T22_Cross_Section from dual) CrossSection
                           
  /*-------------------------------------------------------------
    Compressive Strength
    -psi(pound force per square inch), rounded to nearest 10
    -MPa (Megapascal)
    T22_RptMaxload kN, (T22_Cross_Section * 0.0001) cm2 ==> m2
    kN/m2 == kPa
    round to nearest 69 kPa
    0.001 * kPa => MPa (Megapascal)
  -------------------------------------------------------------*/
  
  cross apply (select case when T22_RptMaxload > 0 and T22_Cross_Section > 0 
                           then case when uom.reporting_units = 'C' 
                                     then ((round((T22_RptMaxload / T22_Cross_Section) / 10)) * 10)
                                     else ((round((T22_RptMaxload / (T22_Cross_Section * 0.0001)) /69.0) * 69.0) * 0.001)
                                     end
                           else -1 
                           end as T22_Compressive_Strength from dual) CompressiveStrength

  /*-------------------------------------------------------------
    Unit Weight
    
    (grams / (grams per pound)) = pounds, 453.592 grams per pound
    
    in^3 -> ft^3 = 12^3 = 1728.0 in pcf, Pound-force per Cubic Foot (unit of material density)
    
    metric calculation: kg per cubic metres
    gm=>kg: 0.001, cm3=>m3 100^3; 0.001/(100^3) => 10000 <--- ??
    uw = 10000.0*wt/(section*ht);
    
    so, mass_core is in grams, convert to kg
    section * height is in cm (not really. but let's pretend)
    expanding a cm^3 to m^3 is 100^3 (1M) 
    ....and this calculation is not making sense to me, now
    oh well....
    
  -------------------------------------------------------------*/
  
  -- correct the cylinder units based upon mass
  cross apply (select case when T22.mass_cylinder > 100 then 'gm' else 'lb' end 
               as T22_cylinder_units_actual from dual) cylinderUnits                           
  
  
  cross apply (select 
               case when T22.mass_cylinder > 0 and T22_Cross_Section > 0 and T22_RptAvgHt > 0
  
                    then case when uom.reporting_units = 'C' and T22_cylinder_units_actual = 'gm'
                              then round((((T22.mass_cylinder / 453.592) * 1728.0) / (T22_Cross_Section * T22_RptAvgHt)),3)
                                     
                              when uom.reporting_units = 'C' and T22_cylinder_units_actual = 'lb'
                              then round(((T22.mass_cylinder * 1728.0) / (T22_Cross_Section * T22_RptAvgHt)),3)
                                     
                              when uom.reporting_units = 'M' and T22_cylinder_units_actual = 'gm'
                              then round(((T22.mass_cylinder / (T22_Cross_Section * T22_RptAvgHt)) * 10000.0),3)
                              
                              -- not sure about this calculation. I do not believe that this has occurred
                              -- this has not occurred. see the query, below
                              when uom.reporting_units = 'M' and T22_cylinder_units_actual = 'lb' 
                              then round((((T22.mass_cylinder * 1728.0) / (T22_Cross_Section * T22_RptAvgHt)) * 10000.0),3)
                                     
                              else -100 end -- I did this to distinguish the two cases from each other
                                     
                    else -1 
                    end as T22_Unit_Weight from dual) UnitWeight
 
 order by T22.sample_id, T22seg.segment_nbr
 ;






select * from V_T22_Compressive_Strength_Portland_Cement_Concrete
 where T22_reporting_units = 'M' 
   and T22_cylinder_units_actual = 'lb' 
   and t22_mass_cylinder <> -1
 ; -- no rows returned
 
 
 
 
 




