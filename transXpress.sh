#! /bin/bash

echo "Running the transXpress pipeline using snakemake"

CLUSTER="slurm"

if [ ! -z `which sbatch` ]; then
  CLUSTER="SLURM"
fi

if [ ! -z `which bsub` ]; then
  CLUSTER="LSF"
fi

if [ ! -z `which qsub` ]; then
  CLUSTER="PBS"
fi

case "$CLUSTER" in
"LSF")
  echo "Submitting snakemake jobs to LSF cluster"
  snakemake --conda-frontend conda --use-conda --latency-wait 60 --restart-times 1 --jobs 10000 --cluster "bsub -oo {log}.bsub -n {threads} -R rusage[mem={params.memory}000] -R span[hosts=1]" "$@"
  ;;
"SLURM")
  echo "Submitting snakemake jobs to SLURM cluster"
  snakemake --conda-frontend conda --use-conda --latency-wait 60 --restart-times 1 --jobs 10000 --cluster "sbatch  --comment RnD --partition i192,i128-o {log}.slurm.out -e {log}.slurm.err -n {threads} --mem {params.memory}GB" "$@"
  ;;
"PBS")
  echo "Submitting snakemake jobs to PBS/Torque cluster"
  snakemake --conda-frontend conda --use-conda --latency-wait 60 --restart-times 1 --jobs 10000 --cluster "qsub -o {log}.slurm.out -e {log}.slurm.err -l select=1:ncpus={threads}:mem={params.memory}gb" "$@"
  ;;
*)
  snakemake --conda-frontend conda --use-conda --cores all "$@"
  ;;
esac


