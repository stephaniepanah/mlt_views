


/*--------------------------------------------------------------------------------

-- DL907 has been used as a stand-alone labtest for sieve analysis results
-- and also as a receptacle for all sieve analysis labtests,
-- I guess so that there is one source available to access

SU538624_DL907_or_TransferBlock

The transfer block is current and being used. The last DL907 proper was in 2015


Hello Stephanie

What I recall about DL907 ---
The final characterization of a sample (such as in reports) contains a single gradation analysis. 
One test method or another may be the best way to the determine the gradation, depending on the 
nature of the sample material. (clean gravel, muddy, or whatever.) The lab may run more than one 
of these tests, to decide which works best for a particular sample. 
But only one set of data can be 'the' results for the sample. 

DL907 contains the 'official' results to be reported for the sample. 
RPTSCN and SACA pull their sieve data from DL907, whatever lab test generated it.
As I recollect, there are "downstream" labtests in MTEST that pull their sieve data from DL907 too.

The forms for the sieve analysis tests such as DL11, DL27, WL413, or others  
will have an area showing the contents of DL907.  When they complete one of these tests 
and like the results, they can copy the results to DL907. (The labtests will have a button for that) 
If results from another sieve test are already in DL907 they will see them and can compare. 
I don’t remember what “transfer block” might be but it might have to do with showing data “owned by” DL907’s SU 
in another labtest’s “space”.

(It is possible to enter data into DL907 by hand, if the lab isn’t using one of the labtests in MTEST. 
I don’t know that the lab ever did that, but I always allow for a way to bypass the calculations in MTEST if needed. 
That was important to the generation of labtechs who was used to doing the calculations by hand)

Any labtest that is saved will save all its own data, including its results. If the lab did run
multiple sieve tests they can reference the results for the test(s) that didn’t make it into DL907, 
which they wanted to do at least at the time I wrote those tests.  Of course, they can delete the 
labtests they don’t use if they want to, but “way back when” they wanted to save them for reference.

As I remember, making a single location for reportable results (DL907) and implementing it as I did 
was a great simplification from what went before when RPTSCN, SACA, etc, each had their own code to 
search all the sieve analysis tests for reportable data, and figure out what to do if they found more than one set. 
I seem to recall something about each sieve analysis having a “use me” checkbox which labtechs often ignored, 
or might leave checked in more than one labtest. Having the final, reportable data shown in each labtest, 
wherever it came from, made it easier for lab techs to keep track. 

So DL907 serves two purposes: it puts the final, reportable gradation data, no matter where it came from, 
in one known spot, and it makes it easy for the lab to keep track of what will be reported.

I hope this helps,
John


--------------------------------------------------------------------------------*/



select * from V_DL907_Sieve_Analysis_Results where DL907_sample_ID = 

'W-21-0198-AG'
--'W-20-1356-SL'
--'W-19-1381-AG'
--'W-19-0398-AG'
--'W-19-0140-AG'

;



--------------------------------------------------------------------------------
-- some diagnostics
--------------------------------------------------------------------------------



select count(*), min(sample_year), max(sample_year) from test_dl907 where sample_year not in ('1960','1966');
-- count    minYr   maxYr
-- 27394	1983	2020




select * from test_dl907 where sample_id like 'W-84%'
--'W-89-0851-AG'
;



select * from test_dl907_segments where sample_id like 'W-84%'
 order by sample_id, segment_nbr
--'W-89-0851-AG'
;


--delete from test_dl907 where sample_id like 'W-89-0851-AG';
--delete from test_dl907_segments where sample_id like 'W-89-0851-AG';
--commit;



select * from test_dl907 order by sample_year desc, sample_id;



select * from test_dl907_segments order by sample_id, segment_nbr;



select sample_year, count(sample_year) from test_dl907
 group by sample_year
 order by sample_year desc
 ;

/**

2020	590
2019	671
2018	780
2017	940
2016	663
2015	507
2014	709
2013	383
2012	514
2011	632
2010	676
2009	653
2008	714
2007	695
2006	520
2005	530
2004	675
2003	934
2002	983
2001	1068
2000	797
1999	756
1998	828
1997	748
1996	844
1995	1279
1994	827
1993	655
1992	647
1991	1310
1990	1013
1989	1339
1988	1172
1987	855
1986	461
1985	15
1984	3
1983	8
1966	4
1960	3

**/

--create table test_dl907_bak as select * from test_dl907;
--create table test_dl907_segments_bak as select * from test_dl907_segments;



select test_source, count(test_source) from test_dl907
 group by test_source
 order by test_source
 ;
 
/**
 
' ' 	    6193
AF	           1
AR	         391
AS	           5
DL11	    2823
DL27	    1074
MS	           2
T30	        2925
T88	        6483
TG	           4
WL411	    1022
WL411-O	       3
WL411-R	       2
WL412	     134
WL412-O	       2
WL413	    6337
 
**/
 


-- find headers without segments
select hdr.sample_id from Test_DL907 hdr
 where hdr.sample_id not in (select seg.sample_id from Test_DL907_segments seg
                              where seg.sample_id = hdr.sample_id)
