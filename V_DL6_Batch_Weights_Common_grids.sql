


/***********************************************************************************

 on the main page of the following Batch Weight series are the common grids; 
 Stockpiles, Sieves, and Batches (which open the batch grids)
 
 -- the Stockpile grid is from WL800
 -- the Sieves grid is most usually from WL367

 DL608-c Batch Weights for Coarse Specific Gravity, T85        - W-19-0955-AC 
 DL608-f Batch Weights for Fine Specific Gravity, T84          - W-19-0955-AC
 
 DL632   Batch Weights for Asphalt Mix Design                  - W-19-1041-AC - predecessor WL800/WL367
 
 DL633   Batch Weights for I.C. (Immersion Compression) T165   - W-11-0870-AC, W-10-0414-AC
 DL634   Batch Weights for Gauge Calibration                   - W-99-0327-AC, W-99-0479-AC, W-97-0225-AC, W-93-1365-AC
 DL636-c Batch Weights recast to Coarse - generic              - W-03-0870-AG, W-03-0871-AG, W-01-0688-AG, W-01-1603-AG
 
 DL637-c Batch Weights for Humphres Compaction, WL360 - Coarse - W-19-0911-AG 
         - all gradation sources: WL800
         - proposed batch weight since 2011, mostly 3800, some 5000, a few 0, and one -1 (null). previously, all null
 
 DL637-f Batch Weights for Humphres Compaction, WL360 - Fine   - W-19-0911-AG
         - all gradation sources: WL800
         - proposed batch weight since 2011, 5200, and one -1 (null). previously, all null

***********************************************************************************/


/*----------------------------------------------------------------
  V_WL800_Stockpiles_grid as Batch Weights
  Gradation Source Stockpile grid
----------------------------------------------------------------*/

select  WL800_SAMPLE_YEAR
       ,WL800_SAMPLE_ID
       ,WL800_STOCKPILE_NBR
       ,WL800_STOCKPILE_DESCRIPTION -- Stockpile
       ,WL800_PCT_USED              -- Portion
       ,WL800_PCT_USED_DECIMAL
       ,WL800_PCT_USED_SUMMATION 

  from V_WL800_Stockpiles_grid
  
  where WL800_SAMPLE_ID = 'W-19-1041-AC'
 ;



/*----------------------------------------------------------------
  V_WL367_Stockpiles as Sieves percent retained grid
  when WL367 is the gradation source
----------------------------------------------------------------*/

select  WL367_Sample_ID
       ,WL367_stockpile_nbr
       ,WL367_segment_nbr
       ,WL800_Sieves
       ,WL367_Adjusted_Batch_Pct_Retained_calc

  from V_WL367_Stockpiles 
 
  where WL367_Sample_ID = 'W-19-1041-AC'
  
 order by 
 WL367_Sample_ID, 
 WL367_stockpile_nbr, 
 WL367_segment_nbr
 ;
 


/*----------------------------------------------------------------
  V_WL800_Sieve_Segments_grid as Sieves percent retained grid
  when WL800 is the gradation source
----------------------------------------------------------------*/

select  WL800_Sample_ID
       ,WL800_SEGMENT_NBR
       ,WL800_SIEVE_SIZE
       ,SP1_PCT_RETAINED
       ,SP2_PCT_RETAINED
       ,SP3_PCT_RETAINED
       ,SP4_PCT_RETAINED
       ,SP5_PCT_RETAINED
       ,SP6_PCT_RETAINED
            
  from V_WL800_sieve_segments_grid
 
  where WL800_Sample_ID = 'W-19-1041-AC'
  
  order by 
  WL800_Sample_ID, 
  WL800_SEGMENT_NBR
  ;






select gradation_source, count(gradation_source) from Test_DL632
 group by gradation_source
 order by gradation_source
 ;
/*
' ' 	31  -- 1 in 1995, 1 in 1989, the remainder in 1988
031	    49  -- 1989 - 1991
800	    5   -- set to WL800
WL367	284
WL800	42
*/




