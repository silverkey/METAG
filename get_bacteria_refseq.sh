wget ftp://ftp.ncbi.nlm.nih.gov/genomes/Bacteria/all.fna.tar.gz
nohup /home/remo/src/ncbi-blast-2.2.28+/bin/makeblastdb -dbtype nucl -in all_bacteria.fa &