;
-- 206 samples without segments (a few recent examples, below)
/*
W-14-0364-AC
W-14-0501-AC
W-15-0053-AC
W-16-0835-AC
W-16-1370-AC
W-17-0998-ACT
W-17-1445-AC
W-17-1445-ACA
W-17-1445-ACB
W-17-1445-ACC
W-20-1356-SL
W-20-1356-SO
*/



-- find segments without headers (none should be found)
select seg.sample_id from Test_DL907_segments seg
 where seg.sample_id not in (select hdr.sample_id from Test_DL907 hdr
                              where hdr.sample_id = seg.sample_id)
;
-- none found




select embed_plot_in_rpt, count(embed_plot_in_rpt) from test_dl907
 group by embed_plot_in_rpt
 order by embed_plot_in_rpt
 ;
 /**
 ' ' 	27343
 N	    7
 Y	    51
 **/
 
 

/***********************************************************************************

 DL907 Sieve Analysis Results
 
 W-15-0991-SO, W-14-0642-SO, W-11-2158-SO
 W-15-0181-SO, W-15-0184-SO, W-14-0648-SO
 
 Embed Plot in Report
 --------------------
 Default (no entry) Report only if DL145 is present
 Y (yes) Include Plot
 N (no)  No Plot
 
***********************************************************************************/


create or replace view V_DL907_Sieve_Analysis_Results as 


with nbr4 as ( -- needed for DL145

     select  sample_ID           as sample_id
            ,pct_passing         as pctpassnbr4
            ,(100 - pct_passing) as gravel
            
       from Test_DL907_segments  
      where (sieve_size = '#4'   or sieve_size = '4.75mm')
)

,nbr200 as ( -- needed for DL145

     select  sample_ID           as sample_id
            ,pct_passing         as fines
            ,(100 - pct_passing) as nonfines
            
       from Test_DL907_segments  
      where (sieve_size = '#200' or sieve_size = '75?m')
)

/*------------------------------------------------------------------------------
  main SQL
------------------------------------------------------------------------------*/

select  dl907.sample_id                              as DL907_Sample_ID
       ,dl907.sample_year                            as DL907_Sample_Year
       ,dl907.test_status                            as DL907_test_status
       ,dl907.test_source                            as DL907_test_source
       ,dl907.embed_plot_in_rpt                      as DL907_embed_plot_in_rpt
       
       /*-----------------------------------------------------------------------
         segments
       -----------------------------------------------------------------------*/
       
       ,case when dl907seg.segment_nbr  is not null  then dl907seg.segment_nbr         else  -1  end  as DL907_segment_nbr
       ,case when dl907seg.sieve_size   is not null  then dl907seg.sieve_size          else ' '  end  as DL907_sieve_size
       ,case when dl907seg.pct_passing  is not null  then dl907seg.pct_passing         else  -1  end  as DL907_pct_passing
       ,case when dl907seg.pct_passing  is not null  then (100 - dl907seg.pct_passing) else -1 end as DL907_pct_retained
       
       /*-----------------------------------------------------------------------
         MLT_sieve_size (sieve)
       -----------------------------------------------------------------------*/
       
       ,case when dl907seg.sieve_size   is not null  then sieve.sieve_customary        else ' '  end  as sieve_customary
       ,case when dl907seg.sieve_size   is not null  then sieve.sieve_metric           else ' '  end  as sieve_metric
       ,case when dl907seg.sieve_size   is not null  then sieve.sieve_metric_in_mm     else  -1  end  as sieve_metric_in_mm
       
       /*-----------------------------------------------------------------------
         -- needed for DL145
       -----------------------------------------------------------------------*/
       
       ,case when nbr4.gravel           is not null  then nbr4.gravel                  else  -1  end  as DL907_gravel_for_DL145
       ,case when nbr200.fines          is not null  then nbr200.fines                 else  -1  end  as DL907_fines_for_DL145
       ,case when nbr200.nonfines       is not null  then nbr200.nonfines              else  -1  end  as DL907_nonfines_for_DL145
       ,sand_for_DL145                                                                             as DL907_sand_for_DL145
       
       /*-----------------------------------------------------------------------
         table relationships
       -----------------------------------------------------------------------*/
       
       from MLT_1_Sample_WL900                           smpl
       join Test_DL907                                  dl907 on dl907.sample_id      = smpl.sample_id
       
       left join Test_DL907_segments                 dl907seg on dl907.sample_id      = dl907seg.sample_id
       
       left join mlt_sieve_size                         sieve on (dl907seg.sieve_size = sieve.sieve_customary or
                                                                  dl907seg.sieve_size = sieve.sieve_metric)
                                                   
       left join nbr4                                         on dl907.sample_id      = nbr4.sample_id
       left join nbr200                                       on dl907.sample_id      = nbr200.sample_id
       
       /*-----------------------------------------------------------------------
         calculations -- needed for DL145
       -----------------------------------------------------------------------*/
       
       cross apply (select case when ((nbr4.pctpassnbr4 > nbr200.fines) and nbr200.fines >= 0)
                                then  (nbr4.pctpassnbr4 - nbr200.fines) 
                                else -1 
                                end as sand_for_DL145 from dual) sand_DL145
 ;









