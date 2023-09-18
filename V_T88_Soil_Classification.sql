



select * from V_T88_Soil_Classification where sample_id = 'W-21-0080-SO'
--'W-19-0007-SO'
;




/*------------------------------------------------------------------------------

 from MTest, Lt_T88ut_BC.cpp
 
 int HydroCalcs::doCalcsGrad(double factor, int eh, int bPpFine) {
 
 // 2020-02-03
 const int nbreaks = 6;
 
 // sieve sizes:                            3",   #4,  #10,   #40,  #200, 2 micrometers
 static const double abreaks[nbreaks] = { 75.0, 4.75,  2.0, 0.425, 0.075, 0.002 }; 

 Calculate sand and gravel summary values
 
      Gravel:   Pass 3"      retained on #4        (75mm,    4.75mm ) 100%                 - percent passing #4
 Coarse sand:   Pass #4      retained on #10       (4.75mm,  2.0mm  ) percent passing #4   - percent passing #10
 Medium sand:   Pass #10     retained on #40       (2.0mm,   0.425mm) percent passing #10  - percent passing #40
   Fine sand:   Pass #40     retained on #200      (0.425mm, 0.075mm) percent passing #40  - percent passing #200
        Silt:   Pass #200    retained on .002mm    (0.075mm, 0.002mm) percent passing #200 - percent passing .002mm
        Clay:   Pass .002mm  percent passing .002mm 
    Colloids:   Pass .001mm  percent passing .001mm


	// clay and colloids do not have a lower bracket

	if (_tblPp[xpp].sv == 0.002)
        _classes[xClay] = _tblPp[xpp].pp;
        
	else 
    if (_tblPp[xpp].sv == 0.001)
        _classes[xColloids] = _tblPp[xpp].pp;

------------------------------------------------------------------------------*/


create or replace view V_T88_Soil_Classification as 

select  v_t88pp.sample_id        as sample_id
       ,v_t88pp.group_nbr        as group_nbr
       ,v_t88pp.segment_nbr      as segment_nbr       
       ,v_t88pp.sieve_size       as sieve_size
       
       --------------------------------------------------------------------
       -- use pct_retained_of_soil_type for retained values on
       -- #4 gravel, #10 coarse, #40 medium, #200 fine, 2µm silt
       --------------------------------------------------------------------
       
       ,lag(v_t88pp.pct_passing,1,100) over (partition by v_t88pp.sample_id 
        order by v_t88pp.sample_id, v_t88pp.group_nbr, v_t88pp.segment_nbr) - v_t88pp.pct_passing
        as pct_retained_of_soil_type
       
       -------------------------------------------------------------------- 
       -- pct_passing_lag is not display, but used in the calculation
       -- I am including it for verification
       --------------------------------------------------------------------
       
       ,lag(v_t88pp.pct_passing,1,100) over (partition by v_t88pp.sample_id 
        order by v_t88pp.sample_id, v_t88pp.group_nbr, v_t88pp.segment_nbr)
        as pct_passing_lag
        
       --------------------------------------------------------------------
       -- use pct_passing 2µm for clay and 1µm for colloids 
       --------------------------------------------------------------------
       
       ,v_t88pp.pct_passing      as pct_passing
       
       ,sieve.sieve_metric_in_mm as metric_mm

  from V_T88_sieves_Pct_Passing_Grid         v_t88pp
  join mlt_sieve_size                          sieve on (v_t88pp.sieve_size = sieve.sieve_customary or
                                                         v_t88pp.sieve_size = sieve.sieve_metric)
                                                    and  sieve.sieve_metric_in_mm in (75.0, 4.75,  2.0,  .425, .075,  .002, .001)
                                                                                     -- 3",   #4,  #10,   #40,  #200,  2µm,  1µm

 order by
 v_t88pp.sample_id,
 v_t88pp.group_nbr,
 v_t88pp.segment_nbr 
;









