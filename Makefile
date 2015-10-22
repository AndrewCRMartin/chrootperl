DEST=/usr/local/bin
CC=gcc
COPTS=-ansi -pedantic -Wall
#COPTS=-ansi -pedantic -Wall -DDEBUG -g

# Check that SANDBOX environment variables is set
CHECKSB=X$(SANDBOX)
ifeq ($(CHECKSB),X) 
$(error Run with 'make SANDBOX=$$SANDBOX' or 'source ./chrootperl.cfg; make' ***)
endif

all : chrootperl

chrootperl : chrootperl.c
	$(CC) $(COPTS) -DSANDBOX=\"$(SANDBOX)\" -o $@ $<
	sudo chown root $@
	sudo chmod u+s $@

clean :
	\rm -f chrootperl

distclean : clean



install :
	sudo \cp -v chrootperl $(DEST)
	sudo chown root $(DEST)/chrootperl
	sudo chmod u+s  $(DEST)/chrootperl
