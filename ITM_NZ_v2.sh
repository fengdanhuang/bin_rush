#!/bin/bash
#Purpose: preprocess the ITM input file, convert it to a two-column file, (name int, value int)
inputFile=$1
genoFile="Geno_Value_"${inputFile%.*}".dat" #get the string at left side of .
phenoFile="Pheno_Value_"${inputFile%.*}".dat" 
#echo $genoFile  #Test whether get the right string
#echo $phenoFile
genoTable=${genoFile%.*} #still get the string at the left side of "."
phenoTable=${phenoFile%.*}
#echo $genoTable
#echo $phenoTable

case $2 in
	1)	#get the maximum permission for current directory.
		chmod 777 .
		#Convert the input data file to a two-column output file Geno_Vaue.dat and Pheno_Value.dat
		echo "Generate two-column file $genoFile from $inputFile."
		awk '{len=split($0, a, " "); for(i=1;i<len;i++){print FNR "\t" i "\t" a[i]}}' $inputFile > $genoFile
		echo "Generate two-column file $phenoFile from $inputFile."
		awk '{len=split($0, a, " "); print FNR "\t" len "\t" a[len]}' $inputFile > $phenoFile
		echo

		#create table for Geno data and Pheno data
		echo "Create a table $genoTable for Genotype data."
		nzsql -c "create table $genoTable (S int, G int, V int)" -time
		echo "Create a table $phenoTable for Phenotype data."
		nzsql -c "create table $phenoTable (S int, P int, V int)" -time
		echo

		#load the input data into the table
		echo "Load input file $genoFile into the table $genoTable."
		nzload -t $genoTable -df $genoFile
		echo "Load input file $phenoFile into the table $phenoTable."
		nzload -t $phenoTable -df $phenoFile
		echo;;

	2)	#start test
		#nzsql arguments:
		#-c: run a single query 
		#-t: print rows only
		#-F: set field seperator, here set as " "(space)
		#-time: print time taken by queries
		#-o: send query output to file
		echo -e "\n*************Start***************\n"
		echo "**********Test:  PHENO_MEAN(PHENOTYPE)*****************" 
		nzsql -c "select pheno_mean(V) as pheno_mean from $phenoTable" -time
		echo -e "*******************************************************\n "

		echo "**********Test:  PHENO_VARIANCE(PHENOTYPE)*************"
		nzsql -c "select pheno_variance(V) as pheno_variance from $phenoTable" -time
		echo -e "*******************************************************\n "

		echo "**********Test:  ENTROPY_PHENOTYPE(PHENOTYPE P)********"
		nzsql -c "select pheno_entropy(V) as entropy_phenotype from $phenoTable" -time
		echo -e "*******************************************************\n "

		#echo "**********Test:  COMB_MEAN(COMBINATION C)**************"
		#nzsql -c "select comb_mean(A.V) as mean_1, comb_mean(B.V) as mean_2, comb_mean(C.V) as mean_3 \
		#          from $genoTable as A, $genoTable as B, $genoTable as C \
   	 	# 	  where A.G=1 and B.G=2 and C.G=3" -time 
		#	  echo -e "*******************************************************\n "
:<<BLOCK	
		echo "***********Test:  COMB_MEAN(COMBINATION C)**************"
		nzsql -c "select comb_mean(A.V) as mean \
			  from $genoTable as A \
			  where A.G=1" -time
			  echo -e "*******************************************************\n "

		echo "**********Test:  COMB_MEAN_COMB_2(COMBINATION C)**************"
		nzsql -c "select comb_mean_comb_2(A.V, B.V) as mean \
		          from $genoTable as A, $genoTable as B \
   	 	 	  where A.G=1 and B.G=2" -time 
			  echo -e "*******************************************************\n "

		echo "**********Test:  COMB_MEAN_COMB_3(COMBINATION C)**************"
		nzsql -c "select comb_mean_comb_3(A.V, B.V, C.V) as mean \
		          from $genoTable as A, $genoTable as B, $genoTable as C \
   	 	 	  where A.G=1 and B.G=2 and C.G=3" -time 
			  echo -e "*******************************************************\n "

		#echo "**********Test:  COMB_VARIANCE(COMBINATION C)*********"
		#nzsql -c "select comb_variance(A.V) as variance_1, comb_variance(B.V) as variance_2, comb_variance(C.V) as variance_3 \
		#          from $genoTable as A, $genoTable as B, $genoTable as C \
 		#	  where A.G=1 and B.G=2 and C.G=3" -time
		#echo -e "*******************************************************\n "

		echo "**********Test:  COMB_VARIANCE(COMBINATION C)*********"
		nzsql -c "select comb_variance(A.V) as variance_1 \
		          from $genoTable as A \
 			  where A.G=1" -time
		echo -e "*******************************************************\n "

		echo "**********Test:  COMB_VARIANCE_COMB_2(COMBINATION C)*********"
		nzsql -c "select comb_variance_comb_2(A.V,B.V) as variance_2 \
		          from $genoTable as A, $genoTable as B \
 			  where A.G=1 and B.G=2" -time
		echo -e "*******************************************************\n "
		
		echo "**********Test:  COMB_VARIANCE_COMB_3(COMBINATION C)*********"
		nzsql -c "select comb_variance_comb_3(A.V,B.V,C.V) as variance_3 \
		          from $genoTable as A, $genoTable as B, $genoTable as C \
 			  where A.G=1 and B.G=2 and C.G=3" -time
		echo -e "*******************************************************\n "
