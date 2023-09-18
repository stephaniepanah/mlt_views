


--  T308 Asphalt Content (Ignition) (2021) (formerly WL464)
-- WL164 Asphalt Content (Vacuum)   (2006)
-- CL164 Asphalt Content (Reflux)   (1966)



select * from V_T308_Asphalt_Content_Ignition order by T308_Sample_Year desc, T308_Sample_ID
;



----------------------------------------------------------------------------
-- some diagnostics
----------------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_T308 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 2342	    1999	2021



select * from Test_T308 order by sample_year desc, sample_id;



select sample_id, sample_year, moisture_source, moisture_source_alt, captured_pct_moisture
  from test_t308
 order by moisture_source, sample_id desc
 ;
 


select moisture_source, count(moisture_source) from test_t308
 group by moisture_source
 order by moisture_source
 ;
/**
' ' 	 310  --  
Manual	  47  -- there are some that say Manual, but have data from legitimate sources
T110	   3  -- most recently in 2011
T329	 689  -- 2020, most recent
WL110	1212  -- 2016, most recent
**/



select sample_id, sample_year, moisture_source, moisture_source_alt, captured_pct_moisture
  from test_t308 where moisture_source = ' '
 order by sample_year desc, sample_id;
/*
 310 records are blank, captured_pct_moisture is -1
*/



select sample_id, sample_year, moisture_source, moisture_source_alt, captured_pct_moisture
  from test_t308 where moisture_source = 'Manual'
 order by sample_year desc, sample_id;
/* 47 samples
W-19-0728-ACB	2019	Manual	' ' 	0    -- most samples that are Manual are 0 or -1
W-17-0998-AC	2017	Manual	' ' 	-1
W-66-9001-GEO	1966	Manual	' ' 	30.8 -- only 2 samples with captured_pct_moisture
W-66-9011-GEO	1966	Manual	' ' 	30.8
*/



select sample_id, sample_year, moisture_source, moisture_source_alt, captured_pct_moisture
  from test_t308 where moisture_source = 'T329'
 order by sample_year desc;
/* 689 samples
W-20-1089-AC	2020	T329	' ' 	0.03
W-20-1090-AC	2020	T329	' ' 	0.014
W-20-1091-AC	2020	T329	' '     0.021
W-20-1109-AC	2020	T329	' ' 	0
W-20-1110-AC	2020	T329	' ' 	0.009
W-20-1111-AC	2020	T329	' ' 	0.028
*/



select sample_id, sample_year, moisture_source, moisture_source_alt, captured_pct_moisture
  from test_t308 where moisture_source = 'WL110'
 order by sample_year desc, sample_id;
/* 1212 samples
W-16-0439-AC	2016	WL110	' ' 	0.15
W-16-0440-AC	2016	WL110	' ' 	0.095
W-16-1429-AC	2016	WL110	' ' 	1.61
W-15-0310-AC	2015	WL110	' ' 	0.124
W-15-0312-AC	2015	WL110	' ' 	0.037
W-15-0313-AC	2015	WL110	' ' 	0.097
*/



select sample_id, sample_year, moisture_source, moisture_source_alt, captured_pct_moisture
  from test_t308 where moisture_source = 'T110'
 order by sample_year desc, sample_id;
/* 3 samples
W-11-1323-AC	2011	T110	' ' 	0.041
W-11-1834-AC	2011	T110	' ' 	0.077
W-11-1324-AC	2011	T110	' ' 	0.024
*/



select sample_id, sample_year, moisture_source, moisture_source_alt, captured_pct_moisture
  from test_t308 where (moisture_source = 'T308' or moisture_source_alt = 'T308')
 order by sample_year desc, sample_id;
/*
19 samples from 2010, moisture_source = 'T329', moisture_source_alt = 'T308'
*/



