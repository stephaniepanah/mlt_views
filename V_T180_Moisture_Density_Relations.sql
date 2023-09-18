


-- will need to get Proctor Plot values:
-- optimum moisture pct
-- maximum density, kg/m^3
-- maximum density, pcf


select * from V_T180_Moisture_Density_Relations 
 order by T180_Sample_Year desc, T180_Sample_ID, T180seg_segment_nbr
 ;
 
 

--  T99 Moisture-Density Relations (2.5kg)   (current)
-- T180 Moisture-Density Relations (4.54 Kg) (current)



select count(*), min(sample_year), max(sample_year) from Test_T180 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 169	    1987	2020


select count(*), min(sample_year), max(sample_year) from Test_T180;
-- count    minYr   maxYr
-- 174	    1966	2020


select * from Test_T180 order by Sample_Year desc, Sample_ID;


select * from Test_T180_segments;


select count(distinct(Sample_ID)) from Test_T180_segments; -- 166
-- therefore, the T180 count of 174 indicates that not all samples contain segments
-- 174 - 166 = 8


select hdr.sample_id from test_t180 hdr
 where hdr.sample_id not in (select seg.sample_id from test_t180_segments seg
                              where seg.sample_id = hdr.sample_id)
;
/* the 8 T180 header samples w/o segments

W-07-0802-SO
W-94-2027-AG
W-94-2128-AG
W-66-9001-GEO
W-66-9002-GEO
W-66-9003-GEO
W-66-9004-GEO
W-66-9011-GEO

*/


select customary_metric, count(customary_metric) from test_t180
 group by customary_metric
 order by customary_metric
 ;
/*
' '  	24
CC	    1
CM	    114
MC	    6
MM	    29
*/


select * from test_t180 where customary_metric = ' ' order by sample_year desc, sample_id
;



select T180_method, count(T180_method) from test_t180
 group by T180_method
 order by T180_method
 ;
/*
' '   	2
A	    15
B	    2
C	    16
D	    139
*/




/***********************************************************************************

 T180 Moisture-Density Relations (4.54kg)
 
 W-20-0033, W-20-0682-SO, W-19-0520-SO, W-19-0999-SO, W-18-0884-SO, W-17-1952-SO
 
 ------------------------------------------
 
 Method A   Mold volume: 0.000943 m^3 (0.0333 cu ft) // standard volume for 4" mold (m3)
 Method B   Mold volume: 0.002124 m^3 (0.075  cu ft) // standard volume for 6" mold (m3)
 Method C   Mold volume: 0.000943 m^3 (0.0333 cu ft)
 Method D   Mold volume: 0.002124 m^3 (0.075  cu ft)
 
 from lmtmspec_D8 solution: mapT99.cpp
 
 4-98 (JCU): drop -8; it is redundant with -99
 -8    * mold volume
 -99   * test method
 -1    * optimum moisture percentage
 -2	   * maximum density lbs/cu ft
 -4    * maximum density kg/m3
 -3	   * percent field compaction
 
 ------------------------------------------
 
 CustomaryOrMetric

 [0] Maximum Density  (C) pcf    (M) kg/m3
 [1] Weight           (C) lbs    (M) grams

 W-19-0397-SO   |CM|  (C) pcf    (M) grams
 W-18-1306-SO   |MM|  (M) kg/m3  (M) grams
 W-12-0019-AG   |CC|  (C) pcf    (C) lbs
 W-03-0515-AG   |MC|  (M) kg/m3  (C) lbs
  
 24 samples     |  |  W-20-0207, W-20-0682-SO, W-19-0520-SO, 
                      W-19-0523-SO, W-19-0984-AG, W-18-1216-SO and the remainder are pre-2000
 
 from lmtmspec_D8 solution: mapT99.cpp
 
 const units_legalvals_t UnitSettingsT99base_C2::_us_legalvals[us_nuc] = {
	"MC",    // us_xresult     // doesn't affect any fields
	"CM"     // us_xwt
 };
 
 ------------------------------------------
 
 from MTest, Lt_T99c_C2.cpp, void LtT99base_C2::CorRowLauf::calcLauf(unsigned id)
 {
		// mass of specimen (all - tare)
        
		if (all >= 0.0)                       // mass_specimen_and_tare >= 0 (my notes)
		{
			double tare = <get data>
			if (tare < 0.0) tare = 0.0;
            
			double wtSpec = all - tare;       // mass of specimen (my notes)

			if (ismetric)
			{
				wtSpecM = wtSpec;
				wtSpecC = wtSpec / LBStoG;    // convert to Customary (not my notes)
			}
			else
			{
				wtSpecC = wtSpec;
				wtSpecM = wtSpec * LBStoG;
			}
		}
 
		// moisture: % moisture = 100*(WetWt - dryWt)/(DryWt - tare)

		if (dry > 0.0 && wet >= dry)
		{
			double tare = <get data>
			if (tare < 0.0) tare = 0.0;
			mc = (wet - dry) / (dry - tare);  // moisture_content
			mcp = 100.0*mc;                   // moisture percent
		}
        
        // wet density
        
        if (wtSpecM > 0.0)
		{
			if (vol > 0.0) // metric
				// convert grams to kg: /1000
				wetDensM = wtSpecM / (vol*1000.0); // (mass_specimen_grams / (Mold_Volume_metric * 1000)
		}
		if (wtSpecC > 0.0) // customary
		{
			if (vol > 0.0)
				wetDensC = wtSpecC / vol;          // (mass_specimen_pounds / Mold_Volume_customary)
		}
        
        // dry density
        
		if (mc >= 0.0)
		{
			if (wetDensM >= 0.0) // metric
				dryDensM = wetDensM / (mc + 1.0);
                
			if (wetDensC >= 0.0) // customary
				dryDensC = wetDensC / (mc + 1.0);
		}

***********************************************************************************/

       

