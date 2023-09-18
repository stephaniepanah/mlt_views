



select * from V_2_Accounting_WL901 order by SAMPLE_YEAR desc, SAMPLE_ID, SEGMENT_NBR
;



select * from V_2_Accounting_WL901 
 where SAMPLE_YEAR in ('1992','1986')
 order by SAMPLE_YEAR desc, SAMPLE_ID, SEGMENT_NBR
 ;
 
 
 

select * from V_2_Accounting_WL901 
 where SAMPLE_YEAR = '1980'
 order by SAMPLE_YEAR desc, SAMPLE_ID, SEGMENT_NBR
 ;




create or replace view V_2_Accounting_WL901 as 

select 
 SAMPLE_ID
,LABTEST
,SEGMENT_NBR
,TEST_STATUS
,NBR_TRIALS_TO_BILL
,NBR_OF_TRIALS
,REQUESTED
,SAMPLE_YEAR
,STORAGE_UNIT
,STORAGE_UNIT_ORIGINAL
,TEMPDATE

from MLT_2_Accounting_WL901
;









/*********************************

2019-04-10

Hi John,

I am a little confused regarding the storage units associated with accounting

After SU 1, there are 10240, 14336 & 47104

I believe that 47104 is simply a cross-reference from labtest number to labtest name, so I think that we can put that one aside

That leaves 10240 & 14336….

I think that 10240 simply lists the status of the labtests (and WL900/WL901)
And 14336 is a record of billing runs

But then, I see samples where billing runs appear in both SUs

Lastly, in 14336 the first entry, 32767 is the status of the sample, yes? It is now complete (or not)

I see in SU 14336, that there are miscellaneous charges that are not labtests, so I am beginning to understand the nuance.

SAMPLE W-18-0001-CO, SU 10240 (2800)   (7 items, length 56 bytes)

      -24319  (a101)   "WL900"
      -32509  (8103)   "C"
      -24319  (a101)   "T22"
      -32509  (8103)   "C"
      -24319  (a101)   "WL901"
      -32509  (8103)   "C"
      -32508  (8104)   "0" ---- not sure about this

SAMPLE W-18-0001-CO, SU 14336 (3800)   (5 items, length 44 bytes)

       32767  (7fff)   "C"
      -24319  (a101)   "WL900"
      -32508  (8104)   "1"
      -24319  (a101)   "T22"
      -32508  (8104)   "1"

SAMPLE W-18-0001-CO, SU 47104 (b800)   (6 items, length 110 bytes)

      -24319  (a101)   "WL900"
      -32510  (8102)   "Sample Login Information"
      -24319  (a101)   "WL901"
      -32510  (8102)   "Accounting"
      -24319  (a101)   "T22"
      -32510  (8102)   "Compressive Strength of PCC"


--------------------------------------------------------------------------------

2019-04-10

SU 47104 (0xb800) is the "Tests Requested" list. It contains just a list of labtest IDs (FC 0x8101) and descriptions (FC 0x8102).

SU 10240 (0x2800) is "Test Tracking". It contains a table with: labtest nr (FC 0x8101), status (0x8103), and number of trials (0x8104).

From mtmBaseC_AB.cpp it appears that values for 0x8103 are (left hand column):
   "0"  (labtest exists but has no status field or entry)
   "1"  "New"
   "N"  "NC"
   "C"  "COM"
   "d"  (labtest was deleted)
These are also "internal" values for  labtest's corresponding FC_TestStatus. Right hand column is displayed versions for FC_TestStatus.

WL901 (Accounting) is not a billable labtest. Originally it did not take "Completed" status but that was added later. The "Completed" dialog was designed for billable labtests and usually allows "number of billable trials" to be entered. I think code to suppress that part completely was added, but apparently it was handled for WL901 by setting it to "0".


SU 14336 (0x3800) is "Billing". It has a table containing columns for labtest ID (FC 0x8101) and number of trials to bill (FC 0x8104), and (if needed) a table containing columns for Delphi account data (0x8203, 0x8204) and "old style" account numbers (0x8202), and the portion of the sample billing to be charged to each account (0x8201).

I think that WL1006 and WL1027 are chargeable items that are not labtests.  The list of such items is in Admin/WL901A.mlu. In WL901 they can be added to the list of items to be billed for a sample.


SU 47104 (0xb800) -- When the contractor sends a sample to the lab they tell the lab what tests they want performed on it; this is the list of tests the contractor has requested. It is filled out when the sample is first logged in. It appears in MLOGIN and MTEST, I believe as a page of WL900.

SU 10240 (0x2800) -- It does not appear as a labtest but has an internal "pseudo-labtest" number "$984". It contains status  information for labtests that have been  created and saved.  A status "Not Complete" or "Complete" is saved in a labtest's "Primary SU" (under standard FC FC_TestStatus, 0x7FFF) and SU 0x2800 is also updated with this value. The Labtest status in SU 0x2800 is more comprehensive than the value stored with the labtest since it indicates "Deleted" values as well. As I recall, this SU is combined with SU 0xb800 in a dialog that allows the user to "jump" directly to any labtest that has been requested or that has already been created.


SU 14336 (0x3800) appears as WL901. It builds on the labtests shown as "Complete" in SU 0x2800 and lab techs can add charges.  TLBA will access this SU when it calculates the billing for a sample.


Another item saved in SUs 0x2800 and 0x3800 is the number of trials to be billed. When a lab tech marks a labtest "Complete" the number of trials can be specified too, for those labtests for which multiple trials makes sense. Billing gets this from SU 0x2800 and saves a (possibly modified) copy for TLBA to use in billing.
-- John


--------------------------------------------------------------------------------

Hi Stephanie, various answers --

Sample status is in SU 1, FC = 49d.

FC x7FFF (32767) is always the MTM (labtest) status. In SU x3800 (14336), even though this is not a billable labtest they use this so they can indicate when they've completed getting all the billing data in order and are ready to send this sample on to billing.

'WFL' account number fields aren't restricted to WFL accocunt numbers. They sometimes put Purchase Order numbers or whatever they have to bill to.  There is some pattern test to determine whether the datum is a WFL account number. The only reason MTEST cares what it is, is so it can give it proper formatting (with hyphens) if appropriate. TLBA checks WFL and Delphi account numbers for validity but beyond that it's up to WFL's billing department to figure out what they need to do with them.

If both the WFL account and the Delphi account fields have entries, I don't know which would take precedence. I would guess Delphi, since it is the more recent.

If MLT were designed with logical hindsight, all account information would be entered in the table in WL901. But the "tradition" of a single account entered on the WL900 MTEST/MLOGIN form was well established before anyone ever thought of apportioning charges for a single sample among multiple accounts. So --

When they have to use the Accounts table in WL901, the account data from WL900 is displayed to them above the table. (It is not copied into the table itself, to avoid instances that are redundant and possibly inconsistent since they could edit one and not the other copy.)

FC x10 (16) is the portion for the account saved in WL900. Since that account is not actually in the Accounts table, this item can't be either.


You will already know this but I can't resist repeating it. The way embedded tables (such as the Account table in WL901 and many others), FCs have the pattern: 0x8tcc where: the Hex digits in 'cc' hold a unique (within that table) "column" identifier. 't' holds a number unique among tables in that SU, identifying the embedded table. So, the mapping for SU 0x3800 looks like this.
(MTM  IDs left, FC IDs right. I use hex values for FCs because they are constructed as unsigned bit patterns. I find the signed values confusing since the notions of 'positive' or 'negative' don't apply to these items.)
   IDF_teststatus : FC_TESTSTATUS (0x7FFF, 32767)
   IDF_portion :           0x10   (16)

   // billing table
   IDBc_mtmnr :      0x8101   (-32511)
   IDBc_runs :          0x8104   (-32508)

   // account table
   IDAc_portion :      0x8201   (-32255)
   IDAc_acctnr :        0x8202   (-32254)
   IDAc_delphiproj : 0x8203   (-32253)
   IDAc_delphitask : 0x8204   (-32252)

Thus to read 0x8204:
      0x8---  it's an embedded table
      0x-2--  the table ID is '2'
      0x--04  the 'column' ID is 4.

Fields in SUs that are not in tables do not depend on position. If a field is empty, neither it nor its FC are written to the SU. The fields that are saved can be written in any order (but FC list and the fields must have the same order).

Special cases are: all fields of an embedded table must be contiguous. The whole embedded table can be written anywhere in the SU but table fields can't be interspersed among non-table fields. Likewise, the fields for each row must be contiguous. As with non-table fields, if a field is empty it is not saved into the SU. In theory, a row's fields can be saved in any order as long as they are together.

Since the 'first' column in a row might not be saved, and the columns that are saved might not be in their usual order anyway, there is a dynamic way to indicate when to start a new row. When MLT saves a row in a table, for each row: when it finds the first item ('column') that is not empty (and that it will save), it adds (ORs) the bit 0x2000 to the FC it writes to the SU's FC list.

0x8 | 0x2 = 0xA, so in a STOA printout some FCs with a 0x8tcc pattern will look like they have a 0xAtcc pattern. FCs that look like 0xAtcc are just 0x8tcc, combined with the 'New Row' flag. But there is no guarantee which field in a row of saved data will have the 0x2000 bit set. (No guarantee that the lab techs will never leave a field in the 'first column' empty.) Rather than putting 0xAtcc values into a switch table, it would be safer to test for the 0x2000 bit first to determine if this is the first item in a new row, and then filter it out and proceed with the 0x8tcc version of the FC.

-- John




*********************************/