/***********************************************************************************

 T308 Asphalt Content (Ignition)
 
 W-20-0002,    W-20-0003,    W-20-0710-AC, W-20-0716-AC, W-20-0828-AC, W-20-0829-AC
 W-19-0525-AC, W-19-0948-AC, W-18-0107-AC, W-18-0569-AC, W-17-0712-AC, W-16-0776-AC

 from MTest, Lt_T308_C2.cpp
 ==========================
 
 void LtT308_C2::CorGrpRoot::calc(unsigned id)
 {
   // ARGUMENT id: IDcode of input field. 0 to calc all
   double result, tare;
   unsigned need = 0;

   switch( id ){
   case COPARMsT308::IDF_tare:         need = needWtSmplCalc | needResidAg; break;
   case COPARMsT308::IDF_wtBasketAnte: need = needWtSmplCalc; break;
   case COPARMsT308::IDF_ResidBasket:  need = needResidAg; break;
   case COPARMsT308::IDF_ArCor:        need = needArFinal; break;      
   case COPARMsT308::IDF_moco:         need = needArFinal; break;
   default: break;
   }
   
   if( need & (needWtSmplCalc|needResidAg) )
   {
      if( tare < 0.0 ) tare = 0.0;
   }

   if( need & needWtSmplCalc )
   {
       if( basketAnte >= tare )
           result = basketAnte - tare; // weight initial sample (weight before - weight tare)
   }

   if( need & needResidAg )
   {
      double basketResid = getNum(CorX::xResidAll); // residual aggregate and basket
      
      if(basketResid >= tare)
         result = basketResid - tare;
   }

   if( need & needArFinal )
   {
      if(moco < 0.0) moco = 0.0;           // moisture content
      double arcor = getNum(CorX::xArCor); // pct_corrected_asphalt_content
      
      if(arcor > 0.0)
         result = arcor - moco;            // xArMix = arcor - moco
         
      getFld(CorX::xArMix)->reviseFltValueShow(result);
            
      if(result >= 0.0)
         result = 100.0*result/(100.0 - result); // xArAgg = 100 * (xArMix / (100 - xArMix))
      
      getFld(CorX::xArAgg)->reviseFltValueShow(result);
   }
}

***********************************************************************************/


create or replace view V_T308_Asphalt_Content_Ignition as 


