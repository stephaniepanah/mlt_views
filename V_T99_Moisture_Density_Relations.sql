


-- will need to get Proctor Plot values:
-- optimum moisture pct
-- maximum density, kg/m^3
-- maximum density, pcf

-- good video on splines (c++)
-- https://www.youtube.com/watch?v=9_aJGUTePYo


select * from V_T99_Moisture_Density_Relations where T99_Sample_ID = 'W-18-0124-SO'
 order by T99_Sample_Year desc, T99_Sample_ID, T99seg_segment_nbr
 ;
 
 

select * from V_T99_Moisture_Density_Relations 
 order by T99_Sample_Year desc, T99_Sample_ID, T99seg_segment_nbr
 ;
 

--  T99 Moisture-Density Relations (2.5kg)   (current)
-- T180 Moisture-Density Relations (4.54 Kg) (current)



/***********************************************************************************
 
 The Proctor Plot and the Spline
 
 from MTest, LT_T99_Plot_C2.cpp // Do Proctor Plots
 ---------------------------------------------
 
 int LtT99base_C2::CorGrpRoot::collectPlotData(NM_proctor::ProctorTransfer &transfer)
 {
     szcpy(psz, bufb);  // MC (moisture content)
     psz = g_smToSz->cnvt(sm);  // Dry density
 
 
 void LtT99base_C2::CorGrpRoot::runPlot(bool doCurve)
 {
     NM_proctor::ProctorPlotter plotter;
     
     retval = plotter.calcCurve();
     
     if(doCurve)
     {
        optMC = plotter.getOptMc();
        maxDens = plotter.getMaxDens();
        
        if(ismetric)
           dens = maxDens/PCFtoKGM3;
        else
           dens = maxDens*PCFtoKGM3;
        
        retval = plotter.drawPlot();
 
 
 from MTest, lmProctor.cpp   ---- plotter
 ---------------------------------------------
 
 _drawer = new ProctorDrawer();
 
 int ProctorPlotter::calcCurve()
 {
     int retval = _drawer->calcCurve();
  
 
 from MTest, ProctorDrawer.cpp   ---- _drawer
 ---------------------------------------------
 
 int ProctorDrawer::drawPlot()
 {
 
 int ProctorDrawer::calcCurve()
 {
     Alglib_spline spline;
     spline.setInputs(_nTrials, _aTryX, _aTryY);
     spline.iniSplines();
     
     for(int xpt = 0; xpt < _nPts; ++xpt)
     {
        double yval = spline.getYatX(xval);
 
 
 from MTest, AlglibSpline.cpp
 ---------------------------------------------
 
 #include "alglibCurves.h"
 #include "\cm\alglib\alglib\interpolation.h"
 
 void Alglib_spline::setInputs(int npts, const double axvals[], const double ayvals[])
 {
 
 void Alglib_spline::iniSplines()
 {
    spline1dbuildcubic(ax, ay, _nInPts, natural_bound_type, 0.0, natural_bound_type, 0.0, _prot->_sinterp);
    // _prot->_sinterp --- output parameter, spline interpolant
    
 
 double Alglib_spline::getYatX(double xval)
 {
   double calcy = spline1dcalc(_prot->_sinterp, xval);
   return calcy;
 }
 
 
 from MTest, lmProctor_D8, interpolation.h
 ---------------------------------------------
 
 // This subroutine calculates the value of the spline at the given point X
 double spline1dcalc(const spline1dinterpolant &c, const double x);
 
 
 from \cm\alglib\alglib\interpolation.cpp (good grief)
 ---------------------------------------------
 
 void spline1dbuildcubic(const real_1d_array &x, const real_1d_array &y, const ae_int_t n, 
                         const ae_int_t boundltype, const double boundl, const ae_int_t boundrtype, 
                         const double boundr, spline1dinterpolant &c)
 {
    // This subroutine builds cubic spline interpolant
    // OUTPUT PARAMETERS: C - spline interpolant
    
    
 double spline1dcalc(const spline1dinterpolant &c, const double x)
 {
    spline1d_spline1dgriddiffcubicinternal(x, y, n, boundltype, boundl, boundrtype, boundr, &d, &a1, &a2, &a3, &b, &dt, _state);

***********************************************************************************/


