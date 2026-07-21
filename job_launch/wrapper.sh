export RANK=$SLURM_PROCID
export LOCAL_RANK=0
export WORLD_SIZE=$SLURM_NTASKS
export MASTER_ADDR=$master_ip
export MASTER_PORT=3442

python -u $ttsd_root/train_mp.py --yaml_config $lus_dir/ViT.yaml --config model_parallel --tensor_parallel=2
