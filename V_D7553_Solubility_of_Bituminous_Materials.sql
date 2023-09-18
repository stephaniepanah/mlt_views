


select * from V_D7553_Solubility_of_Bituminous_Materials
 order by D7553_Sample_Year desc, D7553_Sample_ID
;



--   T44 Solubility  of Bituminous Materials  (current)
-- D7553 Solubility  of Bituminous Materials  (2015) -- same layout as T44
--   T49 Penetration of Bituminous Materials  (current)
--   T51 Ductility   of Bituminous Materials  (current)
--  T301 Elastic Recovery of Bituminous materials (current)



-----------------------------------------------------------------------
-- some diagnostics
-----------------------------------------------------------------------


select count(*), min(sample_year), max(sample_year) from Test_D7553 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
--    12    2013    2015



select * from test_d7553 order by sample_year desc, sample_id;



/***********************************************************************************
 
 D7553 Solubility of Bituminous Materials
 Bituminous - of, containing, or of the nature of bitumen (aka Asphalt)

 W-15-0172-AB, W-15-0242-AB, W-15-0256-AB, W-15-0257-AB, W-15-0258-AB, W-15-0298-AB
 W-13-0894-AB, W-13-0931-AB, W-13-0932-AB, W-13-0933-AB, W-13-0934-AB, W-13-0935-AB
 
 samples are only found in 2015 & 2013, about six samples in each year
 there were several samples that were abandoned for D7553 in 2016, 2017 & 2018
 
 -------------------------------------------------------------------
 from MTest, Lt_D7553_BC.cpp, void LtD7553_D9::CorGrpRoot::calc(){
 -------------------------------------------------------------------

 double tare  = getNum(CorX::xTare);    // mass crucible & filter
 double gross = getNum(CorX::xGross);   // mass crucible, filter & residue
 double as    = getNum(CorX::xAsphalt); // asphalt
 
 if (tare >= 0.0 && gross >= 0.0 && as > 0.0)
 {
    soluble = 100.0 * ((as - (gross - tare)) / as);
 }
 

***********************************************************************************/


create or replace view V_D7553_Solubility_of_Bituminous_Materials as 

--------------------------------------------------------------------------------
-- main SQL
--------------------------------------------------------------------------------


select  d7553.sample_id                                        as D7553_Sample_ID
       ,d7553.sample_year                                      as D7553_Sample_Year
       ,d7553.test_status                                      as D7553_Test_Status
       ,d7553.tested_by                                        as D7553_Tested_by
       
       ,case when to_char(d7553.date_tested, 'yyyy') = '1959'  then ' '
             else to_char(d7553.date_tested, 'mm/dd/yyyy') end as D7553_date_tested
       
       ,d7553.date_tested                                      as D7553_date_tested_DATE
       ,d7553.date_tested_orig                                 as D7553_date_orig
       
       ,d7553.mass_crucible_and_filter                         as D7553_mass_crucible_and_filter
       ,d7553.mass_asphalt                                     as D7553_mass_asphalt
       ,d7553.mass_crucible_filter_residue                     as D7553_mass_crucible_filter_residue        
       ,pct_soluble_calculated                                 as D7553_Percent_Soluble
       ,d7553.minimum_spec                                     as D7553_minimum_spec
                            
       ,d7553.remarks as D7553_Remarks
       
       /*--------------------------------------------------------------------------------
         table relationships
       --------------------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                            smpl
       join Test_D7553                                   d7553 on smpl.sample_id = d7553.sample_id
       
       /*--------------------------------------------------------------------------------
         percent soluble = ((asphalt - (gross - tare)) / asphalt)) * 100
       --------------------------------------------------------------------------------*/
  
       cross apply (select case when d7553.mass_asphalt                 >  0 and -- asphalt
                                     d7553.mass_crucible_filter_residue >= 0 and -- gross
                                     d7553.mass_crucible_and_filter     >= 0     -- tare
                                
                                then ((d7553.mass_asphalt - (d7553.mass_crucible_filter_residue - d7553.mass_crucible_and_filter)) -- numerator
                                      / (d7553.mass_asphalt)) * 100
                                   
                                else -1
                                end as pct_soluble_calculated from dual) calc_sol
 ;









