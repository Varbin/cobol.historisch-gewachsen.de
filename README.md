# `historisch-gewachsen.de` - COBOL edition

`historisch-gewachsen.de` (German for "historically grown") is website listing reasons for historically grown projects.
In contrast to the main edition, running on Python, this implementation is written in COBOL and has an exclusive set of quotes.

```
$ ./historisch-gewachsen
=== REPORT OF cobol.historisch-gewachsen.de ===                                 
Date:       2019-09-19                                                          
Web-CGI:    N                                                                   
                                                                                
-- PROBLEM                                                                      
Project has historically grown, it is still written in COBOL.                   
                                                                                
-- REASON                                                                       
#004                                                                            
Did you know it's possible to write websites in COBOL?                          
```

How to build:
 - Install GnuCOBOL on your system
    - On older systems it might be called openCOBOL.
 - Run `make` to compile.
 - The executable is `historisch-gewachsen`.

A copy of the executable will be place in `cgi-bin`, together with the `quotes_cobol.txt` and HTML templates.

## CGI detection

The program detects beeing run from a Webserver with the *Common Gateway Interface*.
The detection happens by checking for the enviroment variable `REQUEST_METHOD`. 
If it exists, the script puts HTTP headers and HTML around its output.

## FAQ
### Is it possible to run it on a mainframe?
Maybe. The source code should conform to the IBM-COBOL standard,
but calls the UNIX C library function `getenv(*char)` to detect CGI.
Thus it might run in the UNIX subsystem of z/OS or System/390.

### Why COBOL?
For fun. COBOL isn't actually that bad. Also ["COBOL is the language of the future"](https://share.confex.com/share/120/webprogram/Handout/Session12334/S12334TR.pdf)!