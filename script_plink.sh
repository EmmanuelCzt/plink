#! /usr/bin/env bash

# See http://zzz.bwh.harvard.edu/plink/ for more instructions about PLINK
# See http://people.virginia.edu/~wc9c/KING/manual.html for more instructions about KING
# File names are showed as exemples

# Recoding of cases files and exclusions of gonosomes SNPs and rsrs3754055
plink --bfile ic_cases --exclude toexclude.txt --make-bed --out ic_cases_recoded_excluded --noweb
plink --bfile ic_cases_recoded_excluded --exclude rs3754055.txt --make-bed --out ic_cases_recoded_excluded_rs --noweb

# Recoding of controls files and exclusions of gonosomes SNPs
plink --bfile ic_controls --exclude toexclude.txt --make-bed --out ic_controls_recoded_excluded --noweb

# Merge of cases and controls files to build a unique dataset
plink --bfile ic_cases_recoded_excluded_rs --bmerge ic_controls_recoded_excluded.bed ic_controls_recoded_excluded.bim ic_controls_recoded_excluded.fam --make-bed --out merged --noweb

# strand flipping in order to get the same strand everywhere
plink --bfile ic_controls_recoded_excluded --flip merged.missnp --make-bed --out ic_controls_recoded_excluded_flipped --noweb

# 2nd Merge
plink --bfile ic_cases_recoded_excluded_rs --bmerge ic_controls_recoded_excluded_flipped.bed ic_controls_recoded_excluded_flipped.bim ic_controls_recoded_excluded_flipped.fam --make-bed --out t1dcc --noweb

#QC on SNPs
# Genotyping < 0.95
plink --bfile t1dcc --geno 0.05 --make-bed --out filter1 --noweb
# Genotyping rates patients/contrôles
plink --bfile filter1 --test-missing --pfilter 0.00001 --make-bed --out missingcc --noweb
# Error correction
plink --bfile filter1 --exclude missingcc.missing --make-bed --out filter2 --noweb
# H&W equilibrium
plink --bfile filter2 --hwe 0.0001 --make-bed --out filter3 --noweb
# MAF < 0.01
plink --bfile filter3 --maf 0.01 --make-bed --out filter4 --noweb

# QC on the subjects
# Genotyping < 0.95
plink --bfile filter4 --mind 0.05 --make-bed --out filter5 --noweb

# Exclusion of related subject : KING
# Creation of file of all the related subjects
king -b filter5.bed --kinship --related
# Creation of file of all the non-related subjects
king -b filter5.bed --kinship --unrelated --prefix filter6
# Selection of the non related subjects
plink --bfile filter5 --keep filter6unrelated.txt --make-bed --out filter6

# Checking for population stratification
plink --bfile filter6 --exclude mhc_range.txt --range --make-bed --out withoutmhc
# Identification and elimination of Linkage desiquilibrium SNPs
plink --bfile withoutmhc --indep 50 5 2
plink --bfile withoutmhc --extract plink.prune.in --make-bed --out withoutld

# MDS analysis
king -b withoutld.bed --mds --ibs --prefix stratifwithoutld

# Use of MDS components for stratification correction
plink --bfile filter6 --logistic --adjust --covar stratifwithoutldpc.ped --covar-number 5-9 --hide-covar --ci 0.95 --out logistic_mds_PC5

# Allelic association test
plink --bfile filter6 --assoc --adjust --out allelictest
