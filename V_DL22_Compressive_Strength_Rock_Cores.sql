


-- DL22 Compressive Strength, Rock Cores (current)
--  T22 Compressive Strength of PCC (Portland Cement Concrete) (current)



select * from V_DL22_Compressive_Strength_Rock_Cores
 where DL22_Sample_ID in ('W-20-0862-SO', 'W-19-0056-CO', 'W-18-2135-CO', 'W-16-0019-CO')
 order by DL22_Sample_Year desc, DL22_Sample_ID, DL22_segment_nbr
 ;



----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_DL22 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
--   695	1992	2020 
--   702 including 1960



select * from test_dl22 order by sample_year desc, sample_id;



select distinct(customary_metric), count(customary_metric) from test_dl22
 group by (customary_metric)
 order by (customary_metric)
 ;
/**
' '    --  88 samples, many from 2018-2020, when blank, customary_metric defaults to CCCC
'CCCC' --   5 samples, W-10-0201-CO, W-09-0039-CO, W-09-0043-CO
'CMCC' -- 609 samples
          ===
          702
**/



/***********************************************************************************

 DL22 Compressive Strength, Rock Cores
 W-20-0094,    W-20-0102,    W-20-0465,    W-20-0500
 W-20-0847-SO, W-20-0862-SO, W-20-1344-CO, W-20-1354-CO
 W-19-0054-CO, W-19-0098-CO, W-19-0784-CO, W-19-2018-CO
 W-18-0012-CO, W-18-0013-CO, W-18-0925-CO, W-14-0173-CO

 CustomaryOrMetric, from lmtmspec_D8
 [0] reporting units  'M' metric      'C' customary
 [1] cylinder weight  'M' gm          'C' lbs           - mass of core should always be reported in grams, regardless of the designation
 [2] height           'M' mm          'C' inches        - working height and diameter
 [3] Load kN/lbf      'M' kilonewtons 'C' pounds-force  - working load

 DL22, W-20-0862-SO | |    all units are marked as Customary
 DL22, W-20-0850-SO |CMCC|
 DL22, W-10-0201-CO |CCCC| most recent sample designated as CCCC
  
 from MTest, Lt_DL22b_BA.cpp, Lt_DL22_BA.h
 =========================================
  
  void LtDL22::CorGrpRoot::doCalcs(unsigned idcode)
  {
  
  // cross section, from average diameter
  
  double section;
  if (av > 0.0)
  {
      if (uomrpt == uom_mm)            // units of measurement for reporting[0] vs
      {                                // units of measurement for working height and diameter[2]
          av *= 0.1;                   // convert mm to cm
      }
      section =  av * 0.5;             // diameter to radius
      section *= section * PI;         // radius^2 * PI (area of a circle)
  }
  
  
  // reported max load from working max load
  
  if(uomrpt != uomwrk)                 // units of measurement for reporting[0] vs
  {                                    // units of measurement for working load[3]
     cnvtuom(&val, uomwrk, uomrpt);    // lbf (pounds-force) to kN (kilonewtons)
  }
  
  
  // compressive strength from max load (actually RptMaxload)
  double load = getFltValue(CorX::xRptMaxload);
  double section = getFltValue(CorX::xSection);
  double stren;
  if(load > 0.0 && section > 0.0)            // RptMaxload and cross section
  {
    if( ismetric )                           // I think that this is reporting units
    {
       section *= 0.0001;                    // cm2 ==> m2
       stren = load/section;
       
       // load: kN, section: m2, stren now: kN/m2 == kPa       
       stren = 69.0*roundEven(stren/69.0);   // round to nearest 69 kPa
       stren *= 0.001;                       // kPa => MPa (Megapascal)
    }
    else
    {
       stren = load/section;
       stren = 10.0 * roundEven(stren/10.0); // psi(pound force per square inch), round to nearest 10
    }
  }
  
  
  // unit weight
  // [0] reporting units 'M' metric, 'C' customary
  
  double uw;
  double ht = getChild((int)CorX::xRptHt)        // reported height
  double wt = getChild((int)CorX::xWtCore)       // mass of core
  double section = getChild((int)CorX::xSection) // cross section
  
  if(ht > 0.0 && wt > 0.0 && section > 0.0)
  {
     FmtFldNum const *specwt = units->getFmtFldNum(UnitSettingsDL22::IDF_WtCore);
     uint16 uomwt = specwt->getUOM();
     bool ismetric = units->ismetric_res(); // section, ht are in reporting units
     
     if (ismetric)                          // reporting units
     {
        if(uomwt != uom_g)                  // if mass of core is not in grams
        {
          cnvtuom(&wt, uomwt, uom_g);
        }
        // gm=>kg: .001, cm3=>m3 100^3; .001/(100^3) => 10000
        uw = 10000.0*wt/(section*ht);
     }
     else
     {
        if(uomwt != uom_lb )                // if mass of cylinder is not in pounds
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


create or replace view V_DL22_Compressive_Strength_Rock_Cores as 

with average_sql as (

     select  sample_id as sample_id
            ,DL22_type as DL22_type            
            ,avg(case when DL22_type = 'Height'   then measurement else 0 end) as DL22_Avg_Height
            ,avg(case when DL22_type = 'Diameter' then measurement else 0 end) as DL22_Avg_Diameter
            
       from Test_DL22_segments
      group by sample_id, DL22_type
)

,radius_sql as (

     -- radius was placed into its own query to be available across all segments

     select  sample_id as sample_id
            ,DL22_type as DL22_type            
            ,((avg(case when DL22_type = 'Diameter' then measurement else 0 end)) * 0.5) as DL22_radius    
            
       from Test_DL22_segments
      group by sample_id, DL22_type
)

,units_of_measurement as (

     select  sample_id as sample_id
     
     -- if customary_metric is absent, all units will default to the customary 'C' values
     ,case when trim(customary_metric) is not null and substr(customary_metric,1,1) = 'M' then 'M'  else 'C'   end as reporting_units
     ,case when trim(customary_metric) is not null and substr(customary_metric,2,1) = 'M' then 'gm' else 'lb'  end as core_units
     ,case when trim(customary_metric) is not null and substr(customary_metric,3,1) = 'M' then 'mm' else 'in'  end as height_diameter_units
     ,case when trim(customary_metric) is not null and substr(customary_metric,4,1) = 'M' then 'kN' else 'lbf' end as max_load_units
     
     from Test_DL22
)

--------------------------------------------------
--  main sql
--------------------------------------------------


select  dl22.sample_id                                                  as DL22_Sample_ID
       ,dl22.sample_year                                                as DL22_Sample_Year
       ,dl22.test_status                                                as DL22_Test_Status
       ,dl22.tested_by                                                  as DL22_Tested_By
       
       ,case when to_char(dl22.date_tested, 'yyyy') = '1959' then ' '
             else to_char(dl22.date_tested, 'mm/dd/yyyy')    end        as DL22_date_tested
       
       ,dl22.date_tested                                                as DL22_date_tested_DATE
       ,dl22.date_tested_orig                                           as DL22_date_orig
       
       ,dl22.customary_metric                                           as DL22_customary_metric
       
       ,uom.reporting_units                                             as DL22_reporting_units
       
       ,dl22.core_id_nbr                                                as DL22_core_id_nbr
       ,dl22.depth_of_sample                                            as DL22_depth_of_sample
       
       ,dl22.mass_core                                                  as DL22_mass_core
       ,'gm'                                                            as DL22_core_units_actual -- all measurements are reported in grams
       ,uom.core_units                                                  as DL22_core_units_assigned
                     
       ,dl22.fracture_type                                              as DL22_fracture_type
       
       ,dl22.maximum_load                                               as DL22_maximum_load
       ,uom.max_load_units                                              as DL22_Max_load_units
       
       ,DL22_RptMaxload                                                 as DL22_RptMaxload
       ,case when uom.reporting_units = 'C' then 'lbf' else 'kN'    end as DL22_RptMaxload_units
       
       ,DL22_Compressive_Strength                                       as DL22_Compressive_Strength
       ,case when uom.reporting_units = 'C' then 'psi' else 'MPa'   end as DL22_Compressive_Strength_units
       
       ,DL22_Unit_Weight                                                as DL22_Unit_Weight
       ,case when uom.reporting_units = 'C' then 'pcf' else 'kg/m3' end as DL22_Unit_Weight_units
       
       /*-------------------------------------------------------------
         DL22 segments, height and diameter
       -------------------------------------------------------------*/
       
       ,case when dl22seg.segment_nbr is not null  then dl22seg.segment_nbr  else -1    end as DL22_segment_nbr
       ,case when dl22seg.dl22_type   is not null  then dl22seg.DL22_Type    else ' '   end as DL22_Type   -- Height or Diameter
       ,case when dl22seg.measurement is not null  then dl22seg.measurement  else -1    end as DL22_measurement
       
       ,case when dl22seg.dl22_type = 'Height'     then DL22_Avg_Height      else -1    end as DL22_AvgHeight
       ,case when dl22seg.dl22_type = 'Diameter'   then DL22_Avg_Diameter    else -1    end as DL22_Avg_Diameter
       ,uom.height_diameter_units                                                           as DL22_Avg_units -- Height & Diameter
       
       ,case when dl22seg.dl22_type = 'Height'     then DL22_RptAvgHeight    else -1    end as DL22_RptAvgHt
       ,case when dl22seg.dl22_type = 'Diameter'   then DL22_RptAvgDiameter  else -1    end as DL22_RptAvgDiameter
       ,case when uom.reporting_units = 'C'        then 'in'                 else 'mm'  end as DL22_RptAvg_units
       
       -----------------------------------------------------------------------------------------------------
       -- need to have radius and cross section available across all segments, not dependent upon diameter
       -- (cross section is dependent upon the radius)
       -- because unit weight needs height and cross section and mass of core
       -----------------------------------------------------------------------------------------------------
       
       ,case when radius_sql.DL22_Radius is not null then radius_sql.DL22_Radius      else -1    end as DL22_Radius -- not displayed       
       ,case when DL22_Cross_Section > 0             then to_char(DL22_Cross_Section) else ' '   end as DL22_Cross_Section       
       ,case when uom.reporting_units = 'C'          then 'in2'                       else 'cm2' end as DL22_Cross_Section_units
       
       ,dl22.remarks as DL22_Remarks
       
       /*---------------------------------------------------------------------------
         table relationships
       ---------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                     smpl
       join Test_DL22                              dl22 on dl22.sample_id    = smpl.sample_id
       
       left join Test_DL22_segments             dl22seg on dl22seg.sample_id = dl22.sample_id
       
       left join average_sql                            on dl22seg.sample_id = average_sql.sample_id
                                                       and dl22seg.dl22_type = average_sql.dl22_type
                                                       
       left join radius_sql                             on dl22seg.sample_id = radius_sql.sample_id
                                                       and radius_sql.DL22_radius <> 0
                                                       
       join units_of_measurement                    uom on dl22.sample_id    = uom.sample_id
       
       /*-------------------------------------------------------------
         Reported Average Height
         in reality, all height & diameter measurements are in inches
       -------------------------------------------------------------*/
       
       cross apply (select case when dl22seg.dl22_type = 'Height' 
       then case when uom.reporting_units = 'C' and uom.height_diameter_units = 'in' then (DL22_Avg_Height)        -- already in inches
                 when uom.reporting_units = 'C' and uom.height_diameter_units = 'mm' then (DL22_Avg_Height / 25.4) -- mm to inches
                 when uom.reporting_units = 'M' and uom.height_diameter_units = 'mm' then (DL22_Avg_Height)        -- already in mm
                 when uom.reporting_units = 'M' and uom.height_diameter_units = 'in' then (DL22_Avg_Height * 25.4) -- inches to mm
                 else -1 end
       else -1   end as DL22_RptAvgHeight from dual) RptAvgHt 
       
       /*-------------------------------------------------------------
         Reported Average Diameter
       -------------------------------------------------------------*/
       
       cross apply (select case when dl22seg.dl22_type = 'Diameter' 
       then case when uom.reporting_units = 'C' and uom.height_diameter_units = 'in' then (DL22_Avg_Diameter)        -- already in inches
                 when uom.reporting_units = 'C' and uom.height_diameter_units = 'mm' then (DL22_Avg_Diameter / 25.4) -- mm to inches
                 when uom.reporting_units = 'M' and uom.height_diameter_units = 'mm' then (DL22_Avg_Diameter)        -- already in mm
                 when uom.reporting_units = 'M' and uom.height_diameter_units = 'in' then (DL22_Avg_Diameter * 25.4) -- mm to inches
                 else -1 end
       else -1   end as DL22_RptAvgDiameter from dual) RptAvgDiameter 
       
       /*-------------------------------------------------------------
         Reported Maximum Load
         1 lbf(pound-force) = 0.0044822 kN = 4.44822 Newtons
         1 kN (kilonewton)  = 224.80894 lbf, 1 Newton = 0.224809 lbf
         in reality, all measurements are in lbf
       -------------------------------------------------------------*/
       
       cross apply (select case when uom.reporting_units = 'C' and uom.Max_load_units = 'lbf' -- no conversion necessary
                                then (dl22.maximum_load)
                                
                                when uom.reporting_units = 'C' and uom.Max_load_units = 'kN'  -- convert kN to lbf
                                then (dl22.maximum_load * 224.80894)
                                
                                when uom.reporting_units = 'M' and uom.Max_load_units = 'lbf' -- convert lbf to kN
                                then (dl22.maximum_load * 0.0044822)
                                
                                when uom.reporting_units = 'M' and uom.Max_load_units = 'kN'  -- no conversion necessary
                                then (dl22.maximum_load)
                                
                                else -1 end as DL22_RptMaxload from dual) RptMaxload
                                
       /*-------------------------------------------------------------
         Cross Section, in units squared
       -------------------------------------------------------------*/
       
       cross apply (select case when radius_sql.DL22_radius > 0
       
                                then case when uom.height_diameter_units = 'in'
                                     then round((POWER(radius_sql.DL22_radius, 2) * 3.1415926),4)         -- inches (inches^2)
                                     else round((POWER((radius_sql.DL22_radius * 0.1), 2) * 3.1415926),4) -- * 0.1 converts mm to cm (cm^2)
                                     end
                                     
                                else -1 end as DL22_Cross_Section from dual) CrossSection
       
       /*-------------------------------------------------------------
         Compressive Strength
         -psi(pound force per square inch), rounded to nearest 10
         -MPa (Megapascal)
         DL22_RptMaxload kN, (DL22_Cross_Section * 0.0001) cm2 ==> m2
         kN/m2 == kPa
         round to nearest 69 kPa
         0.001 * kPa => MPa (Megapascal)
       -------------------------------------------------------------*/
       
       cross apply (select case when DL22_RptMaxload > 0 and DL22_Cross_Section > 0 
  
                                then case when uom.reporting_units = 'C' 
                                          then ((round((DL22_RptMaxload / DL22_Cross_Section) / 10)) * 10)
                                          else ((round((DL22_RptMaxload / (DL22_Cross_Section * 0.0001)) /69.0) * 69.0) * 0.001)
                                          end
                                     
                                else -1 end as DL22_Compressive_Strength from dual) CompressiveStrength
       
       /*-------------------------------------------------------------
         Unit Weight
         (grams / (grams per pound)) = pounds, 453.592 grams per pound
         in^3 -> ft^3 = 12^3 = 1728.0 in pcf 
         pcf -- Pound-force per Cubic Foot (unit of material density)
       
         metric calculation: kg per cubic metres
         gm=>kg: 0.001, cm3=>m3 100^3; 0.001/(100^3) => 10000 <--- ??
         uw = 10000.0*wt/(section*ht);
       
         so, mass_core is in grams, convert to kg
         section * height is in cm (not really. but let's pretend)
         expanding a cm^3 to m^3 is 100^3 (1M) 
         ....and this calculation is not making sense to me, now. oh well....
       
       -------------------------------------------------------------*/
       
       cross apply (select case when dl22.mass_core > 0 and DL22_Cross_Section > 0 and DL22_RptAvgHeight > 0
  
                                then case when uom.reporting_units = 'C' and uom.core_units = 'gm' -- in reality, this is always the case
                                          then round((((dl22.mass_core / 453.592) * 1728.0) / (DL22_Cross_Section * DL22_RptAvgHeight)),3)
                                     
                                          when uom.reporting_units = 'C' and uom.core_units = 'lb' -- says lb, but is in grams, ha
                                          then round((((dl22.mass_core / 453.592) * 1728.0) / (DL22_Cross_Section * DL22_RptAvgHeight)),3)
                                     
                                          when uom.reporting_units = 'M' and uom.core_units = 'gm' -- this has never occured
                                          then round(((dl22.mass_core / (DL22_Cross_Section * DL22_RptAvgHeight)) * 10000.0),3)
                                     
                                          when uom.reporting_units = 'M' and uom.core_units = 'lb' 
                                          -- this has never occured, it says lb but is gm. when this happens, I will work upon it
                                          then round(((dl22.mass_core / (DL22_Cross_Section * DL22_RptAvgHeight)) * 10000.0),3)
                                     
                                          -- I did this to distinguish the two case statements from each other (just in case)
                                          else -100 end
                                
                                else -1 end as DL22_Unit_Weight from dual) UnitWeight
 
 
 order by 
 dl22.sample_id, 
 dl22seg.segment_nbr
 ;









