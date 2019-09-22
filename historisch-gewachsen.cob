       >> SOURCE FORMAT IS FIXED
      
HISTO *> COBOL edition of historisch-gewachsen.de
RICAL *>
LY    *> Usage:
      *>   - Use as a CGI binary
GROWN *>   - Directly run from command line

       IDENTIFICATION DIVISION.
       PROGRAM-ID. historisch-gewachsen.
       AUTHOR. Simon Biewald.
       INSTALLATION. "The cloud".
       DATE-WRITTEN. 16/09/2019.
       SECURITY. NON-CONFIDENTIAL.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
           SOURCE-COMPUTER. Thinkpad-T480.
           SPECIAL-NAMES.

       INPUT-OUTPUT SECTION.
           FILE-CONTROL.
           SELECT QuoteDb ASSIGN TO "quotes_cobol.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

DATA   DATA DIVISION.
       FILE SECTION.
           FD QuoteDb.
           01 QuoteDetails.
               02  quote-line          PIC X(80).

       WORKING-STORAGE SECTION.
           01 NEWLINE                  PIC X       VALUE x"0a".

      *>   Get request type.
           01 request-method           PIC X(5)    VALUE "GET".
           01 request-method-var       PIC X(20) 
               VALUE Z"REQUEST_METHOD".

           01 request-invalid          PIC X.
               88 invalid-method                   VALUE HIGH-VALUES.
      *>   Note: The final result is stored in the LINKAGE SECTION.

      *>   To remove spaces of output string
           01 trailing-spaces          PIC 9(2).

      *>   Current line in file.
           01 line-count               PIC 9(3)    VALUE 0.

      *>   The line to print (0-indexed)
           01 chosen-line              PIC 999.
           01 chosen-line-repr         PIC **9.

      *>   Check for EOF when determining lines in quotes file.
           01 file-status              PIC X.
               88 file-eof                         VALUE HIGH-VALUES.

      *>   struct timeval of sys/time.h
           01 timestamp-struct.
               02 timestamp-seconds        PIC X(4)    COMP-5.
               02 timestamp-microseconds   PIC X(4)    COMP-5.

           01 cgi-status               PIC X(1)    VALUE "N".
               88 cgi-enabled                      VALUE "Y".
               88 cgi-disabled                     VALUE "N".

           01 current-date-data.
               02 current-date.
                   03 current-year         PIC 9(4).
                   03 current-month        PIC 9(2).
                   03 current-day          PIC 9(2).
               02 current-time.
                   03 current-hours        PIC 9(2).
                   03 current-minute       PIC 9(2).
                   03 current-seconds      PIC 9(2).
                   03 current-milliseconds PIC 9(2).

           01 data-rng-seed            PIC 9(18).

           01 today-formatted.
               02  formatted-year      PIC 9(4).
               02  filler              PIC X(1)    VALUE "-".
               02  formatted-month     PIC 9(2).
               02  filler              PIC X(1)    VALUE "-".
               02  formatted-day       PIC 9(2).
               
           01 display-row              PIC x(80).

CODE   PROCEDURE DIVISION.
       DECLARATIVES.
       END DECLARATIVES.

       MAIN-LINE SECTION.
           PERFORM SETUP-TIME
           PERFORM CGI-CHECK
           PERFORM GET-QUOTE

           IF cgi-enabled
               CALL "HTMLSTART" END-CALL
           END-IF
           
           MOVE "=== REPORT OF cobol.historisch-gewachsen.de ===" TO 
               display-row
           DISPLAY display-row

           MOVE " " TO display-row
           STRING
               "Date:       " today-formatted
               INTO display-row
           END-STRING
           DISPLAY display-row

           MOVE " " TO display-row
           STRING
               "Web-CGI:    " cgi-status
               INTO display-row
           END-STRING
           DISPLAY display-row

           MOVE " " TO display-row
           DISPLAY display-row

           MOVE "-- PROBLEM" TO display-row
           DISPLAY display-row
           STRING 
               "Project has historically grown, " 
               "it is still written in COBOL."
               INTO  display-row
           END-STRING
           DISPLAY display-row

           MOVE " " TO display-row
           DISPLAY display-row

           MOVE "-- REASON" TO display-row
           DISPLAY display-row
           MOVE " " TO display-row
           STRING
               "#" chosen-line 
               INTO display-row END-STRING
           display display-row

           DISPLAY quote-line(1:(80 - trailing-spaces))

           MOVE " " TO display-row
           DISPLAY display-row

           IF cgi-enabled
               CALL "HTMLSTOP" END-CALL
           END-IF

           STOP RUN.

       CGI-CHECK SECTION.
           CALL "CGIHEADER" USING
      *>       cgi-status         
               by reference cgi-status
      *>       restrict-request-methods (to GET/HEAD only)
               "Y"
      *>       content-type
               by content "text/html; charset=us-ascii   "
      *>       request-method
               by reference request-method
           END-CALL
       
           IF cgi-enabled THEN
               DISPLAY "Via: COBOL" NEWLINE
               IF request-method = "HEAD" THEN
                   GOBACK
               END-IF
           END-IF
           .
    
       GET-QUOTE SECTION.
      *>   Get Linecount
           OPEN INPUT QuoteDb
           PERFORM UNTIL file-eof
               ADD 1 TO line-count END-ADD
    
               READ QuoteDb
                   AT END SET file-eof TO TRUE
               END-READ
           END-PERFORM
           CLOSE QuoteDb
    
      *>   Get 'random' quote number.
           COMPUTE
               chosen-line =
                   (line-count - 1) * FUNCTION RANDOM(data-rng-seed)
           END-COMPUTE
           MOVE chosen-line TO chosen-line-repr.
    
           SET line-count TO 0
    
      *>   Read correct quote.
           OPEN INPUT QuoteDb
           PERFORM UNTIL line-count = (chosen-line + 1)
               READ QuoteDb END-READ
               ADD 1 TO line-count END-ADD
           END-PERFORM
           CLOSE QuoteDb
           .

       SETUP-TIME SECTION.
              MOVE FUNCTION CURRENT-DATE TO current-date-data
              MOVE current-date-data TO data-rng-seed
              MOVE current-year TO formatted-year
              MOVE current-month TO formatted-month
              MOVE current-day TO formatted-day
       .

       END PROGRAM historisch-gewachsen.

      *> CGI "header" function 
