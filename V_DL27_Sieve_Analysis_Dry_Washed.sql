


-- DL11 Sieve Analysis, fine wash T11/T27     (2020)
-- DL27 Sieve Analysis, Complete Dry/Washed   (2020)
-- T30  Sieve Analysis of Extracted Aggregate (2020)
-- T37  Sieve Analysis of Mineral Filler      (1994)



select * from V_DL27_Sieve_Analysis_Dry_Washed 
 where DL27_Sample_Year = '2020'
 order by DL27_Sample_Year desc, DL27_Sample_ID, DL27_segment_nbr
;




select * from V_DL27_Sieve_Analysis_Dry_Washed 
 where DL27_Sample_ID in ('W-20-0036', 'W-20-0138', 'W-20-0660', 'W-17-0876-AG')
 order by DL27_Sample_Year desc, DL27_Sample_ID, DL27_segment_nbr
;





select count(*), min(sample_year), max(sample_year) from Test_DL27 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 1160	    1988	2019
-- 1168 including 1960




/***********************************************************************************

 DL27 Sieve Analysis, Complete Dry/Washed
 
 W-18-0078-AG, W-18-0120-AG, W-17-0014-AG, W-17-0043-SO, W-17-0116-SO

 CustomaryOrMetric
 -----------------
 W-18-0078-AG |C| Sieve Units, Customary
 W-03-0737-AG |M| Sieve Units, Metric (very few instances of metric)
 W-02-0433-AC |M| Sieve Units, Metric
 
   
  from TMtest, Lt_DL27_BC.cpp, calcGrad()            // DL27_segments percent passing
  
  void LtDL27_BC::CorGrpRoot::calcGrad() {           // calculate percent passing (manual calcs: must get input data)
    
	double wdry     = Wash total dry mass            // calculated
	double totdry   = Wash total dry mass            // need a total dry wt for cross-check
    double wtwashed = mass washed
    double totwt    = 0.0;                           // 'pan', no wash adjustment: 'dry' calculations
	double fnum     = 100.0
	int nr, xr = 0;
	int xpan = -1;

	if (totdry < 0.0)  return;                       // if Wash total dry mass < 0 return

	if (wtwashed >= 0.0) {
	    totwt = totdry - wtwashed;                   // 'pan' -- wdry - wtwashed;
	    if (totwt < 0.0) return;
	}

	double *avals = new double[nr];
	array<String^>^ asvs = gcnew array<String^>(nr);

	for (xr = 0; xr < nr; ++xr)
	{
		if (val < 0.0) return;

		totwt += val;                                // sum mass retained
		avals[xr] = val;                             // array of accumulated totals

		asvs[xr] = cda->getSmValue();
		double sv = cda->getFltValue();
        
		if (sv == 0.0)                               // pan
		    xpan = xr;
	}

	if (totwt <= 0.0) return;

	if (totwt < totdry*0.997 || totwt > totdry*1.003) { --- perform +/-0.3% check
        fmtrange[] = " Sum of masses: %f is not within 0.3%% of entered total: %f "
		return;
	}
	
	// use totdry, not sum (old totwt value), in these calcs
	totwt = 100.0 / totdry; // calc_totwt_complete = 100 / calc_total_dry_mass (the Factor)

	// if pan is present, it must be the last wt retained
	if (xpan >= 0)
	    --nr; // kill the pan for conversion to % passing

	for (xr = 0; xr < nr; ++xr) {
		fnum -= avals[xr] * totwt;
		avals[xr] = fnum;
	}
 }
                    
***********************************************************************************/


create or replace view V_DL27_Sieve_Analysis_Dry_Washed as

/*-------------------------------------------------------------
  DL27 calculated header values
  obtain moisture_ratio, pct_moisture and total_dry_mass
-------------------------------------------------------------*/