create or replace view V_T180_Moisture_Density_Relations as 
 
with volume_sql as (

     select  sample_id as sample_id
     
            ,case when T180_method = 'A' or T180_method = 'C' then '0.000943 m³ (0.0333 cu ft)'
                  when T180_method = 'B' or T180_method = 'D' then '0.002124 m³ (0.075 cu ft)'
                  else ' ' end as Mold_Volume
     
            ,case when T180_method = 'A' or T180_method = 'C' then 0.000943
                  when T180_method = 'B' or T180_method = 'D' then 0.002124
                  else -1 end as Mold_Volume_metric
     
            ,case when T180_method = 'A' or T180_method = 'C' then 0.033333
                  when T180_method = 'B' or T180_method = 'D' then 0.075
                  else -1 end as Mold_Volume_customary
                  
       from Test_T180
)

,T180seg_sql as (

     select  sample_id   as Sample_ID
            ,segment_nbr as segment_nbr
            
            ,case when mass_specimen_and_tare >= 0 then mass_specimen_and_tare else 0 end as tmp_mass_specimen_and_tare
            ,case when mass_tare1             >= 0 then mass_tare1             else 0 end as tmp_mass_tare1
            ,case when mass_wet               >= 0 then mass_wet               else 0 end as tmp_mass_wet
            ,case when mass_dry               >= 0 then mass_dry               else 0 end as tmp_mass_dry
            ,case when mass_tare2             >= 0 then mass_tare2             else 0 end as tmp_mass_tare2
            
       from Test_T180_segments
)

