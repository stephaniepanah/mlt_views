


-- this needs work, the most recent T84 Mineral segment is 2001 (yes, 2006, but no data was present)
-- moving on for now

select * from V_T84_Mineral_Filler 
 where T84_Mineral_Sample_ID in ( 'W-01-0006-AC', 'W-01-0006-ACA', 'W-00-0126-AC' )
;


select * from Test_T84_Mineral order by sample_id;



/***********************************************************************************

 T84 Mineral -- 47 samples
 
 W-06-0031-AG,  W-03-0267-AC (no data for these samples)
 
 W-01-0006-AC,  W-01-0006-ACA,  W-00-0126-AC
 
 W-99-0370-AC,  W-99-0370-AC1, W-99-0370-ACA, W-99-0370-ACA1, W-99-0370-ACB
 W-99-0370-ACC, W-99-0370-ACX, W-99-0370-ACY, W-99-0370-ACY1, W-99-0721-AC
 
 W-98-0168-ACCL, W-98-0168-ACEL, W-98-0967-ACL, W-98-1230-AC, W-98-1230-ACA 
 W-97-0859-ACSP 
 W-96-0101-AC,  W-96-0101-ACX, W-96-1098-AC6, W-96-1098-ACS, W-96-1552-AC08
 W-95-0151-AC,  W-95-0457-AC,  W-95-0457-ACI, W-95-0457-ACX, W-95-0457-ACZ, W-95-1427-AC, W-95-1496-AC
 W-94-0179-ACA, W-94-0179-ACB, W-94-1169-AC,  W-94-1169-ACA, W-94-1678-AC
 W-93-0799-ACL, W-93-1365-AC,  W-93-1565-ACF, W-92-0428-AC,  W-91-0930-AC
 W-90-0492-AC,  W-90-0793-AC   W-90-0793-ACT 

 W-90-0492-AC	1	LIME <-- sole sample with two segments
 W-90-0492-AC	2	LIME
 
 
 from MTest, Lt_T84_B5_da.cpp, 
 
 void LtT84::CorGrpRoot::calc()
 {
      if( xgrp == CorX::xMf ) // Mf, mineral filler
	  {
         CorGrpMf^ grpMf = getGrpMf();
         ratio = grpMf->getNum(CorMfX::xRatio);
           asg = grpMf->getNum(CorMfX::xAsgAv);

         if( ratio > 0.0 && asg > 0.0 )
		 {
            avasg += asg*ratio;
            // use ASG as a stand-in for BSG and SSD SG
            // DO NOT include MF in average absorption
            avbsg += asg*ratio;
            avssg += asg*ratio;
            parts += ratio;
         }
      }
 
 
 void LtT84::CorTblMf::calcRow(int xRow) --- not sure if this is applicable to mineral filler
 {
	/* Calculations assume that volume of flask == wt of water
	 * (X ml water == X grams water) Thus these units are locked in
	 
	double sg = FLT_BLANK;   // specific gravity

	if (mw > 0.0)            // mass of water (volume of flask)
	{
		if (ms > 0.0)        // mass of sample
		{
			if (msw > 0.0)   // mass of sample and water
			{
				double denom = mw + ms - msw;
				if (denom > 0.0)
				{
					sg = ms / denom;
				}


 void LtT84::CorGrpMf::calcAvs()
 {
	double asg;
	double asgav = 0.0;
	int count = 0;
	int xr = 0;
    
	for (;;)
    {
		asg = row->getColAsDatum((int)MfTblC::cAsg)->getFltValue();

		if (asg > 0.0)
		{
			asgav += asg;
			++count;
		}
		++xr;
	}
	if (count > 0)
	{
		asgav /= count;
	}
    
	_daroot->updateEchoFld(COPARMsT84::IDF_mf_asg, sm);
}


***********************************************************************************/



create or replace view V_T84_Mineral_Filler as 

with mineral_segment_evaluation as (

     select  sample_id   -- used in the join clause
            ,segment_nbr -- used in the join clause
            
            ,case when volume_flask            > 0 and 
                       mass_dry_sample         > 0 and 
                       mass_water_and_sample   > 0 
                  then 1
                  else 0 
                   end as T84_Mineral_count
            
            ,case when volume_flask            > 0 and 
                       mass_dry_sample         > 0 and 
                       mass_water_and_sample   > 0 
                  then (mass_dry_sample / (volume_flask + mass_dry_sample - mass_water_and_sample))
                  else -1 
                   end as T84_Mineral_ASG
                  
       from Test_T84_Mineral
)

--------------------------------------------------------------------------------
-- main sql
--------------------------------------------------------------------------------

select  t84min.sample_id                                      as T84_Mineral_Sample_ID   -- key
       ,t84min.segment_nbr                                    as T84_Mineral_segment_nbr -- key
       
       /*-----------------------------------------------------------------------
         Description and Ratio
       -----------------------------------------------------------------------*/
       
       ,t84min.mineral_description                            as T84_Mineral_Description  
       ,t84min.mineral_ratio                                  as T84_Mineral_Ratio
       
       /*-----------------------------------------------------------------------
         user entered fields
       -----------------------------------------------------------------------*/
       
       ,t84min.volume_flask                                   as T84_Mineral_volume_flask
       ,t84min.mass_dry_sample                                as T84_Mineral_mass_dry_sample
       ,t84min.mass_water_and_sample                          as T84_Mineral_mass_water_and_sample
       ,t84min.temperature                                    as T84_Mineral_temperature
       
       /*-----------------------------------------------------------------------
         apparent specific gravity, from mineral_segment_evaluation
       -----------------------------------------------------------------------*/
       
       ,t84eval.T84_Mineral_ASG                               as T84_Mineral_Apparent_SG
       
       /*-----------------------------------------------------------------------
         average apparent specific gravity
       -----------------------------------------------------------------------*/
       
       ,case when avg(case when T84_Mineral_ASG > 0 then T84_Mineral_ASG end) over (partition by t84min.sample_id) is not null
             then avg(case when T84_Mineral_ASG > 0 then T84_Mineral_ASG end) over (partition by t84min.sample_id)
             else -1 end as T84_Mineral_Avg_ASG
        
       /*-----------------------------------------------------------------------
         support fields, used in calculations, not displayed
       -----------------------------------------------------------------------*/
       
       ,T84_Mineral_count       
       ,sum(T84_Mineral_count) over (partition by t84min.sample_id) as T84_Mineral_count_summ
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                      smpl
       join Test_T84                                 t84 on t84.sample_id      = smpl.sample_id
       join Test_T84_Mineral                      t84min on t84.sample_id      = t84min.sample_id
       
       join mineral_segment_evaluation           t84eval on t84min.sample_id   = t84eval.sample_id
                                                        and t84min.segment_nbr = t84eval.segment_nbr
       
       order by 
       T84_Mineral_Sample_ID, 
       T84_Mineral_segment_nbr
       ;