with DL27_sql as (

     select sample_id as sample_id
     
     /*------------------------------------------------------------------------------
       Moisture Ratio: from Mtest, Lt_DL27_BC.cpp, calcMD()
       
       if (mdry > 0.0 && mwet >= mdry) ratio = ((mwet - mdry) / mdry)
       used for pct_moisture and total_dry_mass
       
       if (mdry > 0.0 && mwet >= mdry) mpct = (((mwet - mdry) / mdry) * 100.0)
       ....or, Moisture Ratio * 100
     ------------------------------------------------------------------------------*/
  
     ,case when (mass_dry > 0 and mass_wet >= mass_dry) then  ((mass_wet - mass_dry) / mass_dry)        else -1 end as moisture_ratio
     ,case when (mass_dry > 0 and mass_wet >= mass_dry) then (((mass_wet - mass_dry) / mass_dry) * 100) else -1 end as pct_moisture
      
     /*---------------------------------------------------------------------------
       Wash: from TMtest, Lt_DL27_BC.cpp calcWash() to find Total Dry Mass
       
       // do moisture adjustment if there is one                 my notes:
       if (wwet > 0.0)                                           if (mass_wet_total > 0)
       {
         if ((mwet - mdry) / mdry) >= 0.0                        if (mass_wet >= mass_dry and mass_dry > 0)
              wdry = wwet  / (1.0 + ((mwet - mdry) / mdry));         mass_wet_total / (1.0 + (mass_wet - mass_dry) / mass_dry))
         else                                                    else
              wdry = wwet; // no correction                          mass_wet_total
    
       The samples below are where DL27_calc_total_dry_mass follows the logic above but Total Dry Mass is blank.
       my calculations yield values. weird
       W-98-0168-ACB, W-98-0168-ACEL, W-98-0168-ACDL, W-98-0168-ACD, W-98-0168-ACCL, W-98-0168-ACC, W-98-0168-ACA
     ---------------------------------------------------------------------------*/
  
     ,case when (mass_wet_total > 0) 
           then case when (mass_dry > 0 and mass_wet >= mass_dry)
                     then (mass_wet_total / (1.0 + ((mass_wet - mass_dry) / mass_dry)))
                     else (mass_wet_total) 
                     end
           else -1
           end as total_dry_mass
           
     from Test_DL27
)

/*-------------------------------------------------------------
  DL27 segment cumulation
  obtain the accumulation of mass_retained on the segments
-------------------------------------------------------------*/

,cumulative_sql as (

     select  sample_id    as sample_id
            ,segment_nbr  as segment_nbr
            
            ,sum(case when mass_retained >= 0 then mass_retained else 0 end)
                 over (partition by sample_id order by sample_id, segment_nbr) as mass_retained_cumulative
     
     from Test_DL27_segments
    order by sample_id, segment_nbr
)

/*-------------------------------------------------------------
  DL27 segment summation
  obtain the summation of mass_retained on the segments
-------------------------------------------------------------*/

,summation_sql as (

     select  sample_id as sample_id
            ,sum(case when mass_retained >= 0 then mass_retained else 0 end) as mass_retained_summ
            
       from Test_DL27_segments
      group by sample_id
)

--------------------------------------------------------------------------------
-- main SQL
--------------------------------------------------------------------------------

