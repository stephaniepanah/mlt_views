 



select * from V_WL190_Segments_Resistance_Values where rval_Sample_ID = 

 'W-21-0112-SO'
 --'W-21-1055-GS'
 --'W-21-1172-GS'
 --'W-20-0737-SO'
 --'W-20-1505-SO'
 --'W-19-1506-SO'
 --'W-19-1822-SO'
 
 ;
  




create or replace view V_WL190_Segments_Resistance_Values as 


select  wl190seg.sample_id                                as rval_Sample_ID   -- key
       ,wl190seg.segment_nbr                              as rval_segment_nbr -- key 
       
       /*----------------------------------------------------------------------
         Stabilometer: PV - vertical pressure, PH - horizontal pressure
       ----------------------------------------------------------------------*/
       
       ,max_stabilometer_pv                               as max_stabilometer_pv -- max pv-ph pair after comparison
       ,max_stabilometer_ph                               as max_stabilometer_ph -- use this pair for calculations
       
       ,ph_comparison_flag                                as ph_comparison_flag -- ' **** '
       
       ,max_pv_tmp                                        as max_pv_tmp
       ,max_pv_tmp_corresponding_ph                       as max_pv_tmp_corresponding_ph
       
       ,max_ph_tmp                                        as max_ph_tmp
       ,max_ph_tmp_corresponding_pv                       as max_ph_tmp_corresponding_pv
       
       /*----------------------------------------------------------------------
         R values, Resistance values
       ----------------------------------------------------------------------*/
       
       ,case when wl190seg.Resistance_values_distance_turns >= 0 
             then wl190seg.Resistance_values_distance_turns 
             else -1 end                                as R_values_distance_turns 
       
       ,rawrv                                           as resistance_value_raw
       
       /*----------------------------------------------------------------------
         table relationships
       ----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                     smpl
       join Test_WL190                            wl190 on wl190.sample_id = smpl.sample_id
       join Test_WL190_Segments                wl190seg on wl190.sample_id = wl190seg.sample_id 
       
       /*---------------------------------------------------------------------------------------
         
         Stabilometer: PV - vertical pressure, PH - horizontal pressure
         Find the max_stabilometer_pv, max_stabilometer_ph pair
         
         from MTest, Lt_BWL190_ca_B6.cpp, calcStabMax()
         
         if (pv >= 0.0 && ph > 0.0)
         {
            if (pv > maxpv && ph > maxph)
            {
              maxpv = pv;
              maxph = ph;
            }
         }
         
         My calculations:
         
         step1: select maximum stabilometer vertical pressure as max_pv_tmp
         step2: find the ph that corresponds to max_pv_tmp
         step3: select maximum stabilometer horizontal pressure as max_ph_tmp
         step4: find the pv that corresponds to max_ph_tmp
         
         step5: compare max_ph_tmp to the corresponding ph tmp
         step6: set max_stabilometer_pv
         step7: set max_stabilometer_ph
         
         if the same (>99.99%) use max_pv_tmp & its corresponding ph
         else, use max_ph_tmp & its corresponding pv                
         these two become the max_stabilometer_pv, max_stabilometer_ph pair
         
         In the 8 cases where max_ph_tmp <> corresponding_ph, use the max_ph_tmp, corresponding_pv pair
         
         Sample ID         maxPV      CorrespondingPH    maxPH     CorrespondingPV
         ------------      -----      ---------------    -----     ---------------
         W-19-1865-SO	    160	        17	                20      120
         W-12-0021-SO	    160	 	    -1                 110      120
         W-10-0237-SO	    160	 	    -1                  28      120
         W-10-0273-SO	    160	 	    -1                  20      120
         W-09-1241-SO	    160	 	    -1                  20      120
         W-07-0184-SO	    160	 	    -1                  30       80
         W-05-0215-AC	    160	        19	                32      120
         W-00-0594-SO	    160	 	    -1                  59      120
         
       ---------------------------------------------------------------------------------------*/
       
       -- step1: select maximum stabilometer vertical pressure as max_pv_tmp
       cross apply (select greatest ( nvl(wl190seg.stabilometer_pv1,0), nvl(wl190seg.stabilometer_pv2,0),
                                      nvl(wl190seg.stabilometer_pv3,0), nvl(wl190seg.stabilometer_pv4,0),
                                      nvl(wl190seg.stabilometer_pv5,0), nvl(wl190seg.stabilometer_pv6,0),
                                      nvl(wl190seg.stabilometer_pv7,0)
                                    ) as max_pv_tmp from dual) step1
       
       -- step2: find the ph that corresponds to max_pv_tmp
       cross apply (select case when wl190seg.stabilometer_pv1 = max_pv_tmp then wl190seg.stabilometer_ph1
                                when wl190seg.stabilometer_pv2 = max_pv_tmp then wl190seg.stabilometer_ph2
                                when wl190seg.stabilometer_pv3 = max_pv_tmp then wl190seg.stabilometer_ph3
                                when wl190seg.stabilometer_pv4 = max_pv_tmp then wl190seg.stabilometer_ph4
                                when wl190seg.stabilometer_pv5 = max_pv_tmp then wl190seg.stabilometer_ph5
                                when wl190seg.stabilometer_pv6 = max_pv_tmp then wl190seg.stabilometer_ph6
                                when wl190seg.stabilometer_pv7 = max_pv_tmp then wl190seg.stabilometer_ph7
                                else -1
                                 end as max_pv_tmp_corresponding_ph from dual) step2
  
       -- step3: select maximum stabilometer horizontal pressure as max_ph_tmp
       cross apply (select greatest ( nvl(wl190seg.stabilometer_ph1,0), nvl(wl190seg.stabilometer_ph2,0),
                                      nvl(wl190seg.stabilometer_ph3,0), nvl(wl190seg.stabilometer_ph4,0),
                                      nvl(wl190seg.stabilometer_ph5,0), nvl(wl190seg.stabilometer_ph6,0),
                                      nvl(wl190seg.stabilometer_ph7,0)
                                    ) as max_ph_tmp from dual) step3
  
       -- step4: find the pv that corresponds to max_ph_tmp
       cross apply (select case when wl190seg.stabilometer_ph1 = max_ph_tmp then wl190seg.stabilometer_pv1
                                when wl190seg.stabilometer_ph2 = max_ph_tmp then wl190seg.stabilometer_pv2
                                when wl190seg.stabilometer_ph3 = max_ph_tmp then wl190seg.stabilometer_pv3
                                when wl190seg.stabilometer_ph4 = max_ph_tmp then wl190seg.stabilometer_pv4
                                when wl190seg.stabilometer_ph5 = max_ph_tmp then wl190seg.stabilometer_pv5
                                when wl190seg.stabilometer_ph6 = max_ph_tmp then wl190seg.stabilometer_pv6
                                when wl190seg.stabilometer_ph7 = max_ph_tmp then wl190seg.stabilometer_pv7
                                else -1
                                 end as max_ph_tmp_corresponding_pv from dual) step4
                            
       -- step5: compare max_ph_tmp to the corresponding ph tmp  
       -- when the corresponding ph to pv matches the max ph, do not set the flag (99.99% of cases)
       -- when the corresponding ph to pv does not match the max ph, set the flag
       
       cross apply (select case when max_pv_tmp_corresponding_ph = max_ph_tmp then ' '
                                else ' **** ' -- flag the mismatch (8 samples)
                                 end as ph_comparison_flag from dual) step5
       
       -- step6: if the corresponding ph to pv matches the max ph
       --           set the max_ph_tmp as max_stabilometer_pv
       --      else set max_ph_tmp_corresponding_pv as max_stabilometer_pv
       
       cross apply (select case when max_pv_tmp_corresponding_ph = max_ph_tmp then max_pv_tmp
                                else max_ph_tmp_corresponding_pv
                                 end as max_stabilometer_pv from dual) step6
       
       -- step7: if the corresponding pv to ph matches the max ph
       --           set the max_pv_tmp as max_stabilometer_ph
       --      else set max_pv_tmp_corresponding_ph as max_stabilometer_ph
  
       cross apply (select case when max_pv_tmp_corresponding_ph = max_ph_tmp then max_pv_tmp_corresponding_ph
                                else max_ph_tmp
                                 end as max_stabilometer_ph from dual) step7
        
       
       /*---------------------------------------------------------------------------------------
         
         R value calculations, from MTest, Lt_BWL190_ca_B6.cpp, calcRVs()
         {
           // RV = 100 - ( 100/( (2.5/D)*(160/Ph - 1) + 1 ) )
         
           if (dturns > 0.0)
           {
             if (pv >= 0.0 && ph >= 0.0)
             {
               if (ismetricSt)
               {
                 // the calcs must use lbf, psi
                 pv = pv / LBFtoN;   // LBFtoN = 4.4482216526;  // pounds (force) to Newtons
                 ph = ph / PSItoKPA; // PSItoMPA = 0.006894757; // PSI to megaPascals
               }
              
               rawrv = 100.0 - ( 100.0 / ( (2.5 / dturns) * (pv/ph - 1.0) + 1.0) ); -- uncorrected R value
             }
           }
         
       ---------------------------------------------------------------------------------------*/
       
       cross apply (select 
       
       case when wl190seg.Resistance_values_distance_turns > 0
       
            then 
            case when (max_stabilometer_pv >= 0 and max_stabilometer_ph > 0)
                 then (100.0 - ( 100.0 / ( (2.5 / wl190seg.Resistance_values_distance_turns) * ((max_stabilometer_pv / max_stabilometer_ph) - 1.0) + 1.0) ) )  
                 else -1
                 end
                 
            else -1
            end as rawrv from dual
       
       ) calc_rawrv
  
  order by
  wl190seg.sample_id,
  wl190seg.segment_nbr
  ;









