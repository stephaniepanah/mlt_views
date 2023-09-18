


select * from V_T44_Solubility_of_Bituminous_Materials
 order by T44_Sample_Year desc, T44_Sample_ID
;



--   T44 Solubility  of Bituminous Materials  (current)
--   T49 Penetration of Bituminous Materials  (current)
--   T51 Ductility   of Bituminous Materials  (current)
--  T301 Elastic Recovery of Bituminous materials (current)
-- D7553 Solubility  of Bituminous Materials  (2015) -- same layout as T44




select count(*), min(sample_year), max(sample_year) from Test_T44 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 45	    2008	2019




select * from Test_T44
 order by Sample_Year desc, Sample_ID
;




/***********************************************************************************

 T44 Solubility of Bituminous Materials
 Bituminous - of, containing, or of the nature of bitumen
 Wikipedia - Bitumen, aka Asphalt
 
 W-18-0183-AB, W-18-0184-AB, W-17-1070-AB, W-12-0391-AB, W-15-0344-AB, W-14-0592-AB
 
 from MTest, Lt_T44_BC.cpp, void LtT44_BC::CorGrpRoot::calc()
 
 2012-03-23. Per Bill McKenna, changed formula 
 
 from: %Sol = 100 * (  as - (gross-tare) /as )
   to: %Sol = 100 * ( (as-(gross-tare))  /as )

 double tare  = getNum(CorX::xTare);    // mass crucible & filter
 double gross = getNum(CorX::xGross);   // mass crucible, filter & residue
 double as    = getNum(CorX::xAsphalt); // just asphalt (good grief, such variable names....)
 
 if (tare >= 0.0 && gross >= 0.0 && as > 0.0)
 {
    soluble = 100.0 * ((as - (gross - tare)) / as);
 }

***********************************************************************************/



create or replace view V_T44_Solubility_of_Bituminous_Materials as 

select  t44.sample_id                         as T44_Sample_ID
       ,t44.sample_year                       as T44_Sample_Year
       ,t44.test_status                       as T44_Test_Status
       ,t44.tested_by                         as T44_Tested_by
       
       ,case when to_char(t44.date_tested, 'yyyy') = '1959'
             then ' '
             else to_char(t44.date_tested, 'mm/dd/yyyy')
             end                              as T44_date_tested
            
       ,t44.date_tested                         as T44_date_tested_DATE
       ,t44.date_tested_orig                    as T44_date_tested_orig
       

       /*----------------------------------------------------------
         Calculations
       ----------------------------------------------------------*/
       
       ,case when t44.mass_crucible_and_filter >= 0 
             then to_char(t44.mass_crucible_and_filter, '9990.9999')
             else ' ' end 
             as T44_mass_crucible_and_filter
       
       ,case when t44.mass_asphalt >= 0 
             then to_char(t44.mass_asphalt, '9990.9999')
             else ' ' end 
             as T44_mass_asphalt
        
       ,case when t44.mass_crucible_filter_residue >= 0 
             then to_char(t44.mass_crucible_filter_residue, '9990.9999')
             else ' ' end 
             as T44_mass_crucible_filter_residue
        
       ,case when calc_pct_soluble >= 0 
             then to_char(calc_pct_soluble, '9990.9999')
             else ' ' end 
             as T44_Percent_Soluble
             
       ,case when t44.minimum_spec >= 0 then to_char(t44.minimum_spec, '990.99') else ' ' end as T44_min_spec
       
       ,mass_crucible_filter_tare as T44_mass_crucible_filter_tare
                            
       ,t44.remarks as T44_Remarks
       
  /*-------------------------------------------------------------
    table relationships
  -------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900                      smpl
  join Test_T44                                 t44 on t44.sample_id = smpl.sample_id
  
  /*-------------------------------------------------------------
    tare = mass_crucible_and_filter
    address -1 'null' values by setting to 0
  -------------------------------------------------------------*/
  
  cross apply (select case when (t44.mass_crucible_and_filter >= 0) then t44.mass_crucible_and_filter 
                           else 0
                           end as mass_crucible_filter_tare from dual
  ) calc_tare
  
  /*-------------------------------------------------------------
    percent soluble = ( 100.0*( (as - (gross - tare)) / as) );
  -------------------------------------------------------------*/
  
  cross apply (select case when mass_crucible_filter_tare        >= 0 and -- tare
                                t44.mass_crucible_filter_residue >= 0 and -- gross
                                t44.mass_asphalt                 >  0     -- asphalt
                                
                           then (((t44.mass_asphalt - (t44.mass_crucible_filter_residue - mass_crucible_filter_tare)) -- numerator
                                   / (t44.mass_asphalt)) * 100)
                                   
                           else -1
                           end as calc_pct_soluble from dual
  ) calc_sol  
  
 ;









