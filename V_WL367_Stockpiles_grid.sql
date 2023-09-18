


/*----------------------------------------------------------------

 WL367 USFS Increment Wash Correction and Stockpiles
 
 the stockpiles from WL800/WL801 feed into WL367
 
 Each stockpile contains the array of sieves,
 referenced as segment_nbr and associated to sieve_size
 
 notes:
 need to be able to discern the WL800 from WL801 when associated with WL367 (yes? no?)

 While sieve size is on the Test_WL367_Stockpile table, 
 the view, V_WL367_Stockpiles, uses the sieves from WL800
 
 the code from MTest, Lt_WL367Lauf_BC.cpp, is below the SQL
 
 // make sure there's a row for the pan *** check this ***

----------------------------------------------------------------*/




select * from V_WL367_Increment_Wash_Correction 
 where WL367_Sample_ID = 'W-19-0862-AC' 
 order by WL367_sample_year desc, WL367_sample_id, WL800_stockpile_nbr
 ;




select * from V_WL367_Stockpiles_grid 
 where WL367_Sample_ID = 'W-19-0862-AC'
 ;
 



/***********************************************************************************

 V_WL367_Stockpiles_grid

***********************************************************************************/


create or replace View V_WL367_Stockpiles_grid as 

--------------------------------------------------------------------------------
-- stockpile_summation
-- obtain the summation of Mass_Washed_Retained, by Sample_ID, Stockpile
-- this becomes Mass_After_Sieving
--------------------------------------------------------------------------------

with stockpile_summation as (

     select  Sample_ID
            ,Stockpile
            
            ,sum(case when Mass_Washed_Retained >= 0 then Mass_Washed_Retained else 0 end)
             as Washed_Wts_Retained_summation
     
       from Test_WL367_Stockpile 
      group by Sample_ID, Stockpile
)

--------------------------------------------------------------------------------
-- stockpile_cumulative
-- obtain the accumulation of Mass_Washed_Retained
-- by Sample_ID, Stockpile, segment_nbr
--------------------------------------------------------------------------------

,stockpile_cumulative as (
     
     select  Sample_ID
            ,Stockpile
            ,segment_nbr
            
            ,sum(case when Mass_Washed_Retained >= 0 then Mass_Washed_Retained else 0 end)
                 over (partition by Sample_ID, Stockpile order by Sample_ID, Stockpile, segment_nbr)
             as Washed_Wts_Retained_cumulative
     
       from Test_WL367_Stockpile
)

--------------------------------------------------------------------------------
-- main SQL
--------------------------------------------------------------------------------

