


/*----------------------------------------------------------------

 the view, V_WL190_Segments_Combined_Resistance_Nomograph, 
 is a combination of two other views: 
 
 V_WL190_Resistance_values and V_WL190_Segments_Nomograph
 
 this view is defined at the Sample ID / segment number level, and
 this view returns two rows of nomograph values per segment, because the 
 resistance value needs to be bound by the Nomograph indices 

----------------------------------------------------------------*/




select * from V_WL190_Segments_Combined_Resistance_Nomograph where rval_sample_id = 

 'W-21-0112-SO'
 --'W-21-1055-GS'
 --'W-21-1172-GS'
 --'W-20-0737-SO'
 --'W-20-1505-SO'
 --'W-19-1506-SO'
 --'W-19-1822-SO'
;

/*

 Sample ID     seg  R value     low     high    |-------      low values       -------|     |-------      high values      -------|
 
 W-19-1865-SO	1	76.0098	    75	    80	    -0.23553	-0.16776	0.36777	0.73554	    -0.63892	-0.36946	0.46946	0.93892
 W-19-1865-SO	2	77.2627	    75	    80	    -0.23553	-0.16776	0.36777	0.73554	    -0.63892	-0.36946	0.46946	0.93892
 W-19-1865-SO	3	71.3063	    70	    75	     0.25492	-0.02255	0.12255	0.44508	    -0.23553	-0.16776	0.36777	0.73554

*/


select * from MLT_Resistance_value_Nomograph;




select * from V_WL190_Segments_Nomograph where Nomograph_sample_id = 

 'W-21-0112-SO'
 --'W-21-1055-GS'
 --'W-21-1172-GS'
 --'W-20-0737-SO'
 --'W-20-1505-SO'
 --'W-19-1506-SO'
 --'W-19-1822-SO'
;




select * from V_WL190_Segments_Resistance_Values where rval_Sample_ID = 

 'W-21-0112-SO'
 --'W-21-1055-GS'
 --'W-21-1172-GS'
 --'W-20-0737-SO'
 --'W-20-1505-SO'
 --'W-19-1506-SO'
 --'W-19-1822-SO'
;




create or replace view V_WL190_Segments_Combined_Resistance_Nomograph as 

select  Rval.rval_sample_id
       ,Rval.rval_segment_nbr
       
       ,Rval.resistance_value_raw
       ,Nom.Resistance_value_low
       ,Nom.Resistance_value_high
       ,R_value_high_minus_rval
       
       ,Nom.index_1_low
       ,Nom.index_2_low
       ,Nom.index_3_low
       ,Nom.index_4_low
       
       ,Nom.index_1_high
       ,Nom.index_2_high
       ,Nom.index_3_high
       ,Nom.index_4_high
     
  from  V_WL190_Segments_Resistance_Values  Rval
  
  join  V_WL190_Segments_Nomograph           Nom  on Rval.rval_Sample_ID   = Nom.Nomograph_sample_id
                                                 and Rval.rval_segment_nbr = Nom.Nomograph_segment_nbr
                                                 and Rval.resistance_value_raw between Nom.Resistance_value_low and Nom.Resistance_value_high

  cross apply (select (Nom.Resistance_value_high - Rval.resistance_value_raw) as R_value_high_minus_rval from dual) rvalhigh
;









