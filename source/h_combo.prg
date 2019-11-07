/*
 * $Id: h_combo.prg $
 */
/*
 * ooHG source code:
 * ComboBox control
 *
 * Copyright 2005-2019 Vicente Guerra <vicente@guerra.com.mx> and contributors of
 * the Object Oriented (x)Harbour GUI (aka OOHG) Project, https://oohg.github.io/
 *
 * Portions of this project are based upon:
 *    "Harbour MiniGUI Extended Edition Library"
 *       Copyright 2005-2019 MiniGUI Team, http://hmgextended.com
 *    "Harbour GUI framework for Win32"
 *       Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 *       Copyright 2001 Antonio Linares <alinares@fivetech.com>
 *    "Harbour MiniGUI"
 *       Copyright 2002-2016 Roberto Lopez <mail.box.hmg@gmail.com>
 *    "Harbour Project"
 *       Copyright 1999-2019 Contributors, https://harbour.github.io/
 */
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file LICENSE.txt. If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1335,USA (or download from http://www.gnu.org/licenses/).
 *
 * As a special exception, the ooHG Project gives permission for
 * additional uses of the text contained in its release of ooHG.
 *
 * The exception is that, if you link the ooHG libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the ooHG library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the ooHG
 * Project under the name ooHG. If you copy code from other
 * ooHG Project or Free Software Foundation releases into a copy of
 * ooHG, as the General Public License permits, the exception does
 * not apply to the code that you add in this way. To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for ooHG, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 */


#include "oohg.ch"
#include "hbclass.ch"
#include "i_windefs.ch"

/*--------------------------------------------------------------------------------------------------------------------------------*/
CLASS TCombo FROM TLabel

   DATA aValues                   INIT {}
   DATA cText                     INIT ""
   DATA ImageListColor            INIT CLR_DEFAULT
   DATA ImageListFlags            INIT LR_LOADTRANSPARENT + LR_DEFAULTCOLOR + LR_LOADMAP3DCOLORS
   DATA ImageSource               INIT NIL
   DATA ItemNumber                INIT NIL
   DATA lAdjustImages             INIT .F.
   DATA lDelayLoad                INIT .F.
   DATA lFocused                  INIT .F.
   DATA lIncremental              INIT .F.
   DATA lRefresh                  INIT NIL
   DATA nHeight2                  INIT 150
   DATA nLastFound                INIT 0
   DATA nLastItem                 INIT 0
   DATA nTextHeight               INIT 0
   DATA nWidth                    INIT 120
   DATA oEditBox                  INIT NIL
   DATA oListBox                  INIT NIL
   DATA OnListClose               INIT NIL
   DATA OnListDisplay             INIT NIL
   DATA OnRefresh                 INIT NIL
   DATA SearchLapse               INIT 1000
   DATA SourceOrder               INIT NIL
   DATA Type                      INIT "COMBO" READONLY
   DATA uField                    INIT NIL
   DATA uIniTime                  INIT 0
   DATA uValueSource              INIT NIL
   DATA WorkArea                  INIT ""

   METHOD AddItem
   METHOD Autosize                SETGET
   METHOD AutosizeDropDown
   METHOD CaretPos                SETGET
   METHOD Define
   METHOD DeleteAllItems
   METHOD DeleteItem
   METHOD DisplayValue            SETGET    /// Caption alias
   METHOD EditHeight              SETGET
   METHOD Events
   METHOD Events_Command
   METHOD Events_DrawItem
   METHOD Events_MeasureItem
   METHOD Field                   SETGET
   METHOD FindString
   METHOD FindStringExact
   METHOD ForceHide               BLOCK { |Self| SendMessage( ::hWnd, CB_SHOWDROPDOWN, 0, 0 ), ::Super:ForceHide() }
   METHOD GetDropDownWidth
   METHOD GetEditSel
   METHOD InsertItem
   METHOD Item                    BLOCK { |Self, nItem, uValue| ComboItem( Self, nItem, uValue ) }
   METHOD ItemBySource
   METHOD ItemCount               BLOCK { |Self| ComboboxGetItemCount( ::hWnd ) }
   METHOD ItemHeight
   METHOD ItemValue
   METHOD nHeight                 SETGET
   METHOD OptionsHeight           SETGET
   METHOD Refresh
   METHOD RefreshData
   METHOD Release
   METHOD SelectFirstItem         BLOCK { |Self| ComboSetCursel( ::hWnd, 1 ) }
   METHOD SelectLastItem          BLOCK { |Self| ComboSetCursel( ::hWnd, ::ItemCount ) }
   METHOD SetDropDownWidth
   METHOD SetEditSel
   METHOD ShowDropDown
   METHOD Value                   SETGET
   METHOD ValueSource             SETGET
   METHOD Visible                 SETGET
   METHOD VisibleItems

   ENDCLASS

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Define( ControlName, ParentForm, x, y, w, rows, value, fontname, ;
               fontsize, tooltip, changeprocedure, h, gotfocus, lostfocus, ;
               uEnter, HelpId, invisible, notabstop, sort, bold, italic, ;
               underline, strikeout, itemsource, valuesource, displaychange, ;
               ondisplaychangeprocedure, break, GripperText, aImage, lRtl, ;
               TextHeight, lDisabled, lFirstItem, lAdjustImages, backcolor, ;
               fontcolor, listwidth, onListDisplay, onListClose, ImageSource, ;
               ItemNumber, lDelayLoad, lIncremental, lWinSize, lRefresh, ;
               sourceorder, onrefresh, nLapse, nMaxLen, EditHeight, OptHeight, ;
               lHScroll ) CLASS TCombo

   LOCAL ControlHandle, WorkArea, uField, nStyle, nId

   ASSIGN ::nCol          VALUE x             TYPE "N"
   ASSIGN ::nRow          VALUE y             TYPE "N"
   ASSIGN ::nWidth        VALUE w             TYPE "N"
   ASSIGN ::nHeight       VALUE h             TYPE "N"
   ASSIGN rows            VALUE rows          TYPE "A" DEFAULT {}
   ASSIGN sort            VALUE sort          TYPE "L" DEFAULT .F.
   ASSIGN ::nTextHeight   VALUE TextHeight    TYPE "N"
   ASSIGN displaychange   VALUE displaychange TYPE "L" DEFAULT .F.
   ASSIGN ::lAdjustImages VALUE lAdjustImages TYPE "L"
   ASSIGN ::ImageSource   VALUE ImageSource   TYPE "B"
   ASSIGN ::ItemNumber    VALUE ItemNumber    TYPE "B"
   ASSIGN ::lDelayLoad    VALUE lDelayLoad    TYPE "L" DEFAULT .F.
   ASSIGN ::lIncremental  VALUE lIncremental  TYPE "L" DEFAULT .F.
   ASSIGN lWinSize        VALUE lWinSize      TYPE "L" DEFAULT .F.
   ASSIGN ::lRefresh      VALUE lRefresh      TYPE "L" DEFAULT NIL
   ASSIGN ::SourceOrder   VALUE sourceorder   TYPE "CMNB"
   ASSIGN ::OnRefresh     VALUE onrefresh     TYPE "B"
   IF HB_ISNUMERIC( nLapse ) .AND. nLapse >= 0
      ::SearchLapse := nLapse
   ENDIF

   ::SetForm( ControlName, ParentForm, FontName, FontSize, FontColor, BackColor, .T., lRtl )
   ::SetFont( NIL, NIL, bold, italic, underline, strikeout )

   IF ::lDelayLoad .AND. Sort
      MsgOOHGError( "SORT and DELAYLOAD clauses can't be used simultaneously. Program terminated." )
   ENDIF

   IF ValType( itemsource ) != 'U' .AND. Sort
      MsgOOHGError( "SORT and ITEMSOURCE clauses can't be used simultaneously. Program terminated." )
   ENDIF

   IF ValType( valuesource ) != 'U' .AND. Sort
      MsgOOHGError( "SORT and VALUESOURCE clauses can't be used simultaneously. Program terminated." )
   ENDIF

   IF ValType( itemsource ) == 'A'
      WorkArea := itemsource[ 1 ]
      uField := itemsource[ 2 ]
      IF Len( itemsource ) > 2
         ASSIGN ::SourceOrder VALUE itemsource[ 3 ] TYPE "CMNB"
      ENDIF
   ELSEIF ValType( itemsource ) != 'U'
      IF ! '->' $ itemsource
         MsgOOHGError( "ITEMSOURCE clause must be a fully qualified field name. Program terminated." )
      ELSE
         WorkArea := Left( itemsource, At( '->', itemsource ) - 1 )
         uField := Right( itemsource, Len( itemsource ) - At( '->', itemsource ) - 1 )
      ENDIF
   ENDIF

   nStyle := ::InitStyle( NIL, NIL, Invisible, notabstop, lDisabled ) + ;
             iif( HB_ISLOGICAL( sort ) .AND. sort, CBS_SORT, 0 ) + ;
             iif( ! displaychange, CBS_DROPDOWNLIST, CBS_DROPDOWN ) + ;
             iif( HB_ISARRAY( aImage ) .OR. HB_ISBLOCK( ItemNumber ) .OR. displaychange, CBS_OWNERDRAWFIXED, 0) + ;
             iif( OSisWinXPorLater() .AND. _OOHG_LastFrame() != "SPLITBOX" .AND. ! lWinSize, CBS_NOINTEGRALHEIGHT, 0 ) + ;
             iif( HB_ISLOGICAL( lHScroll ) .AND. lHScroll, CBS_AUTOHSCROLL, 0 )

   ::SetSplitBoxInfo( Break, GripperText, ::nWidth )

   nId := _GetId()
   ::PreAddToCtrlsArrays( nId )   // Needed because WM_MEASUREITEM message is fired before ::Register
   ControlHandle := InitCombobox( ::ContainerhWnd, nId, ::ContainerCol, ::ContainerRow, ::nWidth, ::nHeight, nStyle, ::lRtl )
   ::Register( ControlHandle, ControlName, HelpId, NIL, ToolTip, nId )

   ::SetFont()
   ::Field := uField
   ::WorkArea := WorkArea
   ::ValueSource := valuesource

   IF HB_ISARRAY( aImage )
      ::AddBitMap( aImage )
   ENDIF

   IF HB_ISNUMERIC( ListWidth )
      ::SetDropDownWidth( ListWidth )
   ENDIF

   IF ValType( WorkArea ) $ "CM"
      ::Refresh()
   ELSE
      AEval( rows, { |x| ::AddItem( x ) } )
   ENDIF

   IF HB_ISLOGICAL( lFirstItem ) .AND. lFirstItem .AND. ::ItemCount > 0
      ::SelectFirstItem()
   ENDIF

   ::oListBox := TListCombo():Define( Self, ComboBoxGetListhWnd( ::hWnd ) )
   IF displaychange
      ::oEditBox := TEditCombo():Define( Self, GetWindow( ::hWnd, GW_CHILD ) )
      IF HB_ISNUMERIC( nMaxLen ) .AND. nMaxLen > 0
         ::oEditBox:MaxLength := nMaxLen
      ENDIF
   ENDIF

   ::Value := Value

   ::EditHeight := editheight
   ::OptionsHeight := optheight

   ASSIGN ::OnClick       VALUE ondisplaychangeprocedure TYPE "B"
   ASSIGN ::OnLostFocus   VALUE LostFocus                TYPE "B"
   ASSIGN ::OnGotFocus    VALUE GotFocus                 TYPE "B"
   ASSIGN ::OnChange      VALUE ChangeProcedure          TYPE "B"
   ASSIGN ::OnEnter       VALUE uEnter                   TYPE "B"
   ASSIGN ::OnListDisplay VALUE onListDisplay            TYPE "B"
   ASSIGN ::OnListClose   VALUE onListClose              TYPE "B"

   RETURN Self

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Field( uField ) CLASS TCombo

   IF HB_ISBLOCK( uField )
      ::uField := uField
   ELSEIF ValType( uField ) $ "CM"
      ::uField := &( "{ || " + uField + " }" )
   ENDIF

   RETURN ::uField

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD ValueSource( uValue ) CLASS TCombo

   IF PCount() > 0 .AND. uValue == NIL
      ::aValues := {}
      ::uValueSource := NIL
   ELSEIF HB_ISARRAY( uValue )
      ::aValues := AClone( uValue )
      ::uValueSource := NIL
   ELSEIF HB_ISBLOCK( uValue )
      ::aValues := {}
      ::uValueSource := uValue
   ELSEIF ValType( uValue ) $ "CM"
      ::aValues := {}
      IF Empty( uValue )
         ::uValueSource := NIL
      ELSE
         ::uValueSource := &( "{ || " + uValue + " }" )
      ENDIF
   ENDIF

   RETURN ::uValueSource

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD nHeight( nHeight ) CLASS TCombo

   IF HB_ISNUMERIC( nHeight ) .AND. ! ValidHandler( ::hWnd )
      ::nHeight2 := nHeight
   ENDIF

   RETURN ::nHeight2

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD EditHeight( nHeight )

   IF HB_ISNUMERIC( nHeight ) .AND. nHeight > 0
      SendMessage( ::hWnd, CB_SETITEMHEIGHT, -1, nHeight )
   ENDIF

   RETURN SendMessage( ::hWnd, CB_GETITEMHEIGHT, -1, nHeight )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD OptionsHeight( nHeight )

   IF HB_ISNUMERIC( nHeight ) .AND. nHeight > 0
      SendMessage( ::hWnd, CB_SETITEMHEIGHT, 0, nHeight )
   ENDIF

   RETURN SendMessage( ::hWnd, CB_GETITEMHEIGHT, 0, nHeight )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD VisibleItems() CLASS TCombo

   LOCAL nRet

   IF IsWindowStyle( ::hWnd, CBS_NOINTEGRALHEIGHT )
      nRet := ::nHeight / ::ItemHeight()
      IF nRet - Int( nRet ) > 0
         nRet := Int( nRet ) + 1
      ENDIF
   ELSE
      nRet := SendMessage( ::hWnd, CB_GETMINVISIBLE, 0, 0 ) * 2
   ENDIF

   RETURN nRet

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Refresh() CLASS TCombo

   LOCAL BackRec, bField, aValues, uValue, bValueSource, lNoEval, BackOrd := NIL
   LOCAL lRefreshImages, aImages, nMax, nCount, nArea

   IF ( nArea := Select( ::WorkArea ) ) != 0
      IF HB_ISBLOCK( ::ImageSource )
         lRefreshImages := .T.
         aImages := {}
      ELSE
         lRefreshImages := .F.
      ENDIF

      uValue := ::Value
      bField := ::Field
      BackRec := ( nArea )->( RecNo() )
      IF HB_ISBLOCK( ::SourceOrder )
         BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::SourceOrder ) ) ) )
      ELSEIF ValType( ::SourceOrder ) $ "CMN"
         BackOrd := ( nArea )->( ordSetFocus( ::SourceOrder ) )
      ENDIF

      IF OSisWinXPorLater() .AND. ::lDelayLoad
         nMax := ::VisibleItems * 2
      ELSE
         nMax := ( nArea )->( LastRec() )
      ENDIF

      ( nArea )->( dbGoTop() )
      IF ( nArea )->( Eof() )
         ::nLastItem := 0
      ENDIF

      nCount := 0

      ComboboxReset( ::hWnd )
      aValues := {}
      bValueSource := ::ValueSource
      lNoEval := Empty( bValueSource )

      DO WHILE ! ( nArea )->( Eof() ) .AND. nCount < nMax
         ::AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::ItemNumber ) } )
         AAdd( aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
         IF lRefreshImages
            AAdd( aImages, Eval( ::ImageSource ) )
         ENDIF

         ::nLastItem := ( nArea )->( RecNo() )
         ( nArea )->( dbSkip() )
         nCount ++
      ENDDO

      IF BackOrd != NIL
         ( nArea )->( ordSetFocus( BackOrd ) )
      ENDIF
      ( nArea )->( dbGoto( BackRec ) )

      IF lRefreshImages
         ::ClearBitMaps()

         ::AddBitMap( aImages )
      ENDIF

      ::aValues := aValues
      ::Value := uValue

      ::DoEvent( ::OnRefresh, "REFRESH" )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DisplayValue( cValue ) CLASS TCombo

   RETURN ( ::Caption := cValue )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Value( uValue ) CLASS TCombo

   LOCAL uRet

   IF Len( ::aValues ) == 0
      IF HB_ISNUMERIC( uValue )
         ComboSetCursel( ::hWnd, uValue )
         ::DoChange()
      ENDIF
      uRet := ComboGetCursel( ::hWnd )
   ELSE
      IF ValType( ::aValues[ 1 ] ) == ValType( uValue ) .OR. ;
         ( ValType( uValue ) $ "CM" .AND. ValType( ::aValues[ 1 ] ) $ "CM" )
         ComboSetCursel( ::hWnd, AScan( ::aValues, uValue ) )
          ::DoChange()
      ENDIF
      uRet := ComboGetCursel( ::hWnd )
      IF uRet >= 1 .AND. uRet <= Len( ::aValues )
         uRet := ::aValues[ uRet ]
      ELSEIF ValType( ::aValues[ 1 ] ) $ "CM"
         uRet := ""
      ELSE
         uRet := 0
      ENDIF
   ENDIF

   RETURN uRet

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Visible( lVisible ) CLASS TCombo

   IF HB_ISLOGICAL( lVisible )
      ::Super:Visible := lVisible
      IF ! lVisible
         SendMessage( ::hWnd, CB_SHOWDROPDOWN, 0, 0 )
      ENDIF
   ENDIF

   RETURN ::lVisible

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD RefreshData() CLASS TCombo

   LOCAL lRefresh

   IF HB_ISLOGICAL( ::lRefresh )
      lRefresh := ::lRefresh
   ELSE
      lRefresh := _OOHG_ComboRefresh
   ENDIF
   IF lRefresh
      ::Refresh()
   ENDIF

   RETURN ::Super:RefreshData()

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Release() CLASS TCombo

   IF HB_ISOBJECT( ::oEditBox )
      ::oEditBox:Release()
   ENDIF

   RETURN ::Super:Release()

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD ShowDropDown( lShow ) CLASS TCombo

   ASSIGN lShow VALUE lShow TYPE "L" DEFAULT .T.
   IF lShow
      SendMessage( ::hWnd, CB_SHOWDROPDOWN, 1, 0 )
   ELSE
      SendMessage( ::hWnd, CB_SHOWDROPDOWN, 0, 0 )
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD AutoSizeDropDown( lResizeBox, nMinWidth, nMaxWidth ) CLASS TCombo

   LOCAL nCounter, nNewWidth, nScrollWidth := GetVScrollBarWidth()

   /*
   lResizeBox = Resize dropdown list and combobox (.t.) or dropdown list only (.f.)
   defaults to .f.
   */
   ASSIGN lResizeBox VALUE lResizeBox TYPE "L" DEFAULT .F.

   /*
   Compute the space needed to show the longest item in the dropdown list.
   The extra character "0" is added to provide room for the margin in the dropdown list.
   */
   nNewWidth := GetTextWidth( NIL, "0", ::FontHandle ) + ::IconWidth + nScrollWidth

   FOR nCounter := 1 TO ::ItemCount
      nNewWidth := Max( GetTextWidth( NIL, ::Item(nCounter) + "0", ::FontHandle ) + ::IconWidth + nScrollWidth, nNewWidth )
   NEXT

   /*
   nMinWidth = minimum width of dropdown list.
   If omited or is less than 0, defaults to 0 if lResizeBox == .T. or to combobox width otherwise.
   */
   IF ! HB_ISNUMERIC( nMinWidth ) .OR. nMinWidth < 0
      nMinWidth := iif( lResizeBox, 0, ::Width )
   ENDIF

   /*
   If the computed value is less than the minimum, use the minimum.
   */
   nNewWidth := Max( nNewWidth, nMinWidth )

   /*
   nMaxWidth = maximum width of dropdown list, if omited defaults to longest item's width
   If no maximum specified or is less than minimun, use computed value as maximum.
   */
   IF ! HB_ISNUMERIC( nMaxWidth ) .OR. nMaxWidth < nMinWidth
      nMaxWidth := nNewWidth
   ENDIF

   /*
   If the computed value is greater than the maximum, use the maximum.
   */
   nNewWidth := Min( nNewWidth, nMaxWidth )

   /*
   Resize combobox.
   Must be done before resizing dropdown list, because dropdown list's width is,
   always, at least equal to combobox width.
   */
   IF lResizeBox
     ::width := nNewWidth
   ENDIF

   /*
   Resize dropdown list
   */
   ::SetDropDownWidth( nNewWidth )

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD GetDropDownWidth() CLASS TCombo

   RETURN ComboGetDroppedWidth( ::hWnd )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetDropDownWidth( nWidth ) CLASS TCombo

   LOCAL nNew := ComboSetDroppedWidth( ::hWnd, nWidth )

   IF nNew == -1
     nNew := ComboGetDroppedWidth( ::hWnd )
   ENDIF

   RETURN nNew

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD AutoSize( lValue ) CLASS TCombo

   LOCAL cCaption

   IF HB_ISLOGICAL( lValue )
      ::lAutoSize := lValue
      IF lValue
         cCaption := GetWindowText( ::hWnd )
         ::SizePos(, , GetTextWidth( NIL, cCaption + "0", ::FontHandle ) + ::IconWidth + GetVScrollBarWidth(), GetTextHeight( NIL, cCaption, ::FontHandle ) )
      ENDIF
   ENDIF

   RETURN ::lAutoSize

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD FindString( c, n ) CLASS TCombo

   LOCAL nPos

   IF HB_ISOBJECT( ::oListBox ) .AND. ValType( c ) $ "CM" .AND. ! Empty( c )
      IF ! HB_ISNUMERIC( n ) .OR. n < 0
         // Search from the top
         n := 0
      ENDIF
      n := Int( n )
      nPos := ::oListBox:FindString( c, n )
   ELSE
      nPos := 0
   ENDIF

   RETURN nPos

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD FindStringExact( c, n ) CLASS TCombo

   LOCAL nPos

   IF HB_ISOBJECT( ::oListBox ) .AND. ValType( c ) $ "CM" .AND. ! Empty( c )
      IF ! HB_ISNUMERIC( n ) .OR. n < 0
         // Search from the top
         n := 0
      ENDIF
      n := Int( n )
      nPos := ::oListBox:FindStringExact( c, n )
   ELSE
      nPos := 0
   ENDIF

   RETURN nPos

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Events( hWnd, nMsg, wParam, lParam ) CLASS TCombo

   LOCAL nArea, BackRec, nMax, i, nStart, bField, bValueSource, lNoEval, BackOrd := NIL

   IF nMsg == WM_CHAR
      IF ::lIncremental
         IF wParam < 32
            ::cText := ""
         ELSE
            IF Empty( ::cText )
               ::uIniTime := hb_MilliSeconds()
               ::cText := Upper( Chr( wParam ) )
               nStart := ComboGetCursel( ::hWnd )
            ELSEIF ::SearchLapse > 0 .AND. hb_MilliSeconds() > ::uIniTime + ::SearchLapse
               ::uIniTime := hb_MilliSeconds()
               ::cText := Upper( Chr( wParam ) )
               nStart := ComboGetCursel( ::hWnd )
            ELSE
               ::uIniTime := hb_MilliSeconds()
               ::cText += Upper( Chr( wParam ) )
               nStart := ::nLastFound
            ENDIF

            ::nLastFound := ::FindString( ::cText, nStart )
            IF ::nLastFound > 0 .AND. ::nLastFound >= nStart
               // item was found in the rest of the list, select
               IF Len( ::aValues ) == 0
                  ::Value := ::nLastFound
               ELSEIF ::nLastFound >= 1 .AND. ::nLastFound <= Len( ::aValues )
                  ::Value := ::aValues[ ::nLastFound ]
               ENDIF
            ELSE
               // if there are more items not already loaded, load them and search again
               IF OSisWinXPorLater() .AND. ::lDelayLoad
                  IF ( nArea := Select( ::WorkArea ) ) != 0
                     nMax := ::VisibleItems
                     bField := ::Field
                     bValueSource := ::ValueSource
                     lNoEval := Empty( bValueSource )

                     BackRec := ( nArea )->( RecNo() )
                     IF HB_ISBLOCK( ::SourceOrder )
                        BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::SourceOrder ) ) ) )
                     ELSEIF ValType( ::SourceOrder ) $ "CMN"
                        BackOrd := ( nArea )->( ordSetFocus( ::SourceOrder ) )
                     ENDIF

                     ( nArea )->( dbGoto( ::nLastItem ) )
                     ( nArea )->( dbSkip() )
                     DO WHILE ! ( nArea )->( Eof() )
                        // load more items
                        i := 0
                        DO WHILE ! ( nArea )->( Eof() ) .AND. i < nMax
                           ::AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::ItemNumber ) } )
                           AAdd( ::aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
                           IF ValidHandler( ::ImageList )
                              ::AddBitMap( Eval( ::ImageSource ) )
                           ENDIF

                           ::nLastItem := ( nArea )->( RecNo() )
                           ( nArea )->( dbSkip() )
                           i ++
                        ENDDO
                        // search again
                        ::nLastFound := ::FindString( ::cText )
                        IF ::nLastFound > 0
                          EXIT
                        ENDIF
                     ENDDO

                     IF BackOrd != NIL
                        ( nArea )->( ordSetFocus( BackOrd ) )
                     ENDIF
                     ( nArea )->( dbGoto( BackRec ) )
                  ENDIF
               ENDIF

               IF ::nLastFound > 0
                  IF Len( ::aValues ) == 0
                     ::Value := ::nLastFound
                  ELSEIF ::nLastFound >= 1 .AND. ::nLastFound <= Len( ::aValues )
                     ::Value := ::aValues[ ::nLastFound ]
                  ENDIF
               ELSE
                  ::cText := ""
               ENDIF
            ENDIF

            RETURN 0
         ENDIF
      ELSE
         ::cText := ""
         IF OSisWinXPorLater() .AND. ::lDelayLoad
            IF ( nArea := Select( ::WorkArea ) ) != 0
               // load all remaining items so OS can search
               bField := ::Field
               bValueSource := ::ValueSource
               lNoEval := Empty( bValueSource )

               BackRec := ( nArea )->( RecNo() )
               IF HB_ISBLOCK( ::SourceOrder )
                  BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::SourceOrder ) ) ) )
               ELSEIF ValType( ::SourceOrder ) $ "CMN"
                  BackOrd := ( nArea )->( ordSetFocus( ::SourceOrder ) )
               ENDIF

               ( nArea )->( dbGoto( ::nLastItem ) )
               ( nArea )->( dbSkip() )
               DO WHILE ! ( nArea )->( Eof() )
                  ::AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::ItemNumber ) } )
                  AAdd( ::aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
                  IF ValidHandler( ::ImageList )
                     ::AddBitMap( Eval( ::ImageSource ) )
                  ENDIF

                  ::nLastItem := ( nArea )->( RecNo() )
                  ( nArea )->( dbSkip() )
               ENDDO

               IF BackOrd != NIL
                  ( nArea )->( ordSetFocus( BackOrd ) )
               ENDIF
               ( nArea )->( dbGoto( BackRec ) )
            ENDIF
         ENDIF
      ENDIF

   ELSEIF nMsg == WM_MOUSEWHEEL
      ::cText := ""
      IF OSisWinXPorLater() .AND. ::lDelayLoad
         IF ( nArea := Select( ::WorkArea ) ) != 0
            IF GET_WHEEL_DELTA_WPARAM( wParam ) < 0                // DOWN
               bField := ::Field
               bValueSource := ::ValueSource
               lNoEval := Empty( bValueSource )

               BackRec := ( nArea )->( RecNo() )
               IF HB_ISBLOCK( ::SourceOrder )
                  BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::SourceOrder ) ) ) )
               ELSEIF ValType( ::SourceOrder ) $ "CMN"
                  BackOrd := ( nArea )->( ordSetFocus( ::SourceOrder ) )
               ENDIF

               ( nArea )->( dbGoto( ::nLastItem ) )
               ( nArea )->( dbSkip() )
               i := 0
               DO WHILE ! ( nArea )->( Eof() ) .and. i < 3
                  ::AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::ItemNumber ) } )
                  AAdd( ::aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
                  IF ValidHandler( ::ImageList )
                     ::AddBitMap( Eval( ::ImageSource ) )
                  ENDIF

                  ::nLastItem := ( nArea )->( RecNo() )
                  ( nArea )->( dbSkip() )
                  i ++
               ENDDO

               IF BackOrd != NIL
                  ( nArea )->( ordSetFocus( BackOrd ) )
               ENDIF
               ( nArea )->( dbGoto( BackRec ) )
            ENDIF
         ENDIF
      ENDIF

   ELSEIF nMsg == WM_KEYDOWN
      IF OSisWinXPorLater() .AND. ::lDelayLoad
         IF ( nArea := Select( ::WorkArea ) ) != 0
            DO CASE
            CASE wParam == VK_END
               ::cText := ""

               // load all remaining items
               bField := ::Field
               bValueSource := ::ValueSource
               lNoEval := Empty( bValueSource )

               BackRec := ( nArea )->( RecNo() )
               IF HB_ISBLOCK( ::SourceOrder )
                  BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::SourceOrder ) ) ) )
               ELSEIF ValType( ::SourceOrder ) $ "CMN"
                  BackOrd := ( nArea )->( ordSetFocus( ::SourceOrder ) )
               ENDIF

               ( nArea )->( dbGoto( ::nLastItem ) )
               ( nArea )->( dbSkip() )
               DO WHILE ! ( nArea )->( Eof() )
                  ::AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::ItemNumber ) } )
                  AAdd( ::aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
                  IF ValidHandler( ::ImageList )
                     ::AddBitMap( Eval( ::ImageSource ) )
                  ENDIF

                  ::nLastItem := ( nArea )->( RecNo() )
                  ( nArea )->( dbSkip() )
               ENDDO

               IF BackOrd != NIL
                  ( nArea )->( ordSetFocus( BackOrd ) )
               ENDIF
               ( nArea )->( dbGoto( BackRec ) )

            CASE wParam == VK_NEXT
               ::cText := ""

               // load one more page of items
               nMax := ::VisibleItems
               bField := ::Field
               bValueSource := ::ValueSource
               lNoEval := Empty( bValueSource )

               BackRec := ( nArea )->( RecNo() )
               IF HB_ISBLOCK( ::SourceOrder )
                  BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::SourceOrder ) ) ) )
               ELSEIF ValType( ::SourceOrder ) $ "CMN"
                  BackOrd := ( nArea )->( ordSetFocus( ::SourceOrder ) )
               ENDIF

               ( nArea )->( dbGoto( ::nLastItem ) )
               ( nArea )->( dbSkip() )
               i := 0
               DO WHILE ! ( nArea )->( Eof() ) .and. i < nMax
                  ::AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::ItemNumber ) } )
                  AAdd( ::aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
                  IF ValidHandler( ::ImageList )
                     ::AddBitMap( Eval( ::ImageSource ) )
                  ENDIF

                  ::nLastItem := ( nArea )->( RecNo() )
                  ( nArea )->( dbSkip() )
                  i ++
               ENDDO

               IF BackOrd != NIL
                  ( nArea )->( ordSetFocus( BackOrd ) )
               ENDIF
               ( nArea )->( dbGoto( BackRec ) )

            CASE wParam == VK_DOWN
               ::cText := ""

               // load one more item
               bField := ::Field
               bValueSource := ::ValueSource
               lNoEval := Empty( bValueSource )

               BackRec := ( nArea )->( RecNo() )
               IF HB_ISBLOCK( ::SourceOrder )
                  BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::SourceOrder ) ) ) )
               ELSEIF ValType( ::SourceOrder ) $ "CMN"
                  BackOrd := ( nArea )->( ordSetFocus( ::SourceOrder ) )
               ENDIF

               ( nArea )->( dbGoto( ::nLastItem ) )
               ( nArea )->( dbSkip() )
               IF ! ( nArea )->( Eof() )
                  ::AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::ItemNumber ) } )
                  AAdd( ::aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
                  IF ValidHandler( ::ImageList )
                     ::AddBitMap( Eval( ::ImageSource ) )
                  ENDIF

                  ::nLastItem := ( nArea )->( RecNo() )
               ENDIF

               IF BackOrd != NIL
                  ( nArea )->( ordSetFocus( BackOrd ) )
               ENDIF
               ( nArea )->( dbGoto( BackRec ) )

            CASE wParam == VK_UP .OR. wParam == VK_HOME .OR. wParam == VK_PRIOR
               ::cText := ""

            ENDCASE
         ENDIF
      ENDIF

   ELSEIF nMsg == WM_LBUTTONDOWN
      IF ! ::lFocused
         ::SetFocus()
      ENDIF

   ENDIF

   RETURN ::Super:Events( hWnd, nMsg, wParam, lParam )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Events_Command( wParam ) CLASS TCombo

   LOCAL Hi_wParam := HIWORD( wParam ), nArea, BackRec, i, nMax, bField, bValueSource, lNoEval, BackOrd := NIL

   IF Hi_wParam == CBN_SELCHANGE
      IF ::lAutosize
         ::Autosize(.T.)
      ENDIF

      ::DoChange()
      RETURN NIL

   ELSEIF Hi_wParam == CBN_DROPDOWN
      ::cText := ""
      ::DoEvent( ::OnListDisplay, "LISTDISPLAY" )
      RETURN NIL

   ELSEIF Hi_wParam == CBN_CLOSEUP
      ::cText := ""
      ::DoEvent( ::OnListClose, "LISTCLOSE" )
      RETURN NIL

   ELSEIF Hi_wParam == CBN_KILLFOCUS
      ::cText := ""
      ::lFocused := .F.
      RETURN ::DoLostFocus()

   ELSEIF Hi_wParam == CBN_SETFOCUS .OR. ;
          Hi_wParam == BN_SETFOCUS
      IF ! ::lFocused
         ::cText := ""
         ::lFocused := .T.
         GetFormObjectByHandle( ::ContainerhWnd ):LastFocusedControl := ::hWnd
         ::FocusEffect()
         ::DoEvent( ::OnGotFocus, "GOTFOCUS" )
      ENDIF
      RETURN NIL

   ELSEIF Hi_wParam == EN_CHANGE
      // avoids incorrect processing
      RETURN NIL

   ELSEIF Hi_wParam == CBN_EDITCHANGE
      IF ::lIncremental
         ::cText := Upper( ::DisplayValue )
         IF ::oEditBox:LastKey == VK_BACK
            nMax := Len( ::cText )
            IF nMax > 0
               ::cText := SubStr( ::cText, 1, nMax - 1 )
            ENDIF
         ENDIF
         ::nLastFound := ::FindString( ::cText )
         IF ::nLastFound > 0
            ComboSetCurSel( ::hWnd, ::nLastFound )
            ::SetEditSel( Len( ::cText ), Len( ::DisplayValue ) )
            ::DoChange()
            RETURN NIL
         ENDIF
         // if there are more items not already loaded, load them and search again
         IF OSisWinXPorLater() .AND. ::lDelayLoad
            IF ( nArea := Select( ::WorkArea ) ) != 0
               nMax := ::VisibleItems
               bField := ::Field
               bValueSource := ::ValueSource
               lNoEval := Empty( bValueSource )

               BackRec := ( nArea )->( RecNo() )
               IF HB_ISBLOCK( ::SourceOrder )
                  BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::SourceOrder ) ) ) )
               ELSEIF ValType( ::SourceOrder ) $ "CMN"
                  BackOrd := ( nArea )->( ordSetFocus( ::SourceOrder ) )
               ENDIF

               ( nArea )->( dbGoto( ::nLastItem ) )
               ( nArea )->( dbSkip() )
               DO WHILE ! ( nArea )->( Eof() )
                  // load more items
                  i := 0
                  DO WHILE ! ( nArea )->( Eof() ) .AND. i < nMax
                     ::AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::ItemNumber ) } )
                     AAdd( ::aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
                     IF ValidHandler( ::ImageList )
                        ::AddBitMap( Eval( ::ImageSource ) )
                     ENDIF

                     ::nLastItem := ( nArea )->( RecNo() )
                     ( nArea )->( dbSkip() )
                     i ++
                  ENDDO

                  // search again
                  ::nLastFound := ::FindString( ::cText )
                  IF ::nLastFound > 0
                    EXIT
                  ENDIF
               ENDDO

               IF BackOrd != NIL
                  ( nArea )->( ordSetFocus( BackOrd ) )
               ENDIF
               ( nArea )->( dbGoto( BackRec ) )

               IF ::nLastFound > 0
                  ComboSetCurSel( ::hWnd, ::nLastFound )
                  ::SetEditSel( Len( ::cText ), Len( ::DisplayValue ) )
                  ::DoChange()
                  RETURN NIL
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      ::DoEvent( ::OnClick, "DISPLAYCHANGE" )
      RETURN NIL

   ELSEIF Hi_wParam == EN_KILLFOCUS .OR. ;
          Hi_wParam == BN_KILLFOCUS
      // avoids incorrect processing
      RETURN NIL

   ENDIF

   RETURN ::Super:Events_Command( wParam )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD SetEditSel( nStart, nEnd ) CLASS TCombo

   /*
   start:
      -1 the selection, if any, is removed.
       0 is first character.
   end:
       -1 all text from the start to the last character is selected.

   The first character after the last selected character is in the ending
   position. For example, to select the first four characters, use a
   starting position of 0 and an ending position of 4.

   This method is meaningfull only when de combo is in edit state.
   When the combo loses the focus, it gets out of edit state.
   When the combo gets the focus, all the text is selected.
   */

   LOCAL lRet

   IF HB_ISNUMERIC( nStart ) .AND. nStart >= -1 .AND. HB_ISNUMERIC( nEnd ) .AND. nEnd >= -1
      lRet := SendMessage( ::hWnd, CB_SETEDITSEL, 0, MakeLParam( nStart, nEnd ) )
   ELSE
      lRet := .F.
   ENDIF

   RETURN lRet

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD GetEditSel() CLASS TCombo

   /*
   Returns an array with 2 items:
   1st. the starting position of the selection (zero-based value).
   2nd. the ending position of the selection (position of the first character
   after the last selected character). This value is the caret position.

   This method is meaningfull only when de combo is in edit state.
   When the combo loses the focus, it gets out of edit state.
   When the combo gets the focus, all the text is selected.
   */

   LOCAL rRange := SendMessage( ::hWnd, CB_GETEDITSEL, 0, 0 )

   RETURN { LoWord( rRange ), HiWord( rRange ) }

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD CaretPos( nPos ) CLASS TCombo

   /*
   Returns the ending position of the selection (position of the first character
   after the last selected character). This value is the caret position.

   This method is meaningfull only when de combo is in edit state.
   When the combo loses the focus, it gets out of edit state, and this method returns 0.
   When the combo gets the focus, all the text is selected.
   */

   IF HB_ISNUMERIC( nPos )
      SendMessage( ::hWnd, CB_SETEDITSEL, 0, MakeLParam( nPos, nPos ) )
   ENDIF

   RETURN HiWord( SendMessage( ::hWnd, CB_GETEDITSEL, NIL, NIL ) )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD ItemValue( cText ) CLASS TCombo

   LOCAL nPos, uRet

   nPos := ::FindStringExact( cText )

   IF Len( ::aValues ) == 0
      uRet := nPos
   ELSEIF nPos >= 1 .AND. nPos <= Len( ::aValues )
      uRet := ::aValues[ nPos ]
   ELSEIF ValType( ::aValues[ 1 ] ) $ "CM"
      uRet := ""
   ELSE
      uRet := 0
   ENDIF

   RETURN uRet

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD ItemBySource( nItem, uValue ) CLASS TCombo

   LOCAL cRet, nPos

   IF Len( ::aValues ) == 0
      cRet := ComboItem( Self, nItem, uValue )
   ELSE
      IF ValType( ::aValues[ 1 ] ) == ValType( nItem ) .OR. ;
         ( ValType( nItem ) $ "CM" .AND. ValType( ::aValues[ 1 ] ) $ "CM" )
         nPos := AScan( ::aValues, nItem )
         IF nPos > 0
            cRet := ComboItem( Self, nPos, uValue )
         ELSE
            cRet := ""
         ENDIF
      ENDIF
   ENDIF

   RETURN cRet

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD AddItem( uValue, uSource ) CLASS TCombo

   IF PCount() > 1 .AND. ( Len( ::aValues ) > 0 .OR. ( Len( ::aValues ) == 0 .AND. ::ItemCount == 0 ) )
      AAdd( ::aValues, uSource )
   ENDIF

   RETURN TCombo_Add_Item( Self, uValue )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD InsertItem( nItem, uValue, uSource ) CLASS TCombo

   IF PCount() > 2 .AND. Len( ::aValues ) > 0
      AAdd( ::aValues, NIL )
      AIns( ::aValues, nItem )
      ::aValues[ nItem ] := uSource
   ENDIF

   RETURN TCombo_Insert_Item( Self, nItem, uValue )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DeleteItem( nPos ) CLASS TCombo

  LOCAL nSel, nSize

   nSel := ComboGetCursel( ::hWnd )

   nSize := Len( ::aValues )
   IF nSize >= nPos
      ADel( ::aValues, nPos )
      ASize( ::aValues, nSize - 1 )
   ENDIF

   IF ComboboxDeleteString( ::hWnd, nPos )
      IF nSel # ComboGetCursel( ::hWnd )
         ::Redraw()
         ::DoChange()
      ENDIF
      RETURN .T.
   ENDIF

   RETURN .F.

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD DeleteAllItems() CLASS TCombo

   ::aValues := {}
   ::xOldValue := NIL
   ::OldValue := NIL
   ComboboxReset( ::hWnd )

   RETURN NIL


/*--------------------------------------------------------------------------------------------------------------------------------*/
#pragma BEGINDUMP

#include "oohg.h"
#include <hbvm.h>
#include <hbstack.h>
#include <windowsx.h>

#ifndef CB_GETCOMBOBOXINFO
   #define CB_GETCOMBOBOXINFO 0x0164
#endif

#define s_Super s_TLabel

/*--------------------------------------------------------------------------------------------------------------------------------*/
static WNDPROC _OOHG_TCombo_lpfnOldWndProc( WNDPROC lp )
{
   static WNDPROC lpfnOldWndProc = 0;

   WaitForSingleObject( _OOHG_GlobalMutex(), INFINITE );
   if( ! lpfnOldWndProc )
   {
      lpfnOldWndProc = lp;
   }
   ReleaseMutex( _OOHG_GlobalMutex() );

   return lpfnOldWndProc;
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
static LRESULT APIENTRY SubClassFunc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   return _OOHG_WndProcCtrl( hWnd, msg, wParam, lParam, _OOHG_TCombo_lpfnOldWndProc( 0 ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( INITCOMBOBOX )          /* FUNCTION InitCombobox( hWnd, nId, nCol, nRow, nWidth, nHeight, nStyle, lRtl ) -> hWnd */
{
   HWND hcombo;
   INT Style, StyleEx;

   Style = hb_parni( 7 ) | WS_CHILD | WS_VSCROLL | CBS_HASSTRINGS;
   StyleEx = _OOHG_RTL_Status( hb_parl( 8 ) );

   hcombo = CreateWindowEx( StyleEx, "COMBOBOX", "", Style,
                            hb_parni( 3 ), hb_parni( 4 ), hb_parni( 5 ), hb_parni( 6 ),
                            HWNDparam( 1 ), HMENUparam( 2 ), GetModuleHandle( NULL ), NULL );

   _OOHG_TCombo_lpfnOldWndProc( ( WNDPROC ) SetWindowLongPtr( hcombo, GWL_WNDPROC, ( LONG_PTR ) SubClassFunc ) );

   HWNDret( hcombo );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOADDSTRING )          /* FUNCTION ComboAddString( hWnd, cString ) -> NIL */
{
   SendMessage( HWNDparam( 1 ), CB_ADDSTRING, 0, ( LPARAM ) hb_parc( 2 ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOINSERTSTRING )          /* FUNCTION ComboInsertString( hWnd, cString, nPos ) -> NIL */
{
   SendMessage( HWNDparam( 1 ), CB_INSERTSTRING, ( WPARAM ) hb_parni( 3 ) - 1, ( LPARAM ) hb_parc( 2 ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOSETCURSEL )          /* FUNCTION ComboSetCurSel( hwnd, nPos ) -> NIL */
{
   SendMessage( HWNDparam( 1 ), CB_SETCURSEL, ( WPARAM ) hb_parni( 2 ) - 1, 0 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOGETCURSEL )          /* FUNCTION ComboGetCurSel( hWnd ) -> nPos */
{
   hb_retni( SendMessage( HWNDparam( 1 ), CB_GETCURSEL, 0, 0 ) + 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOGETDROPPEDWIDTH )          /* FUNCTION ComboGetDroppedWidth( hWnd ) -> nWidth */
{
   hb_retni( SendMessage( HWNDparam( 1 ), CB_GETDROPPEDWIDTH, 0, 0 ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOSETDROPPEDWIDTH )          /* FUNCTION ComboSetDroppedWidth( hWnd, nWidth ) -> nWidth */
{
   hb_retni( SendMessage( HWNDparam( 1 ), CB_SETDROPPEDWIDTH, ( WPARAM ) hb_parni( 2 ), 0 ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOBOXDELETESTRING )          /* FUNCTION ComboboxDeleteString( hWnd, nPos ) -> lSuccess */
{
   if( SendMessage( HWNDparam( 1 ), CB_DELETESTRING, ( WPARAM ) hb_parni( 2 ) - 1, 0 ) >= 0 )
   {
      hb_retl( TRUE );
   }
   else
   {
      hb_retl( FALSE );
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOBOXRESET )          /* FUNCTION ComboboxReset( hWnd ) -> NIL */
{
   SendMessage( HWNDparam( 1 ), CB_RESETCONTENT, 0, 0 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOGETSTRING )          /* FUNCTION ComboGetString( hWnd, nPos ) -> cString */
{
   char cString [1024] = "";
   SendMessage( HWNDparam( 1 ), CB_GETLBTEXT, ( WPARAM ) hb_parni( 2 ) - 1, ( LPARAM ) cString );
   hb_retc( cString );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOBOXGETITEMCOUNT )          /* FUNCTION ComboboxGetItemCount( hWnd ) -> nCount */
{
   hb_retnl( SendMessage( HWNDparam( 1 ), CB_GETCOUNT, 0, 0 ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
static void TCombo_SetImageBuffer( POCTRL oSelf, struct IMAGE_PARAMETER pStruct, int nItem )
{
   BYTE * cBuffer;
   ULONG ulSize, ulSize2;
   INT * pImage;

   if( oSelf->AuxBuffer || pStruct.iImage1 != -1 || pStruct.iImage2 != -1 )
   {
      if( nItem >= ( INT ) oSelf->AuxBufferLen )
      {
         ulSize = sizeof( INT ) * 2 * ( nItem + 100 );
         cBuffer = ( BYTE * ) hb_xgrab( ulSize );
         memset( cBuffer, -1, ulSize );
         if( oSelf->AuxBuffer )
         {
            memcpy( cBuffer, oSelf->AuxBuffer, ( sizeof( INT ) * 2 * oSelf->AuxBufferLen ) );
            hb_xfree( oSelf->AuxBuffer );
         }
         oSelf->AuxBuffer = cBuffer;
         oSelf->AuxBufferLen = nItem + 100;
      }

      pImage = &( ( INT * ) oSelf->AuxBuffer )[ nItem * 2 ];
      if( nItem < ComboBox_GetCount( oSelf->hWnd ) )
      {
         ulSize  = sizeof( INT ) * 2 * ComboBox_GetCount( oSelf->hWnd );
         ulSize2 = sizeof( INT ) * 2 * nItem;
         cBuffer = ( BYTE * ) hb_xgrab( ulSize );
         memcpy( cBuffer, pImage, ulSize - ulSize2 );
         memcpy( &pImage[ 2 ], cBuffer, ulSize - ulSize2 );
         hb_xfree( cBuffer );
      }
      pImage[ 0 ] = pStruct.iImage1;
      pImage[ 1 ] = pStruct.iImage2;
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC_STATIC( TCOMBO_EVENTS_DRAWITEM )          /* METHOD Events_DrawItem( lParam ) CLASS TCombo -> NIL */
{
   PHB_ITEM pSelf = hb_stackSelfItem();
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
   LPDRAWITEMSTRUCT lpdis = ( LPDRAWITEMSTRUCT ) HB_PARNL( 1 );
   COLORREF FontColor, BackColor;
   TEXTMETRIC lptm;
   CHAR cBuffer[ 2048 ];
   INT x, y, cx, cy, iImage, dy;

   if( lpdis->itemID != ( UINT ) -1 )
   {
      // checks if and image is defined for the current item
      if( oSelf->ImageList && oSelf->AuxBuffer && ( lpdis->itemID + 1 ) <= oSelf->AuxBufferLen )
      {
         iImage = ( ( INT * ) oSelf->AuxBuffer )[ ( lpdis->itemID * 2 ) + ( lpdis->itemState & ODS_SELECTED ? 1 : 0 ) ];
         if( iImage >= 0 && iImage < ImageList_GetImageCount( oSelf->ImageList ) )
         {
            ImageList_GetIconSize( oSelf->ImageList, &cx, &cy );
         }
         else
         {
            cx = 0;
            cy = 0;
            iImage = -1;
         }
      }
      else
      {
         cx = 0;
         cy = 0;
         iImage = -1;
      }

      // text color
      if( lpdis->itemState & ODS_SELECTED )
      {
         FontColor = SetTextColor( lpdis->hDC, ( ( oSelf->lFontColorSelected == -1 ) ? GetSysColor( COLOR_HIGHLIGHTTEXT ) : ( COLORREF ) oSelf->lFontColorSelected ) );
         BackColor = SetBkColor( lpdis->hDC, ( ( oSelf->lBackColorSelected == -1 ) ? GetSysColor( COLOR_HIGHLIGHT ) : ( COLORREF ) oSelf->lBackColorSelected ) );
      }
      else if( lpdis->itemState & ODS_DISABLED )
      {
         FontColor = SetTextColor( lpdis->hDC, GetSysColor( COLOR_GRAYTEXT ) );
         BackColor = SetBkColor( lpdis->hDC, GetSysColor( COLOR_BTNFACE ) );
      }
      else
      {
         FontColor = SetTextColor( lpdis->hDC, ( ( oSelf->lFontColor == -1 ) ? GetSysColor( COLOR_WINDOWTEXT ) : ( COLORREF ) oSelf->lFontColor ) );
         BackColor = SetBkColor( lpdis->hDC, ( ( oSelf->lBackColor == -1 ) ? GetSysColor( COLOR_WINDOW ) : ( COLORREF ) oSelf->lBackColor ) );
      }

      // window position
      GetTextMetrics( lpdis->hDC, &lptm );
      y = ( lpdis->rcItem.bottom + lpdis->rcItem.top - lptm.tmHeight ) / 2;
      x = LOWORD( GetDialogBaseUnits() ) / 2;

      // text
      SendMessage( lpdis->hwndItem, CB_GETLBTEXT, lpdis->itemID, ( LPARAM ) cBuffer );
      ExtTextOut( lpdis->hDC, cx + x * 2, y, ETO_CLIPPED | ETO_OPAQUE, &lpdis->rcItem, ( LPCSTR ) cBuffer, strlen( cBuffer ), NULL );

      SetTextColor( lpdis->hDC, FontColor );
      SetBkColor( lpdis->hDC, BackColor );

      // draws image vertically centered
      if( iImage != -1 )
      {
         if( cy < lpdis->rcItem.bottom - lpdis->rcItem.top )                   // there is spare space
         {
            y = ( lpdis->rcItem.bottom + lpdis->rcItem.top - cy ) / 2;         // center image
            dy = cy;
         }
         else
         {
            y = lpdis->rcItem.top;                                             // place image at top

            _OOHG_Send( pSelf, s_lAdjustImages );
            hb_vmSend( 0 );

            if( hb_parl( -1 ) )
            {
               dy = ( lpdis->rcItem.bottom - lpdis->rcItem.top );              // clip exceeding pixels or stretch image
            }
            else
            {
               dy = cy;                                                        // use real size
            }
         }

         ImageList_DrawEx( oSelf->ImageList, iImage, lpdis->hDC, x, y, cx, dy, CLR_DEFAULT, CLR_NONE, ILD_TRANSPARENT );
      }

      // focused rectangle
      if( lpdis->itemState & ODS_FOCUS )
      {
         DrawFocusRect( lpdis->hDC, &lpdis->rcItem );
      }
   }
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC_STATIC( TCOMBO_EVENTS_MEASUREITEM )          /* METHOD Events_MeasureItem( lParam ) CLASS TCombo -> 1 */
{
   PHB_ITEM pSelf = hb_stackSelfItem();
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
   LPMEASUREITEMSTRUCT lpmis = ( LPMEASUREITEMSTRUCT ) ( LPARAM ) HB_PARNL( 1 );

   HWND hWnd = GetActiveWindow();
   HDC hDC = GetDC( hWnd );
   HFONT hOldFont;
   SIZE sz;
   INT iSize;

   // checks for a pre-defined text size
   _OOHG_Send( pSelf, s_nTextHeight );
   hb_vmSend( 0 );
   iSize = hb_parni( -1 );

   hOldFont = ( HFONT ) SelectObject( hDC, oSelf->hFontHandle );
   GetTextExtentPoint32( hDC, "_", 1, &sz );
   SelectObject( hDC, hOldFont );
   ReleaseDC( hWnd, hDC );

   if( iSize < sz.cy + 2 )
   {
      iSize = sz.cy + 2;
   }

   lpmis->itemHeight = iSize;

   hb_retnl( 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( TCOMBO_ADD_ITEM )          /* FUNCTION TCombo_Add_Item( Self, uValue ) -> nItem */
{
   PHB_ITEM pSelf = ( PHB_ITEM ) hb_param( 1, HB_IT_ANY );
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
   struct IMAGE_PARAMETER pStruct;
   INT nItem = ComboBox_GetCount( oSelf->hWnd );

   ImageFillParameter( &pStruct, hb_param( 2, HB_IT_ANY ) );
   TCombo_SetImageBuffer( oSelf, pStruct, nItem );
   SendMessage( oSelf->hWnd, CB_ADDSTRING, 0, ( LPARAM ) pStruct.cString );

   hb_retnl( ComboBox_GetCount( oSelf->hWnd ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOITEM )          /* FUNCTION ComboItem( Self, nItem, uValue ) -> cItem */
{
   PHB_ITEM pSelf = ( PHB_ITEM ) hb_param( 1, HB_IT_ANY );
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
   PHB_ITEM pValue = hb_param( 3, HB_IT_ANY );
   INT nItem = hb_parni( 2 ) - 1;
   CHAR * cBuffer;
   struct IMAGE_PARAMETER pStruct;
   INT nItemSel, nItemNew;

   if( pValue && ( HB_IS_STRING( pValue ) || HB_IS_NUMERIC( pValue ) || HB_IS_ARRAY( pValue ) ) )
   {
      nItemSel = SendMessage( oSelf->hWnd, CB_GETCURSEL, 0, 0 );

      if( ( GetWindowLongPtr( oSelf->hWnd, GWL_STYLE ) & CBS_SORT ) == CBS_SORT )
      {
         SendMessage( oSelf->hWnd, CB_DELETESTRING, ( WPARAM ) nItem, 0 );
         ImageFillParameter( &pStruct, pValue );
         TCombo_SetImageBuffer( oSelf, pStruct, nItem );
         nItemNew = SendMessage( oSelf->hWnd, CB_ADDSTRING, 0, ( LPARAM ) pStruct.cString );
      }
      else
      {
        SendMessage( oSelf->hWnd, CB_DELETESTRING, ( WPARAM ) nItem, 0 );
        ImageFillParameter( &pStruct, pValue );
        TCombo_SetImageBuffer( oSelf, pStruct, nItem );
        nItemNew = SendMessage( oSelf->hWnd, CB_INSERTSTRING, ( WPARAM ) nItem, ( LPARAM ) pStruct.cString );
      }

      if( nItem == nItemSel )
      {
        SendMessage( oSelf->hWnd, CB_SETCURSEL, ( WPARAM ) nItemNew, 0 );
      }
   }

   cBuffer = ( CHAR * ) hb_xgrab( 2000 );
   SendMessage( oSelf->hWnd, CB_GETLBTEXT, ( WPARAM ) nItem, ( LPARAM ) cBuffer );
   hb_retc( cBuffer );
   hb_xfree( cBuffer );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( TCOMBO_INSERT_ITEM )          /* FUNCTION TCombo_Insert_Item( Self, nItem, uValue ) -> nItem */
{
   PHB_ITEM pSelf = ( PHB_ITEM ) hb_param( 1, HB_IT_ANY );
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
   PHB_ITEM pValue = hb_param( 3, HB_IT_ANY );
   INT nItem = hb_parni( 2 ) - 1;
   struct IMAGE_PARAMETER pStruct;

   if( pValue && ( HB_IS_STRING( pValue ) || HB_IS_NUMERIC( pValue ) || HB_IS_ARRAY( pValue ) ) )
   {
      ImageFillParameter( &pStruct, pValue );
      TCombo_SetImageBuffer( oSelf, pStruct, nItem );
      if( ( GetWindowLongPtr( oSelf->hWnd, GWL_STYLE ) & CBS_SORT ) == CBS_SORT )
      {
         SendMessage( oSelf->hWnd, CB_ADDSTRING, 0, ( LPARAM ) pStruct.cString );
      }
      else
      {
         SendMessage( oSelf->hWnd, CB_INSERTSTRING, ( WPARAM ) nItem, ( LPARAM ) pStruct.cString );
      }
   }

   hb_ret();
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOBOXFINDSTRING )          /* FUNCTION ComboboxFindString( hWnd, nStart, cString ) -> nPos */
{
   hb_retni( SendMessage( HWNDparam( 1 ), CB_FINDSTRING, ( WPARAM ) ( hb_parni( 2 ) - 1 ), ( LPARAM ) hb_parc( 3 ) ) + 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOBOXFINDSTRINGEXACT )          /* FUNCTION ComboboxFindStringExact( hWnd, nStart, cString ) -> nPos */
{
   hb_retni( SendMessage( HWNDparam( 1 ), CB_FINDSTRINGEXACT, ( WPARAM ) ( hb_parni( 2 ) - 1 ), ( LPARAM ) hb_parc( 3 ) ) + 1 );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( COMBOBOXGETLISTHWND )          /* FUNCTION ComboboxGetListHWND( hWnd ) -> hWnd */
{
   COMBOBOXINFO info;

   info.cbSize = sizeof( COMBOBOXINFO );
   info.hwndList = 0;

   SendMessage( HWNDparam( 1 ), CB_GETCOMBOBOXINFO, 0, ( LPARAM ) &info );

   HWNDret( info.hwndList );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC_STATIC( TCOMBO_ITEMHEIGHT )          /* METHOD ItemHeight() CLASS TCombo -> nHeight */
{
   PHB_ITEM pSelf = hb_stackSelfItem();
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
   HDC hDC;
   COMBOBOXINFO info;
   HFONT hOldFont;
   SIZE sz;
   INT iSize;

   info.cbSize = sizeof( COMBOBOXINFO );
   info.hwndList = 0;
   SendMessage( oSelf->hWnd, CB_GETCOMBOBOXINFO, 0, ( LPARAM ) &info );
   hDC = GetDC( info.hwndList );

   _OOHG_Send( pSelf, s_nTextHeight );
   hb_vmSend( 0 );
   iSize = hb_parni( -1 );

   hOldFont = ( HFONT ) SelectObject( hDC, oSelf->hFontHandle );
   GetTextExtentPoint32( hDC, "_", 1, &sz );
   SelectObject( hDC, hOldFont );
   ReleaseDC( info.hwndList, hDC );

   if( iSize < sz.cy + 2 )
   {
      iSize = sz.cy + 2;
   }

   hb_retni( iSize );
}

#pragma ENDDUMP


/*--------------------------------------------------------------------------------------------------------------------------------*/
CLASS TListCombo FROM TControl STATIC

   METHOD Define
   METHOD Events_VScroll
   METHOD FindString( c, n )      BLOCK { |Self, c, n| ListboxFindString( ::hWnd, n, c ) }
   METHOD FindStringExact( c, n)  BLOCK { |Self, c, n| ListboxFindStringExact( ::hWnd, n, c ) }

   ENDCLASS

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Define( ParentForm, hWnd ) CLASS TListCombo

   ::SetForm( , ParentForm )
   InitListCombo( hWnd )
   ::Register( hWnd )

   RETURN Self

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Events_VScroll( wParam ) CLASS TListCombo

   LOCAL Lo_wParam := LoWord( wParam ), nArea, bField, bValueSource, lNoEval, BackRec, nLoad, i, BackOrd := NIL

   IF Lo_wParam == SB_LINEDOWN
      IF ( nArea := Select( ::Container:WorkArea ) ) != 0
         // load one more item
         bField := ::Container:Field
         bValueSource := ::Container:ValueSource
         lNoEval := Empty( bValueSource )

         BackRec := ( nArea )->( Recno() )
         IF ValType( ::Container:SourceOrder ) == "B"
            BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::Container:SourceOrder ) ) ) )
         ELSEIF ValType( ::Container:SourceOrder ) $ "CMN"
            BackOrd := ( nArea )->( ordSetFocus( ::Container:SourceOrder ) )
         ENDIF

         ( nArea )->( dbGoto( ::Container:nLastItem ) )
         ( nArea )->( dbSkip() )
         If ! ( nArea )->( Eof() )
            ::Container:AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::Container:ItemNumber ) } )
            AAdd( ::Container:aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
            IF ValidHandler( ::Container:ImageList )
               ::Container:AddBitMap( Eval( ::Container:ImageSource ) )
            ENDIF

            ::Container:nLastItem := ( nArea )->( RecNo() )
         ENDIF

         IF BackOrd != NIL
            ( nArea )->( ordSetFocus( BackOrd ) )
         ENDIF
         ( nArea )->( dbGoto( BackRec ) )
      ENDIF
      RETURN NIL
   ELSEIF Lo_wParam == SB_PAGEDOWN .OR. Lo_wParam == SB_THUMBPOSITION
      IF ( nArea := Select( ::Container:WorkArea ) ) != 0
         // load one more page of items
         nLoad := ::Container:VisibleItems
         bField := ::Container:Field
         bValueSource := ::Container:ValueSource
         lNoEval := Empty( bValueSource )

         BackRec := ( nArea )->( RecNo() )
         IF ValType( ::Container:SourceOrder ) == "B"
            BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::Container:SourceOrder ) ) ) )
         ELSEIF ValType( ::Container:SourceOrder ) $ "CMN"
            BackOrd := ( nArea )->( ordSetFocus( ::Container:SourceOrder ) )
         ENDIF

         ( nArea )->( dbGoto( ::Container:nLastItem ) )
         ( nArea )->( dbSkip() )
         i := 0
         DO WHILE ! ( nArea )->( Eof() ) .AND. i < nLoad
            ::Container:AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::Container:ItemNumber ) } )
            AAdd( ::Container:aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
            IF ValidHandler( ::Container:ImageList )
               ::Container:AddBitMap( Eval( ::Container:ImageSource ) )
            ENDIF

            ::Container:nLastItem := ( nArea )->( RecNo() )
            ( nArea )->( dbSkip() )
            i ++
         ENDDO

         IF BackOrd != NIL
            ( nArea )->( ordSetFocus( BackOrd ) )
         ENDIF
         ( nArea )->( dbGoto( BackRec ) )
      ENDIF
      RETURN NIL
   ELSEIF Lo_wParam == SB_BOTTOM
      IF ( nArea := Select( ::Container:WorkArea ) ) != 0
         // load all remaining items
         bField := ::Container:Field
         bValueSource := ::Container:ValueSource
         lNoEval := Empty( bValueSource )

         BackRec := ( nArea )->( RecNo() )
         IF ValType( ::Container:SourceOrder ) == "B"
            BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::Container:SourceOrder ) ) ) )
         ELSEIF ValType( ::Container:SourceOrder ) $ "CMN"
            BackOrd := ( nArea )->( ordSetFocus( ::Container:SourceOrder ) )
         ENDIF

         ( nArea )->( dbGoto( ::Container:nLastItem ) )
         ( nArea )->( dbSkip() )
         DO WHILE ! ( nArea )->( Eof() )
            ::Container:AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::Container:ItemNumber ) } )
            AAdd( ::Container:aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
            IF ValidHandler( ::Container:ImageList )
               ::Container:AddBitMap( Eval( ::Container:ImageSource ) )
            ENDIF

            ::Container:nLastItem := ( nArea )->( RecNo() )
            ( nArea )->( dbSkip() )
         ENDDO

         IF BackOrd != NIL
            ( nArea )->( ordSetFocus( BackOrd ) )
         ENDIF
         ( nArea )->( dbGoto( BackRec ) )
      ENDIF
      RETURN NIL
   ELSEIF Lo_wParam == SB_THUMBTRACK
      IF ( nArea := Select( ::Container:WorkArea ) ) != 0
         bField := ::Container:Field
         bValueSource := ::Container:ValueSource
         lNoEval := Empty( bValueSource )

         BackRec := ( nArea )->( RecNo() )
         IF ValType( ::Container:SourceOrder ) == "B"
            BackOrd := ( nArea )->( ordSetFocus( ( nArea )->( Eval( ::Container:SourceOrder ) ) ) )
         ELSEIF ValType( ::Container:SourceOrder ) $ "CMN"
            BackOrd := ( nArea )->( ordSetFocus( ::Container:SourceOrder ) )
         ENDIF

         ( nArea )->( dbGoto( ::Container:nLastItem ) )
         ( nArea )->( dbSkip() )
         i := 0
         DO WHILE ! ( nArea )->( Eof() ) .AND. i < 3
            ::Container:AddItem( { ( nArea )->( Eval( bField ) ), _OOHG_Eval( ::Container:ItemNumber ) } )
            AAdd( ::Container:aValues, iif( lNoEval, ( nArea )->( RecNo() ), Eval( bValueSource ) ) )
            IF ValidHandler( ::Container:ImageList )
               ::Container:AddBitMap( Eval( ::Container:ImageSource ) )
            ENDIF

            ::Container:nLastItem := ( nArea )->( RecNo() )
            ( nArea )->( dbSkip() )
            i ++
         ENDDO

         IF BackOrd != NIL
            ( nArea )->( ordSetFocus( BackOrd ) )
         ENDIF
         ( nArea )->( dbGoto( BackRec ) )
         SetWindowPos( ::hWnd, 0, 0, 0, 0, 0, SWP_NOACTIVATE + SWP_FRAMECHANGED + SWP_NOSIZE + SWP_NOMOVE )
      ENDIF
      RETURN NIL
   ENDIF

   RETURN ::Super:Events_VScroll( wParam )


#pragma BEGINDUMP

/*--------------------------------------------------------------------------------------------------------------------------------*/
static WNDPROC _OOHG_TListCombo_lpfnOldWndProc( WNDPROC lp )
{
   static WNDPROC lpfnOldWndProc = 0;

   WaitForSingleObject( _OOHG_GlobalMutex(), INFINITE );
   if( ! lpfnOldWndProc )
   {
      lpfnOldWndProc = lp;
   }
   ReleaseMutex( _OOHG_GlobalMutex() );

   return lpfnOldWndProc;
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
static LRESULT APIENTRY SubClassFuncCL( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   return _OOHG_WndProcCtrl( hWnd, msg, wParam, lParam, _OOHG_TListCombo_lpfnOldWndProc( 0 ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( INITLISTCOMBO )          /* FUNCTION InitListCombo( hWnd ) -> NIL */
{
   _OOHG_TListCombo_lpfnOldWndProc( ( WNDPROC ) SetWindowLongPtr( HWNDparam( 1 ), GWL_WNDPROC, ( LONG_PTR ) SubClassFuncCL ) );
}

#pragma ENDDUMP


/*--------------------------------------------------------------------------------------------------------------------------------*/
CLASS TEditCombo FROM TControl STATIC

   DATA LastKey                   INIT 0
   DATA nMaxLength                INIT 0
   DATA Type                      INIT "EDITCOMBO"

   METHOD Define
   METHOD Events
   METHOD Events_Enter            BLOCK { |Self| ::Parent:Events_Enter() }
   METHOD MaxLength               SETGET
   METHOD Release

   ENDCLASS

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Define( Parent, hWnd ) CLASS TEditCombo

   ::Name   := _OOHG_GetNullName()
   ::Parent := Parent
   ::hWnd   := hWnd
   ::SethWnd( hWnd )

   ::AddToCtrlsArrays()

   InitEditCombo( hWnd )

   RETURN Self

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Events( hWnd, nMsg, wParam, lParam ) CLASS TEditCombo

   HB_SYMBOL_UNUSED( hWnd )
   HB_SYMBOL_UNUSED( lParam )

   IF nMsg == WM_KEYDOWN
      ::LastKey := wParam
   ENDIF

   RETURN NIL

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD MaxLength( nLen ) CLASS TEditCombo

   IF HB_ISNUMERIC( nLen )
      ::nMaxLength := iif( nLen >= 1, nLen, 0 )
      SendMessage( ::hWnd, EM_LIMITTEXT, ::nMaxLength, 0 )
   ENDIF

   RETURN SendMessage( ::hWnd, EM_GETLIMITTEXT, 0, 0 )

/*--------------------------------------------------------------------------------------------------------------------------------*/
METHOD Release() CLASS TEditCombo

   ::DelFromCtrlsArrays()

   RETURN NIL

#pragma BEGINDUMP

/*--------------------------------------------------------------------------------------------------------------------------------*/
static WNDPROC _OOHG_TEditCombo_lpfnOldWndProc( WNDPROC lp )
{
   static WNDPROC lpfnOldWndProc = 0;

   WaitForSingleObject( _OOHG_GlobalMutex(), INFINITE );
   if( ! lpfnOldWndProc )
   {
      lpfnOldWndProc = lp;
   }
   ReleaseMutex( _OOHG_GlobalMutex() );

   return lpfnOldWndProc;
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
static LRESULT APIENTRY SubClassFuncCE( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   return _OOHG_WndProcCtrl( hWnd, msg, wParam, lParam, _OOHG_TEditCombo_lpfnOldWndProc( 0 ) );
}

/*--------------------------------------------------------------------------------------------------------------------------------*/
HB_FUNC( INITEDITCOMBO )          /* FUNCTION InitEditCombo( hWnd ) -> NIL */
{
   _OOHG_TEditCombo_lpfnOldWndProc( ( WNDPROC ) SetWindowLongPtr( HWNDparam( 1 ), GWL_WNDPROC, ( LONG_PTR ) SubClassFuncCE ) );
}

#pragma ENDDUMP