/***********************************************************************************

https://www.sisense.com/blog/spline-interpolation-in-sql/

https://docs.oracle.com/cd/E57185_01/ESBTR/spline.html#spline_algorithm

@SPLINE - Applies a smoothing spline to a set of data points

A spline is a mathematical curve that smoothes or interpolates data

Syntax: 

@SPLINE (YmbrName [, s [, XmbrName [, XrangeList]]])

@SPLINE (T99seg_moisture_percent, 1, , T99seg_dry_density_customary) --- my attempt


YmbrName - A valid single member name that contains the dependent variable values used (when crossed with rangeList) to construct the spline.

s - Optional. A zero (0) or positive value that determines the smoothness parameter. The default value is 1.0.

XmbrName - Optional. A valid single member name that contains the independent variable values used (when crossed with rangeList) to construct the spline. 
The default independent variable values are 0,1,2,3, and so on.

XrangeList - Optional. A valid member name, a comma-delimited list of member names, cross dimension members, 
or a member set function or range function (including @XRANGE) that returns a list of members from the same dimension. 
If XrangeList is not specified, Essbase uses the level 0 members from the dimension tagged as Time.


"Sales Spline" = @SPLINE(Sales,2,,Jan:Jun);

             Colas     Actual    New York
               Sales       Sales Spline
               =====       ============
Jan             645         632.8941564
Feb             675         675.8247101
Mar             712         724.7394598
Apr             756         784.2860765
May             890         852.4398456
Jun             912         919.8157517


***********************************************************************************/



