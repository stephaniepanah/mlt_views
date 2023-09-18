


select * from V_T85_RAP_Recycled_Asphalt_Pavement
 order by T85_RAP_Sample_Year desc, T85_RAP_Sample_ID
;



select count(*) from test_t85_rap; -- 137




/***********************************************************************************

 T85 RAP - Recycled Asphalt Pavement

 W-19-0719-AC, W-19-0728-AC, W-19-0862-AC, W-19-0955-AC
 W-18-0036-AC, W-18-0391-AC
 
 
 from MTest, Lt_T85_B5_da.cpp, void LtT85::CorGrpCmb::calcRap()
 {
   2014-08-12, Calcs based on "Form FHWA 1641 (Rev 03-11)", but in place of
   the form's calculation of Gse "10/Gmm" is replaced by 100/Gmm
   
   // calculate Gse, Gsb
   double denoma, denomb;
   double gb = <get data>               // specific_gravity_binder
   
   if (gb > 0.0)                        // if specific_gravity_binder > 0
   {
      double pb  = <get data>           // pct_binder
      double gmm = <get data>           // max_specific_gravity
      
      // calculate Gse, Gsb
      if ( pb > 0.0 && gmm > 0.0 )      // if pct_binder > 0 && max_specific_gravity > 0
      {
         denoma = 100.0 / gmm;          // 100.0 / max_specific_gravity
         denomb = pb / gb;              // pct_binder / specific_gravity_binder
         
         if (denoma > denomb)           // if (100.0 / max_specific_gravity) > (pct_binder / specific_gravity_binder)
             gse = ((100.0 - pb) / (denoma - denomb));
          // gse = ((100.0 - pct_binder) / ((100.0 / max_specific_gravity) - (pct_binder / specific_gravity_binder)))
          // gse, effective specific gravity
      }
      
      double pba = <get data>           // pct_binder_absorbed
      
      if (gse > 0.0 && pba > 0.0)       // if effective specific gravity > 0 && pct_binder_absorbed > 0
      {
         denomc = (pba * gse) / (100.0 * gb) + 1.0;
      // denomc = (pct_binder_absorbed * effective specific gravity) / (100 * specific_gravity_binder) + 1
         
         if (denomc > 0.0)
         {
            gsb = gse / denomc;         //   bulk specific gravity of stone = effective specific gravity / denomc
         }
      }
   }
   
   if (!isfBlank(gsb))                  // if gsb > 0
   {
      // calculate combined Gsb of agg and RAP
      double prap = <get data>          // Pct_RAP_recycled_asphalt_pavement

		if (prap >= 0.0)                // if Pct_RAP_recycled_asphalt_pavement > 0
		{
			prap /= 100.0; // convert to decimal pct
                                        // prap = prap / 100 or prap = prap * 0.01
            
			double sgagg = getFld(CorCmbX::xBsg)->getFltValue(); <get data> 

			if (sgagg > 0.0)           // what is this ?????????????
			{
				csg = prap*gsb + (1.0 - prap)*sgagg; // ((prap * gsb) + ((1.0 - prap) * sgagg));
			}
		}
	}
 
            
***********************************************************************************/


create or replace view V_T85_RAP_Recycled_Asphalt_Pavement as

with T85_RAP_evaluation as (

     select  sample_id as sample_id
                 
            ,case when  pb_pct_binder              > 0 and 
                        pba_pct_binder_absorbed    > 0 and 
                        gb_specific_gravity_binder > 0 and
                        gmm_maximum_specific_gravity   > 0
                  then round((100.0 / gmm_maximum_specific_gravity),4)
                  else -1 end
                  as denoma
            
            ,case when  pb_pct_binder              > 0 and 
                        pba_pct_binder_absorbed    > 0 and 
                        gb_specific_gravity_binder > 0 and
                        gmm_maximum_specific_gravity   > 0
                  then round((pb_pct_binder / gb_specific_gravity_binder),4)
                  else -1 end
                  as denomb
            
            ,case when  pb_pct_binder              > 0 and 
                        pba_pct_binder_absorbed    > 0 and 
                        gb_specific_gravity_binder > 0 and
                        gmm_maximum_specific_gravity   > 0 and
                        
                        -- and denoma > denomb
                        (100.0 / gmm_maximum_specific_gravity) > (pb_pct_binder / gb_specific_gravity_binder)
                        
                  -- gse = ( (100.0 - pb) /  ( denoma -  denomb ))
                  then round( ( (100.0 - pb_pct_binder) / 
                              ( (100.0 / gmm_maximum_specific_gravity) - (pb_pct_binder / gb_specific_gravity_binder)) ), 4)
                  
                  else -1 end
                  as gse_effective_sg -- gse, effective specific gravity
                  
       from Test_T85_RAP       
)