select  t180.sample_year                         as T180_Sample_Year
       ,t180.sample_id                           as T180_Sample_ID
       ,t180.test_status                         as T180_Test_Status
       ,t180.tested_by                           as T180_Tested_by
       
       ,case when to_char(t180.date_tested, 'yyyy') = '1959'
             then ' '
             else to_char(t180.date_tested, 'mm/dd/yyyy')
             end                                 as T180_date_tested
            
       ,t180.date_tested                           as T180_date_tested_DATE
       ,t180.date_tested_orig                      as T180_date_tested_orig
       
       ,t180.customary_metric                    as T180_customary_metric
       
       /*-------------------------------------------------------------
         Method and Mold Volume, from MTest, Lt_T99b_C2.cpp
         method 'A' or 'C' : 0.000943 m³ (0.0333 cu ft) : std vol, 4" mold
         method 'B' or 'D' : 0.002124 m³ (0.0750 cu ft) : std vol, 6" mold
       -------------------------------------------------------------*/
       
       ,t180.T180_method                         as T180_Method
       ,Mold_Volume                              as T180_Mold_Volume
       
       /*-------------------------------------------------------------
         Proctor Plot - calculated results from plotting
       -------------------------------------------------------------*/
       
       -- Optimum moisture, percent
       -- Maximum density, kg/m^3
       -- Maximum density, pcf
       
       /*-------------------------------------------------------------
         Compaction, Moisture and Density
       -------------------------------------------------------------*/
       
       ,case when t180.pct_compaction            >= 0 then to_char(t180.pct_compaction)            else ' ' end as T180_pct_compaction
       ,case when t180.reported_optimum_moisture_pct >= 0 then to_char(t180.reported_optimum_moisture_pct) else ' ' end as T180_rptd_optimum_moisture_pct
       ,case when t180.maximum_density           >= 0 then to_char(t180.maximum_density)           else ' ' end as T180_maximum_density
       
       /*-------------------------------------------------------------
         segments / Trials
       -------------------------------------------------------------*/

       ,case when t180seg.segment_nbr     is not null then to_char(t180seg.segment_nbr)            else ' ' end as T180seg_segment_nbr
       ,case when t180seg.trial_id        is not null then to_char(t180seg.trial_id)               else ' ' end as T180seg_trial_id
       
       ,case when t180seg.mass_specimen_and_tare >= 0 then to_char(t180seg.mass_specimen_and_tare) else ' ' end as T180seg_mass_specimen_and_tare
       ,case when t180seg.mass_tare1             >= 0 then to_char(t180seg.mass_tare1)             else ' ' end as T180seg_mass_tare1
       ,case when mass_specimen_grams            >= 0 then to_char(mass_specimen_grams)            else ' ' end as T180seg_mass_specimen_grams
       ,case when mass_specimen_pounds           >= 0 then to_char(mass_specimen_pounds)           else ' ' end as T180seg_mass_specimen_pounds
       
       ,case when t180seg.pan_nbr         is not null then to_char(t180seg.pan_nbr)                else ' ' end as T180seg_Pan_number
       
       ,case when t180seg.mass_wet               >= 0 then to_char(t180seg.mass_wet)               else ' ' end as T180seg_mass_wet
       ,case when t180seg.mass_dry               >= 0 then to_char(t180seg.mass_dry)               else ' ' end as T180seg_mass_dry
       ,case when t180seg.mass_tare2             >= 0 then to_char(t180seg.mass_tare2)             else ' ' end as T180seg_mass_tare2
       ,case when moisture_percent               >= 0 then to_char(moisture_percent)               else ' ' end as T180seg_moisture_percent
       
       ,case when wet_density_metric             >= 0 then to_char(wet_density_metric)             else ' ' end as T180seg_wet_density_metric
       ,case when wet_density_customary          >= 0 then to_char(wet_density_customary)          else ' ' end as T180seg_wet_density_customary
       ,case when dry_density_metric             >= 0 then to_char(dry_density_metric)             else ' ' end as T180seg_dry_density_metric
       ,case when dry_density_customary          >= 0 then to_char(dry_density_customary)          else ' ' end as T180seg_dry_density_customary
       
       ,case when t180seg.exclude_segment is not null then to_char(t180seg.exclude_segment)        else ' ' end as T180seg_exclude_segment
       
       -- not sure that I will retain this
       ,case when t180seg.mass_specimen_captured is not null
             then case when t180seg.mass_specimen_captured >= 0
                       then to_char(t180seg.mass_specimen_captured)
                       else ' ' end -- is -1
             else ' ' end -- is null
             as T180seg_mass_specimen_captured
       
       ,t180.remarks                             as T180_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T180                               t180 on t180.sample_id      = smpl.sample_id
  join volume_sql                                   on t180.sample_id      = volume_sql.sample_id
  
  left outer join Test_T180_segments        t180seg on t180.sample_id      = t180seg.sample_id
  
  left outer join T180seg_sql                       on t180seg.sample_id   = T180seg_sql.sample_id
                                                   and t180seg.segment_nbr = T180seg_sql.segment_nbr
       
  /*-------------------------------------------------------------
    calculations
  -------------------------------------------------------------*/
  
  -- mass_specimen_grams
  cross apply (select case when tmp_mass_specimen_and_tare >= tmp_mass_tare1
                           then tmp_mass_specimen_and_tare  - tmp_mass_tare1
                           else -1 end as mass_specimen_grams from dual)  wtSpecM
  
  -- mass_specimen_pounds, 453.592 grams per pound
  cross apply (select case when mass_specimen_grams >= 0 then round((mass_specimen_grams / 453.592),4)
                           else -1 end as mass_specimen_pounds from dual) wtSpecC
                           
  -- moisture_content
  cross apply (select case when tmp_mass_dry > 0 and tmp_mass_wet >= tmp_mass_dry
                           then ((tmp_mass_wet - tmp_mass_dry) / (tmp_mass_dry - tmp_mass_tare2))
                           else -1 end as moisture_content from dual) mc

  -- moisture_percent
  cross apply (select round((moisture_content * 100),4) as moisture_percent from dual) mcp
  
  -- wet_density_metric
  cross apply (select case when mass_specimen_grams > 0 and Mold_Volume_metric > 0
                           then round((mass_specimen_grams / (Mold_Volume_metric * 1000)),3)
                           else -1 end as wet_density_metric from dual) wetDensM
  
  -- wet_density_customary
  cross apply (select case when mass_specimen_pounds > 0 and Mold_Volume_customary > 0
                           then round((mass_specimen_pounds / Mold_Volume_customary),3)
                           else -1 end as wet_density_customary from dual) wetDensC
  
  -- dry_density_metric
  cross apply (select case when moisture_content >= 0 and wet_density_metric >= 0
                           then round((wet_density_metric / (moisture_content + 1.0)),3)
                           else -1 end as dry_density_metric from dual) dryDensM
  
  -- dry_density_customary
  cross apply (select case when moisture_content >= 0 and wet_density_customary >= 0
                           then round((wet_density_customary / (moisture_content + 1.0)),3)
                           else -1 end as dry_density_customary from dual) dryDensC
                          
  order by T180_Sample_ID, T180seg_segment_nbr
  ;
 
 







-- headers w/o segments

select * from V_T180_Moisture_Density_Relations
 where T180_Sample_ID in 
 (
   'W-07-0802-SO',  'W-94-2027-AG',  'W-94-2128-AG', 
   'W-66-9001-GEO', 'W-66-9002-GEO', 'W-66-9003-GEO', 'W-66-9004-GEO', 'W-66-9011-GEO'
 );




select ''''||hdr.sample_id||''''||', ' from test_t180 hdr
 where hdr.sample_id not in (select seg.sample_id from test_t180_segments seg
                              where seg.sample_id = hdr.sample_id)
;