/*----------------------------------------------------------------
 
 Batch Weight calculations: MTest, Lt_DL630c_B4.cpp
 
 enum class MTM_ID { // IDs for specific batch tests
   INVALID,
   DL608f,    // for T84
   DL608c,    // for T85
   DL632,     // for HVEEM Mix design: T246
   DL633,     // for I.C: T165, etc
   DL634,     // for gauge calibration
   DL635,     // for CKE (NOT IN USE)
   DL636f,    // generic recast to fine <-- not present (my notes)
   DL636c,    // generic recast to coarse
   DL637f,    // for Humphres' compaction (fine portion): WL360
   DL637c     // for Humphres' compaction (coarse portion): WL360
   };
   
 
 from MTest: for Batch Weights
 Lt_DL630_B4.h, Lt_DL608.cpp, Lt_DL630a_B4.cpp, Lt_DL630b_B4.cpp, Lt_DL630c_B4.cpp, 
 Lt_DL632_B4.cpp, Lt_DL636.cpp,  Lt_DL637.cpp
 
 #include "stdafx.h"
 #include "Lt_DL630_B4.h"
 #include <lmtmExtAccess_F6.h>
 
 mtDL630_B4::SpData::SpData(mtDL630_B4^ mtm)
 {

   _isPrecalcReady = false;
   _mtm = mtm;
   // processed external data
   _aSpPortions = gcnew array<double>(MaxStockpiles);
   _asmSpPortions = gcnew array<String^>(MaxStockpiles);
   _aSrcPiles = gcnew array< array<double>^ >(MaxStockpiles);
   _aSpDescs = gcnew array<String^>(MaxStockpiles);
   _nPile = 0;
   _nRows = 0;
   // results of preliminary calculations
   _iscurrentPC = false;
   _fractionsPC = gcnew array<double>(MaxStockpiles);
   _axspPC = gcnew array<int>(MaxStockpiles);
 }


void mtDL630_B4::SpData::iniVarsFromFlds()
{
   // get convenient copies of mtm-global values used in batches
   int xp, xr;
   CordaDatum^ cda;

   CorGrpRoot^ cordaRoot = _mtm->getCordaRoot();

   _nPile = 0;

   for( xp = 0; xp < MaxStockpiles; ++xp )
   {
       _aSpDescs[xp] = cordaRoot->getFld(l_acdaDesc[xp])->getSmValue();
       double val = cordaRoot->getFld(l_acdaPortion[xp])->getFltValue();
       _aSpPortions[xp] = val;

       if(  val > 0.0 ) _nPile = xp + 1;
   }
   CorTblPr^ tbl = cordaRoot->getTblPr();
   _nRows = tbl->getnRows();

   _aSrcSvs = gcnew array<double>(_nRows);
   _asmSrcSvs = gcnew array<String^>(_nRows);

   for( xp = 0; xp < _nPile; ++xp )
   {
      _aSrcPiles[xp] = gcnew array<double>(_nRows);
   }

   xr = 0;
   for(;;){
      int xcol = (int)TblPrC::cSv;
      CordaRow^ row = tbl->getCordaRow(xr);
      if( row == nullptr ) break;
      cda = row->getColAsDatum(xcol++);
      _asmSrcSvs[xr] = cda->getSmValue();
      _aSrcSvs[xr] = cda->getFltValue();

      for( xp = 0; xp < _nPile; ++xp )
	  {
         cda = row->getColAsDatum(xcol++);
         _aSrcPiles[xp][xr] = cda->getFltValue();
      }
      ++xr;
   }
}

void mtDL630_B4::SpData::refreshEffectiveSpList()
{
   --Rebuilds _axspPC after user changes exclusions. This should
   be called when the user makes changes, so _axspPC will be
   current when a batch form is displayed (and so the correct
   stockpiles will be displayed in the batch form headers)
 
   int xp, xxp;
   double pctret[MaxStockpiles];

   CorGrpRoot^ cordaRoot = _mtm->getCordaRoot();

   for( xp = 0; xp < MaxStockpiles; ++xp)
   {
       _axspPC[xp] = EOLIST;
       pctret[xp] = _aSpPortions[xp];
       bool exclude = cordaRoot->getExcludeSp(xp);
       if( exclude ) pctret[xp] = 0.0;
   }
   xxp = 0;
   for( xp = 0; xp < MaxStockpiles; ++xp)
   {
      if( pctret[xp] > 0.0 )
	  {
         Debug::Assert( xp < _nPile );
         _axspPC[xxp++] = xp;
      }
   }
   _npilesPC = xxp;
}


--int mtDL630_B4::SpData::precalcbatwts()
{

   int xp, xxp, npiles, xr, xrmax, br, nr;
   double pctret[MaxStockpiles];
   double val, totpctret;
   int error = 0;
   double totused = 0.0;

   if( _isPrecalcReady ) return error;

   _proposedBatWt = FLT_BLANK;

   nr = 0;
   char *bmsg = g_fmtBuffers.getBuffer8();
   char *pmsg = bmsg;
   CorGrpRoot^ cordaRoot = _mtm->getCordaRoot();

   for( xp = 0; xp < MaxStockpiles; ++xp)
   {
       _axspPC[xp] = EOLIST;
       _fractionsPC[xp] = 0.0;
       pctret[xp] = _aSpPortions[xp];
       bool exclude = cordaRoot->getExcludeSp(xp);
       if( exclude ) pctret[xp] = 0.0;
   }
   xxp = 0;

   for( xp = 0; xp < MaxStockpiles; ++xp)
   {
      if( pctret[xp] > 0.0 )
	  {
         Debug::Assert( xp < _nPile );
         _axspPC[xxp++] = xp;
         totused += pctret[xp];
      }
   }

   npiles = xxp;

   // convert portions to fractions used
   for( xxp = 0; xxp < npiles; ++xxp)
   {
      xp = _axspPC[xxp];
      _fractionsPC[xxp] = pctret[xp] / totused;
   }

   // maximum sieve
   -- start output with smallest sieve with > 0% retained
   for( xr = 0; xr < _nRows; ++xr )
   {
      for( xxp = 0; xxp < npiles; ++xxp )
	  {
         xp = _axspPC[xxp];
         val = _aSrcPiles[xp][xr];
         if( val > 0.0 )
		 {
            xrmax = (xr > 0)? xr-1 : xr;
            goto ateRmax;
         }
      }
   }
ateRmax:
   -- get largest sieve 
   br = xrmax;
   if( _recast == Recast::ToFines )
   {
      while( br < _nRows )
	  {
         if( _aSrcSvs[br] < SV_NR4 ) break;
         ++br;
      }
   }
   if( br >= _nRows )
   {
      strcpy(pmsg,
         --"All sieves larger than nominal max, or can't recast to fines "
         //"because all sieves too large.");
         "No sieves smaller than nominal max, or can't recast to fines "
         "because no fine sieves");
      error = MESS_WARN;
      goto atend;
   }

   // get smallest sieve 
   nr = br + 1;
   // recast to coarse, or include fines 
   val = (_recast == Recast::ToCse)? SV_NR4 : 0.0;
   while( nr < _nRows ){
      if( _aSrcSvs[nr] < val ) break;
      ++nr;
   }
   if( nr <= br ){
      strcpy(pmsg, "Can't batch: not enough sieves specified");
      error = MESS_WARN;
      goto atend;
   }

   // check stockpiles' % retained for validity
   for( xxp = 0; xxp < npiles; ++xxp )
   {
      xp = _axspPC[xxp];
      for( xr = br; xr < nr; ++xr )
	  {
         if( _aSrcPiles[xp][xr] < 0.0 )
		 {
            sprintf(pmsg,
				"Source stockpile \"%s\" has %s value (source's row %d)\n"
				"(\"%% retained\" \n",
               _aSpDescs[xp],
               (_aSrcPiles[xp][xr] == FLT_BLANK)? "a missing" : "an invalid",
               xr + 1
               );
            pmsg += strlen(pmsg);
            error = MESS_WARN;
            break;
         }
      }
   }
   if( error ) goto atend;

----------------------------------------------------------------*/

   -- find total pct retained for each stockpile 
