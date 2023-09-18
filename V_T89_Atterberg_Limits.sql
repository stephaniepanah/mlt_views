


select * from V_T89_Atterberg_Limits 
 where T89_sample_id in (
 'W-20-0452', 'W-20-0464', 'W-20-0630', 'W-20-0653', 'W-20-0681-SO', 'W-19-1460-SO', 'W-13-0744-SO', 'W-03-0044-SO' 
 )
 order by T89_sample_year desc, T89_sample_id, T89_segment_nbr 
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
select hdr.sample_id, hdr.sample_year from test_T89 hdr
 where hdr.sample_id not in (select seg.sample_id from test_T89_segments seg
                              where seg.sample_id = hdr.sample_id)
 order by hdr.sample_year desc, hdr.sample_id
;
-- over 2000 samples do not contain segments
-- 44 samples are post year 2000



-- find segments without headers (there should not be any)
select seg.sample_id from test_T89_segments seg
 where seg.sample_id not in (select hdr.sample_id from test_T89 hdr
                              where hdr.sample_id = seg.sample_id)
;
-- 0



select * from test_t89 order by sample_year desc, sample_id;



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



create or replace view V_T89_Atterberg_Limits as 

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
                        --   dried > 0            tare < 0            damp < dried       W-11-0094-SO: sole sample, but does not fit here
                        --   dried > 0            tare < 0            damp > mass_dried  17 samples from 1986
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
            
       from Test_T89_Segments
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
             
            
       from Test_T89_Segments
      group by sample_id, TYPE_L_OR_P
)

/*----------------------------------------------------------------------------
  main SQL
----------------------------------------------------------------------------*/

