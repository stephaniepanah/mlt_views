


select * from V_WL89_Atterberg_Limits 
 where WL89_sample_id in (
 'W-06-0096-AG', 'W-06-0097-AG', 'W-07-0185-AG', 'W-07-0187-AG', 'W-08-0258-AG', 'W-11-1029-SO', 'W-11-1275-AG'
 )
 order by WL89_sample_year, WL89_sample_id, WL89_segment_nbr 
;




----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T89  where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 15453	1983	2020



select count(*), min(sample_year), max(sample_year) from Test_WL89 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 840	    1986	2020



-- the structures (header, segments, liquid, plastic) are identical for T89 and WL89



-- find headers without segments
select hdr.sample_id, hdr.sample_year from test_WL89 hdr
 where hdr.sample_id not in (select seg.sample_id from test_WL89_segments seg
                              where seg.sample_id = hdr.sample_id)
 order by hdr.sample_year desc, hdr.sample_id
;
-- 308 samples do not contain segments
--  15 samples are post year 2000



-- find segments without headers (there should not be any)
select seg.sample_id from test_WL89_segments seg
 where seg.sample_id not in (select hdr.sample_id from test_WL89 hdr
                              where hdr.sample_id = seg.sample_id)
;
-- 0



select * from test_WL89 order by sample_year desc, sample_id;




/***********************************************************************************

  T89 Atterberg Limits (LL/PI) (Liquid Limit/Plasticity Index)
  W-18-0051-SO, W-18-0052-SO, W-17-0001-AG, W-17-0002-AG
       
  WL89 Atterberg Limits (Lab Crushed)
  W-18-0550-AG, W-18-1238-AG, W-17-1057-AG, W-17-2343-AG
  W-11-1275-AG, W-08-0258-AG, W-07-0185-AG <-- good samples


 from MTest, Lt_T89_B2.cpp; calcLL(), calcPL(), calcPI()

 ------------------------------------------
  Liquid pct moisture
 ------------------------------------------

 void mtT89_lo::CorGrpRoot::calcLL(int xrow)

 if (tare >= 0.0 && damp > 0.0 && dry > 0.0 && blows > 0.0)
 {
    double denom = dry - tare;

    if (denom > 0.0)
    {
        moist = damp - dry;

        if (moist >= 0.0)
            moist *= 100.0 / denom;
    }
 }

 ------------------------------------------
  Liquid limit
 ------------------------------------------
 
 if (!skip)
 {
    if (tll >= 0.0)
    {
      ++count;
      sum += tll;
    }
 }
 
 // calculate the individual Liquid limit
 opll = moist * pow(blows / 25.0, 0.121);
 if (opll == 0.0) isnp = true; // is nonplastic
 
 // calculate final LL
 ll = roundEven(sum / count);

 ------------------------------------------
  Plastic pct moisture
 ------------------------------------------

 void mtT89_lo::CorGrpRoot::calcPL(int xrow)

 if (tare >= 0.0 && damp > 0.0 && dry > 0.0)
 {
    double denom = dry - tare;

    if (denom > 0.0)
    {
        moist = damp - dry;

        if (moist >= 0.0)
            moist *= 100.0 / denom;
    }
 }

 ------------------------------------------
  Plastic limit
 ------------------------------------------

 // calculate average plastic limit
 if (moist >= 0.0)
 {
	++count;
    sum += moist; -- percent moisture
 }

 // calculate final PL
 pl = roundEven(sum / count);          

 ------------------------------------------
  Plasticity Index = LL - PL
 ------------------------------------------

 void mtT89_lo::CorGrpRoot::calcPI()
 pi = ll - pl;
 

***********************************************************************************/



create or replace view V_WL89_Atterberg_Limits as 

/*----------------------------------------------------------------------------
  segment level SQL
----------------------------------------------------------------------------*/

