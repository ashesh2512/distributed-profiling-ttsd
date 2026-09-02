export RANK=$SLURM_PROCID
export LOCAL_RANK=0
export WORLD_SIZE=$SLURM_NTASKS
export MASTER_ADDR=$master_ip
export MASTER_PORT=3442

outdir="${lus_dir}/rocprof_trace/rank_${RANK}"
outfile="${outdir}/results.csv"

# /opt/rocm-7.2.0/bin/rocprofv3 --rccl-trace --sys-trace --truncate-kernels --output-format pftrace -d ${outdir} -- python -u $ttsd_root/train_mp.py --yaml_config $lus_dir/ViT.yaml --config model_parallel --tensor_parallel=2

python -u $ttsd_root/train.py --yaml_config $lus_dir/ViT.yaml --config data_parallel

#python -u $ttsd_root/train_mp.py --yaml_config $lus_dir/ViT.yaml --config model_parallel --tensor_parallel=2
