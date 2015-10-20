/************************************************************************/
/**

   \file       chrootperl.c
   
   \version    V1.0
   \date       20.10.15
   \brief      Run Perl in a chroot jail
   
   \copyright  (c) UCL / Dr. Andrew C. R. Martin 2015
   \author     Dr. Andrew C. R. Martin
   \par
               Institute of Structural & Molecular Biology,
               University College London,
               Gower Street,
               London.
               WC1E 6BT.
   \par
               andrew.martin@ucl.ac.uk
               andrew@bioinf.org.uk
               
**************************************************************************

   This program is released under the GNU Public Licence V2.0 or above

**************************************************************************

   Description:
   ============

   This program must have SANDBOX defined with -D when compiled. 
   The executable must be owned by root and have the setuid bit set - 
   this is all done by the Makefile

**************************************************************************

   Usage:
   ======
   
   This program runs perl in a chroot sandbox. makesandbox.pl must be
   run first to create the sandbox and to install required binaries and
   libraries.

**************************************************************************

   Revision History:
   =================
-  V1.0  20.10.15 Original

*************************************************************************/
/* Includes
*/
#define _BSD_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <pwd.h>
#include <errno.h>
#include <sys/types.h>

/************************************************************************/
/* Defines and macros
*/
#define MAXBUFF 1024

#ifndef SANDBOX
#error "SANDBOX must be defined with -D during compilation!"
#endif

/************************************************************************/
/* Globals
*/

/************************************************************************/
/* Prototypes
*/
int main(int argc, char **argv, char **env);
int CheckCommandLine(int argc, char **argv);
void Usage(void);
void CopyPerlScript(char *script, char *sandbox);
int RunPerlScript(char *sandbox, int argc, char **argv, char **env);

/************************************************************************/
/*>int main(int argc, char **argv, char **env)
   --------------------------------------------
*//**
   Main program to be run Perl in a chroot sandbox environment

-  20.10.15 Original   By: ACRM
*/
int main(int argc, char **argv, char **env)
{
   /* Check the command line                                            */
   if(!CheckCommandLine(argc, argv))
   {
      Usage();
      return(0);
   }
   
#ifdef DEBUG
   fprintf(stderr,"SANDBOX: %s\n",   SANDBOX);
#endif

   /* Copy the Perl script into the sandbox                             */
   CopyPerlScript(argv[1], SANDBOX);
   RunPerlScript(SANDBOX, argc, argv, env);

   return(0);
}

/************************************************************************/
/*>void CopyPerlScript(char *script, char *sandbox)
   ------------------------------------------------
*//**
   \param[in]  script  The perl script to be run
   \param[in]  sandbox The sandbox directory

   Copies the perl script to the sandbox/run directory

-  20.10.15 Original   By: ACRM
*/
void CopyPerlScript(char *script, char *sandbox)
{
   char cmd[MAXBUFF];
   
   sprintf(cmd, "cp %s %s/run", script, sandbox);
   system(cmd);
}
   
/************************************************************************/
/*>void Usage(void)
   ----------------
*//**
   Prints a usage message

-  20.10.15 Original   By: ACRM
*/
void Usage(void)
{
   fprintf(stderr,"\nchrootperl V1.0 (c) 2015 UCL, Dr. Andrew \
C.R. Martin\n");
   fprintf(stderr,"\nUsage: chrootperl program.pl [arguments...]\n");

   fprintf(stderr,"\nRuns Perl in a chroot sandbox\n\n");
}


/************************************************************************/
/*>int CheckCommandLine(int argc, char **argv)
   -------------------------------------------
*//**
   \param[in]  argc   The argument count
   \param[in]  argv   The arguments
   \return            0: Error; 1: Success

-  20.10.15 Original   By: ACRM
*/
int CheckCommandLine(int argc, char **argv)
{
   if(argc < 2)
   {
      return(0);
   }
   else
   {
      int i;
      for(i=0; i<argc; i++)
      {
         if(!strcmp(argv[i], "-h"))
         {
            return(0);
         }
      }
   }
   return(1);
}

   
/************************************************************************/
/*>int RunPerlScript(char *sandbox, int argc, char **argv, char **env)
   -------------------------------------------------------------------
*//**
   \param[in]  sandbox   The sandbox directory
   \param[in]  argc      Argument count
   \param[in]  argv      Arguments
   \param[in]  env       Environment variables
   \return               Error code (0: OK)

   Runs a perl script in a chroot environment
   argv[0] (the name of this program) is replaced by 'perl'
   argv[1] (the name of the perl script) has '/run/' prepended to it
           (and any existing path stripped)

-  20.10.15 Original   By: ACRM
*/
int RunPerlScript(char *sandbox, int argc, char **argv, char **env)
{
   int retval = 0;
   const char *m;
   char cmd[MAXBUFF],
       *chp;

   /* Replace the chrootperl name with 'perl'                           */
   argv[0] = "perl";

   /* Strip the path from the perl script name if present               */
   if((chp=strrchr(argv[1], '/'))==NULL)
      chp = argv[1];
   else
      chp++;
   
   /* Replace the name of the perl script with the one in sandbox/run   */
   sprintf(cmd, "/run/%s", chp);
   argv[1] = cmd;

#ifdef DEBUG
   {
      int i;
      printf("ARGUMENTS: ");
      for(i=0; i<argc; i++)
      {
         printf("%s ", argv[i]);
      }
      printf("\n");
   }
#endif

   if((m="chdir" ,retval=chdir(sandbox)) == 0)
   {
      if((m="chroot",retval=chroot(sandbox)) == 0)
      {
         if((m="setuid",retval=setuid(getuid())) == 0) 
         {
            m="execve", execve("/bin/perl", argv, NULL); 
         }
      }
   }
   
   perror(m);
   return(retval);
}
