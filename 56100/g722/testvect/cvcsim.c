/*********************************************************************/
/* FILE cvcsim.c : program to convert the hexa CCITT test sequence   */
/*                 in sim56116 file format                           */
/*********************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>

/* prototypes of functions */
/***************************/

int convertfichier(FILE *stream, short *wtab);
int cbin(char c);
getline(char *s,int lim, FILE *stream);


void main(int argc,char *argv[])


{
static short sqin[20000];		/* maximum size of G722 = 16384 */
int nin,i;
FILE *xin,*xout;


		if (argc != 3 ){
		printf("\n Incorrect number of parameters");
		printf("\n Use: CVCSIM fich.xxx SIMfich.xxx");
		printf("\n To convert a CCITT G722 hexa file in ADS Format");
                exit(1);
		}


		if ((xin=fopen(argv[1],"r"))==NULL){
		printf(" Cannot open file: %s\n",argv[1]);
		exit(1);
		}

		if ((xout=fopen(argv[2],"w"))==NULL){
		printf(" Cannot open file : %s\n",argv[2]);
		exit(1);
                }


             nin=convertfichier(xin,sqin);
	     printf("\n Number of received words %d \n",nin);

	     /* print the sim file: one word per ligne */
	     /******************************************/
	     for(i=0; i <nin;i++){
	     fprintf(xout,"%04x\n",sqin[i]);
	     }


	     printf("End of program: convert %s in %s\n",argv[1],argv[2]);
	     printf("**************\n ");

		  exit(0);
	}



/* read a line in input file */
/*****************************/

getline(char *s,int lim, FILE *stream)
{
	int i=0;
	char ch;

	for(i=0;i<lim && (ch=fgetc(stream))!=EOF && ch!='\n';++i)
	s[i]=ch;
	s[i]='\0';
	return(i);
}

/* convert a hexa in short */
/***************************/

int cbin(char c)
{
      return ( isdigit(c) ? c-'0':isupper(c) ? 10+c-'A':10+c-'a');
}


/* convert the file in a array of short integer */
/************************************************/

int convertfichier(FILE *stream, short *wtab)
{
short wtemp;
int nbshort,nbligne,i,j,k;
char s[81];
nbshort=nbligne=0;

    while( getline(s,80,stream) !=0){
	if (s[1] != '*') {  	 /* skip comment of CCITT */
	++nbligne;
	k= 16;                           /* for 16 short values   */

                     for(j=0,i=0;j<k;j++)
                        {
			wtemp=cbin(s[i++]) ;
			wtemp=cbin(s[i++]) | ( wtemp << 4);
			wtemp=cbin(s[i++]) | ( wtemp << 4);
                        wtemp=cbin(s[i++]) | ( wtemp << 4);
			wtab[nbshort]=wtemp;
			++nbshort;
                 	}

	   }
    }
	   return(nbshort);

}

