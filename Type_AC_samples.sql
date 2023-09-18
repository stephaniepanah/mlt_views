

--- select the fields that you need, below, I have selected all from accounting

select acct.sampleid, acct.labtest, acct.teststatus, acct.nbroftrialstobill,
       acct.requested, acct.sampleyear, acct.segmentnbr, 
       acct.nbroftrials -- I do not really pay attention to number of trials
              
  from  T_2_WL901_Accounting acct -- acct is an alias for the table
       ,T_1_WL900_Sample     smpl -- smpl is an alias for the table
       
 where acct.sampleid = smpl.sampleid
 
 --  and smpl.sampleid like '%AC'       --- giving you options
 --  and smpl.sampleid = 'W-19-0759-AC'
 --  and smpl.sampleid in ('W-19-1736-AC')
   and smpl.sampleid in ('W-19-1736-AC', 'W-19-1414-AC', 'W-18-0036-AC')
   
 --  and smpl.sampleyear in ('2019', '2018') --- more options
 --  and smpl.sampleyear in ('2019')
 --  and smpl.sampleyear = '2019'
 --  and smpl.sampleyear like '2018' 
   
 --  and acct.teststatus = 'COM'
 -- and acct.teststatus <> 'DEL'      --- not equals DEL (same results as = 'COM' ...as long as there are no other statuses)
 -- and acct.teststatus = 'DEL' 
 --  and acct.teststatus <> 'COM'   --- same results as = 'DEL' (as long as there are no other statuses)
                                    --- may also use != in place of <> but <> is an ISO standard 
   
 order by smpl.sampleyear desc, smpl.sampleid, acct.segmentnbr
 ;

/**
--- the key to T_2_WL901_Accounting is sampleID, Labtest
--- not segmentNbr, which is only used for sorting
--- also, SCN is a reserved word (keyword) in Oracle, so using sampleID in place of SCN

SampleID,SCN    Labtest     status  billed  requested   sampleYear  segment     nbrOfTrials
------------    -------     ------  ------  ---------   ----------  -------     -----------
W-19-0759-AC	WL900	    COM	    1	    X	        2019	    1	        1
W-19-0759-AC	WL901	    COM	    0	    X	        2019	    2	        0
W-19-0759-AC	DL27	    DEL	    4	    X	        2019	    3	        -1
W-19-0759-AC	WL800	    COM	    -1	    X	        2019	    4	        -1
W-19-0759-AC	DL906	    COM	    -1	    X	        2019	    5	        0
W-19-0759-AC	WL367	    COM	    3	    X	        2019	    6	        3
W-19-0759-AC	DL608-C	    COM	    -1	    X	        2019	    7	        0
W-19-0759-AC	DL608-F	    COM	    -1	    X	        2019	    8	        0
W-19-0759-AC	T84	        COM	    3	    X	        2019	    9	        -1
W-19-0759-AC	T85	        COM	    3	    X	        2019	    10	        -1
W-19-0759-AC	DL632	    COM	    -1	    X	        2019	    11	        0
W-19-0759-AC	T209	    COM	    3	    X	        2019	    12	        -1
W-19-0759-AC	T312	    COM	    3	    X	        2019	    13	        -1
W-19-0759-AC	DL969	    COM	    -1	    X	        2019	    14	        1
W-19-0759-AC	WL419	    COM	    1	    X	        2019	    15	        -1
**/


select * from T_DL27 where sampleid = 'W-19-0759-AC'; --- no data, labtest was deleted


--- select all from T_WL800 without using the sample table as a reference
--- not my preference (but it is MUCH simpler to write)
--- I use this all the time, when doing chicken-scratch
--- but in a formal program, I will always use the full selection, immediately below

select * from T_WL800 where sampleid = 'W-19-0759-AC';


--- select all from T_WL800 by using the sample table as a reference
--- this is ** always ** my preference

select wl800.sampleid, wl800.sampleyear, wl800.teststatus, wl800.testedby, 
       
       wl800.testdateorig, --- the original incoming test date as a string (which it was)
       wl800.testdate,     --- the original incoming test date as a DATE type data field, eg, 04-JUN-17
       
       --- or, rather than selecting the above two fields, select testdate
       --- when it is null (01-JAN-59) as ' ' (space)
       --- else, format the DATE field 
       
       case
       when to_char(wl800.testdate, 'yyyy') = '1959' then ' '
       else to_char(wl800.testdate, 'mm/dd/yyyy')
       end 
       as test_date,
       
       wl800.gradationtype, 
       wl800.donotreport,
       wl800.stockpile1description, wl800.stockpile1description,
       wl800.stockpile2description, wl800.stockpile2description,
       wl800.stockpile3description, wl800.stockpile3description,
       wl800.stockpile4description, wl800.stockpile6description,
       wl800.stockpile5description, wl800.stockpile1description,
       wl800.stockpile6description, wl800.stockpile1description
       
  from T_WL800          wl800, 
       T_1_WL900_Sample smpl
  
 where wl800.sampleid = smpl.sampleid
   and smpl.sampleid  = 'W-19-0759-AC';



--- more chicken scratch

select * from T_WL800_segments where sampleid = 'W-19-0759-AC';



-- select all from the T_WL800_segments table, using WL800 and WL900

select seg.sampleid, seg.segmentnbr, seg.sievesize, seg.excludesegment, 
       seg.pctpassing, seg.lospec, seg.hispec,
       seg.pctpassstockpile1, seg.pctpassstockpile2, seg.pctpassstockpile3, 
       seg.pctpassstockpile4, seg.pctpassstockpile5, seg.pctpassstockpile6

  from T_WL800_segments seg, 
       T_WL800          hdr,
       T_1_WL900_Sample smpl
       
 where seg.sampleid  = hdr.sampleid
   and hdr.sampleid  = smpl.sampleid
   and smpl.sampleid = 'W-19-0759-AC'
 order by seg.segmentnbr
 ;



-- select all from the T_WL800_segments table referencing a specific segment


select * from T_WL800_segments where sampleid = 'W-19-0759-AC' and segmentnbr = 2; --- chicken scratch


select seg.sampleid, seg.segmentnbr, seg.sievesize, seg.excludesegment, 
       seg.pctpassing, seg.lospec, seg.hispec,
       seg.pctpassstockpile1, seg.pctpassstockpile2, seg.pctpassstockpile3, 
       seg.pctpassstockpile4, seg.pctpassstockpile5, seg.pctpassstockpile6

  from T_WL800_segments seg, 
       T_WL800          hdr,
       T_1_WL900_Sample smpl
       
 where seg.sampleid   = hdr.sampleid
   and hdr.sampleid   = smpl.sampleid
   and smpl.sampleid  = 'W-19-0759-AC'
   and seg.segmentnbr = 4
 ;




select * from t_WL367_Stockpile where sampleid = 'W-19-0759-AC';

















