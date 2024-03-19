#!/bin/bash

outfile=pandp-vilhuber-2023-$(date +%F).zip

zip -rp $outfile AEA*tex AEA*pdf *bib images/ data/registry/Output/*png tables/*tex *.cls *.sty  *.bst
