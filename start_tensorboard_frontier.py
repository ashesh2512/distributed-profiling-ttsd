#!/usr/bin/env python
"""Launch TensorBoard on OLCF Frontier to view PyTorch profiler traces.

Traces are written by train_mp.py to $lus_dir/torch_trace. TensorBoard binds to
a port on the node; to view it in a browser on your laptop, open an SSH tunnel
(the exact command is printed on startup):

    ssh -N -L 6006:<node>:6006 <user>@frontier.olcf.ornl.gov

Then browse to http://localhost:6006 and open the PYTORCH_PROFILER tab.

Requires the profiler plugin: pip install torch-tb-profiler
"""
import argparse
import os
import socket
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--lus_dir",
        default=os.environ.get("lus_dir"),
        help="lustre run dir containing torch_trace (defaults to $lus_dir)",
    )
    parser.add_argument("--port", type=int, default=6006, help="TensorBoard port")
    args = parser.parse_args()

    if not args.lus_dir:
        parser.error("lus_dir not provided and $lus_dir is not set")

    log_dir = os.path.join(args.lus_dir, "torch_trace")
    port = args.port

    node = socket.gethostname()
    user = os.environ.get("USER", "<user>")
    print(f"ssh -N -L {port}:{node}:{port} {user}@frontier.olcf.ornl.gov")
    print("then open http://localhost:6006")

    subprocess.run(
        [
            "tensorboard",
            "--logdir", log_dir,
            "--host", "0.0.0.0",
            "--port", str(port),
        ]
    )


if __name__ == "__main__":
    main()