select  wl367stk.sample_id                                       as WL367_Sample_ID     -- key
       ,wl367stk.stockpile                                       as WL367_stockpile_nbr -- key (1,2,3,4,5,6) corresponds to WL800
       ,wl367stk.segment_nbr                                     as WL367_segment_nbr   -- key (the sieves)
       
       ,v_wl800stk.WL800_stockpile_description                   as WL800_stockpile_description
       
       /*-----------------------------------------------------------------------
         Stockpile-Sieve grid
       -----------------------------------------------------------------------*/
       
       ,v_wl800seg.WL800_sieve_size                              as WL800_Sieve_Size
       ,v_wl800seg_WL800_pct_passing                             as WL800_Design_Gradation_Pct_Passing
       ,wl367stk.projected_gradation_pct_passing                 as WL367_Projected_Gradation_Pct_Passing
       
       ,(100 - wl367stk.projected_gradation_pct_passing) * (wl367stk.mass_before_drying * 0.01)
                                                                 as WL367_Cumulative_Calculated_Batch_Wts
       
       ,wl367stk.Mass_Cumulative_Actual                          as WL367_Cumulative_Actual_Batch_Wts
       ,wl367stk.Mass_Washed_Retained                            as WL367_Washed_Weights_Retained
        
        -- from MTest, Lt_WL367Lauf_BC.cpp, void LtWL367_BC::CorPile::doCalcs
        -- pradj = (design_factor_previous - design_factor)
       ,case 
        when (((lag(design_factor, 1, 100) over (partition by wl367stk.sample_id, wl367stk.stockpile
                                                    order by wl367stk.sample_id, wl367stk.stockpile, wl367stk.segment_nbr))
               - design_factor) > 0) 
        
        then ((lag(design_factor, 1, 100) over (partition by wl367stk.sample_id, wl367stk.stockpile
                                                    order by wl367stk.sample_id, wl367stk.stockpile, wl367stk.segment_nbr))
               - design_factor)
        else 0 end                                               as WL367_Adjusted_Batch_Pct_Retained
       
       ,THE_Factor                                               as WL367_Factor
       
       /*-----------------------------------------------------------------------
         Moisture Determination - values displayed beneath the grid
       -----------------------------------------------------------------------*/
              
       ,wl367stk.Mass_before_drying                              as WL367_Mass_before_drying
       ,wl367stk.Mass_after_drying                               as WL367_Mass_after_drying
       ,WL367_pct_moisture                                       as WL367_percent_moisture
       
       ,wl367stk.Mass_Dry_Wash                                   as WL367_Mass_Dry_Wash       
       ,Washed_Wts_Retained_summation                            as WL367_Mass_After_Sieving
       
       /*-----------------------------------------------------------------------
         not for display, used in calculations
       -----------------------------------------------------------------------*/
       
       ,lag(design_factor, 1, 100) over (partition by wl367stk.sample_id, wl367stk.stockpile
                                             order by wl367stk.sample_id, wl367stk.stockpile, wl367stk.segment_nbr)
                                                                 as design_factor_previous
        
       ,design_factor                                            as design_factor -- an intermediate step
       
       ,stockpile_cumulative.Washed_Wts_Retained_cumulative      as WL800_stockpile_Washed_Wts_Ret_cumulative
       ,stockpile_summation.Washed_Wts_Retained_summation        as WL800_stockpile_Washed_Wts_Ret_summation
       
       ,denominator                                              as denominator
       
       ,v_wl800stk.WL800_pct_used                                as WL800_pct_used           -- not used, but included
       ,v_wl800stk.WL800_pct_used_decimal                        as WL800_pct_used_decimal   -- not used, but included
       ,v_wl800stk.WL800_pct_used_summation                      as WL800_pct_used_summation -- not used, but included
       
       /*-----------------------------------------------------------------------
         MLT_Sieve_Size
       -----------------------------------------------------------------------*/
       
       ,MLT_Sieve_Size.sieve_customary
       ,MLT_Sieve_Size.sieve_metric
       ,MLT_Sieve_Size.sieve_metric_in_mm
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                         smpl
       join Test_WL367                                wl367 on wl367.sample_id       = smpl.sample_id
       
       left join Test_WL367_Stockpile              wl367stk on wl367.sample_id       = wl367stk.sample_id
       
       join V_WL800_Stockpiles_grid              v_wl800stk on wl367stk.sample_id    = v_wl800stk.WL800_Sample_ID
                                                           and wl367stk.stockpile    = v_wl800stk.WL800_stockpile_nbr
       
       join V_WL800_Sieve_Segments_grid          v_wl800seg on wl367stk.sample_id    = v_wl800seg.WL800_Sample_ID
                                                           and wl367stk.segment_nbr  = v_wl800seg.WL800_segment_nbr
  
       join stockpile_summation                             on wl367stk.sample_id    = stockpile_summation.Sample_ID
                                                           and wl367stk.stockpile    = stockpile_summation.stockpile
  
       join stockpile_cumulative                            on wl367stk.sample_id    = stockpile_cumulative.Sample_ID
                                                           and wl367stk.stockpile    = stockpile_cumulative.stockpile
                                                           and wl367stk.segment_nbr  = stockpile_cumulative.segment_nbr
  
       left join MLT_Sieve_Size                             on (v_wl800seg.WL800_sieve_size = MLT_Sieve_Size.sieve_customary or
                                                                v_wl800seg.WL800_sieve_size = MLT_Sieve_Size.sieve_metric)
       
       
       /*-----------------------------------------------------------------------
         calculations: percent passing, as decimal, from WL800
         displayed as: Design_Gradation_Pct_Passing
       -----------------------------------------------------------------------*/
       
       cross apply (select  
        case when wl367stk.stockpile = '1' then v_wl800seg.WL800_Stk1_pct_pass
             when wl367stk.stockpile = '2' then v_wl800seg.WL800_Stk2_pct_pass
             when wl367stk.stockpile = '3' then v_wl800seg.WL800_Stk3_pct_pass
             when wl367stk.stockpile = '4' then v_wl800seg.WL800_Stk4_pct_pass
             when wl367stk.stockpile = '5' then v_wl800seg.WL800_Stk5_pct_pass
             when wl367stk.stockpile = '6' then v_wl800seg.WL800_Stk6_pct_pass
             end as v_wl800seg_WL800_pct_passing from dual) pctpassing
       
       /*-----------------------------------------------------------------------
         calculations: percent moisture
         if(post > 0.0 && ante >= post)
            moist = 100.0 * (ante - post) / post;
       -----------------------------------------------------------------------*/
       
       cross apply (select 
        case when  (wl367stk.Mass_after_drying > 0) and (wl367stk.Mass_before_drying >= wl367stk.Mass_after_drying)
             then  (((wl367stk.Mass_before_drying - wl367stk.Mass_after_drying) / wl367stk.Mass_after_drying) * 100) 
             else  -1 end as WL367_pct_moisture from dual) pctmoisture
       
       /*-----------------------------------------------------------------------
         calculations: denominator used in calculating the Factor
       -----------------------------------------------------------------------*/
       
       cross apply (select 
        case when  (wl367stk.Mass_after_drying > 0) 
             then  (1.0 - (stockpile_cumulative.Washed_Wts_Retained_cumulative / wl367stk.Mass_after_drying))
             else  -1 end as denominator from dual) denom
       
       /*-----------------------------------------------------------------------
         calculations: THE Factor!
       -----------------------------------------------------------------------*/
       
       cross apply (select 
        case when  (denominator > 0) 
             then  ((1.0 - (wl367stk.Mass_Cumulative_Actual / wl367stk.Mass_before_drying)) / denominator)
             else  0 end as THE_Factor from dual) thefactor
       
       /*-----------------------------------------------------------------------
         calculations: design_factor, an intermediate step
         WL800 Design Gradation pct passing * THE_Factor
       -----------------------------------------------------------------------*/
       
       cross apply (select case when (v_wl800seg_WL800_pct_passing > 0) 
                                then (v_wl800seg_WL800_pct_passing * THE_Factor)
                                else 0 end as design_factor from dual) designfactor
       
       
       order by 
       wl367stk.sample_id, 
       wl367stk.stockpile, 
       wl367stk.segment_nbr
       ;









