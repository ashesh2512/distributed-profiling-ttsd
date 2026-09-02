#!/bin/bash
#SBATCH --export=NONE
#SBATCH -J VIT
#SBATCH -A VEN114
#SBATCH -N 2
#SBATCH --time=00:20:00
#SBATCH --exclusive
#SBATCH --output=job.out
#SBATCH --mail-user=ashesh.sharma@hpe.com

unset SLURM_EXPORT_ENV

export ttsd_root=/ccs/home/asharma/distributed-profiling-ttsd
export lus_dir=/lustre/orion/scratch/asharma/ven114/ttsd_multi_node

rm -rf "$lus_dir/tmp" "$lus_dir/logs" "$lus_dir/rocprof_trace" "$lus_dir/torch_trace" "$lus_dir/mem_snapshot" "$lus_dir/tmp/miopen_cache_${USER}"
mkdir -p "$lus_dir/tmp" "$lus_dir/logs" "$lus_dir/tmp/miopen_cache_${USER}"

source ~/.bashrc
load_amd_env 7.2.0
module load craype-accel-amd-gfx90a
module load rccl-net-plugin
conda activate ttsd
module list

export HDF5_USE_FILE_LOCKING=FALSE
export TRANSFORMERS_CACHE=$(pwd)/.cache

export master_ip=$(hostname -i)
echo "master IP: $master_ip"

# MIOpen kernel cache: persist across jobs to avoid re-tuning
export MIOPEN_USER_DB_PATH=/tmp/miopen_cache_${USER}
export MIOPEN_CUSTOM_CACHE_DIR=/tmp/miopen_cache_${USER}

sacct -j $SLURM_JOB_ID --format=JobID,JobName,Start,End,Elapsed
HOME=$lus_dir/tmp srun --exclusive --exact -n 16 -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpus-per-task=1 --gpu-bind=closest bash -c "$lus_dir/wrapper.sh" &> ttsd.log
sacct -j $SLURM_JOB_ID --format=JobID,JobName,Start,End,Elapsed