/***********************************************************************************

 T99 Moisture-Density Relations (2.5kg)
 
 W-18-0124-SO, W-18-0393-AG, W-18-1076-SO, W-17-0382-SO, W-17-0472-SO, W-16-1371-AG
 
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

 W-18-0124-SO   |CM|  (C) pcf    (M) grams
 W-13-0418-SO   |MM|  (M) kg/m3  (M) grams
 W-12-0609-SO   |CC|  (C) pcf    (C) lbs
 
 506 samples    |  |  W-19-1638-SO, W-18-2201-AG, W-17-1375-AG, four in 2000 and the remainder are pre-2000
 
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

       

create or replace view V_T99_Moisture_Density_Relations as 
 
with volume_sql as (

     select  sample_id as sample_id
     
            ,case when T99_method = 'A' or T99_method = 'C' then '0.000943 m³ (0.0333 cu ft)'
                  when T99_method = 'B' or T99_method = 'D' then '0.002124 m³ (0.075 cu ft)'
                  else ' ' end as Mold_Volume
     
            ,case when T99_method = 'A' or T99_method = 'C' then 0.000943
                  when T99_method = 'B' or T99_method = 'D' then 0.002124
                  else -1 end as Mold_Volume_metric
     
            ,case when T99_method = 'A' or T99_method = 'C' then 0.033333
                  when T99_method = 'B' or T99_method = 'D' then 0.075
                  else -1 end as Mold_Volume_customary
                  
       from Test_T99
)

,T99seg_sql as (

     select  sample_id   as Sample_ID
            ,segment_nbr as segment_nbr
            
            ,case when mass_specimen_and_tare >= 0 then mass_specimen_and_tare else 0 end as tmp_mass_specimen_and_tare
            ,case when mass_tare1             >= 0 then mass_tare1             else 0 end as tmp_mass_tare1
            ,case when mass_wet               >= 0 then mass_wet               else 0 end as tmp_mass_wet
            ,case when mass_dry               >= 0 then mass_dry               else 0 end as tmp_mass_dry
            ,case when mass_tare2             >= 0 then mass_tare2             else 0 end as tmp_mass_tare2
            
       from Test_T99_segments
)

select  t99.sample_year                         as T99_Sample_Year
       ,t99.sample_id                           as T99_Sample_ID
       ,t99.test_status                         as T99_Test_Status
       ,t99.tested_by                           as T99_Tested_by
       
       ,case when to_char(t99.date_tested, 'yyyy') = '1959'
             then ' '
             else to_char(t99.date_tested, 'mm/dd/yyyy')
             end                                as T99_date_tested
            
       ,t99.date_tested                           as T99_date_tested_DATE
       ,t99.date_tested_orig                      as T99_date_tested_orig
       
       ,t99.customary_metric                    as T99_customary_metric
       
       /*-------------------------------------------------------------
         Method and Mold Volume, from MTest, Lt_T99b_C2.cpp
         method 'A' or 'C' : 0.000943 m³ (0.0333 cu ft) : std vol, 4" mold
         method 'B' or 'D' : 0.002124 m³ (0.0750 cu ft) : std vol, 6" mold
       -------------------------------------------------------------*/
       
       ,t99.T99_method                          as T99_Method
       ,Mold_Volume                             as T99_Mold_Volume
       
       /*-------------------------------------------------------------
         Proctor Plot - calculated results from plotting
       -------------------------------------------------------------*/
       
       -- Optimum moisture, percent
       -- Maximum density, kg/m^3
       -- Maximum density, pcf
       
       /*-------------------------------------------------------------
         Compaction, Moisture and Maximum Density
         these values are user-entered, after the plot values
         have been calculated
       -------------------------------------------------------------*/
       
       ,case when t99.pct_compaction            >= 0 then to_char(t99.pct_compaction)            else ' ' end as T99_pct_compaction
       ,case when t99.rptd_optimum_moisture_pct >= 0 then to_char(t99.rptd_optimum_moisture_pct) else ' ' end as T99_rptd_optimum_moisture_pct
       ,case when t99.maximum_density           >= 0 then to_char(t99.maximum_density)           else ' ' end as T99_maximum_density
       
       /*-------------------------------------------------------------
         segments / Trials
       -------------------------------------------------------------*/

       ,case when t99seg.segment_nbr     is not null then to_char(t99seg.segment_nbr)            else ' ' end as T99seg_segment_nbr
       ,case when t99seg.trial_id        is not null then to_char(t99seg.trial_id)               else ' ' end as T99seg_trial_id
       
       ,case when t99seg.mass_specimen_and_tare >= 0 then to_char(t99seg.mass_specimen_and_tare) else ' ' end as T99seg_mass_specimen_and_tare
       ,case when t99seg.mass_tare1             >= 0 then to_char(t99seg.mass_tare1)             else ' ' end as T99seg_mass_tare1
       ,case when mass_specimen_grams           >= 0 then to_char(mass_specimen_grams)           else ' ' end as T99seg_mass_specimen_grams
       ,case when mass_specimen_pounds          >= 0 then to_char(mass_specimen_pounds)          else ' ' end as T99seg_mass_specimen_pounds
       
       ,case when t99seg.pan_nbr         is not null then to_char(t99seg.pan_nbr)                else ' ' end as T99seg_Pan_number
       
       ,case when t99seg.mass_wet               >= 0 then to_char(t99seg.mass_wet)               else ' ' end as T99seg_mass_wet
       ,case when t99seg.mass_dry               >= 0 then to_char(t99seg.mass_dry)               else ' ' end as T99seg_mass_dry
       ,case when t99seg.mass_tare2             >= 0 then to_char(t99seg.mass_tare2)             else ' ' end as T99seg_mass_tare2
       ,case when moisture_percent              >= 0 then to_char(moisture_percent)              else ' ' end as T99seg_moisture_percent
       
       ,case when wet_density_metric            >= 0 then to_char(wet_density_metric)            else ' ' end as T99seg_wet_density_metric
       ,case when wet_density_customary         >= 0 then to_char(wet_density_customary)         else ' ' end as T99seg_wet_density_customary
       ,case when dry_density_metric            >= 0 then to_char(dry_density_metric)            else ' ' end as T99seg_dry_density_metric
       ,case when dry_density_customary         >= 0 then to_char(dry_density_customary)         else ' ' end as T99seg_dry_density_customary
       
       ,case when t99seg.exclude_segment is not null then to_char(t99seg.exclude_segment)        else ' ' end as T99seg_exclude_segment
       
       -- not sure that I will retain this
       ,case when t99seg.mass_specimen_captured is not null
             then case when t99seg.mass_specimen_captured >= 0
                       then to_char(t99seg.mass_specimen_captured)
                       else ' ' end -- is -1
             else ' ' end -- is null
             as T99seg_mass_specimen_captured
       
       ,t99.remarks                             as T99_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T99                                 t99 on t99.sample_id      = smpl.sample_id
  join volume_sql                                   on t99.sample_id      = volume_sql.sample_id
  
  left outer join Test_T99_segments          t99seg on t99.sample_id      = t99seg.sample_id
  
  left outer join T99seg_sql                        on t99seg.sample_id   = T99seg_sql.sample_id
                                                   and t99seg.segment_nbr = T99seg_sql.segment_nbr
       
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
                          
  order by T99_Sample_ID, T99seg_segment_nbr
  ;
 
 







