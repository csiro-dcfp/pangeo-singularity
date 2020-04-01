# pangeo-singularity
Scripts to run dask and jupyter lab on SLURM hpc using Singularity

Based heavily on the scripts written by Paul Branson using Shifter (https://github.com/pbranson/pangeo-hpc-shifter/blob/master/start_jupyter.sh) and the scripts provided by Pawsey for running Jupyter lab on Zeus with Singularity (https://support.pawsey.org.au/documentation/display/US/Running+JupyterHub+on+Zeus+with+Singularity).

The approach is to run two separate jobs:
> `start_jupyter.sh` starts Jupyter and the dask-scheduler
> `start_worker.sh` starts the dask workers



Useful links:
https://support.pawsey.org.au/documentation/display/US/Containers
https://docs.dask.org/en/latest/setup/hpc.html#using-a-shared-network-file-system-and-a-job-scheduler
https://github.com/pbranson/pangeo-hpc-shifter

