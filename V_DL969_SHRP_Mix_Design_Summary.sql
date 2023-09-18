


select * from V_DL969_SHRP_Mix_Design_Summary;



select * from V_DL969_SHRP_Mix_Design_Summary order by sample_year desc;



select * from test_dl969;



select count(*), min(sample_year), max(sample_year) from Test_DL969 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 79       2009    2020




/***********************************************************************************

 DL969 SHRP Mix Design Summary (Strategic Highway Research Program)
 
 W-19-0297-AC, W-18-0036-AC, W-18-0391-AC, W-17-0509-AC, W-17-0998-AC, W-09-0001-AC

 density of water at 25.0 Celsius = 62.245 pcf (Pound-force per Cubic Foot)
 used to calculate Gmb unit wt & Gmm unit wt
 
 from MTest, Lt_DL969_BC.cpp, void LtDL969_BC::CorGrpRoot::calc(unsigned idcode)
 
 (but, this SQL is using the density of water, stated above)
 
 idcode: ID of modified field
 
 enum{
 xGmb, // bulk specific gravity
 xGmm, //  max specific gravity
 nFlds
 };
    
 bool isuwm = units->ismetric_uw();
 uomuw = isuwm ? uom_kgcum : uom_pcf; // uomuw (units of measurement, unit wt (I think))
 
 // calculate UW
 double val = getNum(xsrc);
 cnvtuom(&val, uomsg, uomuw);
  
 
 --------------------------------------------------------
 
 CustomaryOrMetric
                       metric         customary
 [0] unit wt, density   'M' = kg/m3    'C' = pcf  62.245 * specific gravity
 [1] temperature        'C' = Celsius  'F' = Fahrenheit
         
 W-18-0391-AC |CM| wt pcf,   temp C
 W-15-0157-AC |MM| wt kg/m3, temp C
 W-15-0599-AC |MC| wt kg/m3, temp F

 W-19-0297-AC |CC| 163.0	 163.00 <-- incorrect, C should be M
 W-09-0295-AC |CC| 163.0	 163.00 <-- incorrect, C should be M
 W-19-0719-AC |CM| 157.0	 157.00 <-- M is correct
 W-18-0036-AC |CC| 322.0	 161.11 <-- C is correct
 
 
 The scale should be determined by the temperature, IMO
 eg; if > 200 then F else C --- and forget about assigning M or C
 or, if M, the do not accept a temperature > 200 (there are usually several ways to arrive to a destination)
 
 W-09-0295-AC     C     163.0 --- should be M
 W-11-0079-AC     C     160.0 --- should be M
 W-19-0759-AC     M     163.0

***********************************************************************************/


create or replace view V_DL969_SHRP_Mix_Design_Summary as


select  dl969.sample_id                                       as DL969_Sample_ID
       ,dl969.sample_year                                     as DL969_sample_year
       ,dl969.test_status                                     as DL969_test_status
       ,dl969.tested_by                                       as DL969_tested_by
       
       ,case when to_char(dl969.date_tested, 'yyyy') = '1959' then ' ' 
        else to_char(dl969.date_tested, 'mm/dd/yyyy') end     as DL969_date_tested
        
       ,dl969.date_tested                                     as DL969_date_tested_DATE
       ,dl969.date_tested_orig                                as DL969_date_tested_orig
       
       ,dl969.customary_metric                                as DL969_customary_metric
       
       ,dl969.filler                                          as DL969_filler
       ,dl969.pct_filler                                      as DL969_pct_filler
       
       ,dl969.nbr_gyrations_initial                           as DL969_nbr_gyrations_initial
       ,dl969.nbr_gyrations_design                            as DL969_nbr_gyrations_design
       ,dl969.nbr_gyrations_maximum                           as DL969_nbr_gyrations_maximum
       
       ,dl969.pct_binder_by_mixture                           as DL969_pct_binder_by_mix_Pb
       ,dl969.pct_binder_by_aggregate                         as DL969_pct_binder_by_agg
       ,dl969.pct_air_voids                                   as DL969_pct_air_voids_AV
       ,dl969.pct_voids_in_mineral_aggregate                  as DL969_pct_voids_in_mineral_agg_VMA
       ,dl969.voids_filled_asphalt                            as DL969_voids_filled_asphalt_VFA
       
       ,dl969.bulk_specific_gravity                           as DL969_bulk_specific_gravity_Gmb
       ,case when dl969.bulk_specific_gravity >= 0 then (dl969.bulk_specific_gravity * 62.245) else -1 end as DL969_Gmb_unit_wt_calculated
       
       ,dl969.maximum_specific_gravity                        as DL969_max_specific_gravity_Gmm
       ,case when dl969.maximum_specific_gravity >= 0 then (dl969.bulk_specific_gravity * 62.245) else -1 end as DL969_Gmm_unit_wt_calculated
       
       ,dl969.effective_specific_gravity_aggregate            as DL969_Gse_aggregate
       ,dl969.dust_to_binder_ratio                            as DL969_dust_to_binder_ratio_DP
       ,dl969.specific_gravity_binder                         as DL969_specific_gravity_binder_Gb
       
       /*---------------------------------------------------------------------------
         cannot rely upon customary_metric assignment, using mixing_temperature
         to determine mixing_temperature_celsius and compaction_temperature 
         to determine compaction_temperature_celsius
       ---------------------------------------------------------------------------*/
       
       ,dl969.mixing_temperature                              as DL969_mixing_temperature
       
       ,case when dl969.mixing_temperature  < 0     then -1                                            -- three samples
             when dl969.mixing_temperature >= 200.0 then ((dl969.mixing_temperature - 32.0) * (5/9))   -- F to C
             else dl969.mixing_temperature end                as DL969_mixing_temperature_celsius      -- Celsius
       
       ,dl969.compaction_temperature                          as DL969_compaction_temperature
       
       ,case when dl969.compaction_temperature  < 0     then -1                                              -- three samples
             when dl969.compaction_temperature >= 200.0 then ((dl969.compaction_temperature - 32.0) * (5/9)) -- F to C
             else dl969.compaction_temperature end            as DL969_compaction_temperature_celsius        -- Celsius
       
       ,dl969.pct_compaction_initial                          as DL969_pct_compaction_initial
       ,dl969.pct_compaction_design                           as DL969_pct_compaction_design
       ,dl969.pct_asphalt_absorption                          as DL969_pct_asphalt_absorption_Pba
       ,dl969.pct_binder_effective                            as DL969_pct_binder_effective_Pbe
       ,dl969.hveem_stabilometer                              as DL969_hveem_stabilometer
       ,dl969.dynamic_modulus                                 as DL969_dynamic_modulus
       
       ,dl969.remarks                                         as DL969_Remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                    smpl
       join Test_DL969                           dl969 on dl969.sample_id = smpl.sample_id
       ;