select  t85.sample_year  as T85_RAP_Sample_Year
       ,t85rap.sample_id as T85_RAP_Sample_ID -- key
       
       ,case when t85rap.PB_PCT_BINDER              >= 0 then to_char(t85rap.PB_PCT_BINDER,                '990.99' ) else ' ' end
        as T85_RAP_PB_PCT_BINDER
        
       ,case when t85rap.PBA_PCT_BINDER_ABSORBED    >= 0 then to_char(t85rap.PBA_PCT_BINDER_ABSORBED,      '990.99' ) else ' ' end
        as T85_RAP_PBA_PCT_BINDER_ABSORBED
        
       ,case when t85rap.GB_SPECIFIC_GRAVITY_BINDER >= 0 then to_char(t85rap.GB_SPECIFIC_GRAVITY_BINDER, '99990.999') else ' ' end
        as T85_RAP_GB_SPECIFIC_GRAVITY_BINDER
       
       ,case when t85rap.gmm_maximum_specific_gravity   >= 0 then to_char(t85rap.gmm_maximum_specific_gravity,   '99990.999') else ' ' end
        as T85_RAP_GMM_MAX_SPECIFIC_GRAVITY
        
       ,case when gse_effective_sg                  >= 0 then to_char(gse_effective_sg) else ' ' end
        as T85_RAP_gse_effective_sg
         
       ,case when gsb_bulk_specific_gravity         >= 0 then to_char(gsb_bulk_specific_gravity) else ' ' end
        as T85_RAP_gsb_bulk_specific_gravity
         
       ,case when t85rap.pct_recycled_asphalt_pavement >= 0 then to_char(gmm_maximum_specific_gravity) else ' ' end
        as T85_RAP_Pct_RAP

       -- need combined, here
        
       ,denoma -- (100.0 / gmm_max_specific_gravity)
       ,denomb -- (pb_pct_binder / gb_specific_gravity_binder)
       ,denomc -- ((pba * gse) / (100.0 * gb)) + 1.0
       
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T85                                 t85 on t85.sample_id      = smpl.sample_id
  join Test_T85_RAP                          t85rap on t85.sample_id      = t85rap.sample_id
  join T85_RAP_evaluation               t85rap_eval on t85rap.sample_id   = t85rap_eval.sample_id
  
  /*-------------------------------------------------------------
    denomc = ((pba * gse) / (100.0 * gb)) + 1.0;
    used for gsb_bulk_specific_gravity
  -------------------------------------------------------------*/
  
  cross apply (select case when t85rap.PBA_PCT_BINDER_ABSORBED    > 0 and 
                                t85rap_eval.gse_effective_sg      > 0 and 
                                t85rap.GB_SPECIFIC_GRAVITY_BINDER > 0 
                                
                           -- denomc = ((pba * gse) / (100.0 * gb)) + 1.0;
                           then round((((t85rap.PBA_PCT_BINDER_ABSORBED * t85rap_eval.gse_effective_sg) / 
                                        (100.0 * t85rap.GB_SPECIFIC_GRAVITY_BINDER)) + 1.0),4)
                                 
                           else -1 end
                           as denomc from dual) denom_c
  
  /*-------------------------------------------------------------
    gsb_bulk_specific_gravity = (gse_effective_sg / denomc)
  -------------------------------------------------------------*/
  
  cross apply (select case when denomc > 0  
                           then round((t85rap_eval.gse_effective_sg / denomc),4)
                           else -1 end
                           as gsb_bulk_specific_gravity from dual) gsb_bsg
  
 ;









