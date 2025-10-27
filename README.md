# dftenergyminer - script series for Gaussian 16 output files analysis (n.1)

**Bash** **Linux only** script to parse Gaussian 16 output files for DFT calculations, including TD. Extracts energies (SCF, TD-DFT, thermochemistry) and HOMO-LUMO orbitals.
Processes all .log/.out files in directory, outputs one CSV file (having TXT extension).

## Features
- Extracts SCF energy, TD-DFT energy (if present)
- **Frequency calculation check** - detects if frequencies were computed and checks for imaginary values
- Extracts zero-point energy, enthalpy, and free Gibbs energy **Requires frequency calculation**
- Extracts HOMO and LUMO orbital energies for alpha and beta spins
- Automatic processing of all .log and .out files in current directory
- Output file with date prefix (YYYYMMDD_gaussian_results.txt) saved in current directory
- No external dependencies

## Input Requirements
- Gaussian 16 output files (`.log`, `.out`) from DFT calculations
- Supports both ground state and TD-DFT calculations
- Frequency calculations required for thermochemical properties

## How to run it
./dftenergyminer.sh
Detailed instructions on how to run the script are reported at the beginning of the script (file: dftenergyminer.sh).

## Output file
CSV file with naming format: YYYYMMDD_gaussian_results.txt
Output columns:
- File name
- Frequencies (OK/error/not present)
- E (hartree)
- E TD-HF/TD-DFT (hartree)
- E+ZPE (hartree)
- H (hartree)
- G (hartree)
- HOMO alpha (hartree)
- LUMO alpha (hartree)
- HOMO beta (hartree)
- LUMO beta (hartree)

## Citation
J.G. Vitillo, 'dftenergyminer.sh', https://github.com/jennygvitillo/dftenergyminer (2025).

## Italiano
Script **bash** **Linux** per analizzare file output di Gaussian 16 per conti DFT, anche TD. Estrae energie e orbitali HOMO-LUMO. Elabora automaticamente tutti i file .log/.out nella directory e salva i risultati in un file CSV (ossia valori separati da virgola) ma con estensione TXT.
- Estrae energie SCF, TD-DFT (if present)
- **Controllo calcolo delle frequenze** - verifica se le frequenze sono state calcolate e se ci sono valori immaginari
- Estrae energia con zero-point, entalpia e energia libera di Gibbs **Richiede calcolo frequenze**
- Estrae energie orbitali HOMO e LUMO per spin alpha e beta
- Elaborazione automatica di tutti i file `.log` e `.out` nella directory corrente
- File di output con prefisso data (YYYYMMDD_gaussian_results.txt) salvato nella directory corrente
- Nessuna dipendenza esterna

Istruzioni dettagliate su come usare lo script sono riportate nella parte iniziale dello script stesso (file: dftenergyminer.sh).
