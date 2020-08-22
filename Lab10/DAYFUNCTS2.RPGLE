000100200805        Ctl-Opt NoMain DatFmt(*USA);
000101200805
000102200805       /COPY LAB10INTRO,DAYPROTO
000103200805
000104200805       Dcl-Proc DayNumName EXPORT;
000105200805
000106200805       Dcl-Pi *n Char(9);
000107200805         Number Packed(1:0);
000108200805       END-PI;
000109200805
000110200805       Dcl-DS DayData;
000111200805             *n Char(9) Inz('Monday');
000112200805             *n Char(9) Inz('Tuesday');
000113200805             *n Char(9) Inz('Wednesday');
000114200805             *n Char(9) Inz('Thursday');
000115200805             *n Char(9) Inz('Friday');
000116200805             *n Char(9) Inz('Saturday');
000117200805             *n Char(9) Inz('Sunday');
000118200805
000119200805             DayArray Char(9) Dim(7) Pos(1);
000120200805
000121200805       END-DS;
000122200805
000123200805       Return DayArray(Number);
000124200805
000125200805       END-PROC;
