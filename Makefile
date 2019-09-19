# Compiler
COBC ?= "cobc"
# Cobol standard
COBSTD ?= "ibm-strict"
# Compileflags
FLAGS = -O2 -W -std=$(COBSTD)

CGI-DIR = cgi-bin
CGI-DATA = quotes_cobol.txt template-0.html template-1.html
PROGRAM = historisch-gewachsen
SOURCES = $(PROGRAM).cob cgi.cob template-html.cob

# Additional files in compilation.
ALL		= $(SOURCES) template-html.cpy

default: $(PROGRAM) cgi

$(PROGRAM): $(ALL) Makefile
	$(COBC) -x $(SOURCES) $(FLAGS) ${COBCFLAGS}

cgi: $(PROGRAM) $(CGI-DATA)
	cp $(CGI-DATA) "$(CGI-DIR)/"
	cp $(PROGRAM) "$(CGI-DIR)/historisch-gewachsen.cgi"

clean:
	rm -f *.[s]o
	rm -f *.c
	rm -f cgi-bin/*
	rm -f historisch-gewachsen

.PHONY: clean default