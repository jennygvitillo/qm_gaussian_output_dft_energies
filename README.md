# qm_gaussian_output_dft_energies.sh

*English*
**Bash** **Linux only** script to parse Gaussian 16 output files for DFT calculations, including TD. Extracts energies (SCF, TD-DFT, thermochemistry) and HOMO-LUMO orbitals. Processes all .log/.out files in directory, outputs CSV.
- Extracts SCF energy, TD-DFT energy, zero-point energy, enthalpy, and free energy
- Extracts HOMO and LUMO orbital energies for alpha and beta spins
- Automatic processing of all .log and .out files in current directory
- Output file with date prefix (YYYYMMDD_gaussian_results.txt) saved in current directory
- No external dependencies

Detailed instructions on how to run the script are reported at the beginning of the file.


*Italiano*
Script **bash** **Linux** per analizzare file output di Gaussian 16 per conti DFT, anche TD. Estrae energie e orbitali HOMO-LUMO. Elabora automaticamente tutti i file .log/.out nella directory.
- Estrae energie SCF, TD-DFT, energia con zero-point, entalpia e energia libera
- Estrae energie orbitali HOMO e LUMO per spin alpha e beta
- Elaborazione automatica di tutti i file `.log` e `.out` nella directory corrente
- File di output con prefisso data (YYYYMMDD_gaussian_results.txt) salvato nella directory corrente
- Nessuna dipendenza esterna

Istruzioni dettagliate su come usare lo script sono riportate nella parte iniziale dello script stesso.
