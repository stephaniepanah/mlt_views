


--  T329 Moisture Content of Hot Mix    (2020)
-- WL110 Moisture in Asphalt Mix (Oven) (2018)
--  T110 Moisture in Asphalt Mix        (2011)


select * from V_T110_Moisture_in_Asphalt_Mix order by T110_Sample_Year desc, T110_Sample_ID
;



select * from V_T110_Moisture_in_Asphalt_Mix where to_number(T110_Sample_Year) >= 2000 -- 6 samples
 order by T110_Sample_Year desc
 ;
 
 
 
----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T110 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 1319	    1986	2011



select * from test_t110;




--------------------------------------------------------------
--------------------------------------------------------------

-- **** see far below for an exchange with John Ulrick ****

--------------------------------------------------------------
--------------------------------------------------------------


/***********************************************************************************

 T110 Moisture in Asphalt Mix
 
 W-11-1323-AC, W-11-1324-AC, W-11-1834-AC, W-06-0698-ACA, W-06-0699-ACA

 from MTest, Lt_T110_BA.cpp

 void LtT110_BA::CorGrpRoot::doCalcs()
 {
	double water, mix, moist;

	if (mix > 0.0 && water >= 0.0)
		moist = (100.0 * water) / mix;
 }

***********************************************************************************/


create or replace view V_T110_Moisture_in_Asphalt_Mix as 


select  t110.sample_id                                         as T110_Sample_ID
       ,t110.sample_year                                       as T110_Sample_Year
       ,t110.test_status                                       as T110_Test_Status
       ,t110.tested_by                                         as T110_Tested_by
       
       ,case when to_char(t110.date_tested, 'yyyy') = '1959'   then ' '
             else to_char(t110.date_tested, 'mm/dd/yyyy')      end
                                                               as T110_date_tested
            
       ,t110.date_tested                                       as T110_date_tested_DATE
       ,t110.date_tested_orig                                  as T110_date_orig
       
       ,t110.mass_wet_mix                                      as T110_mass_wet_mix
       ,t110.mass_water                                        as T110_mass_water
       
       ,pct_moisture                                           as T110_pct_moisture -- calculated
       ,t110.captured_pct_moisture                             as T110_captured_pct_moisture
       
       /*------------------------------------------------------------------------
         There are numerous instances of wet mix and water being interchanged
         
         All the original values are held in their respective _orig fields, 
         (mass_wet_mix_orig and mass_water_orig) and in captured_pct_moisture, 
         which is a field that should be calculated, but was captured for comparison's sake
         
         If correct, then these values also reside in their respective mass_wet_mix and mass_water fields, see above. 
         per my observation, this was only five of 1319 samples
         
         If incorrect, then mass_wet_mix_orig was assigned to mass_water and mass_water_orig was assigned to mass_wet_mix 
         
         The calculation above, percent_moisture, is run off the fields that should be
         
         fyi - all the calculated pct moisture fields in the T110 labtest in the 
         MLT windows, display the correct calculation, which utterly baffles me
       ------------------------------------------------------------------------*/
       
       ,t110.mass_wet_mix_orig                                 as T110_mass_wet_mix_orig
       ,t110.mass_water_orig                                   as T110_mass_water_orig
       
       ,t110.remarks                                           as T110_Remarks
       
       /*---------------------------------------------------------------------------
         table relationships
       ---------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl 
       join Test_T110                                     t110 on t110.sample_id = smpl.sample_id
       
       /*---------------------------------------------------------------------------
         calculations - percent moisture
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when (t110.mass_water >= 0) and (t110.mass_wet_mix > 0) 
                                then ((t110.mass_water / t110.mass_wet_mix) * 100)
                                else 0 end as pct_moisture from dual) pctmoisture
       ;









/*-----------------------------------------------------------------------------------

Thursday, September 10, 2020

Hi John,

I have a question regarding the T110 lab test, which was most recently run in 2011. 
There are 1319 samples. I am noticing that the wet mix and water fields have been 
incorrectly assigned (to each other, per my calculations and observations)

I am enclosing two documents

The first page of the Word document contains the code for the calculation and four samples as examples.
As far as I can determine, wet mix should be in the 500 gram range and water should be a few grams.

The calculation is: moist = 100.0*water / mix;

If you run that calculation on the samples from 97 and 89, you get the results in red (which are wrong)
If you switch wet mix and water and run the calculation, the results are correct.

What baffles me is that all the results are correct in the MLT windows for all the samples. 
How can that be?

If you look at the spreadsheet, you will see that only five samples (in blue) are assigned 
correctly and that all the others are incorrect.
I designated columns as _orig (columns H and I) and my corrections are in columns D and E
I added a calc_compare column to show the calculation if performed as the values were entered

thank you,
Stephanie


----------------------------
----------------------------


Saturday, September 12, 2020

Hello Stephanie,

You are correct, the Mass of mix should be the larger number and the Mass of water should be a small fraction of it

The original data storage of T110 (according to notes in mapT110.cpp) was:
SU 103
   -1  % moisture
   -2  wt mix
   -3  wt water

The WS-5 mapping for T110 is, according to mapT110.cpp:
SU 0x5b00
   1  % moisture
   3  mass mix
   2  mass water

I find code (in crunchT110.cpp, from 2011) to convert old data to:
SU 0x5b800
   1 % moisture
   2  mass mix
   3  mass water

I am assuming that your spreadsheet is a complete list of the T110 instances

My best conjecture as to what happened is this. 

When I was converting from WS-3 to WS-5 data storage I gave T110 the new SU of 0x5b800
I intended to convert the old Negative Number FCs (field codes) "straight across" 
to absolute-value equivalents but I inadvertently reversed Mass Water and Mass Mix

So T110s done after this have the 'reversed' mapping

Converting old (pre-2006) data was not an immediate priority and I didn't do it until 2011. 
When I wrote a program to convert old T110s then, I did convert the FCs "straight across" 
which left the converted data out of sync with the T110 mapping in mapT110.cpp

(The older T110s have correct results because they were done in pre-WS-5 
editions of MTEST which correctly used the WS-3 mappings)

If there are no more post-2006 samples than in the spreadsheet, the simplest thing to do 
might be to modify mapT110.ccp so lines 91-93 which are now:

      COSP_FLD(IDF_moisture, 1, IDG_main),
      COSP_FLD(IDF_wtmix, 3, IDG_main),
      COSP_FLD(IDF_water, 2, IDG_main),
      
become:

      COSP_FLD(IDF_moisture, 1, IDG_main),
      COSP_FLD(IDF_wtmix, 2, IDG_main),
      COSP_FLD(IDF_water, 3, IDG_main),
      
rebuild everything and then manually edit the post-2006 T110 samples so the proper values 
show up in the proper fields. Then all data and all current programs should be using the mappings:

   1 == % moisture
   2 == mass mix
   3 == mass water

John

-----------------------------------------------------------------------------------*/









