#!/bin/bash
set -o errexit
set -o nounset

tenXbam=${IN_TENX_BAM}
barcode=${BARCODE}
dbsnp=${DBSNP}
tenx_fa=${TENX_FA}
output_dir="$(dirname "${OUTPUT_FILES}")"
samplename=${TENX_SAMPLE}
# run samtools
echo "samtools..."
samtools view -H ${tenXbam} >${output_dir}/${barcode}.sam
samtools view ${tenXbam} |grep "CB:Z:${barcode}" >>${output_dir}/${barcode}.sam
samtools view -b  -o ${output_dir}/${barcode}.bam ${output_dir}/${barcode}.sam
samtools index ${output_dir}/${barcode}.bam
echo "remote duplciated umi...."
umi_tools dedup -I ${output_dir}/${barcode}.bam  -S ${output_dir}/${barcode}.dedup.bam --umi-tag="UB" --cell-tag="CB"  --extract-umi-method=tag
# bcftools variants
# rename read group to barcode
echo "Run bcftools....."
echo  "${samplename} ${barcode}" >${output_dir}/${barcode}_RG.txt
# raw variants call
cmd="bcftools mpileup -Ou -S ${output_dir}/${barcode}_RG.txt -f ${tenx_fa} ${output_dir}/${barcode}.dedup.bam|bcftools call -mv -Ob -o ${output_dir}/${barcode}.bcf"
echo $cmd
bcftools mpileup  -Ou -S ${output_dir}/${barcode}_RG.txt -a "FORMAT/DP,FORMAT/AD" -f ${tenx_fa} ${output_dir}/${barcode}.dedup.bam|bcftools call -mv -Ou|bcftools filter -s "LOWDP" -i "INFO/DP>3"  -Ob -o ${output_dir}/${barcode}.bcf
bcftools index ${output_dir}/${barcode}.bcf
# snpEff annotate variants
echo "annotation....."
bcftools annotate -c ID -a  ${dbsnp} ${output_dir}/${barcode}.bcf -Ov |java -Xmx7g -jar /opt/snpEff/snpEff.jar ann GRCh38.86 -csvStats ${output_dir}/${barcode}.stat.csv - |bcftools view -Ob - >${output_dir}/${barcode}.annt.bcf
bcftools index ${output_dir}/${barcode}.annt.bcf

#clean bam and sam
rm ${output_dir}/${barcode}.bam* ${output_dir}/${barcode}.dedup.bam ${output_dir}/${barcode}.sam
