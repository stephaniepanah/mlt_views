



select * from V_WL190_Segments_Nomograph where Nomograph_sample_id = 

 'W-21-0112-SO'
 --'W-21-1055-GS'
 --'W-21-1172-GS'
 --'W-20-0737-SO'
 --'W-20-1505-SO'
 --'W-19-1506-SO'
 --'W-19-1822-SO'
;



select * from MLT_Resistance_value_Nomograph;


/*----------------------------------------------------------------

low     high    |-------       low values          -------|    |-------       high values          -------|

0	    5	    0	        0	        0	        0	       -0.28217	    0	        0	        0.28217
5	    10	   -0.28217	    0	        0	        0.28217	   -0.54509	    0	        0	        0.44508
10	    15	   -0.54509	    0	        0	        0.44508	   -0.86995	   -0.63498	    0.23498	    0.76995
15	    20	   -0.86995	   -0.63498	    0.23498	    0.76995	   -0.93893	   -0.46947	    0.46946	    0.43892
20	    25	   -0.93893	   -0.46947	    0.46946	    0.43892	   -0.53553	   -0.26777	    0.16777	    0.03553
25	    30	   -0.53553	   -0.26777	    0.16777	    0.03553	   -0.29509	   -0.02255	   -0.07746	   -0.05492
30	    35	   -0.29509	   -0.02255	   -0.07746	   -0.05492	   -0.15503	    0.07248	   -0.17248	   -0.19497
35	    40	   -0.15503	    0.07248	   -0.17248	   -0.19497	    0.24472	    0.32236	   -0.12236	   -0.24472
40	    45	    0.24472	    0.32236	   -0.12236	   -0.24472	    0.36156	    0.13078	   -0.03078	   -0.16156
45	    50	    0.36156	    0.13078	   -0.03078	   -0.16156	    0.3	        0	       -0.1	       -0.4
50	    55	    0.3	        0	       -0.1	       -0.4	        0.46156	    0.23078	   -0.03078	   -0.06156
55	    60	    0.46156	    0.23078	   -0.03078	   -0.06156	    0.64472	    0.22236	   -0.12236	   -0.04472
60	    65	    0.64472	    0.22236	   -0.12236	   -0.04472	    0.44497	    0.17248	   -0.07248	    0.05503
65	    70	    0.44497	    0.17248	   -0.07248	    0.05503	    0.25492	   -0.02255	    0.12255	    0.44508
70	    75	    0.25492	   -0.02255	    0.12255	    0.44508	   -0.23553	   -0.16776	    0.36777	    0.73554
75	    80	   -0.23553	   -0.16776	    0.36777	    0.73554	   -0.63892	   -0.36946	    0.46946	    0.93892
80	    85	   -0.63892	   -0.36946	    0.46946	    0.93892	   -0.66995	   -0.53497	    0.53498	    0.86996
85	    90	   -0.66995	   -0.53497	    0.53498	    0.86996	   -0.34508	    0	        0	        0.54508
90	    95	   -0.34508	    0	        0	        0.54508	   -0.28217	    0	        0	        0.18217
95	    100	   -0.28217	    0	        0	        0.18217	    0	        0	        0	        0
100	    0	    0	        0	        0	        0	        0	        0	        0	        0

----------------------------------------------------------------*/


/*----------------------------------------------------------------

 the view, V_WL190_Segments_Nomograph, is a cartesian join
 between Test_WL190_Segments and MLT_R_value_Nomograph.
 It is to be used for a specific WL190 Sample and its respective segments

 The CARTESIAN JOIN is also known as CROSS JOIN
 In a CARTESIAN JOIN there is a join for each row of one table to every 
 row of another table, and the number of rows in the result-set is the 
 product of the number of rows of the two tables

----------------------------------------------------------------*/



create or replace view V_WL190_Segments_Nomograph as 

select  seg.sample_id     as Nomograph_sample_id   -- key
       ,seg.segment_nbr   as Nomograph_segment_nbr -- key
       
       ,nom.Resistance_value_low
       ,nom.Resistance_value_high
       
       ,nom.index_1_low
       ,nom.index_2_low
       ,nom.index_3_low
       ,nom.index_4_low
       
       ,nom.index_1_high
       ,nom.index_2_high
       ,nom.index_3_high
       ,nom.index_4_high
     
  from  Test_WL190_Segments             seg
       ,MLT_Resistance_value_Nomograph  nom
       ;









