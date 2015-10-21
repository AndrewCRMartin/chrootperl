Examples
========

This directory contains some examples of how chrootperl might be used.

The `html` directory contains a simple web page and CGI script that
allows a user to write a Perl script via an HTML form and run that
script. This would normally have huge security implications
(e.g. `print ``cat /etc/passwd`` `), but here the Perl script is only
given access to the chroot directory. Providing the apache user does
not have delete permissions on the files in the sandbox, it's pretty
hard to do any harm. 

However, it is still recommended to clean up the Perl script to remove
potentially dangerous functions (e.g. system(), open(), backticks,
accept(), bind(), connect(), getpeername(), getsockname(),
getsockopt(), listen(), recv(), send(), setsockopt(), shutdown(),
socket(), socketpair(),msgctl(), msgget(), msgrcv(), msgsnd(),
semctl(), semget(), semop(), shmctl(), shmget(), shmread(),
shmwrite(), chdir(), chmod(), chroot(), detach(), endpwent(),
getpwent(), getpwnam(), getpwuid(), setpwent(), endgrent(),
getgrent(), getgrgid(), getgrnam(), setgrent(), emdnetent(),
getnetbyaddr(), getnetbyname(), getnetent(), setnetent(),
endhostent(), gethostbyaddr(), gethostbyname(), gethostent(),
sethostent(), endservent(), getservbyname(), getservbyport(),
getservent(), setservent(), endprotoent(), getprotobyname(),
getprotobynumber(), getprotoent(), setprotoent(), etc.