select  dl27.sample_id                                         as DL27_Sample_ID
       ,dl27.sample_year                                       as DL27_Sample_Year
       ,dl27.test_status                                       as DL27_test_status
       ,dl27.tested_by                                         as DL27_tested_by
       
       ,case when to_char(dl27.date_tested, 'yyyy') = '1959'   then ' '
             else to_char(dl27.date_tested, 'mm/dd/yyyy') end  as DL27_date_tested
       
       ,dl27.date_tested                                       as DL27_date_tested_DATE
       ,dl27.date_tested_orig                                  as DL27_date_orig
       
       ,dl27.customary_metric                                  as DL27_customary_metric
       
       /*---------------------------------------------------------------------------
         Moisture Determination: 
         Wet mass, Dry Mass, Moisture Ratio and percent moisture
       ---------------------------------------------------------------------------*/
       
       ,case when dl27.mass_wet              >= 0         then dl27.mass_wet            else  -1  end as DL27_wet_mass
       ,case when dl27.mass_dry              >= 0         then dl27.mass_dry            else  -1  end as DL27_dry_mass
       ,case when DL27_sql.moisture_ratio    >= 0         then DL27_sql.moisture_ratio  else  -1  end as DL27_moisture_ratio
       ,case when DL27_sql.pct_moisture      >= 0         then DL27_sql.pct_moisture    else  -1  end as DL27_pct_moisture
       
       /*---------------------------------------------------------------------------
         Wash: total_wet_mass, total_dry_mass, washed_mass
       ---------------------------------------------------------------------------*/
       
       ,case when dl27.mass_wet_total        >= 0         then dl27.mass_wet_total      else  -1  end as DL27_total_wet_mass
       ,case when DL27_sql.total_dry_mass    >= 0         then DL27_sql.total_dry_mass  else  -1  end as DL27_total_dry_mass
       ,case when dl27.mass_washed           >= 0         then dl27.mass_washed         else  -1  end as DL27_washed_mass
       ,case when calc_factor                >= 0         then calc_factor              else  -1  end as DL27_factor -- (100 / total_dry_mass) 
       
       /*---------------------------------------------------------------------------
         Test_DL27_segments
         Pan is calculated in this percent passing grid, but is not displayed
       ---------------------------------------------------------------------------*/
       
       ,case when dl27seg.segment_nbr                     is not null  then dl27seg.segment_nbr                     else  -1  end as DL27_segment_nbr
       ,case when dl27seg.sieve_size                      is not null  then dl27seg.sieve_size                      else ' '  end as DL27_sieve_size
       ,case when dl27seg.mass_retained                   is not null  then dl27seg.mass_retained                   else  -1  end as DL27_mass_retained
       ,case when cumulative_sql.mass_retained_cumulative is not null  then cumulative_sql.mass_retained_cumulative else  -1  end as DL27_mass_retained_cumulative
       ,case when summation_sql.mass_retained_summ        is not null  then summation_sql.mass_retained_summ        else  -1  end as DL27_mass_retained_summ
       ,case when pct_retained                            >= 0         then pct_retained                            else  -1  end as DL27_pct_retained
       ,case when pct_retained_cumulative                 >= 0         then pct_retained_cumulative                 else  -1  end as DL27_pct_retained_cumulative
       ,case when pct_passing                             >= 0         then pct_passing                             else  -1  end as DL27_pct_passing
       
       /*---------------------------------------------------------------------------
         verify that: (total_dry_mass - mass_washed + mass_retained_summ)
         is within 0.3% of the total_dry_mass
       ---------------------------------------------------------------------------*/
       
       ,DL27_calc_too_low
       ,DL27_calc_too_high
        
       /*---------------------------------------------------------------------------
         MLT_sieve_size
       ---------------------------------------------------------------------------*/
              
       ,mlt_sieve_size.sieve_customary
       ,mlt_sieve_size.sieve_metric
       ,mlt_sieve_size.sieve_metric_in_mm
       
       ,dl27.remarks as DL27_remarks
       
       /*---------------------------------------------------------------------------
         table relationships
       ---------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                  smpl
       join Test_DL27                           dl27 on dl27.sample_id      = smpl.sample_id
       
       join DL27_sql                                 on dl27.sample_id      = DL27_sql.sample_id
       
       left join Test_DL27_segments          dl27seg on dl27seg.sample_id   = dl27.sample_id
       
       left join summation_sql                       on dl27seg.sample_id   = summation_sql.sample_id
       
       left join cumulative_sql                      on dl27seg.sample_id   = cumulative_sql.sample_id
                                                    and dl27seg.segment_nbr = cumulative_sql.segment_nbr
                                                    
       left join mlt_sieve_size                      on dl27seg.sieve_size  = mlt_sieve_size.sieve_customary 
                                                     or dl27seg.sieve_size  = mlt_sieve_size.sieve_metric
       
       /*---------------------------------------------------------------------------
         calc_factor = (100 / total_dry_mass)
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when DL27_sql.total_dry_mass > 0 then (100 / DL27_sql.total_dry_mass) else -1 end 
       as calc_factor from dual) calcfactor
       
       /*---------------------------------------------------------------------------
         percent_retained = (mass_retained * (100 / total_dry_mass))
                       or = (mass_retained * calc_factor)
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when (dl27seg.mass_retained >= 0 and DL27_sql.total_dry_mass > 0)
                                then (dl27seg.mass_retained * (100 / DL27_sql.total_dry_mass))
                                else -1 end
       as pct_retained from dual) pctret
       
       /*---------------------------------------------------------------------------
         pct_retained_cumulative = (mass_retained_cumulative * (100 / total_dry_mass)
                              or = (mass_retained_cumulative * calc_factor)
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when (cumulative_sql.mass_retained_cumulative >= 0 and DL27_sql.total_dry_mass > 0)
                                then (cumulative_sql.mass_retained_cumulative * (100 / DL27_sql.total_dry_mass))
                                else -1 end
       as pct_retained_cumulative from dual) pctretcum
       
       /*---------------------------------------------------------------------------
         pct_passing = 100 - (mass_retained_cumulative * (100 / total_dry_mass))
                  or = 100 - (mass_retained_cumulative * DL27_calc_factor)
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when (cumulative_sql.mass_retained_cumulative >= 0 and DL27_sql.total_dry_mass > 0)
                                then (100 - (cumulative_sql.mass_retained_cumulative * (100 / DL27_sql.total_dry_mass)))
                                else -1 end
       as pct_passing from dual) pctpass
       
       /*---------------------------------------------------------------------------
         verify that: (total_dry_mass - mass_washed + mass_retained_summ)
         is within 0.3% of the total_dry_mass
       ---------------------------------------------------------------------------*/
       
       cross apply (select 
       case when DL27_sql.total_dry_mass > 0 and dl27.mass_washed > 0 and summation_sql.mass_retained_summ  > 0
            then case when ((DL27_sql.total_dry_mass - dl27.mass_washed + summation_sql.mass_retained_summ) < (DL27_sql.total_dry_mass * 0.997))
                      then ' low '  else ' ' end 
            else ' ' end as DL27_calc_too_low from dual) too_low
       
       cross apply (select 
       case when DL27_sql.total_dry_mass > 0 and dl27.mass_washed > 0 and summation_sql.mass_retained_summ  > 0
            then case when ((DL27_sql.total_dry_mass - dl27.mass_washed + summation_sql.mass_retained_summ) > (DL27_sql.total_dry_mass * 1.003))
                      then ' high ' else ' ' end 
            else ' ' end as DL27_calc_too_high from dual) too_high
  
       order by dl27.sample_id, dl27seg.segment_nbr
       ;









