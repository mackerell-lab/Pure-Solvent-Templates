#!/bin/bash

/home/pchatter/packmol/packmol < step0-gen_%resi%_wbox.inp
/home/pchatter/mmtsb/perl/convpdb.pl -crd charmm22 %resi%_wbox.pdb > %resi%_wbox.crd