with segment_sql as (
     
     select  sample_id   -- key
            ,segment_nbr -- key
            ,TYPE_L_OR_P
            ,type_segment_nbr
            ,can_nbr
            ,mass_tare
            ,mass_damp
            ,mass_dried
            ,liquid_blows
            ,exclude_segment
            ,Minimum_Spec_Plastic
            ,Maximum_Spec
            ,Non_Visous_Non_Plastic_indicator
            
            ,case when (mass_dried > 0) and (mass_tare > 0) and (mass_dried > mass_tare) and (mass_damp > mass_dried)
                  then (((mass_damp - mass_dried) / (mass_dried - mass_tare)) * 100)
                            
                  when (mass_dried > 0) and (mass_tare < 0) and (mass_damp > mass_dried) 
                  then (((mass_damp - mass_dried) / (mass_dried)) * 100)
                            
                  else -1 end 
             as pct_moisture 
            
            ,case when (TYPE_L_OR_P = 'L')
                  then case when (mass_dried > 0) and (mass_tare > 0) and (mass_dried > mass_tare) and 
                                 (mass_damp > mass_dried) and (liquid_blows > 0)
                            then ((((mass_damp - mass_dried) / (mass_dried - mass_tare)) * 100) * power((liquid_blows/25.0), 0.121))
                            
                            when (mass_dried > 0) and (mass_tare < 0) and (mass_damp > mass_dried) and (liquid_blows > 0)
                            then ((((mass_damp - mass_dried) / (mass_dried)) * 100) * power((liquid_blows/25.0), 0.121))
                            
                            else -1 end
                  else -1 end
             as liquid_limit_raw
            
            ,case when (TYPE_L_OR_P = 'P') 
                  then case when (mass_dried > 0) and (mass_tare > 0) and (mass_dried > mass_tare) and (mass_damp > mass_dried)
                            then (((mass_damp - mass_dried) / (mass_dried - mass_tare)) * 100)
                            
                            when (mass_dried > 0) and (mass_tare < 0) and (mass_damp > mass_dried) 
                            then ((((mass_damp - mass_dried) / (mass_dried)) * 100))
                            
                            else -1 end
                  else -1 end
             as plastic_limit_raw -- not displayed, but is used in the plastic limit average calculation
            
       from Test_WL89_Segments
      order by sample_id, segment_nbr
)

/*----------------------------------------------------------------------------
  segment type SQL, liquid or plastic
----------------------------------------------------------------------------*/
  
,limit_sql as (
     
     select  sample_id
            ,TYPE_L_OR_P
            
            ,sum(case when (TYPE_L_OR_P = 'L' and exclude_segment <> 'X' and mass_tare >= 0)
                      then case when (mass_damp > mass_dried) and (mass_dried > mass_tare) and (liquid_blows > 0)
                                then ((((mass_damp - mass_dried) / (mass_dried - mass_tare)) * 100) * power((liquid_blows/25.0), 0.121))
                                else 0 end
                      
                      when (TYPE_L_OR_P = 'L' and exclude_segment <> 'X' and mass_tare  < 0)
                      then case when (mass_damp > mass_dried) and (mass_dried > 0) and (liquid_blows > 0)
                                then ((((mass_damp - mass_dried) / (mass_dried)) * 100) * power((liquid_blows/25.0), 0.121))
                                else 0 end
                      
                      else 0 end
            ) as liquid_limit_sum_raw
             
            ,sum(case when (TYPE_L_OR_P = 'L' and exclude_segment <> 'X' and mass_tare >= 0)
                      then case when (mass_damp > mass_dried) and (mass_dried > mass_tare) and (liquid_blows > 0)
                                then 1
                                else 0 end
                      
                      when (TYPE_L_OR_P = 'L' and exclude_segment <> 'X' and mass_tare  < 0)
                      then case when (mass_damp > mass_dried) and (mass_dried > 0) and (liquid_blows > 0)
                                then 1
                                else 0 end
                      
                      else 0 end
            ) as liquid_limit_count
            
            ,sum(case when (TYPE_L_OR_P = 'P' and exclude_segment <> 'X' and mass_tare >= 0)
                      then case when (mass_damp > mass_dried) and (mass_dried > mass_tare) 
                                then (((mass_damp - mass_dried) / (mass_dried - mass_tare)) * 100)
                                else 0 end
                                          
                      when (TYPE_L_OR_P = 'P' and exclude_segment <> 'X' and mass_tare  < 0)
                      then case when (mass_damp > mass_dried) and (mass_dried > 0) 
                                then (((mass_damp - mass_dried) / (mass_dried)) * 100)
                                else 0 end
                                
                      else 0 end
            ) as plastic_limit_sum_raw
            
            ,sum(case when (TYPE_L_OR_P = 'P' and exclude_segment <> 'X' and mass_tare >= 0)
                      then case when (mass_damp > mass_dried) and (mass_dried > mass_tare) 
                                then 1
                                else 0 end
                                          
                      when (TYPE_L_OR_P = 'P' and exclude_segment <> 'X' and mass_tare  < 0)
                      then case when (mass_damp > mass_dried) and (mass_dried > 0) 
                                then 1
                                else 0 end
                                
                      else 0 end
            ) as plastic_limit_count
             
            
       from Test_WL89_Segments
      group by sample_id, TYPE_L_OR_P
)

/*----------------------------------------------------------------------------
  main SQL
----------------------------------------------------------------------------*/

