#!/bin/sh
# pulls all columns out of each file

if [ $# -eq 0 ]; then
   echo "usage: f2col3.sh [-w width] [-z] file1 file2 file3..."
   exit 1
fi

w=15
z=0
while [ $# -gt 1 ]; do
  if [ "$1" = "-w" ] && [ $# -gt 2 ]; then
    w=$2
    shift 2
  elif [ "$1" = "-z" ]; then
    z=1
    shift
  else
    break
  fi
done


awk -v w=$w -v z=$z 'BEGIN {
  nx = 0;
}
{
  if (FNR == 1) {
    cols[ARGIND]=NF;
  }
  unseen = 0;
  if (!($1 in rx)) {
    unseen = 1;
    for (ix=0; ix<nx; ix++) {
      if (x[ix]+0 != 0 && $1+0 != 0 && (x[ix]+0 == $1+0 || ((x[ix]-$1)^2/(x[ix]+$1)^2 < 1e-27))) {
        unseen=0;
        $1=x[ix];
        break;
      }
    }
  }
  if (unseen) {
    success = 0;
    rx[$1] = 1;
    for (ix=0; ix<nx; ix++) {
      if (x[ix] > $1) {
        for (jx=nx; jx>ix-1; jx--) {
          x[jx+1] = x[jx];
        }
        x[ix] = $1;
        success = 1;
        break;
      }
    }
    if (!success) {
      x[nx] = $1;
    }
    nx++;
  }
  for (i=2; i<NF+1; i+=1) {
    a[$1,ARGIND,i]=$i;
  }
}
END {
  fmt=sprintf ("%%%ds", w);
  for (ix=0; ix<nx; ix++) {
    printf(fmt, x[ix]);
    for (j=1; j<=ARGC; j++) { 
      for (k=2; k<=cols[j]; k++) {
        printf " ";
        if (z==1 && !((x[ix],j,k) in a)) {
          printf(fmt,0);
        }
        else {
          printf(fmt,a[x[ix],j,k]);
        }
      }
    }
    printf("\n")
  }  
}' ${1+"$@"}
