       >> SOURCE FORMAT IS FIXED
CGI   *> Automatically adds the status code and content type.
INIT  *> It will reject all POST requests.
      *>
      *> This method is not portable to non-unix machines,
      *> as it will call "getenv".
      *>
      *> Source: 
      *> Enterprise COBOL for z/OS version 4.2 Programming Guide,
      *> chapter 23:
      *>  "Example: setting and accessing environment variables" 
       IDENTIFICATION DIVISION.
       PROGRAM-ID.    CGIHEADER.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
           01 NEWLINE                  PIC X       VALUE x"0a".

           01 request-method-ptr       POINTER.
           01 request-method-length    PIC 9(5)    VALUE 0.

       LINKAGE SECTION.
           01 restrict-methods         PIC X(1).
           01 cgi-status               PIC X(1).
           01 content-type             PIC X(30).
           01 request-method           PIC X(5).

      *>   Just a variable one can set the memory address of.
      *>   You can only change the addresse for vars in the
      *>   linkage section, thus it is placed here.
           01 temp-method-var          PIC X(5).

       PROCEDURE DIVISION USING 
           cgi-status restrict-methods content-type request-method.
    
       CGIHEADER.
       
      *>   Get HTTP request type.
      *>   It will only be set, if running as CGI.
       CALL "getenv" USING
           by reference    Z"REQUEST_METHOD"
           returning       request-method-ptr
       END-CALL

      *>   If we got a NULL pointer, this is not running as CGI script. 
       IF request-method-ptr = NULL THEN
           MOVE "N" TO cgi-status
           GOBACK
       END-IF
       MOVE "Y" TO cgi-status
       
      *>   Resolve pointer and get request method. 
       SET ADDRESS OF temp-method-var TO request-method-ptr

      *>   length to C's null termination 
       INSPECT temp-method-var TALLYING request-method-length FOR
           CHARACTERS BEFORE INITIAL x"00"

       MOVE FUNCTION UPPER-CASE( 
               temp-method-var(1:request-method-length)
           ) TO request-method

      *>   Set status 405 if  
       IF restrict-methods = "Y" AND 
               request-method NOT = "GET" AND 
               request-method NOT = "HEAD" THEN
           
           DISPLAY "Status: 405 METHOD NOT ALLOWED"
           DISPLAY "Content-Type: text/plain; charset=us-ascii" NEWLINE
           DISPLAY "INVALID REQUEST METHOD:" SPACE request-method
           STOP RUN
       END-IF
       
       DISPLAY "Content-Type:" SPACE content-type
       GOBACK
       .
        
       END PROGRAM CGIHEADER.
