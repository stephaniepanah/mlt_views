


select count(*), min(sample_year), max(sample_year) from Test_T193 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 61	    1987	2013



select * from test_t193 order by sample_year desc, sample_id;


select * from test_t193_segments;


select test_source, count(test_source) from test_t193
 group by test_source
 order by test_source
;
/*
' ' 	41
Manual	3
T180	1
T99	    18
*/


select distinct(customary_metric) from test_t193;
/*
' '
CCCC
CCCCC
CCCPC
CMCC
CMCCC
CMCPC
*/


select sample_id from test_t193 where customary_metric = ' '     order by sample_year desc;
-- 20 of 61 samples without a customary_metric designation
-- W-03-0536-SO, W-00-0773-SO, W-99-0527-SO, W-99-0019-SO, W-99-0018-SO
-- W-97-0072-SO, W-97-1729-SO, W-97-1728-SO, W-97-0073-SO, W-96-0705-SO, W-96-0704-SO
-- W-88-1167-SO, W-88-1166-SO, W-88-1165-SO, W-87-0108-SO, W-87-0378-SO, W-87-0377-SO, W-87-0376-SO
-- W-66-9001-GEO, W-66-9011-GEO


select sample_id from test_t193 where customary_metric = 'CCCC'  order by sample_year desc;
-- 5 of 61 samples
-- W-01-0016-SO, W-01-0015-SO, W-01-0968-SO, W-01-0967-SO, W-00-0772-SO


select sample_id from test_t193 where customary_metric = 'CCCCC' order by sample_year desc;
-- W-07-0802-SO


select sample_id from test_t193 where customary_metric = 'CCCPC' order by sample_year desc;
-- 16 of 61 samples
-- W-08-0629-SO, W-08-0630-SO, W-07-0314-SO, W-07-0315-SO, W-06-0361-SO, W-06-0360-SO
-- W-05-1021-SO, W-05-1020-SO, W-05-1013-SO, W-05-1012-SO, W-05-1011-SO, W-05-0308-SO
-- W-05-0307-SO, W-05-1017-SO, W-03-0535-SO, W-03-0887-SO


select sample_id from test_t193 where customary_metric = 'CMCC'  order by sample_year desc;
-- W-02-0783-SOB


select sample_id from test_t193 where customary_metric = 'CMCCC' order by sample_year desc;
-- W-09-0447-SO, W-09-0446-SO


select sample_id from test_t193 where customary_metric = 'CMCPC' order by sample_year desc;
-- 18 of 61 samples
-- W-13-0562-SO, W-13-0561-SO, W-12-0488-SO, W-12-0487-SO
-- W-11-0295-SO, W-11-0296-SO, W-10-0863-SO, W-10-0862-SO
-- W-04-0463-SO, W-04-0462-SO, W-03-0889-SO, W-02-0828-SO, W-02-0805-SO
-- W-02-0190-SO, W-02-0208-SO, W-01-0091-SO, W-01-0094-SO, W-01-1432-SO


select piston_diameter, count(piston_diameter) from test_t193
 group by piston_diameter
 order by piston_diameter
;
/*
-1	    25
1.951	1
1.954	35
2.001	2
*/



