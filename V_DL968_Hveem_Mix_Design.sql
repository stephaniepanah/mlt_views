


select * from V_DL968_Hveem_Mix_Design;



select * from V_DL968_Hveem_Mix_Design order by sample_year desc;



select count(*), min(sample_year), max(sample_year) from Test_DL968 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 226      1984    2007




/***********************************************************************************

 DL968 Hveem Mix Design Summary Data
 
 W-16-0834-AC (one sample in 2016, deleted), W-07-0225-AC (one sample in 2007)
 W-06-0010-AC, W-06-0011-AC, W-06-0078-AC, W-06-0084-AC, W-06-0085-AC
 
 from MTest, Lt_DL968_C5.cpp
 void LtDL968_C5::CorGrpRoot::calc(unsigned fldmod)
 {
	// If doing global recalc and ARM and ARA both have usable values, recalc ARM from ARA
    
    -- my notes: I suspect that ARM and ARA are Asphalt Agg & Asphalt Mix, respectively
    -- .....but I am sure that I am missing something along the way.....
    -- not sure about the the gymnastics, below
    -- my numbers are close, some are spot on
	 
	if (fldmod & (MOD_ARM | MOD_ARA))
    {
		double arm = getNum(CorX::xArm);
		double ara = getNum(CorX::xAra);
		unsigned calc = 0;
        
		if (fldmod & MOD_ARA) calc |= 2;  // calc arm
		if (fldmod & MOD_ARM) calc |= 1;  // calc ara
		if (calc == 3)
        {   // global recalc
			// figure out which one (if any) has usable input
			if (ara > 0.0) { calc = 2; } // have ara value (calc arm)
			else 
            if (arm > 0.0) { calc = 1; } // have arm (calc ara)
			else{ calc = 0; } // can't calculate: blank both out
		}
		if (calc == 1)
        {
			if (NM_UDN_E3::U_DnStd::isfQuant(arm))
            {
				double denom = 100.0 - arm;
				if (denom > 0.0) { ara = 100.0*arm / denom; }
			}
		}
		else if (calc == 2)
        {   // calc arm
			if (NM_UDN_E3::U_DnStd::isfQuant(ara)) { arm = 100.0*ara / (100.0 + ara); }
		}
		else{
			ara = FLT_BLANK;
			arm = FLT_BLANK;
			calc = 3;
		}
		if (calc & 1){ getFld(CorX::xAra)->reviseFltValueShow(ara);	}
		if (calc & 2){ getFld(CorX::xArm)->reviseFltValueShow(arm); }
	}

	if (fldmod & MOD_SG)
    {
		// calc unit wt
		double uw = FLT_BLANK;
		double sg = getNum(CorX::xMaxSg);
		if (sg > 0.0)
        {
			UnitSettingsDL968 *us = getMtm()->getUnitSettings();
			bool ismetric = us->ismetric_uw();
			uw = Hveem_SgToUw(sg, ismetric);
		}
		getFld(CorX::xMaxUw)->reviseFltValueShow(uw);
	}
}

 -----------------------------------------------
 
 CustomaryOrMetric

 [0] reporting units: 'M' = metric;       'C' = customary
 [1] asphalt ratio:   'A' = by Aggregate; 'M' = by mix
 [2] height:          'M' = mm;           'C' = inches
 [3] specimen temp:   'M' = Celsius;      'C' = Fahrenheit
 [4] weight:          'M' = grams;        'C' = lbs
 [5] stability units: 'M' = kPa;          'C' = psi
 [6] unit wt:         'M' = kg/m3;        'C' = pcf 

               0123456
 W-16-0834-AC |CACMMCC|
 W-07-0225-AC |CACMMCC|
 W-06-0010-AC |CACMMCC| 
 W-04-0189-AC |MACMMCC|
 W-00-0126-AC |MACMMCC|
                    
***********************************************************************************/


create or replace view V_DL968_Hveem_Mix_Design as 

select 

 /*--------------------------------------------
   header information
 --------------------------------------------*/
 
  dl968.sample_id
 ,dl968.sample_year
 ,dl968.test_status
 ,dl968.tested_by
       
 ,case when to_char(dl968.date_tested, 'yyyy') = '1959' then ' '
       else to_char(dl968.date_tested, 'mm/dd/yyyy')
       end as date_tested
            
 ,dl968.date_tested as date_tested_DATE
 ,dl968.date_tested_orig as date_tested_orig
       
 ,dl968.customary_metric
 
 /*--------------------------------------------
   detail information
 --------------------------------------------*/
       
 ,dl968.test_description
 ,case when dl968.pct_filler                 >= 0 then to_char(dl968.pct_filler, '90.99')                       else ' ' end as pct_filler
 ,dl968.pct_filler_description
 ,case when dl968.pct_antistrip              >= 0 then to_char(dl968.pct_antistrip, '90.99')                    else ' ' end as pct_antistrip
 ,dl968.pct_antistrip_description
 ,case when dl968.pct_asphalt_by_aggregate         >= 0 then to_char(dl968.pct_asphalt_by_aggregate, '90.99')               else ' ' end as pct_asphalt_by_agg
 ,case when dl968.pct_asphalt_by_mix         >= 0 then to_char(dl968.pct_asphalt_by_mix, '90.99')               else ' ' end as pct_asphalt_by_mix
 ,case when dl968.stabilometer               >= 0 then to_char(dl968.stabilometer, '999')                       else ' ' end as stabilometer
 ,case when dl968.pct_air_voids              >= 0 then to_char(dl968.pct_air_voids, '990.99')                   else ' ' end as pct_air_voids
 ,case when dl968.pct_voids_in_mineral_aggregate   >= 0 then to_char(dl968.pct_voids_in_mineral_aggregate, '990.99')        else ' ' end as pct_voids_in_mineral_agg       
 ,case when dl968.pct_voids_filled_asphalt   >= 0 then to_char(dl968.pct_voids_filled_asphalt, '990.99')        else ' ' end as pct_voids_filled_asphalt
 ,case when dl968.maximum_specific_gravity       >= 0 then to_char(dl968.maximum_specific_gravity, '990.999')           else ' ' end as max_specific_gravity
 ,case when dl968.maximum_specific_gravity       >= 0 then to_char(dl968.maximum_specific_gravity * 62.245, '99990.99') else ' ' end as calc_Gmm_unit_wt
 ,case when dl968.dust_asphalt_ratio         >= 0 then to_char(dl968.dust_asphalt_ratio, '990.99')              else ' ' end as dust_asphalt_ratio
 ,case when dl968.asphalt_film_thickness     >= 0 then to_char(dl968.asphalt_film_thickness, '990.9')           else ' ' end as asphalt_film_thickness
 ,case when dl968.effective_specific_gravity >= 0 then to_char(dl968.effective_specific_gravity, '90.999')      else ' ' end as effective_specific_gravity
 ,case when dl968.pct_asphalt_absorption     >= 0 then to_char(dl968.pct_asphalt_absorption, '990.99')          else ' ' end as pct_asphalt_absorption
 ,case when dl968.mixing_temperature         >= 0 then to_char(dl968.mixing_temperature, '9990.9')              else ' ' end as mixing_temperature
 ,case when dl968.lab_density_at_design      >= 0 then to_char(dl968.lab_density_at_design, '9990.99')          else ' ' end as lab_density_at_design
 
 ,dl968.remarks
 
 /*---------------------------------------------------------------------------
   table relationships
 ---------------------------------------------------------------------------*/
  
 from MLT_1_Sample_WL900                    smpl  
 join Test_DL968                           dl968 on dl968.sample_id = smpl.sample_id
 ;
 
 
 
 
 
 



