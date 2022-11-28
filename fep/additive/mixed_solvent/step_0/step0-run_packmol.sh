#!/bin/bash

/home/sulstice/software/packmol/packmol < step0-gen_benz_wbox.inp
/home/sulstice/software/perl/convpdb.pl -crd charmm22 benz_wbox.pdb > benz_wbox.crd
