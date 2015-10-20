/************************************************************************/
/**

   \file       rebuildwebsite.c
   
   \version    V1.1
   \date       17.01.15
   \brief      Rebuild the website as the abysis user
   
   \copyright  (c) UCL / Dr. Andrew C. R. Martin 2015
   \author     Dr. Andrew C. R. Martin
   \par
               Institute of Structural & Molecular Biology,
               University College,
               Gower Street,
               London.
               WC1E 6BT.
   \par
               andrew.martin@ucl.ac.uk
               andrew@bioinf.org.uk
               
**************************************************************************

   This program is not in the public domain. All rights reserved.

**************************************************************************

   Description:
   ============

   This program must have ABYSIS_WWWPATH and ABYSIS_OWNER defined with
   -D when compiled. The executable must be owned by root and have the 
   setuid bit set - this is all done by the Makefile

**************************************************************************

   Usage:
   ======

**************************************************************************

   Revision History:
   =================
-  V1.0  14.01.15 Original
-  V1.1  17.01.15 Changed to using -D rather than sed to substitute 
                  variables. Merged in Gary's changes and corrected and 
                  modified for clean compile

*************************************************************************/
/* Includes
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <pwd.h>
#include <sys/types.h>
#include <errno.h>

/************************************************************************/
/* Defines and macros
*/
#define MAXBUFF 1024

#ifndef ABYSIS_OWNER
#error "ABYSIS_OWNER must be defined with -D during compilation!"
#endif
#ifndef ABYSIS_WWWPATH
#error "ABYSIS_WWWPATH must be defined with -D during compilation!"
#endif

#define ERR_CMDLINE       1
#define ERR_NOFILE        2
#define ERR_SYNTAX        3
#define ERR_EXEC          4
#define ERR_CHDIR         5
#define ERR_USER          6
#define ERR_NOPARAM       7
#define ERR_NOROOT        8
#define ERR_NOWEBUSER     9
#define ERR_NOABYSISUSER 10

/************************************************************************/
/* Globals
*/

/************************************************************************/
/* Prototypes
*/
int main(int argc, char **argv);
void Usage(void);
int syserror(char *mesg, int retval);

/************************************************************************/
/*>int main(int argc, char **argv)
   -------------------------------
*//**

   Main program to be run as the web (Apache) user to rebuild the 
   web site using the build.sh script

-  14.01.15 Original   By: ACRM
*/
int main(int argc, char **argv)
{
   struct passwd *pwd;
   uid_t  abysisOwnerUid;
   int    err = 0;
   char   cmd[MAXBUFF];

   /* Check the command line                                            */
   if(argc != 1)
   {
      Usage();
      return(ERR_CMDLINE);
   }

#ifdef DEBUG
   fprintf(stderr,"ABYSIS_OWNER: %s\n",   ABYSIS_OWNER);
   fprintf(stderr,"ABYSIS_WWWPATH: %s\n", ABYSIS_WWWPATH);
#endif

   /* Find the UID for the abysisOwner                                  */
   if((pwd = getpwnam(ABYSIS_OWNER))==NULL)
   {
      fprintf(stderr,"User '%s' does not exist in passwd file\n", 
              ABYSIS_OWNER);
      return(ERR_NOABYSISUSER);
   }
   abysisOwnerUid = pwd->pw_uid;
   /* Change user to abYsis owner                                       */
   if (setuid(abysisOwnerUid) != 0)
      return(syserror("Couldn't drop to non-root (ABYSIS_OWNER) \
privileges\n", ERR_USER));

   /* Change to the web directory                                       */
   if(chdir(ABYSIS_WWWPATH))
      return(syserror("Couldn't change to abysis WWW directory\n",
                      ERR_CHDIR));

   /* Run the build.sh script                                           */
   sprintf(cmd, "%s/build.sh", ABYSIS_WWWPATH);
#ifdef DEBUG
   fprintf(stderr, "%s\n", cmd);
#endif

   if((err=execl(cmd, "build.sh", NULL)) != 0)
      if((err=execl("/bin/bash", "bash", cmd, NULL)) != 0)
         if((err=execl("/bin/bash", cmd, NULL)) != 0)
            return(syserror("exec of build.sh failed\n", err));

   return(0);
}


/************************************************************************/
/*>void Usage(void)
   ----------------
*//**

   Prints a usage message

-  14.01.15 Original   By: ACRM
-  17.01.15 V1.1
*/
void Usage(void)
{
   fprintf(stderr,"\nrebuildwebsite V1.1 (c) 2015 UCL, Dr. Andrew \
C.R. Martin\n");
   fprintf(stderr,"\nUsage: rebuildwebsite\n");

   fprintf(stderr,"\nRebuilds the abYsis web site. This program must be \
owned by root and\n");
   fprintf(stderr,"have the setuid bit set\n\n");
}


/************************************************************************/
/*>int syserror(char *mesg, int retval)
   ------------------------------------
*//**

   \param[in]   *mesg   Message string
   \param[in]   retval  Return value to be returned by this function
   \return              Value passed in as retval

   This prints an error message and also runs perror() to print a system
   error message if there is one. Resets errno to zero afterwards.

-  14.01.15 Original   By: ACRM
*/
int syserror(char *mesg, int retval)
{
   fprintf(stderr, "rebuildwebsite (error): %s", mesg);
   if(errno) perror(NULL);
   errno = 0;
   return(retval);
}
