


-- D5821 Fractured Particles       (2021)
-- FL506 Fractured Faces, Multiple (1995)
-- FL507 Fractured Particles       (2016)
-- FL508 Flakiness Index           (2001)



select * from V_D5821_Fractured_Particles;



--------------------------------------------------------------------------------
-- some diagnostics
--------------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_D5821 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 4330	    2001	2021



select * from Test_D5821;




/***********************************************************************************

 D5821 Fractured Particles
 
 W-19-0135-AG, W-19-0340-AG, W-18-1210-AG, W-18-1217-AG, W-15-0049-AG, W-12-0909-AG

 from MTest, Lt_D5821.cpp

 void mtD5821::CorGrpRoot::doCalcs()
 {
 
   Pct Fracture = (wtFractured + (wtQuestionable/2)) / (wtFractured + wtQuestionable + wtNotFractured)
	 
	double denom, rslt;                      --- denominator, numerator AND result
	double mf, mnf, mq;                      --- mass fractured, mass not fractured, mass questionable

	if (mf >= 0.0 && mnf >= 0.0)             --- if mass fractured >= 0 && mass not fractured >= 0
	{
		if (mq < 0.0) mq = 0.0;              --- if mass questionable < 0, mass questionable = 0
        
		denom = mf + mq + mnf;               --- denominator = mass fractured + mass not fractured + mass questionable
        
		rslt = mf + (mq / 2.0);              --- numerator   = mass fractured + (mass questionable /2)

		if (rslt > 0.0 && denom >= rslt)     --- if numerator > 0 & denominator >= numerator
			rslt = 100.0 * rslt / denom;     --- (numerator / denominator) * 100
	}    
	// report as a whole nr                  --- round Pct Fracture to a whole number
 }
 
 Minimum_Pct_Fractured is a user-entered field
 per the lab:
 It is based on whatever specific standard applies to the material being tested
 Often, it is fixed at 70%, and sometimes 50%
 the responsibility of the Field/Project Engineers is to verify that the 
 percent fractured complies with specific project specifications
 

***********************************************************************************/




create or replace view V_D5821_Fractured_Particles as 

--------------------------------------------------------------------------------
-- main SQL
--------------------------------------------------------------------------------

select  d5821.sample_id                                        as D5821_Sample_ID
       ,d5821.sample_year                                      as D5821_sample_year
       ,d5821.test_status                                      as D5821_test_status
       ,d5821.tested_by                                        as D5821_tested_by
       
       ,case when to_char(d5821.date_tested, 'yyyy') = '1959'  then ' '
             else to_char(d5821.date_tested, 'mm/dd/yyyy') end as D5821_date_tested
       
       ,d5821.date_tested                                      as D5821_date_tested_DATE
       ,d5821.date_tested_orig                                 as D5821_date_orig
       
       ,d5821.mass_sample                                      as D5821_mass_sample
       ,d5821.Mass_Particles_Fractured                         as D5821_Mass_Particles_Fractured
       ,d5821.Mass_Particles_Questionable                      as D5821_Mass_Particles_Questionable
       ,d5821.Mass_Particles_Not_Fractured                     as D5821_Mass_Particles_Not_Fractured
       ,pct_fractured_calculated                               as D5821_pct_fractured
       ,d5821.Minimum_Pct_Fractured                            as D5821_Minimum_Pct_Fractured
       
       ,d5821.remarks                                          as D5821_Remarks
       
       /*--------------------------------------------------------------------------------
         table relationships
       --------------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_D5821                                   d5821 on d5821.sample_id = smpl.sample_id
       
       /*---------------------------------------------------------------------------
         calculations
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when d5821.Mass_Particles_Fractured     >= 0 then d5821.Mass_Particles_Fractured     else 0 end as mass_frac_nbr  from dual) frac   
       cross apply (select case when d5821.Mass_Particles_Questionable  >= 0 then d5821.Mass_Particles_Questionable  else 0 end as mass_ques_nbr  from dual) ques
       cross apply (select case when d5821.Mass_Particles_Not_Fractured >= 0 then d5821.Mass_Particles_Not_Fractured else 0 end as mass_nfrac_nbr from dual) nfrac
       
       cross apply (select (mass_frac_nbr + (mass_ques_nbr / 2) )            as dividend   from dual) numerator
       cross apply (select (mass_frac_nbr + mass_nfrac_nbr + mass_ques_nbr)  as divisor    from dual) denominator
       
       cross apply (select case when (dividend > 0 and divisor >= dividend)  then ((dividend / divisor) * 100) 
                                else 0 end as pct_fractured_calculated from dual) pct_frac
       
       /*---------------------------------------------------------------------------
         these two are a cross check for mass_not_fractured
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when d5821.mass_sample >= 0 then d5821.mass_sample else 0 end as mass_sample_nbr    from dual) smplnbr
       cross apply (select (mass_sample_nbr - mass_frac_nbr - mass_ques_nbr)                  as mass_not_frac_calc from dual) calc_nfrac
       
       ;









