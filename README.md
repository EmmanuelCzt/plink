# plink
bash script for case control association studies using PLINK and KING (UNIX OS)

## Files 
- script_plink.sh : bash script
- mhc_range.txt : text file containing Major Histocompatibility Complex region coordinates, for the exclusion of SNPs in LD
- toexclude.txt : text file containing gonosome located SNPs coordinates for exclusion
- rs3754055.txt : text file containing coordinates of rs3754055 for its exclusion in cases data only

## How to 
- `$ chmod +x script_plink.sh` : make the .sh executable
- `./script_plink.sh` : execute the bash file

## References 
More informations about PLINK : http://zzz.bwh.harvard.edu/plink/ and KING : http://people.virginia.edu/~wc9c/KING/manual.html