select  t89.sample_id                                          as T89_sample_id
       ,t89.sample_year                                        as T89_sample_year
       
       ,t89.test_status                                        as T89_test_status
       ,t89.tested_by                                          as T89_tested_by
       
       ,case when to_char(t89.date_tested, 'yyyy') = '1959'    then ' '
             else to_char(t89.date_tested, 'mm/dd/yyyy') end   as T89_date_tested
            
       ,t89.date_tested                                        as T89_date_tested_DATE
       ,t89.date_tested_orig                                   as T89_date_tested_orig
       
       /*-----------------------------------------------------------------
         segments, liquid and plastic grids
       -----------------------------------------------------------------*/
       
       ,case when t89seg.segment_nbr              is not null then t89seg.segment_nbr              else  -1  end  as  T89_segment_nbr -- key
       ,case when t89seg.TYPE_L_OR_P              is not null then t89seg.TYPE_L_OR_P              else ' '  end  as  T89_TYPE_L_OR_P
       ,case when t89seg.type_segment_nbr         is not null then t89seg.type_segment_nbr         else  -1  end  as  T89_type_segment_nbr
       ,case when t89seg.can_nbr                  is not null then t89seg.can_nbr                  else ' '  end  as  T89_can_nbr
       ,case when t89seg.mass_tare                is not null then t89seg.mass_tare                else  -1  end  as  T89_mass_tare
       ,case when t89seg.mass_damp                is not null then t89seg.mass_damp                else  -1  end  as  T89_mass_damp
       ,case when t89seg.mass_dried               is not null then t89seg.mass_dried               else  -1  end  as  T89_mass_dried
       ,case when t89seg.liquid_blows             is not null then t89seg.liquid_blows             else  -1  end  as  T89_Blows
       ,case when t89seg.exclude_segment          is not null then t89seg.exclude_segment          else ' '  end  as  T89_exclude_segment
       ,case when t89seg.Minimum_Spec_Plastic     is not null then t89seg.Minimum_Spec_Plastic     else ' '  end  as  T89_Minimum_Spec_Plastic
       ,case when t89seg.Maximum_Spec             is not null then t89seg.Maximum_Spec             else ' '  end  as  T89_Maximum_Spec
       ,case when t89seg.Non_Visous_Non_Plastic_indicator
                                                  is not null then t89seg.Non_Visous_Non_Plastic_indicator else ' '  end
                                                  as  T89_nvnp_indicator
       
       ,case when t89seg.pct_moisture             is not null then t89seg.pct_moisture             else  -1  end  as  T89_pct_moisture
       
       /*-----------------------------------------------------------------
         liquid limit at the segment level
       -----------------------------------------------------------------*/
       
       ,case when t89seg.liquid_limit_raw         is not null then t89seg.liquid_limit_raw         else  -1  end  as  T89_liquid_limit_raw
       ,liquid_limit_round                                                                                        as  T89_liquid_limit_round
       ,liquid_limit_roundeven                                                                                    as  T89_liquid_limit_roundeven
       
       /*-----------------------------------------------------------------
         liquid limit summation and average
         LL avg = round_ties_to_even(liquid_limit_sum_raw / liquid_limit_count) 
       -----------------------------------------------------------------*/
       
       ,case when limit_sql.liquid_limit_count    is not null then limit_sql.liquid_limit_count    else  -1  end  as  T89_liquid_limit_count
       ,case when limit_sql.liquid_limit_sum_raw  is not null then limit_sql.liquid_limit_sum_raw  else  -1  end  as  T89_liquid_limit_sum_raw
       ,liquid_limit_sum_round                                                                                    as  T89_liquid_limit_sum_round
       ,liquid_limit_sum_roundeven                                                                                as  T89_liquid_limit_sum_roundeven
       ,case when liquid_limit_average            is not null then liquid_limit_average            else  -1  end  as  T89_liquid_limit_average
       
       /*-----------------------------------------------------------------
         plastic limit at the segment level
       -----------------------------------------------------------------*/
       
       ,case when t89seg.plastic_limit_raw        is not null then t89seg.plastic_limit_raw        else  -1  end  as  T89_plastic_limit_raw -- not displayed
       ,plastic_limit_round                                                                                       as  T89_plastic_limit_round
       ,plastic_limit_roundeven                                                                                   as  T89_plastic_limit_roundeven
       
       /*-----------------------------------------------------------------
         plastic limit summation and average
         PL avg = round_ties_to_even(plastic_limit_sum_raw / plastic_limit_count) 
       -----------------------------------------------------------------*/
       
       ,case when limit_sql.plastic_limit_count   is not null then limit_sql.plastic_limit_count   else  -1  end  as  T89_plastic_limit_count
       ,case when limit_sql.plastic_limit_sum_raw is not null then limit_sql.plastic_limit_sum_raw else  -1  end  as  T89_plastic_limit_sum_raw
       ,plastic_limit_sum_round                                                                                   as  T89_plastic_limit_sum_round
       ,plastic_limit_sum_roundeven                                                                               as  T89_plastic_limit_sum_roundeven
       ,case when plastic_limit_average           is not null then plastic_limit_average           else  -1  end  as  T89_plastic_limit_average
       
       /*-----------------------------------------------------------------
         plasticity index = liquid_limit_average - plastic_limit_average
       -----------------------------------------------------------------*/
       
       ,(first_value(liquid_limit_average) over (partition by t89seg.sample_id order by t89seg.sample_id, t89seg.segment_nbr)) - 
        (last_value(plastic_limit_average) over (partition by t89seg.sample_id order by t89seg.sample_id, t89seg.segment_nbr
         rows between unbounded preceding and unbounded following)) 
         as T89_plasticity_index
        
       ,T89.remarks as T89_remarks
       
       /*----------------------------------------------------------------------------
         table relationships
       ----------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                          smpl
       
       join Test_T89                                     t89 on t89.sample_id = smpl.sample_id
       
       left join segment_sql                          t89seg on t89.sample_id = t89seg.sample_id
       
       left join limit_sql                                   on t89seg.sample_id   = limit_sql.sample_id
                                                            and t89seg.TYPE_L_OR_P = limit_sql.TYPE_L_OR_P
       
       /*---------------------------------------------------------------------------
         liquid segment and summation values, rounded
         liquid limit average
       ---------------------------------------------------------------------------*/
       
       cross apply (select case when (t89seg.liquid_limit_raw         is not null and t89seg.liquid_limit_raw  > 0 )
                                then round(t89seg.liquid_limit_raw) 
                                else -1 
                                end as liquid_limit_round 
                                from dual) LL1
                                
       cross apply (select case when (t89seg.liquid_limit_raw         is not null and t89seg.liquid_limit_raw  > 0 )
                                then round_ties_to_even(t89seg.liquid_limit_raw) 
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
       
       cross apply (select case when (t89seg.plastic_limit_raw        is not null and t89seg.plastic_limit_raw > 0 )
                                then round(t89seg.plastic_limit_raw) 
                                else -1 
                                end as plastic_limit_round
                                from dual) PL1
                                
       cross apply (select case when (t89seg.plastic_limit_raw        is not null and t89seg.plastic_limit_raw > 0 )
                                then round_ties_to_even(t89seg.plastic_limit_raw) 
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
       
       order by t89.sample_id, t89seg.segment_nbr
       ;
  




  
  
  

