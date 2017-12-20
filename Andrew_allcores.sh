#!/bin/sh

squeue -o "%.8u %.2t %.6C" | awk '{if ($2=="R") t[$1]+=$3;} END {for (i in t) print i, t[i];}' | sort -k 2 -n
