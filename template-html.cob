       >> SOURCE FORMAT IS FIXED
      *> Subprogram for printing the HTML files.

       IDENTIFICATION DIVISION.
       PROGRAM-ID. HTMLSTART.
       COPY "template-html.cpy" REPLACING 
           =="FILENAME"== BY =="template-0.html"==.
       
       END PROGRAM HTMLSTART.


       IDENTIFICATION DIVISION.
       PROGRAM-ID. HTMLSTOP.
       COPY "template-html.cpy" REPLACING 
           =="FILENAME"== BY =="template-1.html"==.
       
       END PROGRAM HTMLSTOP.