/***********************************************************************************

 T193 California Bearing Ratio 63 samples
 
 W-13-0561-SO, W-13-0562-SO,  W-12-0487-SO, W-12-0488-SO,  W-11-0295-SO, W-11-0296-SO
 W-10-0862-SO, W-10-0863-SO,  W-09-0446-SO, W-09-0447-SO,  W-08-0629-SO, W-08-0630-SO
 W-07-0314-SO, W-07-0315-SO,  W-07-0802-SO, W-06-0360-SO,  W-06-0361-SO, W-05-0307-SO
 W-05-0308-SO, W-05-1011-SO,  W-05-1012-SO, W-05-1013-SO,  W-05-1017-SO, W-05-1020-SO
 W-05-1021-SO, W-04-0462-SO,  W-04-0463-SO, W-03-0535-SO,  W-03-0536-SO, W-03-0887-SO
 W-03-0889-SO, W-02-0190-SO,  W-02-0208-SO, W-02-0783-SOB, W-02-0805-SO, W-02-0828-SO
 W-01-0015-SO, W-01-0016-SO,  W-01-0091-SO, W-01-0094-SO,  W-01-0967-SO, W-01-0968-SO
 W-01-1432-SO, W-00-0772-SO,  W-00-0773-SO, W-99-0018-SO,  W-99-0019-SO, W-99-0527-SO
 W-97-0072-SO, W-97-0073-SO,  W-97-1728-SO, W-97-1729-SO,  W-96-0704-SO, W-96-0705-SO
 W-88-1165-SO, W-88-1166-SO,  W-88-1167-SO, W-87-0108-SO,  W-87-0376-SO, W-87-0377-SO
 W-87-0378-SO, W-66-9001-GEO, W-66-9011-GEO
 
 ------------------------------------------------------------
 
 from Solution lmtmspec_D8: lmtmSpec_D8.h, lmtmSpec100_D8.h (T193), mapT193.cpp
 
 for customary_metric
 
 const units_legalvals_t UnitSettingsT193_C2::_us_legalvals[us_nuc] = 
 {
	"CM",    // [0] results: customary | metric
	"CM",    // [1]  weight: lb | gm   (surcharge, compaction)
	"CM",    // [2]   swell: inches | mm
	"CMP",   // [3]    Load: C: lbf | M: Newtons | P: psi
	"CM"     // [4] maximum density (lb/cf | kg/m3) from T99 or T180
 };
 
 ------------------------------------------------------------
 
 from MTest, Lt_T193_C2.h, Lt_T193a_C2.cpp, Lt_T193b_C2.cpp, Lt_T193c_C2.cpp
 
 
 Lt_T193a_C2.cpp, String^ LtT193_C2::fetchPistonDefault(char chLoadUOM)
 {
   // Try to fetch default value for piston diameter from INI settings
   // If not possible, supply default values based on current Load UOM
   
   if (!strlen(szPistondefault))   // use AASHTO spec values
   {
       if (isMetricLoad)           // 'M': diameter in mm
           strcpy(szPistondefault, "49.63");
       else                        // 'C': diameter in inches; ('P': diameter not used)
		   strcpy(szPistondefault, "1.954");
           
 
 Lt_T193a_C2.cpp, int LtT193_C2::selExternalData() // select source button, me thinks
 
 // Run Moisture/Density data selection dialog

		if (mdData->_haveT99)
		{
			dlg->setT99vals	(
				mdData->_mc[(int)MD_data::MDX::xT99],     // moisture content? aka, optimum moisture pct?
				mdData->_mdensc[(int)MD_data::MDX::xT99], // max density customary?
				mdData->_mdensm[(int)MD_data::MDX::xT99]  // max density metric?
				);
		}
		if (mdData->_haveT180)
		{
			dlg->setT180vals (
				mdData->_mc[(int)MD_data::MDX::xT180],
				mdData->_mdensc[(int)MD_data::MDX::xT180],
				mdData->_mdensm[(int)MD_data::MDX::xT180]
				);
		}
        
		if (_unitsettings->ismetric_results())
			smDens = dlg->getDensm(); // density metric
		else
			smDens = dlg->getDensc(); // density customary
        
        // calculate 95% max density
        double val = smtof(smDens);
        if (val >= 0.0) dens95 = val*0.95;



***********************************************************************************/



create or replace view V_T193_California_Bearing_Ratio as 