select  wl89.sample_id                                          as WL89_sample_id
       ,wl89.sample_year                                        as WL89_sample_year
       
       ,wl89.test_status                                        as WL89_test_status
       ,wl89.tested_by                                          as WL89_tested_by
       
       ,case when to_char(wl89.date_tested, 'yyyy') = '1959'    then ' '
             else to_char(wl89.date_tested, 'mm/dd/yyyy') end   as WL89_date_tested
            
       ,wl89.date_tested                                        as WL89_date_tested_DATE
       ,wl89.date_tested_orig                                   as WL89_date_tested_orig
       
       /*-----------------------------------------------------------------
         segments, liquid and plastic grids
       -----------------------------------------------------------------*/
       
       ,case when wl89seg.segment_nbr              is not null then wl89seg.segment_nbr              else  -1  end  as  WL89_segment_nbr -- key
       ,case when wl89seg.TYPE_L_OR_P              is not null then wl89seg.TYPE_L_OR_P              else ' '  end  as  WL89_TYPE_L_OR_P
       ,case when wl89seg.type_segment_nbr         is not null then wl89seg.type_segment_nbr         else  -1  end  as  WL89_type_segment_nbr
       ,case when wl89seg.can_nbr                  is not null then wl89seg.can_nbr                  else ' '  end  as  WL89_can_nbr
       ,case when wl89seg.mass_tare                is not null then wl89seg.mass_tare                else  -1  end  as  WL89_mass_tare
       ,case when wl89seg.mass_damp                is not null then wl89seg.mass_damp                else  -1  end  as  WL89_mass_damp
       ,case when wl89seg.mass_dried               is not null then wl89seg.mass_dried               else  -1  end  as  WL89_mass_dried
       ,case when wl89seg.liquid_blows             is not null then wl89seg.liquid_blows             else  -1  end  as  WL89_Blows
       ,case when wl89seg.exclude_segment          is not null then wl89seg.exclude_segment          else ' '  end  as  WL89_exclude_segment
       ,case when wl89seg.Minimum_Spec_Plastic     is not null then wl89seg.Minimum_Spec_Plastic     else ' '  end  as  WL89_Minimum_Spec_Plastic
       ,case when wl89seg.Maximum_Spec             is not null then wl89seg.Maximum_Spec             else ' '  end  as  WL89_Maximum_Spec
       ,case when wl89seg.Non_Visous_Non_Plastic_indicator
                                                   is not null then wl89seg.Non_Visous_Non_Plastic_indicator else ' '  end
                                                   as  WL89_nvnp_indicator
       
       ,case when wl89seg.pct_moisture             is not null then wl89seg.pct_moisture             else  -1  end  as  WL89_pct_moisture
       
       /*-----------------------------------------------------------------
         liquid limit at the segment level
       -----------------------------------------------------------------*/
       
       ,case when wl89seg.liquid_limit_raw         is not null then wl89seg.liquid_limit_raw         else  -1  end  as  WL89_liquid_limit_raw
       ,liquid_limit_round                                                                                          as  WL89_liquid_limit_round
       ,liquid_limit_roundeven                                                                                      as  WL89_liquid_limit_roundeven
       
       /*-----------------------------------------------------------------
         liquid limit summation and average
         LL avg = round_ties_to_even(liquid_limit_sum_raw / liquid_limit_count) 
       -----------------------------------------------------------------*/
       
       ,case when limit_sql.liquid_limit_count    is not null then limit_sql.liquid_limit_count    else  -1  end  as  WL89_liquid_limit_count
       ,case when limit_sql.liquid_limit_sum_raw  is not null then limit_sql.liquid_limit_sum_raw  else  -1  end  as  WL89_liquid_limit_sum_raw
       ,liquid_limit_sum_round                                                                                    as  WL89_liquid_limit_sum_round
       ,liquid_limit_sum_roundeven                                                                                as  WL89_liquid_limit_sum_roundeven
       ,case when liquid_limit_average            is not null then liquid_limit_average            else  -1  end  as  WL89_liquid_limit_average
       
       /*-----------------------------------------------------------------
         plastic limit at the segment level
       -----------------------------------------------------------------*/
       
       ,case when wl89seg.plastic_limit_raw        is not null then wl89seg.plastic_limit_raw        else  -1  end  as  WL89_plastic_limit_raw -- not displayed
       ,plastic_limit_round                                                                                         as  WL89_plastic_limit_round
       ,plastic_limit_roundeven                                                                                     as  WL89_plastic_limit_roundeven
       
       /*-----------------------------------------------------------------
         plastic limit summation and average
         PL avg = round_ties_to_even(plastic_limit_sum_raw / plastic_limit_count) 
       -----------------------------------------------------------------*/
       
       ,case when limit_sql.plastic_limit_count   is not null then limit_sql.plastic_limit_count   else  -1  end  as  WL89_plastic_limit_count
       ,case when limit_sql.plastic_limit_sum_raw is not null then limit_sql.plastic_limit_sum_raw else  -1  end  as  WL89_plastic_limit_sum_raw
       ,plastic_limit_sum_round                                                                                   as  WL89_plastic_limit_sum_round
       ,plastic_limit_sum_roundeven                                                                               as  WL89_plastic_limit_sum_roundeven
       ,case when plastic_limit_average           is not null then plastic_limit_average           else  -1  end  as  WL89_plastic_limit_average
       
       /*-----------------------------------------------------------------
         plasticity index = liquid_limit_average - plastic_limit_average
       -----------------------------------------------------------------*/
       
       ,(first_value(liquid_limit_average) over (partition by wl89seg.sample_id order by wl89seg.sample_id, wl89seg.segment_nbr)) - 
        (last_value(plastic_limit_average) over (partition by wl89seg.sample_id order by wl89seg.sample_id, wl89seg.segment_nbr
         rows between unbounded preceding and unbounded following)) 
         as WL89_plasticity_index
        
       ,wl89.remarks as WL89_remarks
       
       /*----------------------------------------------------------------------------
         table relationships
       ----------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                          smpl
       
       join Test_WL89                                   wl89 on wl89.sample_id = smpl.sample_id
       
       left join segment_sql                         wl89seg on wl89.sample_id = wl89seg.sample_id
       
       left join limit_sql                                   on wl89seg.sample_id   = limit_sql.sample_id
                                                            and wl89seg.TYPE_L_OR_P = limit_sql.TYPE_L_OR_P
       
       /*---------------------------------------------------------------------------
         liquid segment and summation values, rounded
         liquid limit average
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when (wl89seg.liquid_limit_raw         is not null and wl89seg.liquid_limit_raw  > 0 )
                                then round(wl89seg.liquid_limit_raw) 
                                else -1 
                                end as liquid_limit_round 
                                from dual) LL1
                                
       cross apply (select case when (wl89seg.liquid_limit_raw         is not null and wl89seg.liquid_limit_raw  > 0 )
                                then round_ties_to_even(wl89seg.liquid_limit_raw) 
                                else -1 
                                end as liquid_limit_roundeven  
                                from dual) LL2
       
       cross apply (select case when (limit_sql.liquid_limit_sum_raw  is not null and limit_sql.liquid_limit_sum_raw  > 0 )
                                then round(limit_sql.liquid_limit_sum_raw) 
                                else -1 
                                end as liquid_limit_sum_round      
                                from dual) LL3
                                
       cross apply (select case when (limit_sql.liquid_limit_sum_raw  is not null and limit_sql.liquid_limit_sum_raw  > 0 )
                                then round_ties_to_even(limit_sql.liquid_limit_sum_raw) 
                                else -1 
                                end as liquid_limit_sum_roundeven 
                                from dual) LL4

       cross apply (select case when (limit_sql.liquid_limit_sum_raw  is not null and limit_sql.liquid_limit_sum_raw  > 0 and 
                                      limit_sql.liquid_limit_count    is not null and limit_sql.liquid_limit_count    > 0) 
                                then round_ties_to_even(limit_sql.liquid_limit_sum_raw / limit_sql.liquid_limit_count) 
                                else -1 end as liquid_limit_average
                                from dual) LL_avg
       
       /*---------------------------------------------------------------------------
         plastic segment and summation values, rounded
         plastic limit average
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when (wl89seg.plastic_limit_raw        is not null and wl89seg.plastic_limit_raw > 0 )
                                then round(wl89seg.plastic_limit_raw) 
                                else -1 
                                end as plastic_limit_round
                                from dual) PL1
                                
       cross apply (select case when (wl89seg.plastic_limit_raw        is not null and wl89seg.plastic_limit_raw > 0 )
                                then round_ties_to_even(wl89seg.plastic_limit_raw) 
                                else -1 
                                end as plastic_limit_roundeven 
                                from dual) PL2
       
       cross apply (select case when (limit_sql.plastic_limit_sum_raw is not null and limit_sql.plastic_limit_sum_raw > 0 )
                                then round(limit_sql.plastic_limit_sum_raw) 
                                else -1 
                                end as plastic_limit_sum_round 
                                from dual) PL3
                                
       cross apply (select case when (limit_sql.plastic_limit_sum_raw is not null and limit_sql.plastic_limit_sum_raw > 0 )
                                then round_ties_to_even(limit_sql.plastic_limit_sum_raw) 
                                else -1 
                                end as plastic_limit_sum_roundeven 
                                from dual) PL4
       
       cross apply (select case when (limit_sql.plastic_limit_sum_raw is not null and limit_sql.plastic_limit_sum_raw > 0 and 
                                      limit_sql.plastic_limit_count   is not null and limit_sql.plastic_limit_count   > 0) 
                                then round_ties_to_even(limit_sql.plastic_limit_sum_raw / limit_sql.plastic_limit_count) 
                                else -1 end as plastic_limit_average
                                from dual) PL_avg
       
       order by wl89.sample_id, wl89seg.segment_nbr
       ;
  




  
  
  

