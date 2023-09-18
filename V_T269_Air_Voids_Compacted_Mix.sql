


select * from V_T269_Air_Voids_Compacted_Mix
 order by T269_sample_year desc, T269_sample_id
;



--------------------------------------------------------------------------------
-- some diagnostics
--------------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T269 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 11	    1986	2021



select * from Test_T269 order by sample_year desc, sample_id;
/*
W-21-0874-AC - no data
W-21-1012-AC - no data
W-21-1013-AC - no data
W-21-1014-AC - no data
W-21-1015-AC - no data
W-21-1016-AC - no data
W-19-0720-AC - no data
W-14-0665-AC - no data
W-05-0213-AC - good data
W-05-0214-AC - good data
W-86-0660-AC - some data
*/



/*******************************************************************************

 T269 Air Voids, Compacted Mix
 
 from MTest, Lt_T269_C2.cpp
 
 void LtT269_C2::CorGrpRoot::calc()
 {
   //  %AV = 100*(1 - Gmm/Gmb)
   
   double gmm, gmb;
   double av = FLT_BLANK;

   gmm = getNum(CorX::xRice);
   gmb = getNum(CorX::xBsg);

   if( gmb > 0.0 && gmm >= 0.0 )
   {
      double tmp = 1.0 - gmm/gmb;
      if( tmp >= 0.0 )
      {
         av = 100.0 * tmp;
      }
   }
   getFld(CorX::xAv)->reviseFltValueShow(av);
}

*******************************************************************************/


create or replace view V_T269_Air_Voids_Compacted_Mix as 


select  t269.sample_id                                         as T269_Sample_ID
       ,t269.sample_year                                       as T269_sample_year
       ,t269.test_status                                       as T269_test_status
       ,t269.tested_by                                         as T269_tested_by
       
       ,case when to_char(t269.date_tested, 'yyyy') = '1959'   then ' ' 
        else to_char(t269.date_tested, 'mm/dd/yyyy') end       as T269_date_tested
        
       ,t269.date_tested                                       as T269_date_tested_DATE
       ,t269.date_tested_orig                                  as T269_date_tested_orig         
       
       ,t269.asphalt_content                                   as T269_asphalt_content
       ,t269.rice_specific_gravity                             as T269_rice_specific_gravity_Gmm
       ,t269.bulk_specific_gravity                             as T269_bulk_specific_gravity_Gmb
       ,pct_air_voids                                          as T269_pct_air_voids
       
       ,t269.remarks                                           as T269_remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                           smpl
       join Test_T269                                    t269 on t269.sample_id = smpl.sample_id
       
       /*-----------------------------------------------------------------------
         calculations
       -----------------------------------------------------------------------*/
       
       cross apply (select case when (t269.rice_specific_gravity >= 0 and t269.bulk_specific_gravity > 0) 
                                then (1 - (t269.rice_specific_gravity / t269.bulk_specific_gravity)) * 100.0 
                                else -1 end as pct_air_voids from dual) airvoids
       ;








