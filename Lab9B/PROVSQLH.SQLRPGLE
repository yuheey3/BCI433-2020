000100200729       //**************************************************************************
000200191105       //* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE FROM 3
000300191105       //* SEPARATE TABLES, ONTARIO, QUEBEC AND MANITOBA. A NUMBER IS PASSED
000400191105       //* TO THE PROGRAM TO DETERMINE WHICH RECORDS ARE INLCUDED FROM THE 3 TABLES
000500190313       //**************************************************************************
000600190313           DCL-F PROVREPORT PRINTER OFLIND(*IN01) ;
000700190313           DCL-S ProvinceH    Char(10);
000800190313           DCL-S EndOfFile    IND;
000900190313           DCL-S TotalRecords PACKED(5:0) ;
001000190315             // LowLimit is passed to the program
001100200729             Dcl-PI Main extPgm('PROVSQLH');
001101200729               LowLimitIn Packed(15:5);
001102200729               END-PI;
001103200729
001200190315
001300190315
001400190315             // All Host Variables available under a single name
001500200729             DCL-DS CustomerRecord;
001501200729             CustId    Char(6);
001502200729             FullName  Char(31);
001503200729             City      Char(20);
001504200729             Purchase  Packed(7:2);
001505200729             PDate     Date;
001506200729             Province  Char(10);
002100190315
002200190313        End-Ds CustomerRecord;
002300070123     C/EJECT
002400070123     C**************************************************************************
002500070123     C*                        ***   M A I N   R O U T I N E   ***
002600070123     C**************************************************************************
002700070118      /FREE
002701200729                LowLimit = LowLimitIn;
002800100309                EXSR PrepareFiles;
002900200709                Write ReportHdg;
003000200709                Write RColumns;
003100100309                EXSR GetRow;
003200190313                Write NewProv;
003300070209                ProvinceH = Province;
003400070202                DOW NOT EndOfFile;
003500190313                    IF *IN01 = *ON;
003600200729                        Write ReportHdg;
003700200709                        Write RColumns;
003800190313                       *IN01 = *OFF;
003900070209                    ENDIF;
004000190315                    // Province may change
004100200729                    If ProvinceH = Province;
004101200729                     Write Detail;
004102200729                    Else;
004103200729                      ProvinceH = Province;
004104200729                      Write Totals;
004105200729                      TotalPurch = 0;
004106200729                      Write NewProv;
004107200729                      Write Detail;
004108200729                    ENDIF;
004109200729
005200190313                    TotalPurch     = TotalPurch     + Purchase;
005300070202                    TotalRecords= TotalRecords + 1;
005400100309                    EXSR GetRow;
005500070119                ENDDO;
005600190313                Write Totals;
005700070202                EXSR   WRAPUP;
005800190313                Write UnderLimit;
005900070119                *INLR = *ON;
006000070119                RETURN;
006100100309        //**********************************************************************
006200100309        // O P E N F I L E S   S U B R O U T I N E
006300100309        //**********************************************************************
006400100309         BEGSR  PrepareFiles;
006500190315        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  STRUCTURE
006600200729            EXEC SQL
006601200729               DECLARE ALLPROVCURSOR CURSOR
006602200729                FOR
006603200729
006604200729                SELECT CustId, TRIM(FNAME) || ' ' || LNAME AS FullName,
006605200729                   City, Purchase, PDate,
006606200729                   'Ontario' as Province
006607200729                FROM BCI433LIB/ONTARIO
006608200729                WHERE Purchase > :LowLimit
006609200729                union all
006610200729                SELECT CustId, TRIM(FNAME) || ' ' || LNAME AS FullName,
006611200729                   City, Purchase, PDate,
006612200729                   'Quebec' as Province
006613200729                FROM BCI433LIB/QUEBEC
006614200729                WHERE Purchase > :LowLimit
006615200729                union all
006616200729                SELECT CustId, TRIM(FNAME) || ' ' || LNAME AS FullName,
006617200729                   City, Purchase, PDate,
006618200729                   'Manitoba' as Province
006619200729                FROM BCI433LIB/MANITOBA
006620200729                WHERE Purchase > :LowLimit
006621200729                  FOR READ ONLY;
006800190315
006900190315
008700190315
008800100309        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
008900100309
009000200729        EXEC SQL
009001200729             OPEN ALLPROVCURSOR;
009002200729
009003200729             If (SQLCODE <> 0) OR (SQLWN0 = 'W');
009004200729               EndOfFile = *ON;
009005200729             ENDIF;
009006200729
009400190315
009500190315
009600100309            ENDSR;
009700100309        //**********************************************************************
009800100309        //   G E T     R O W    S U B R O U T I N E
009900100309        //**********************************************************************
010000100309            BEGSR     GETROW;
010001200729               EXEC SQL
010100200729               FETCH NEXT
010102200729               FROM ALLPROVCURSOR
010103200729               INTO :CustomerRecord;
010104200729
010105200729                If (SQLCODE <> 0) OR (SQLWN0 = 'W');
010106200729                   EndOfFile = *ON;
010107200729                 ENDIF;
010108200729
010200190315
011000190315
011100100309             ENDSR;
011200100309        //**********************************************************************
011300100309        // W R A P U P     S U B R O U T I N E
011400100309        //**********************************************************************
011500100309           BEGSR WRAPUP;
011502200729             EXEC  SQL
011503200729              CLOSE ALLPROVCURSOR;
011504200729
011505200729             If SQLCODE <> 0 OR SQLWN0 = 'W';
011506200729               EndOfFile = *ON;
011507200729             ENDIF;
011508200729
011509200729             EXEC SQL
011510200729               SELECT COUNT(*) INTO :ONTTOTAL
011511200729                 FROM BCI433LIB/ONTARIO
011512200729                   WHERE Purchase <= :LowLimit;
011513200729
011514200729             EXEC SQL
011515200729               SELECT COUNT(*) INTO :QUETOTAL
011516200729                 FROM BCI433LIB/QUEBEC
011517200729                   WHERE Purchase <= :LowLimit;
011518200729
011519200729             EXEC SQL
011520200729               SELECT COUNT(*) INTO :MANTOTAL
011521200729                 FROM BCI433LIB/MANITOBA
011522200729                   WHERE Purchase <= :LowLimit;
011523200729
011524200729
011600100309          ENDSR;
011751190315
011800190315
011900190315
012000190315
012100190315
012200190315
