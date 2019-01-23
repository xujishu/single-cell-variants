#!/bin/bash


FILES=`ls ${VAR_DIR}/*-1/*-1.stat.csv`

header=("CELL" "TOT_VAR" "DEL" "INS" "SNP" "KNOWN_VAR" "PERC_KNOWN_VAR")
annots=("DOWNSTREAM" "EXON" "INTERGENIC" "INTRON" "MOTIF" "SPLICE_SITE_ACCEPTOR" "SPLICE_SITE_DONOR" "SPLICE_SITE_REGION" "TRANSCRIPT" "UPSTREAM" "UTR_3_PRIME" "UTR_5_PRIME")
header=(${header[@]} ${annots[@]})
echo ${header[@]} >$OUTFILE
newline=()
echo $FILES
for f in $FILES;
do	
	echo $f
	fname=$(basename ${f})
	name_wo_ext=$(echo "$fname" | cut -d'.' -f1)
	num_vars=$(grep "Number_of_variants_before_filter" ${f}|cut -f 2 -d","| tr -d '[:space:]')
	del=$(grep "DEL" ${f}|cut -f 2 -d","| tr -d '[:space:]')
	ins=$(grep INS ${f}|cut -f 2 -d","| tr -d '[:space:]')
	snps=$(grep SNP ${f}|cut -f 2 -d","| tr -d '[:space:]')
	line=$(grep Number_of_known_variants ${f})
	perc_snp=$(echo $line|cut -f 3 -d","|cut -f 1 -d"%"| tr -d '[:space:]')
	dbsnps=$(echo $line|cut -f 2 -d","| tr -d '[:space:]')
	newline=($name_wo_ext $num_vars ${del} ${ins} ${snps} $dbsnps $perc_snp)
	y=()
	for a in ${annots[@]};do
		x=$(grep $a $f|cut -f 3 -d","|cut -f 1 -d"%"|tr -d '[:space:]')
		y+=($x)
	done
	newline=(${newline[@]} ${y[@]})
	echo ${newline[@]} >>$OUTFILE
	
done