select  t308.sample_id                                         as T308_Sample_ID
       ,t308.sample_year                                       as T308_Sample_Year
       ,t308.test_status                                       as T308_Test_Status
       ,t308.tested_by                                         as T308_Tested_by
       
       ,case when to_char(t308.date_tested, 'yyyy') = '1959'   then ' '
             else to_char(t308.date_tested, 'mm/dd/yyyy')      end
                                                               as T308_date_tested
            
       ,t308.date_tested                                       as T308_date_tested_DATE
       ,t308.date_tested_orig                                  as T308_date_orig
       
       /*-----------------------------------------------------------------------
         Reported Ticket Information
       -----------------------------------------------------------------------*/
       
       ,t308.moisture_source                                   as T308_moisture_source                -- T329, WL110, T110, Manual
       ,t308.moisture_source_alt                               as T308_moisture_source_alt       
       ,percent_moisture                                       as T308_percent_moisture
       ,t308.captured_pct_moisture                             as T308_captured_pct_moisture          -- user entered
              
       ,t308.furnace_set_point                                 as T308_furnace_chamber_set_point 
       ,t308.elapsed_time                                      as T308_total_elapsed_time
       ,t308.mass_initial_sample                               as T308_mass_initial_sample
       ,t308.mass_loss_during_ignition                         as T308_mass_loss_during_ignition
       ,t308.Pct_Loss_captured                                 as T308_percent_loss_captured          -- user entered
       ,pct_loss_calculated                                    as T308_percent_loss_calculated        -- for any needed calculation
       ,t308.pct_temperature_compensation                      as T308_pct_temperature_compensation   -- should be calculated
       ,t308.pct_job_mix_correction_factor                     as T308_pct_job_mix_correction_factor  -- should be calculated
       ,t308.pct_corrected_asphalt_content                     as T308_pct_corrected_asphalt_content  -- should be calculated
       
       /*--------------------------------------------------------------------
         Recorded Data and Calculated Values
       --------------------------------------------------------------------*/
       
       ,t308.mass_basket_and_sample                            as T308_mass_basket_and_sample
       ,t308.mass_basket_assembly_tare                         as T308_mass_basket_assembly_tare
       ,mass_tare_calculated                                   as T308_mass_tare_calculated           -- not displayed, used for calculations
       ,mass_initial_sample_weight_calc                        as T308_mass_initial_sample_weight
       ,t308.mass_basket_assembly_residual                     as T308_mass_basket_assembly_residual_aggregate
       ,mass_residual_agg_calculated                           as T308_mass_residual_aggregate
       
       ,pct_corrected_asphalt_mix_calc                         as T308_pct_corrected_asphalt_mix_calc -- (pct_corrected_asphalt_content - moisture content)
       ,t308.pct_corrected_asphalt_mix                         as T308_pct_corrected_asphalt_mix      -- user entered
       ,t308.specs_asphalt_mixture_minimum                     as T308_specs_asphalt_mix_min          -- 646 samples, 2 in 2016, 2007 and before
       ,t308.specs_asphalt_mixture_maximum                     as T308_specs_asphalt_mix_max          -- 646 samples, 2 in 2016, 2007 and before
       
       ,pct_corrected_asphalt_agg_calc                         as T308_pct_corrected_asphalt_agg_calc -- (xArMix / (100.0 - xArMix)) * 100.0
       ,t308.pct_corrected_asphalt_aggregate                   as T308_pct_corrected_asphalt_agg      -- user entered
       ,t308.specs_asphalt_aggregate_minimum                   as T308_specs_asphalt_agg_min          -- 9 samples, in 2001/02
       ,t308.specs_asphalt_aggregate_maximum                   as T308_specs_asphalt_agg_max          -- 9 samples, in 2001/02
       
       ,t308.remarks                                           as T308_Remarks
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_T308                                     t308 on t308.sample_id = smpl.sample_id
       
       left join V_T329_Moisture_Content_of_Hot_Mix     v_t329 on t308.sample_id = v_t329.T329_Sample_ID   -- 2020 (most recent)
       left join V_WL110_Moisture_in_Asphalt_Mix_Oven  v_wl110 on t308.sample_id = v_wl110.WL110_Sample_ID -- 2016
       left join V_T110_Moisture_in_Asphalt_Mix         v_t110 on t308.sample_id = v_t110.T110_Sample_ID   -- 2011
       
       /*-----------------------------------------------------------------------
       calculations
       -----------------------------------------------------------------------*/
       
       cross apply (select case when t308.moisture_source = 'T329' 
                                then case when v_t329.T329_percent_moisture is not null 
                                          then v_t329.T329_percent_moisture
                                          else t308.captured_pct_moisture end
             
                           when t308.moisture_source = 'WL110' 
                                then case when v_wl110.WL110_percent_moisture is not null
                                          then v_wl110.WL110_percent_moisture
                                          else t308.captured_pct_moisture end
                       
                           when t308.moisture_source = 'T110' 
                                then case when v_t110.T110_pct_moisture is not null 
                                          then v_t110.T110_pct_moisture
                                          else t308.captured_pct_moisture end
             
                           when t308.moisture_source = 'Manual' then t308.captured_pct_moisture
                           
                           else -1 end as percent_moisture from dual) pctmoisture
       
       
       cross apply (select case when (percent_moisture >= 0) then percent_moisture else 0 end
                    as moisture_content from dual) moco
       
       
       cross apply (select case when (pct_corrected_asphalt_content - moisture_content) >= 0
                                then (pct_corrected_asphalt_content - moisture_content)
                                else -1 end as pct_corrected_asphalt_mix_calc from dual) xArMix
       
       
       cross apply (select case when (pct_corrected_asphalt_mix_calc >= 0)
                                then ((pct_corrected_asphalt_mix_calc / (100.0 - pct_corrected_asphalt_mix_calc)) * 100.0)
                                else -1 end as pct_corrected_asphalt_agg_calc from dual) xArAgg
       
       
       cross apply (select case when ((t308.mass_loss_during_ignition <= 0) or (t308.mass_initial_sample <= 0)) then 0
                                when (t308.mass_loss_during_ignition > t308.mass_initial_sample)                then 0
                                else ((t308.mass_loss_during_ignition / t308.mass_initial_sample) * 100)
                                end as pct_loss_calculated from dual) pct_loss_calc
       
       
       cross apply (select case when t308.mass_basket_assembly_tare >= 0 then t308.mass_basket_assembly_tare
                                else 0 -- addresses -1 (null) values (do not want -1 in calculations)
                                end as mass_tare_calculated from dual) tare_calc
       
       
       cross apply (select case when (t308.mass_basket_and_sample >= mass_tare_calculated) 
                                then (t308.mass_basket_and_sample  - mass_tare_calculated)
                                else 0 end as mass_initial_sample_weight_calc  from dual) initial_calc
       
       
       cross apply (select case when (t308.mass_basket_assembly_residual >= mass_tare_calculated) 
                                then (t308.mass_basket_assembly_residual  - mass_tare_calculated)
                                else 0 end as mass_residual_agg_calculated from dual) residual_calc
       ;









