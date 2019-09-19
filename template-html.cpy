HTML  *> Displays a file.
----  *> 
TEMP  *> To be included as copyfile.
LATE  *>           
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
           FILE-CONTROL.
           SELECT Html ASSIGN TO "FILENAME"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
           FD Html.
               01 html-data.
                   02 html-line            PIC X(80)   VALUE SPACES.
       
       WORKING-STORAGE SECTION.
           01 EOF                          PIC X(1)    VALUE "N".
       LINKAGE SECTION.
       
       PROCEDURE DIVISION.

       OPEN INPUT Html
       READ Html END-READ
       PERFORM UNTIL EOF="Y"
           DISPLAY html-line
           READ Html AT END MOVE "Y" TO EOF END-READ

       END-PERFORM
       CLOSE Html

       GOBACK.