BLOCK
		echo "**********Test:  ENTROPY_DISCRETE_COMB_2(COMBINATION C)******"
		nzsql -c "select entropy_discrete_comb_2(A.V, B.V) as entropy_discrete_comb_2 from $genoTable as A, $genoTable as B \
		          where A.G=1 and B.G=3 and A.S=B.S" -time
		echo -e "*******************************************************\n "

		echo "**********Test:  ENTROPY_DISCRETE_COMB_3(COMBINATION C)******"
		nzsql -c "select entropy_discrete_comb_3(A.V, B.V, C.V) as entropy_discrete_comb_3 from $genoTable as A, $genoTable as B, $genoTable as C \
			  where A.G=1 and B.G=2 and C.G=3 and A.S=B.S and A.S=C.S" -time
		echo -e "*******************************************************\n "

	        echo "**********Test:  PAI_COMB_2(COMBINATION C)******"
		nzsql -c "select pai_comb_2(A.V, B.V) as pai_comb_2 from $genoTable as A, $phenoTable as B \
			  where A.G=1 and A.S=B.S" -time
		echo -e "*******************************************************\n "

		echo "**********Test:  PAI_COMB_3(COMBINATION C)******"
		nzsql -c "select pai_comb_3(A.V, B.V, C.V) as pai_comb_3 from $genoTable as A, $genoTable as B, $phenoTable as C \
		          where A.G=1 and B.G=2 and A.S=B.S and B.S=C.S" -time
		echo -e "*******************************************************\n "

		echo "**********Test:  KWII_COMB_2(COMBINATION C)******"
		nzsql -c "select kwii_comb_2(A.V, B.V) as kwii_comb_2 from $genoTable as A, $genoTable as B \
		          where A.G=1 and B.G=2 and A.S=B.S" -time
		echo -e "*******************************************************\n "

		echo "**********Test:  KWII_COMB_2_P(COMBINATION C)***"
		nzsql -c "select kwii_comb_2_P(A.V, B.V) as kwii_comb_2_p from $genoTable as A, $phenoTable as B \
			  where A.G=1 and A.S=B.S" -time
		echo -e "*******************************************************\n " 

		echo "**********Test:  KWII_COMB_3(COMBINATION C)******"
		nzsql -c "select kwii_comb_3(A.V, B.V, C.V) as kwii_comb_3 from $genoTable as A, $genoTable as B, $genoTable as C \
		          where A.G=1 and B.G=2 and C.G=3 and A.S=B.S and B.S=C.S" -time
		echo -e "*******************************************************\n "

		echo "**********Test:  KWII_COMB_3_P(COMBINATION C)***"
		nzsql -c "select kwii_comb_3_p(A.V, B.V, C.V) as kwii_comb_3_p from $genoTable as A, $genoTable as B, $phenoTable as C \
			  where A.G=1 and B.G=2 and A.S=B.S and B.S=C.S" -time
		echo -e "******************************************************\n  "
		echo -e "\n*************End***************\n";;
	3)	#drop table for $genoTable and $phenoTable
		echo "Drop table storing genotype."
		nzsql -c "drop table $genoTable" -time
		echo "Drop table storing phenotype." 
		nzsql -c "drop table $phenoTable" -time
		echo;;
	*)	echo "The second argument is invalid!";;
esac
