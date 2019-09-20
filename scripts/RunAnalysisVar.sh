#!/bin/bash
set -o errexit
set -o nounset

echo "filtering....."
bcftools filter -s "LOWDP" -i "INFO/DP>3" ${IN_VCF} -O bcf -o ${OUT_VCF}
bcftools index ${OUT_VCF}

