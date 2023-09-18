


/*----------------------------------------------------------------------------------

 V_T88_Sieves_Fine_Grid, used for the Fine Sieves grid and the percent passing grid
  
----------------------------------------------------------------------------------*/


select * from V_T88_Sieves_Fine_Grid where T88_Sieves_Fine_sample_id in ( 'W-19-0007-SO', 'W-21-0010-SO'
);

-- sample ID       seg  sieveSize      massRet     running total
-- W-19-0007-SO	    1	#40             5.64	    5.64
-- W-19-0007-SO	    2	#200            5.16	    10.8




create or replace view V_T88_Sieves_Fine_Grid as

select  sample_id          as T88_Sieves_Fine_sample_id
       ,segment_nbr        as T88_Sieves_Fine_segment_nbr
       ,sieve_size         as T88_Sieves_Fine_sieve_size
       ,mass_retained      as T88_Sieves_Fine_mass_retained       
       ,sum(mass_retained) over (partition by sample_id order by segment_nbr)
                           as T88_Sieves_Fine_mass_retained_cumulative     
                      
  from Test_T88_Sieves_Fine 
 order by sample_id, segment_nbr 
;









