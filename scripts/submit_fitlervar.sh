#!/bin/bash
readonly PROJECT_ID=${1}
readonly provider="google-v2"
readonly logging=${2}
readonly machine_type="n1-standard-1"
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
  if [[ $genes -gt 1000 && ${counts%.*} -gt 10000 ]];then
   outdir=${output}/${tenx_sample}/${barcode}
   anntvcf="${outdir}/${barcode}.bcf"
   outvcf="${outdir}/${barcode}.filtered.bcf"
   echo $anntvcf
   if [[  `gsutil ls "${anntvcf}"` ]];then 
   cmd="dsub \
    --project ${PROJECT_ID} \
    --zones "us-central1-*" \
    --provider "${provider}"
    --logging ${logging} \
    --disk-size 100 \
    --boot-disk-size 50 \
    --machine-type ${machine_type} \
    --image ${DOCKER} \
    --env TENX_SAMPLE=${tenx_sample} \
    --env BARCODE=${barcode} \
    --input IN_VCF=${anntvcf} \
    --input IN_VCF_IDX=${anntvcf}.csi \
    --output OUT_VCF=${outvcf} \
    --output OUT_VCF_IDX=${outvcf}.csi \
    --script ${script}
    --preemptible "
   echo $cmd
   $cmd
fi
fi
done