/***********************************************************************************

 WL367 USFS Increment Wash Correction and Stockpiles
 
 the stockpiles from WL800/WL801 feed into WL367. Each stockpile contains the 
 array of sieves, referenced as segment_nbr and associated to sieve_size
  
 -------------------------------------------------
 from MTest, Lt_WL367Lauf_BC.cpp, the comments
 -------------------------------------------------
 
 There is an increment wash for each stockpile gradation
 WL367 operations:
 (Re)initialize data from SU 34
 autocalculations (moisture)
 demand calculation of batch weights
 demand calculation of gradation
 m800 = WL800 (?)
 m031 = ???                            // m031 ....WL367? (my notes)

 Wt Before Drying: entered
 Wt  After Drying: entered
 Percent Moisture: 100 * (WBD - WAD) / WAD (%M is display-only)

 A Sieve Sizes(n): from m800
 B Design Gradation(n): from m800
 These are display-only; if m031 doesn't exist, initialize these fields from m800

 C Projected % Passing(n): entered. This is an estimated target gradation

 E Calculated Batch(n):
   f = 100; g = 0;
   loop: g = g + WBD * (f - P%P[i]); 
         CB[i] = g; 
         f = P%P[i]; 
         i = i + 1;
   if more, loop.
   This converts the projected percents passing to percents retained, 
   and produces cumulative batch weights to a total batch weight of WBD

 F Actual Batch Weights(n): entered. These are the actual weights, which will approximate CB

 H Washed Wt Retained(n): entered

 L Factor(n): calculated:
   f = 1;
   loop: f = f - WwtR(i)/WAD; 
         Factor(i) = (1 - CB(i)/ WBD)/f; 
         i = i + 1;
   if more, loop. This will be displayed, but not saved

 K Adjusted Batch(n): calculated:
   f = 100
   loop: g = DG[i] Factor[i]; AB(i) = f - g;  f = g; i = i + 1; // my notes: DG, design gradation
   
   if more, loop. This is the final result.
   
   Total Washed Weight: (TWW) entered
   Weight after Wash: calculated: (aka Mass after sieving)
   WAW = sum (WwtR(n))
   WAW is a check: should match TWW

 2011-05-06
 The Blend table is an undisplayed table containing combined stockpile information
 (my notes: I presume 'Blend' from WL800)
 
 
 -------------------------------------------------
 from MTest, Lt_WL367Lauf_BC.cpp, the code
 -------------------------------------------------
 
 void LtWL367_BC::CorPile::doCalcs(unsigned calcflags)
 {
  /* ARGUMENT
   * calcflags:
   * CF_AUTO = 0x01;
   * CF_BW   = 0x10;
   * CF_GRAD = 0x20;
   
   if( calcflags & CF_AUTO )
   {
      // autocalc pct moisture
      double moist; // percent moisture
      ante =        // mass before drying
      post =        // mass after drying
      
      if(post > 0.0 && ante >= post)
         moist = 100.0 * (ante - post) / post;
   }
   
   if( calcflags & (CF_BW|CF_GRAD) )
   {
                               // my notes
      // arrays of doubles     // no no no!! should NOT use the same variable name for two different arrays
                               // this knocked me for a loop, parsing line by line through code, good freakin' grief
                               
      double  agrad[MAXSIEVES] // used for: PpProj (projected gradation pct passing) AND 
                               // PpDdesign (design gradation pct passing) ....I would not have done this, no no no
                                  
             abatch[MAXSIEVES] // used for: CumBatwtsCalc (cumulative calculated batch wts) AND 
                                  CumBatwtsActual (cumulative_actual_batch_wts) ...why? why??
                                  
              awash[MAXSIEVES] // array of washed wts retained
              
            afactor[MAXSIEVES] // **** THE Factor **** displayed (factor, used how many times? for diff vars??)

      ante =                   // mass before drying

      if ( nrows > 0 ) 
      {
         if( val > 0.0 )
         {
         // data from sources organized as pct passing will not have a pan    // ....not sure what this means
            cda = <get data, cSv>                                             // sieves
            cda->reviseFltValueShow(0.0);                                     // pan ....whatever....
            cda = <get data, PpDdesign>                                       // design gradation pct passing
            cda = <get data, PpProj>                                          // projected gradation pct passing

	  if( calcflags & CF_BW )
	  {
            // calculated Batch Weights
            for(xr = 0; xr < nrows; ++xr )
                agrad[xr] = <get data, PpProj>                                // load array of PpProj, projected gradation pct passing
            
            pp = 100.0;                                                       // initial previous pct passing
            cum = 0.0;                                                        // initial cumulative batch wt

            factor = ante/100.0; // convert to %                              // (mass before drying / 100.0) or (MBD * 0.01)
                                                                              // "A factor" used in calcs, not ** THE Factor **
            for(xr = 0; xr < nrows; ++xr )
            {
               cum += factor * (pp - agrad[xr]);                              // cumulative_calculated_batch_wts
               pp = agrad[xr];                                                // set prev pct passing to array of projected_gradation_pct_passing[i]
               abatch[xr] = cum;                                              // array of cumulative_calculated_batch_wts (CumBatwtsCalc)
            }

         if( calcflags & CF_GRAD )
         {
            post =                                                           // mass after drying           
            cum = 0.0;                                                       // eventually, sum of washed wts retained (Mass after sieving)

            for( xr = 0; xr < nrows; ++xr )
            {
               agrad[xr] = <get data, PpDdesign>                            // load array of PpDdesign, design gradation pct passing
               if(agrad[xr] < 0.0) agrad[xr] = 0.0;

               abatch[xr] = <get data, CumBatwtsActual>                     // load array of cumulative_actual_batch_wts
               if(abatch[xr] < 0.0) abatch[xr] = 0.0;

               awash[xr] = <get data, MrWashed>                             // load array of washed wts retained
               if( awash[xr] < 0.0 ) awash[xr] = 0.0;
               cum += awash[xr];                                            // the sum of washed wts retained
            }

            getFld(SpCorX::xSp_wtPostSieving)->reviseFltValueShow(cum);     // Mass after sieving, the 'cum' from sum of washed wts retained

            pp = 100.0;                                                     // initial previous adjusted pct passing

            cum = 1.0;                                                      // previous proportion retained (reusing cum. oh gosh, again!)
                                                                            // cum becomes the denominator in the calculation of factor,
                                                                            // ** THE Factor ** ---the real factor

            for(xr = 0; xr < nrows; ++xr )
            {
               cum -= awash[xr]/post;                                       // cum -= washed wts retained[xr] / mass after drying
			                                                                // initially (1.0 - (washed wts ret cumulative / mass after drying))

               if(cum > 0.0)                                                // calculate ** THE Factor **
                  factor = (1.0 - abatch[xr]/ante) / cum;                   // (1 - cumulative_actual_batch_wts[i] / mass before drying) / cum 
               else
                  factor = 0.0;

               afactor[xr] = factor;                                        // build an array of ** THE Factor ** elements

               factor *= agrad[xr];                                         // array of PpDdesign, design grad pct passing
                                                                            // design_factor = factor * agrad[xr]; 

               double pradj = pp - factor;                                  // adjusted batch pct retained = pp - design_factor
               pp = factor;                                                 // pp = design_factor (not Factor)


***********************************************************************************/









