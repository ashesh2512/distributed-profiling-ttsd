#!/bin/bash
#SBATCH --export=NONE
#SBATCH -J VIT
#SBATCH -A VEN114
#SBATCH -N 2
#SBATCH --time=00:20:00
#SBATCH --exclusive
#SBATCH --output=job.out
#SBATCH --mail-user=ashesh.sharma@hpe.com
#SBATCH --mail-type=BEGIN

unset SLURM_EXPORT_ENV

export ttsd_root=/ccs/home/asharma/distributed-profiling-ttsd
export lus_dir=/lustre/orion/scratch/asharma/ven114/ttsd_multi_node

rm -rf "$lus_dir/tmp" "$lus_dir/logs"
mkdir -p "$lus_dir/tmp" "$lus_dir/logs"

source ~/.bashrc
load_amd_env 7.2.0
module load craype-accel-amd-gfx90a
conda activate ttsd
module list

export master_ip=$(hostname -i)
echo "master IP: $master_ip"

export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
export HDF5_USE_FILE_LOCKING=FALSE
export TRANSFORMERS_CACHE=$(pwd)/.cache
# export TORCH_NCCL_BLOCKING_WAIT=1

# MIOpen kernel cache: persist across jobs to avoid re-tuning
export MIOPEN_USER_DB_PATH=/tmp/miopen_cache_${USER}
export MIOPEN_CUSTOM_CACHE_DIR=/tmp/miopen_cache_${USER}

# Pre-populate from Lustre if a previous cache exists
if [ -d "$lus_dir/miopen_cache" ]; then
  cp -r $lus_dir/miopen_cache /tmp/miopen_cache_${USER}
else
  mkdir -p /tmp/miopen_cache_${USER}
fi

sacct -j $SLURM_JOB_ID --format=JobID,JobName,Start,End,Elapsed
HOME=$lus_dir/tmp srun --exclusive --exact -n 16 -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpus-per-task=1 --gpu-bind=closest bash -c "$lus_dir/wrapper.sh" &> ttsd.log
sacct -j $SLURM_JOB_ID --format=JobID,JobName,Start,End,Elapsed

cp -r /tmp/miopen_cache_${USER} $lus_dir/miopen_cache

