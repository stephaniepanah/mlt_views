


-- D5821 Fractured Particles       (current)
-- FL506 Fractured Faces, Multiple (1995)
-- FL507 Fractured Particles       (2016)
-- FL508 Flakiness Index           (2001)



select * from V_FL507_Fractured_Particles;




select count(*), min(sample_year), max(sample_year) from Test_FL507 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 3627     1986    2016



select * from Test_FL507;



/***********************************************************************************

 FL507 Fractured Particles

 W-16-1153-AG, W-06-0123-SO, W-01-0006-AC, W-01-0111-AG, W-01-0120-AG

from MTest, Lt_FL507_C6.cpp

void LtFL507_C6::CorGrpRoot::calc()
{
	double pct = FLT_BLANK;                  // pct fractured
	double frac = getNum(CorX::xWtFrac);     // fractured
	double nfrac = getNum(CorX::xWtNotFrac); // not fractured

	if (frac >= 0.0 && nfrac >= 0.0)
	{
		double denom = frac + nfrac;

		if (denom > 0.0)
			pct = 100.0 * frac / denom;
	}
}
                    
***********************************************************************************/

create or replace view V_FL507_Fractured_Particles as

select  fl507.sample_id
       ,fl507.sample_year
       ,fl507.test_status
       ,fl507.tested_by
       
       ,case when to_char(fl507.date_tested, 'yyyy') = '1959' then ' '
             else to_char(fl507.date_tested, 'mm/dd/yyyy')
             end as date_tested
            
       ,fl507.date_tested as date_tested_DATE
       ,fl507.date_tested_orig as date_tested_orig
       
       ,case when fl507.mass_fractured        >= 0 then trim(to_char(fl507.mass_fractured, '9999990.99'))   else ' ' end as mass_fractured
       ,case when fl507.mass_not_fractured    >= 0 then trim(to_char(fl507.mass_not_fractured, '99990.99')) else ' ' end as mass_not_fractured
       ,case when percent_fractured_calc      >= 0 then trim(to_char(percent_fractured_calc, '9990.999'))   else ' ' end as calc_pct_fractured             
       ,case when fl507.minimum_pct_fractured >= 0 then trim(to_char(fl507.minimum_pct_fractured))          else ' ' end as minimum_pct_fractured
        
       ,fl507.remarks       
  
  /*---------------------------------------------------------------------------
    captured_pct_fractured - there are instances where pct fractured is 
    present, but there is no supporting data (mass_fractured and
    mass_not_fractured) so how can this be. capturing in a field
  ---------------------------------------------------------------------------*/
  
       ,fl507.captured_pct_fractured
       
       ,calc_denominator -- used in calculations, not to be displayed
  
  /*---------------------------------------------------------------------------
    table relationships
  ---------------------------------------------------------------------------*/
  
  from MLT_1_Sample_WL900            smpl
  join Test_FL507                    fl507 on smpl.sample_id = fl507.sample_id
  
  /*---------------------------------------------------------------------------
    calculations: pct frac = 100.0 * frac / frac + nfrac
    
    1- need to account for possible -1 null values in mass_fractured and 
       mass_not_fractured. if -1, set to 0, so that calculations are accurate
    2- add mass_fractured_nbr and mass_not_fractured_nbr to obtain
       the denominator
    3- if the denominator is > 0 then calculate the percent fractured
  ---------------------------------------------------------------------------*/
  
  cross apply (select case when fl507.mass_fractured >= 0 then fl507.mass_fractured else 0 end
  as mass_fractured_nbr from dual
  ) frac_nbr
  
  cross apply (select case when fl507.mass_not_fractured >= 0 then fl507.mass_not_fractured else 0 end
  as mass_not_fractured_nbr from dual
  ) nfrac_nbr
  
  -- at this point, calc_denominator will at least be 0, not negative
  cross apply (select mass_fractured_nbr + mass_not_fractured_nbr as calc_denominator from dual
  ) denom
    
  cross apply (select case when calc_denominator > 0 then (100 * fl507.mass_fractured / calc_denominator)
                           else -1 end as percent_fractured_calc from dual
  ) pct_fractured
 ;





 


select * from Test_FL507 where captured_pct_fractured > 0;

/*-----------------------------------------------------------------------------------
Sample ID       Year    Status  date tested     frac nfrac  min pct captured pct frac
-------------   ----    ------  -----------     ---- -----  ------- -----------------
W-66-9001-GEO	1966	NC	 	01-JAN-59	 	-1	    -1	    -1	    50.7	 
W-66-9011-GEO	1966	NC	 	01-JAN-59	 	-1	    -1	    -1	    50.7	 
W-86-0962-AC	1986	 	 	01-JAN-59	 	-1	    -1	    -1	    92	 
W-86-1256-AC	1986	 	 	01-JAN-59	 	-1	    -1	    -1	    80	 
W-86-1380-ACA	1986	 	 	01-JAN-59	 	-1	    -1	    -1	    79	 
W-88-1791-AC	1988	 	 	01-JAN-59	 	-1	    -1	    -1	    100	 
W-88-1792-AC	1988	 	 	01-JAN-59	 	-1	    -1	    -1	    100	 
W-88-1852-AC	1988	 	 	01-JAN-59	 	-1	    -1	    -1	    100	 
W-88-1853-AC	1988	 	 	01-JAN-59	 	-1	    -1	    -1	    100	 
W-88-1854-AC	1988	 	 	01-JAN-59	 	-1	    -1	    -1	    100	 
W-88-1908-AC	1988	 	 	01-JAN-59	 	-1	    -1	    -1	    100	 
W-88-1909-AC	1988	 	 	01-JAN-59	 	-1	    -1	    -1	    100	 
W-88-1941-AC	1988	 	 	01-JAN-59	 	-1	    -1	    -1	    100	 
-----------------------------------------------------------------------------------*/