-- find headers without segments
select hdr.sample_id from test_DL27 hdr
 where hdr.sample_id not in (select seg.sample_id from test_DL27_segments seg where seg.sample_id = hdr.sample_id)
 order by hdr.sample_year desc
;

/**** -- 121 samples

W-18-0631-AC,   W-18-2206-SO
W-17-1445-ACA,  W-17-1445-AC, W-17-1445-ACC,  W-17-0998-ACT, W-17-1445-ACB
W-16-0835-AC,   W-16-0834-AC, W-16-1270-SO,   W-16-0520-AG,  W-16-0948-SO
W-15-0053-AC,   

W-15-0183-SO -- no DL27 data but Results from T88 are in DL907 checkthis

W-14-0364-AC,   W-14-1184-AC, W-14-0527-AC,   W-14-0501-AC,  W-14-1130-SO, W-14-0501-ACB, W-14-0657-AC, 
W-13-0113-ACA,  W-13-0014-AC, W-13-0171-AC,   W-13-0113-AC,  W-13-0170-AC
W-12-0657-AC,   W-12-0169-AC, W-12-0508-AC,   W-12-0196-AC,  W-12-0789-AC
W-11-0102-AC,   W-11-0786-SO, W-11-1013-AC,   W-11-0035-AC,  W-11-0857-AC
W-11-0870-AC,   W-11-0079-AC, W-11-0153-AC,   W-11-0708-AG
W-10-0728-AC,   W-10-0441-AC, W-10-0676-AC,   W-10-0414-AC,  W-10-1032-AC, W-10-0884-AC,  W-10-1325-AC, W-10-1982-AC
W-09-0448-AC,   W-09-0865-AC, W-09-0295-AC,   W-09-0055-AC,  W-09-0296-AC
W-09-0338-AC,   W-09-0233-AC, W-09-0001-AC,   W-09-0535-AC,  W-09-0006-AC
W-08-0345-AC,   W-08-0416-AC, W-08-0602-AC,   W-08-0343-AC,  W-08-0495-AC, W-08-0673-AC,  W-08-0800-AC
W-07-0178-AC,   W-07-0225-AC, W-07-0289-AC,   W-07-0342-AC
W-06-0282-AC,   W-06-0011-AC, W-06-0290-AC,   W-06-0158-AC,  W-06-0374-AC, W-06-0040-AC
W-05-0088-AC,   W-05-0172-AC, W-05-0378-AC
W-04-0055-AC,   W-04-0252-AC, W-04-0434-AC,   W-04-0528-AC,  W-04-0271-AC, W-04-0189-AC
W-03-0784-AC,   W-03-0455-AC, W-03-0059-AC,   W-03-0267-AC,  W-03-0326-AC, W-03-0074-AC
W-03-0108-AC,   W-03-0235-AG, W-03-0654-AC,   W-03-0606-AC,  W-03-0737-AG, W-03-0546-AC
W-02-0716-AC,   W-02-0344-AC, W-02-0969-AC,   W-02-0433-AC,  W-02-0006-AC, W-02-1010-AC
W-02-0152-AC,   W-02-0079-AG, W-02-0151-AC,   W-02-0438-AC
W-01-0157-ACWL, W-01-0745-AC, W-01-0157-INFO, W-01-0812-AC
W-01-0157-ACNL, W-01-0494-AC, W-01-0006-AC,   W-01-1239-AC,  W-01-1145-AC
W-99-1082-AC,   W-98-0215-AG, W-97-1427-AG,   W-97-1433-AG,  W-97-1073-AG, W-60-0405-AC

****/




-- find segments without headers (none should be found)
select seg.sample_id from test_T112_segments seg
 where seg.sample_id not in (select hdr.sample_id from test_T112 hdr where hdr.sample_id = seg.sample_id)
;
-- none found




-- find samples that meet the conditions, below

select sample_id, mass_wet, mass_dry from test_dl27 
 where mass_wet > 0 and mass_dry > 0 and mass_wet <> mass_dry
 order by sample_year desc;
 
/**-----------------------------

sample_id       mass_wet  mass_dry
W-19-1116-AG	1192.2	  1140.1
W-17-1020-AC	2279      2277.4
W-17-0509-AC	2475      2448
W-16-0364-AG	263.1     244.5
W-16-1370-AC	2500      2478.7
W-16-0352-AC	2500      2492.6
W-16-0363-AG	221.4      213.8
W-03-0738-AG	2700      2698.6
W-02-0121-AC	2500      2485.6
W-98-1432-AC	1250      1235.7
W-60-1370-AC	2500      2478.7

-----------------------------**/









