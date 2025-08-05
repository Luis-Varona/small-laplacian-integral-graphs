#!/bin/bash
#SBATCH --job-name=laplacian_integral_con_bip_graphs_1to15
#SBATCH --account=def-mbetti
#SBATCH --cpus-per-task=48
#SBATCH --time=8:00:00
#SBATCH --mem=6G

ROOT="/home/pusheen/scratch/small-laplacian-integral-graphs"
MAIN="/home/pusheen/scratch/small-laplacian-integral-graphs/src/main.jl"

CAT="con_bip"
DST="/home/pusheen/scratch/small-laplacian-integral-graphs/data/laplacian_integral_con_bip_graphs_1to15.txt"

NTHREADS=40
MIN_N=1
MAX_N=15
CHUNK_SZ=2000

module load StdEnv/2023
module load julia/1.11.3
export PATH="/home/pusheen/tools/nauty2_9_0:$PATH"

export JULIA_NUM_THREADS="$NTHREADS"
export OPENBLAS_NUM_THREADS=1
julia --project="$ROOT" "$MAIN" "$CAT" "$DST" "$MIN_N" "$MAX_N" "$CHUNK_SZ"