--   totpctret = 0.0;
--   for( xxp = 0; xxp < npiles; ++xxp )
--   {
--      xp = _axspPC[xxp];
--      pctret[xp] = 0.0;
--      for( xr = br; xr < nr; ++xr )
--	  {
--         Debug::Assert( _aSrcSvs[xr] >= 0.0 );
--         if( _aSrcPiles[xp][xr] > 0.0 )
--            pctret[xp] += _aSrcPiles[xp][xr];
--      }
--      totpctret += pctret[xp]*_fractionsPC[xxp];
--   }
--   for( xxp = 0; xxp < npiles; ++xxp )
--   {
--      _fractionsPC[xxp] = _fractionsPC[xxp]/totpctret;
--   }


/*----------------------------------------------------------------
   
   
      -- get proposed batch wt, batch wt 
      if( _proposesBatWt ){
         val = _aSrcSvs[xrmax];
         _proposedBatWt = _mtm->proposeBatWt(val);

         // put proposed bat wt to field on main form
         //lbl->Text = "Proposed Batch Weight:";
         cda->setFltValue(_proposedBatWt);
      }else{
         lbl->Text = String::Empty;
         cda->setSmValue(String::Empty);
      }
      cda->displayInGui();
   

   // save some variables
   _brPC = br;
   _nrPC = nr;
   _npilesPC = npiles;
   _iscurrentPC = true;
atend:
   if( error ){
      g_outAlert(bmsg);
   }else{
      _isPrecalcReady = true;
   }
   return error;
}


void mtDL630_B4::SpData::calcbatwts(CorRowBat^ batch)
{
//
   int xp, xxp, npiles, xr, br, nr; 
   double pctret[MaxStockpiles];
   double val, batwt;

   CorTblWts^ tblwts = batch->getTblWts();
   tblwts->rmAll();

   int error = precalcbatwts();
   if( error )
      return;

   -- get entered batch wt 
   batwt = batch->getColAsDatum((int)BatCorX::xWte)->getFltValue();
   if( batwt <= 0.0 )
   {
      //strcpy(pmsg, "Bad or missing \"Batch wt\" value");
      return;
   }

   br = _brPC;
   nr = _nrPC;
   npiles = _npilesPC;

   // calculate wts and cum wts for each stockpile
   for( xp = 0; xp < MaxStockpiles; ++xp )
   {
      pctret[xp] = 0.0;
   }
   for( xxp = 0; xxp < npiles; ++xxp )
   {
      xp = _axspPC[xxp];
      pctret[xxp] = batwt*_fractionsPC[xxp];
   }


   // output rows may have different indices than % retained rows
   for( xr = br; xr < nr; ++xr )
   {
      CordaRow^ row = tblwts->newCordaRow();
      row->getColAsDatum((int)TblPrC::cSv)->setSmValue( _asmSrcSvs[xr] );

      for( xxp = 0; xxp < npiles; ++xxp ){
         xp = _axspPC[xxp];
         double portion = pctret[xxp];
         val = ( _aSrcPiles[xp][xr] > 0.0 )? _aSrcPiles[xp][xr]*portion : 0.0;

         int xwt = 1 + xxp*2;
         row->getColAsDatum(xwt)->setFltValue(val);
      }
      tblwts->addCordaRow(row);
   }


   double cumwt = 0.0;
   for( xp = 0; xp < npiles; ++xp )
   {
      xr = 0;
      for(;;){
         CordaRow^ row = tblwts->getCordaRow(xr++);
         if( row == nullptr )
            break;
         int xwt = 1 + xp*2;
         int xcumwt = xwt + 1;
         val = row->getColAsDatum(xwt)->getFltValue();
         if( val > 0.0 )   // exclude FLT_BLANK
            cumwt += val;
         row->getColAsDatum(xcumwt)->setFltValue(cumwt);
      }
   }
   tblwts->displayInGui();
   tblwts->setMod();
}

----------------------------------------------------------------*/

