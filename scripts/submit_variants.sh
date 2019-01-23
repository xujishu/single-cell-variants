#!/bin/bash
readonly PROJECT_ID=${1}
readonly provider="google-v2"
readonly logging=${2}
readonly machine_type="n1-standard-2"
readonly in_tenx_bam=${3}
readonly tenx_sample=${4}
readonly tenx_fa=${5}
readonly output=${6}
readonly script=${7}
readonly snpEffDB="GRCh38.86"
# ensembl GRCh38
readonly dbsnp="ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606_b150_GRCh38p7/VCF/00-All.vcf.gz"
# hg38 broad institute
##readonly dbsnp="ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/hg38/dbsnp_146.hg38.vcf.gz"
readonly DOCKER="quay.io/xujishu/tenx-variants-call:0.02"

while read -r line
do

  barcode=$(echo $line|awk '{print $1}')
  counts=$(echo $line|awk '{print $4}')
  genes=$(echo $line|awk '{print $2}')
  if [[ $genes -gt 1000 && ${counts%.*} -gt 3000 ]];then
   outdir=${output}/${tenx_sample}/${barcode}
   #anntvcf="${outdir}/${barcode}.annt.bcf.csi"
   #echo $anntvcf
   # if [[ ! `gsutil ls "${anntvcf}"` ]];then 
   cmd="dsub \
    --project ${PROJECT_ID} \
    --zones "us-central1-*" \
    --provider "${provider}"
    --logging ${logging} \
    --disk-size 100 \
    --boot-disk-size 50 \
    --machine-type ${machine_type} \
    --image ${DOCKER} \
    --script ${script} \
    --env TENX_SAMPLE=${tenx_sample} \
    --input IN_TENX_BAM=${in_tenx_bam} \
    --input IN_TENX_BAM_INDEX=${in_tenx_bam}.bai \
    --env BARCODE=${barcode} \
    --env DBSNP=${dbsnp} \
    --env SNPEFFDB=${snpEffDB} \
    --input TENX_FA=${tenx_fa} \
    --input TENX_FAI="${tenx_fa}.fai" \
    --output OUTPUT_FILES="${outdir}/${barcode}.*" \
    --preemptible "
   echo $cmd
   $cmd
fi
#fi
done