select  t193.sample_id                                         as T193_Sample_ID
       ,t193.sample_year                                       as T193_Sample_Year
       ,t193.test_status                                       as T193_Test_Status
       ,t193.tested_by                                         as T193_Tested_by
       
       ,case when to_char(t193.date_tested, 'yyyy') = '1959'   then ' ' 
        else to_char(t193.date_tested, 'mm/dd/yyyy') end       as T193_date_tested
            
       ,t193.date_tested                                       as T193_date_tested_DATE
       ,t193.date_tested_orig                                  as T193_date_tested_orig
       
       ,t193.customary_metric                                  as T193_customary_metric
       
       /*-----------------------------------------------------------------------
         user-entered values
       -----------------------------------------------------------------------*/
       
       ,t193.piston_diameter                                   as T193_piston_diameter
       ,t193.test_source                                       as T193_Test_Source
       ,t193.optimum_moisture_pct_manual                       as T193_optimum_moisture_pct_manual
       ,t193.maximum_density_manual                            as T193_maximum_density_manual
       ,t193.mass_surcharge                                    as T193_mass_surcharge
       
       /*-----------------------------------------------------------------------
         segments
       -----------------------------------------------------------------------*/
       
       ,case when t193seg.segment_nbr                    is not null then t193seg.segment_nbr                    else  -1 end as T193_segment_nbr
       ,case when t193seg.pct_moisture_before_compaction is not null then t193seg.pct_moisture_before_compaction else  -1 end as T193_pct_moisture_before_compaction
       ,case when t193seg.mass_mold                      is not null then t193seg.mass_mold                      else  -1 end as T193_mass_mold
       ,case when t193seg.mass_mold_specimen             is not null then t193seg.mass_mold_specimen             else  -1 end as T193_mass_mold_specimen
       ,case when t193seg.blows                          is not null then t193seg.blows                          else  -1 end as T193_blows
       ,case when t193seg.pct_moisture_after_compaction  is not null then t193seg.pct_moisture_after_compaction  else  -1 end as T193_pct_moisture_after_compaction
       ,case when t193seg.hours_soaked                   is not null then t193seg.hours_soaked                   else  -1 end as T193_hours_soaked
       ,case when t193seg.swell                          is not null then t193seg.swell                          else  -1 end as T193_swell
       ,case when t193seg.moisture_top                   is not null then t193seg.moisture_top                   else  -1 end as T193_moisture_top
       ,case when t193seg.load_1                         is not null then t193seg.load_1                         else  -1 end as T193_load_1
       ,case when t193seg.load_2                         is not null then t193seg.load_2                         else  -1 end as T193_load_2
       ,case when t193seg.load_3                         is not null then t193seg.load_3                         else  -1 end as T193_load_3
       ,case when t193seg.load_4                         is not null then t193seg.load_4                         else  -1 end as T193_load_4
       ,case when t193seg.load_5                         is not null then t193seg.load_5                         else  -1 end as T193_load_5
       ,case when t193seg.load_6                         is not null then t193seg.load_6                         else  -1 end as T193_load_6
       ,case when t193seg.load_7                         is not null then t193seg.load_7                         else  -1 end as T193_load_7
       ,case when t193seg.load_8                         is not null then t193seg.load_8                         else  -1 end as T193_load_8
       ,case when t193seg.load_9                         is not null then t193seg.load_9                         else  -1 end as T193_load_9
       ,case when t193seg.exclude_segment                is not null then t193seg.exclude_segment                else ' ' end as T193_exclude_segment
       
       ,t193.remarks                                     as T193_Remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_T193                                     t193 on t193.sample_id = smpl.sample_id
       left join Test_T193_segments                    t193seg on t193.sample_id = t193seg.sample_id
       
       /*-----------------------------------------------------------------------
         calculations
       -----------------------------------------------------------------------*/
  
--  cross apply (select case when (t193.mass_wet_aggregate >= 0) then t193.mass_wet_aggregate
--                           else 0 end as calc_mass_wet  from dual) CALC_WET
--  
--  cross apply (select case when (t193.mass_dry_aggregate >= 0) then t193.mass_dry_aggregate
--                           else 0 end as calc_mass_dry  from dual) CALC_DRY
--                      
--  cross apply (select case when (t193.mass_tare >= 0)          then t193.mass_tare
--                           else 0 end as calc_mass_tare from dual) CALC_TARE
--                          
--  cross apply (select (calc_mass_dry - calc_mass_tare) as calc_denominator from dual) CALC_DENOM -- not using this
--  
--  cross apply (select case when (calc_mass_wet >= calc_mass_dry) and (calc_mass_dry - calc_mass_tare) > 0 
--                           then (((calc_mass_wet - calc_mass_dry) / (calc_mass_dry - calc_mass_tare)) * 100)
--                           else -1 end as calc_pct_moisture from dual) calc_moist
    order by 
    t193.sample_id,
    t193seg.segment_nbr
    ;



  
  
  
  






