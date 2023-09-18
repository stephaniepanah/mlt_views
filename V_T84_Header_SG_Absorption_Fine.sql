



select * from V_T84_Header_SG_Absorption_Fine
 where T84_Sample_ID like 'W-21%'
 order by T84_Sample_Year desc, T84_Sample_ID
;




select * from V_T84_Stockpile 
 order by T84_Stk_Sample_Year desc, T84_Stk_Sample_ID, T84_Stk_stockpile, T84_Stk_segment_nbr
 ;




select * from V_T84_Mineral_Filler
 order by T84_Mineral_Sample_Year desc, T84_Mineral_Sample_ID, T84_Mineral_segment_nbr
 ;




select count(*), min(sample_year), max(sample_year) from Test_T84 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 548	    1984	2021


select * from test_t84_stockpile where sample_id like 'W-20-%'
;



/***********************************************************************************

 T84 Specific Gravity and Absorption of Fine Aggregate

 W-21-0090-AG, W-21-0127-AG, W-21-0136-SAA, W-21-0164-AG
 W-20-0035,    W-20-0036,    W-20-0170,     W-20-0287, W-20-0323
 W-19-0085-AG, W-19-0585-AG, W-19-0719-AC, W-19-0728-AC
 W-18-0036-AC, W-18-0391-AC, W-17-0338-AG, W-17-0998-AC

 CustomaryOrMetric
 -----------------
 [0] reporting units 'M' = metric, 'C' = customary
 W-18-0036-AC |C| Customary - temperature: Fahrenheit
 W-17-0509-AC |M| Metric    - temperature: Celsius


 from MTest, Lt_T84_B5_da.cpp, void LtT84::CorTblSp::calcRow(int xRow)

 Calculations assume that volume of flask = mass of water (X ml water = X grams water)
  
 CALCULATIONS
 -------------------------------------------------------------

 bulk specific gravity: BSG + dry wt  / (vol flask - (wtsamp+water - SSDwt) )

 SSD  specific gravity: SSDSG = SSDwt / (vol flask - (wtsamp&water - SSDwt) )

 apparent specific gravity:
     ASG = dry wt / ((vol flask - (wtsamp&water - SSDwt)) - (SSDwt - dry wt) )
         = dry wt /  (vol flask + dry wt - wtsamp&water)

 fine percent absorption: Absorption = 100 * (SSDwt - dry wt) / dry wt
 
 calculate the wt water + sample
 wt water & sample = wt flask & water & sample - wt flask
 wt flask is allowed to equal 0 in case wtwater&sample is pre-tared
 
 Do not allow blank tare = 0; wt flask MUST be entered. (DW 12-93)
 
 1-98 (JCU): NOTES:
  Vol flask (ml) converts to wt of water
  AASHTO's formula for ASG is:
    ASG = wtDrySample / ( wtFlask&Water - wtFlask&Sample&water + wtSSDsample)
    The version here drops wtFlask from the middle two entries
 
 NOTE: AASHTO (1993) gives a conversion of ml water to gms: gms = 0.9975 * volume, ml
 
 -------------------------------------------------------------
 Calculate summary averages
 Use ASG of mineral filler as a standin for BSG, SSDSG of mineral filler
 ("Mix Design Methods", MS-2 6th ed (1993), p. 48)
 Average of SG uses the formula: sum(part[i]) / sum( (part[i]/SG[i]) ) (ibid, p. 47)
 Average for Pba (absorbed asphalt) does NOT include portion of mineral filler


 from MTest, Lt_T84_B5_da.cpp                // my notes

 if (mw > 0.0)                               // mass of water (volume of flask)
 {
    if (mssd > 0.0)                          // mass SSD
    {
        if (ms > 0.0)                        // mass dry sample
        {
            if (mswf > 0.0)                  // mass sample water flask
                cancalc = true;
        }
        
 if (cancalc)
 {
	if (mf >= 0.0)                           // mass flask
	{ 
		// don't allow tared wt flask + sample + water

		msw    = mswf - mf;                  // mass sample water = mass sample water flask – mass flask
		denbsg = mw - msw + mssd;            // denominator for bsg
		denasg = mw - msw + ms;	             // denominator for asg

		if (denbsg > 0.0 && denasg > 0.0)
		{
			bsg   = ms   / denbsg;           // or (ms   / (mw - msw + mssd))  Bulk SG
			ssdsg = mssd / denbsg;           // or (mssd / (mw - msw + mssd))  SSD SG
			asg   = ms   / denasg;           // or (ms   / (mw - msw + ms))    Apparent SG
			abs   = 100.0 * (mssd - ms) / ms;                                  Absorption pct
		}
	}
 }

***********************************************************************************/


create or replace view V_T84_Header_SG_Absorption_Fine as


select  t84.sample_id                              as T84_Sample_ID
       ,t84.sample_year                            as T84_Sample_Year
       ,t84.test_status                            as T84_test_status
       ,t84.tested_by                              as T84_tested_by
       
       ,case when to_char(t84.date_tested, 'yyyy') = '1959' then ' '
             else to_char(t84.date_tested, 'mm/dd/yyyy') end
                                                   as T84_dt_tested
            
       ,t84.date_tested                            as T84_date_tested_DATE
       ,t84.date_tested_orig                       as T84_date_tested_orig
       
       ,t84.customary_metric                       as T84_customary_metric
       
       ,t84.remarks                                as T84_remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                     smpl
  join Test_T84                                t84 on t84.sample_id = smpl.sample_id 
 ;