--
--int mtDL630_B4::SpData::getExtWL800(){
--
--   char *pmsg = 0;
--   char const *psz;
--   char const*pszDescs[MaxStockpiles];
--   char const*pszPortions[MaxStockpiles];
--   char const **psvs, --/* **psp1, **psp2, **psp3, **psp4, **psp5, **psp6,*/
--   **ppsz;
--   char const **psps[MaxStockpiles];
--   int nrows, xr, xp, npile;
--   double val;
--   bool validSp[MaxStockpiles];
--
--   int nSpSlots = MaxStockpiles;
--
--   int error = 0;
--   psvs = 0;
--   npile = 0; // past last valid pile
--   for( int x = 0; x < MaxStockpiles; ++x ) validSp[x] = false;
--
--   //NM_LUT_D8::CuStrBuffer* msgstore = g_msgRepository.getMsgStore();
--   U_Str8Store *msgstore = g_fmtBuffers.getStore8();
--   char szdss[CMDSSID::m_maxwidsz+1];
--   _mtm->getDSSID()->getSz(szdss);
--
--   NM_MTM_EXT_F6::ExtWL800Stockpiles_F6 extSps;
--   error = extSps.ini(_mtm->_smpl, szdss);
--
--   if( error < 0 )
--   {
--      // source not available
--      pmsg = msgstore->getMem();
--      psz = ErrDescriptor::describe8(error);
--      if( error == NOTFOUND ){
--         sprintf(pmsg, "Gradation source WL800 not found");
--      }else{
--         sprintf(pmsg, "Could not get data from gradation source WL800, error = \"%s\" ", psz );
--      }
--      error = MESS_WARN;
--      goto atend;
--   }
--   nrows = error;
--
--   _maxNomsv = aztof( extSps.getszNominalMax() );
--
--   error = extSps.getszSpDescs(pszDescs, pszPortions, nSpSlots);
--   if( error < NOTFOUND ){
--      pmsg = msgstore->getMem();
--      psz = ErrDescriptor::describe8(error);
--      sprintf(pmsg, "Error getting WL800 data, error = \"%s\" ", psz );
--      goto atend;
--   }
--
--   for( xp = 0; xp < MaxStockpiles; ++xp ){
--      psz = pszDescs[xp];
--      if( ! psz ) psz = "";
--      String^ sm = gcnew String(psz);
--      _aSpDescs[xp] = sm;
--      psz = pszPortions[xp];
--      if( ! psz ) psz = "";
--      _asmSpPortions[xp] = gcnew String(psz);
--      val = aztof(psz);
--      // stockpile must have a portion to be valid
--      if( val > 0.0 ){
--         validSp[xp] = true;
--         npile = xp + 1;
--      }
--      _aSpPortions[xp] = val;
--   }
--
--   // WL800 grad comes in as Pct Passing: must convert to Pct retained
--   int nralloc = nrows + 1;

     -- add a row in case it's necessary to add a PAN row
     
--   int lim = nralloc*(MaxStockpiles+1);
--   psvs = (char const**)malloc( lim*sizeof(char const**) ); // '+1': for sieves
--   for(xr = 0; xr < lim; ++xr ){ psvs[xr] = ""; }
--   ppsz = psvs + nralloc;
--   for( int xsp = 0; xsp < nSpSlots; ++xsp ){
--      psps[xsp] = ppsz;
--      ppsz += nralloc;
--   }
--   //psp1 = psvs + nralloc;
--   //psp2 = psp1 + nralloc;
--   //psp3 = psp2 + nralloc;
--   //psp4 = psp3 + nralloc;
--   //psp5 = psp4 + nralloc;
--   //psp6 = psp5 + nralloc;
--
--   error = extSps.getszPiles(psvs, psps, nSpSlots);
--   assert( error == nrows );
--   error = 0;
--
--   _asmSrcSvs = gcnew array<String^>(nralloc);
--   _aSrcSvs = gcnew array<double>(nralloc);

--   int xpan = -1;

--   for( xr = 0; xr < nrows; ++xr ){
--      psz = psvs[xr];
--      _asmSrcSvs[xr] = gcnew String(psz);
--      val = sievetof(psz);
--      _aSrcSvs[xr] = val;

--      if( val == 0.0 ) xpan = xr;
--   }
--   if( xpan == -1 ){

--      // need to add a pan

--       _asmSrcSvs[nrows] = gcnew String("Pan");
--       _aSrcSvs[nrows] = 0.0;
--       ++nrows;
--   }
--
--   double pp, oldpp;
--   for( xp = 0; xp < npile; ++xp ){
--      _aSrcPiles[xp] = gcnew array<double>(nrows);
--      //switch(xp){
--      //case 0: ppsz = psp1; break;
--      //case 1: ppsz = psp2; break;
--      //case 2: ppsz = psp3; break;
--      //case 3: ppsz = psp4; break;
--      //case 4: ppsz = psp5; break;
--      //case 5: ppsz = psp6; break;
--      //}
--      ppsz = psps[xp];
--
--      if( validSp[xp] )
--	  {
--         oldpp = 100.0;
--         for( xr = 0; xr < nrows; ++xr )
--		 {
--            pp = aztof(ppsz[xr]);
--            if( pp < 0.0 ) pp = 0.0;
--            // convert to pct retained
--            val = oldpp - pp;
--            _aSrcPiles[xp][xr] = val;
--            oldpp = pp;
--         }
--      }
--	  else
--	  {
--         for( xr = 0; xr < nrows; ++xr )
--		 {
--            _aSrcPiles[xp][xr] = FLT_BLANK;
--         }
--      }
--   }
--atend:
--   if( psvs ) free(psvs);
--   extSps.rel();
--   if( error ){
--      g_outAlert(msgstore->getStr(), MESS_WARN);
--      // should clear Corda SpDescs, SpPortions as well
--      error = MESS_NONE;
--   }else{
--      _nRows = nrows;
--      _nPile = npile;
--   }
--   return error;
--}
--
--
--int mtDL630_B4::SpData::getExtWL367(){
--
--   char *pmsg = 0;
--   char const *psz;
--   char const*pszDescs[MaxStockpiles];
--   char const*pszPortions[MaxStockpiles];
--   char const **psvs, -- **psp1, **psp2, **psp3, **psp4, **psp5, **psp6,
--   **ppsz;
--   char const **psps[MaxStockpiles];
--   int nrows, xr, xp;
--   double val;
--
--   int error = 0;
--   int npile = 0;
--   psvs = 0;
--
--   //NM_LUT_D8::CuStrBuffer* msgstore = g_msgRepository.getMsgStore();
--   U_Str8Store *msgstore = g_fmtBuffers.getStore8();
--   char szdss[CMDSSID::m_maxwidsz+1];
--   _mtm->getDSSID()->getSz(szdss);
--
--   NM_MTM_EXT_F6::ExtWL367Stockpiles_F6 extIWSps;
--   error = extIWSps.ini(_mtm->_smpl, szdss);
--   if( error < 0 ){
--      // source not available
--      pmsg = msgstore->getMem();
--      psz = ErrDescriptor::describe8(error);
--      if( error == NOTFOUND ){
--         sprintf(pmsg, "Gradation source WL367 not found");
--      }else{
--         sprintf(pmsg, "Could not get data from gradation source WL367, error = \"%s\" ", psz );
--      }
--      error = MESS_WARN;
--      goto atend;
--   }
--   nrows = error;
--
--   _maxNomsv = aztof( extIWSps.getszNominalMax() );
--
--   error = extIWSps.getszSpDescs(pszDescs, pszPortions, MaxStockpiles);
--   if( error < NOTFOUND ){
--      pmsg = msgstore->getMem();
--      psz = ErrDescriptor::describe8(error);
--      sprintf(pmsg, "Error getting WL367 data, error = \"%s\" ", psz );
--      goto atend;
--   }
--
--   for( xp = 0; xp < MaxStockpiles; ++xp ){
--      psz = pszDescs[xp];
--      if( ! psz ) psz = "";
--      String^ sm = gcnew String(psz);
--      _aSpDescs[xp] = sm;
--      psz = pszPortions[xp];
--      if( ! psz ) psz = "";
--      _asmSpPortions[xp] = gcnew String(psz);
--      val = aztof(psz);
--      if( val > 0.0 )
--         npile = xp + 1;
--      _aSpPortions[xp] = val;
--   }
--
--   psvs = (char const**)malloc( nrows*(MaxStockpiles+1)*sizeof(char const**) ); // '+1': for sieves
--   ppsz = psvs + nrows;
--   for( int xsp = 0; xsp < MaxStockpiles; ++xsp ){
--      psps[xsp] = ppsz;
--      ppsz += nrows;
--   }
--   //psp1 = psvs + nrows;
--   //psp2 = psp1 + nrows;
--   //psp3 = psp2 + nrows;
--   //psp4 = psp3 + nrows;
--   //psp5 = psp4 + nrows;
--   //psp6 = psp5 + nrows;
--
--   error = extIWSps.getszPiles(psvs, psps, MaxStockpiles);
--   assert( error == nrows );
--   error = 0;
--   // WL367 grad comes in as Pct retained
--
--   _asmSrcSvs = gcnew array<String^>(nrows);
--   _aSrcSvs = gcnew array<double>(nrows);
--   for( xr = 0; xr < nrows; ++xr ){
--      psz = psvs[xr];
--      _asmSrcSvs[xr] = gcnew String(psz);
--      _aSrcSvs[xr] = sievetof(psz);
--   }
--   for( xp = 0; xp < npile; ++xp ){
--      _aSrcPiles[xp] = gcnew array<double>(nrows);
--      ppsz = psps[xp];
--      //switch(xp){
--      //case 0: ppsz = psp1; break;
--      //case 1: ppsz = psp2; break;
--      //case 2: ppsz = psp3; break;
--      //case 3: ppsz = psp4; break;
--      //case 4: ppsz = psp5; break;
--      //case 5: ppsz = psp6; break;
--      //}
--      for( xr = 0; xr < nrows; ++xr ){
--         psz = ppsz[xr];
--         _aSrcPiles[xp][xr] = aztof(psz);
--      }
--   }
--atend:
--   if( psvs ) free(psvs);
--   extIWSps.rel();
--   if( error ){
--      g_outAlert(pmsg, MESS_WARN);
--      // should clear Corda SpDescs, SpPortions as well
--      error = MESS_NONE;
--   }else{
--      _nRows = nrows;
--      _nPile = npile;
--   }
--   return error;
--}
--
--int mtDL630_B4::SpData::getExtGradData(SrcGrad src){
-- get external gradation data and put it in a useful format
-- * ARGUMENT
-- *
-- * WL367 stockpiles come in as % retained
-- * WL800 stockpiles come in as % passing and must be converted to % retained
-- *
-- * Put sieves, stockpile descs, stockpile portions in displayed
-- * fields and internal data
-- 
--   int error = 0;
--
--   _iscurrentPC = false;   // preliminary calcs based on ext. data are not current
--   _nRows = 0;
--   _nPile = 0;
--   for( int xp = 0; xp < MaxStockpiles; ++xp ){
--      _aSpDescs[xp] = String::Empty;
--      _asmSpPortions[xp] = String::Empty;
--      _aSpPortions[xp] = FLT_BLANK;
--   }
--
--   switch(src)
--   {
--   case SrcGrad::WL800: error = getExtWL800(); break;
--   case SrcGrad::WL367: error = getExtWL367(); break;
--   default: Debug::Assert(false); break;
--   }
--
--
--}
--

--***********************************************************************************/









