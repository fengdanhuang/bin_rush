
file=$1

awk '{
	if ( $1=="total"){
#		print;
		step = $3;
#		printf "step = %ld\n", step; 
		sum += step; 
	}
}END{
	printf "sum= %ld\n", sum;
}' $file