-----------------------------------------------------------
-- Diagnostics
-----------------------------------------------------------

-----------------------------------------------------------
-- find any samples containing both T99 and T180
-----------------------------------------------------------

select t99.sample_id from test_t99 t99
 where t99.sample_id in (select t180.sample_id from test_t180 t180
                          where t180.sample_id = t99.sample_id)

;

/*

--- 11 samples

W-11-0686-SO
W-11-0756-SO
W-09-0241-SO
W-06-0407-SO
W-01-1983-SO
W-01-1984-SO

W-66-9001-GEO
W-66-9002-GEO
W-66-9003-GEO
W-66-9004-GEO
W-66-9011-GEO

*/


select count(*), min(sample_year), max(sample_year) from Test_T99 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 746	    1985	2020


select count(*), min(sample_year), max(sample_year) from Test_T99;
-- count    minYr   maxYr
-- 753	    1960	2020


select * from Test_T99 order by Sample_Year desc, Sample_ID;


select * from Test_T99_segments;



select count(distinct(Sample_ID)) from Test_T99_segments; -- 727
-- therefore, the T99 count of 753 indicates that not all samples contain segments
-- 753 - 727 = 26


-- identify those 26 samples w/o segments

select hdr.sample_id from test_t99 hdr
 where hdr.sample_id not in (select seg.sample_id from test_t99_segments seg
                              where seg.sample_id = hdr.sample_id)
;
/* the 26 T99 header samples w/o segments

W-13-0418-SO, W-09-0241-SO

W-99-0018-SO, W-99-0115-SO, W-99-0587-SO
W-96-1208-SO, W-96-1209-SO, W-95-0182-SO, W-94-0024-SO
W-93-0025-SO, W-93-0026-SO, W-92-0627-SO, W-92-0628-SO

W-89-0971-SO, W-89-0972-SO, W-89-1255-SO, W-89-1302-SO
W-86-0051-SO, W-86-1070-SO, W-86-1071-SO

W-60-0100-SO
W-66-9001-GEO, W-66-9002-GEO, W-66-9003-GEO, W-66-9004-GEO, W-66-9011-GEO

*/


select customary_metric, count(customary_metric) from test_t99
 group by customary_metric
 order by customary_metric
 ;
/*
' '  	506 --- this leads me to believe that customary_metric is not very important
CC	      3
CM	    179
MM	     38
*/




select T99_method, count(T99_method) from test_t99
 group by T99_method
 order by T99_method
 ;
/*
' '   9
A	163
B	  6
C	558
D	 17
*/





-- headers w/o segments

select * from V_T99_Moisture_Density_Relations
 where T99_Sample_ID in 
 (
   'W-13-0418-SO', 'W-09-0241-SO', 
   'W-99-0018-SO', 'W-99-0115-SO', 'W-99-0587-SO',
   'W-96-1208-SO', 'W-96-1209-SO', 'W-95-0182-SO', 'W-94-0024-SO', 
   'W-93-0025-SO', 'W-93-0026-SO', 'W-92-0627-SO', 'W-92-0628-SO',  
   'W-89-0972-SO', 'W-89-1255-SO', 'W-89-1302-SO', 
   'W-86-0051-SO', 'W-86-1070-SO', 'W-86-1071-SO', 'W-89-0971-SO', 
   'W-60-0100-SO', 'W-66-9001-GEO', 'W-66-9002-GEO', 'W-66-9003-GEO', 'W-66-9004-GEO', 'W-66-9011-GEO'
 );




select ''''||hdr.sample_id||''''||', ' from test_t99 hdr
 where hdr.sample_id not in (select seg.sample_id from test_t99_segments seg
                              where seg.sample_id = hdr.sample_id)
;









