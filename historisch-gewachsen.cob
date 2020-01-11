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

      *>   Current line in file.
           01 line-count               PIC 9(3)    VALUE 0.

      *>   The line to print (0-indexed)
           01 chosen-line              PIC 999.

      *>   Check for EOF when determining lines in quotes file.
           01 file-status              PIC X.
               88 file-eof                         VALUE HIGH-VALUES.

      *>   Wether the program runs as CGI or not.
           01 cgi-status               PIC X(1)    VALUE "N".
               88 cgi-enabled                      VALUE "Y".
               88 cgi-disabled                     VALUE "N".

      *>   Structure for CURRENT-DATE
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

      *>   Numeric variable for RNG seed, based on the current date
           01 data-rng-seed            PIC 9(16).

      *>   Format date in ISO format
           01 today-formatted.
               02  formatted-year      PIC 9(4).
               02  filler              PIC X(1)    VALUE "-".
               02  formatted-month     PIC 9(2).
               02  filler              PIC X(1)    VALUE "-".
               02  formatted-day       PIC 9(2).

      *>   Temporary variable to output
           01 display-row              PIC x(80).

CODE   PROCEDURE DIVISION.

       0000-MAIN SECTION.
           PERFORM 1000-SETUP-TIME
           PERFORM 2000-CGI-CHECK
           PERFORM 3000-GET-QUOTE

           IF cgi-enabled
               CALL "HTMLSTART" END-CALL
           END-IF

           PERFORM 4000-DISPLAY-OUTPUT.

           IF cgi-enabled
               CALL "HTMLSTOP" END-CALL
           END-IF

           STOP RUN.

       *> Fill 'current-date-data' with the current date and time,
       *> set the RNG seed and fill 'today-formatted' with today's date.
       *>
       *> CALLED BY: 0000-MAIN.
       1000-SETUP-TIME SECTION.
              MOVE FUNCTION CURRENT-DATE   TO current-date-data
              MOVE current-date-data       TO data-rng-seed
              MOVE current-year            TO formatted-year
              MOVE current-month           TO formatted-month
              MOVE current-day             TO formatted-day
       .

      *> Check if the program runs as CGI and print HTTP headers
      *> if it does.
      *> 
      *> CALLED BY: 0000-MAIN.
       2000-CGI-CHECK SECTION.
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
               DISPLAY "X-Powered-By: COBOL" NEWLINE
               IF request-method = "HEAD" THEN
                   GOBACK
               END-IF
           END-IF
       .
    
      *> Seek the 'QuoteDb' to a random line,
      *> making 'quote-line' a random quote.
      *> 
      *> CALLED BY: 0000-MAIN.
       3000-GET-QUOTE SECTION.
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
    
           SET line-count TO 0
    
      *>   Read correct quote.
           OPEN INPUT QuoteDb
           PERFORM UNTIL line-count = (chosen-line + 1)
               READ QuoteDb END-READ
               ADD 1 TO line-count END-ADD
           END-PERFORM
           CLOSE QuoteDb
       .

      *> 4000-DISPLAY-OUTPUT
      *> Displays some text, the current date and the chosen quote.
      *> All output has a fixed width of 80 characters.
      *>
      *> CALLED BY: 0000-MAIN.
      *> CALLS: CLEAR-ROW.
       4000-DISPLAY-OUTPUT SECTION.
           MOVE "=== REPORT OF cobol.historisch-gewachsen.de ===" 
                               TO display-row
           DISPLAY display-row  

           PERFORM CLEAR-ROW
           STRING
               "Date:       " today-formatted
                               INTO display-row
           END-STRING
           DISPLAY display-row

           PERFORM CLEAR-ROW
           STRING
               "Web-CGI:    " cgi-status
                               INTO display-row
           END-STRING
           DISPLAY display-row

           PERFORM CLEAR-ROW
           DISPLAY display-row

           MOVE "-- PROBLEM"   TO display-row
           DISPLAY display-row

           STRING 
               "Project has historically grown, " 
               "it is still written in COBOL."
                               INTO  display-row
           END-STRING
           DISPLAY display-row

           PERFORM CLEAR-ROW
           DISPLAY display-row

           MOVE "-- REASON"    TO display-row
           DISPLAY display-row

           PERFORM CLEAR-ROW
           STRING
               "#" chosen-line 
                               INTO display-row 
           END-STRING
           DISPLAY display-row

      *>   Finally print the quote, prepared by '3000-GET-QUOTE'
           DISPLAY quote-line

      *>   Empty line with an 80 character width 
           PERFORM CLEAR-ROW
           DISPLAY display-row
       .

      *> Clear 'display-row' with spaces.
      *>
      *> CALLED BY: 4000-DISPLAY-OUTPUT
       CLEAR-ROW.
           MOVE " "    TO display-row
       .
            

       END PROGRAM historisch-gewachsen.

      *> CGI "header" function 
