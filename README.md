# pangeo-singularity
Scripts to run dask and jupyter lab on SLURM hpc using Singularity

Based heavily on the scripts written by Paul Branson using Shifter (https://github.com/pbranson/pangeo-hpc-shifter/blob/master/start_jupyter.sh) and the scripts provided by Pawsey for running Jupyter lab on Zeus with Singularity (https://support.pawsey.org.au/documentation/display/US/Running+JupyterHub+on+Zeus+with+Singularity). Currently using a Docker image created by Richard Matear: docker://matear/pangeo-mac:mod1 (this is a modification of the pangeo=notebook image that is curated at https://github.com/pangeo-data/pangeo-stacks).

## Running the containers

The approach is to run two separate jobs: one running Jupyter lab and the dask-scheduler; one running the dask workers. This way workers can be added to the scheduler as required.

### Start Jupyter and Dask scheduler
Run `sbatch start_jupyter.sh`

This does a few things:
1. Build the Singularity image in `/group/$PAWSEY_PROJECT/singularity/groupRepository` if the image does not already exist
2. Start an instance of the container running a dask-scheduler. dask-scheduler is instructed to write `$MYSCRATCH/scheduler.json` to communicate the scheduler location to the workers
3. Start an instance on the container running Jupyter Lab
4. Parses the log files to print out a helpful string for tunneling to the port exposed by Jupyter on the compute node. For now, you can find this information in the SLURM .out file that will getting written to the current directory once `start_jupyter.sh` leaves the queue.

Follow the instructions output by `start_jupyter.sh` to tunnel into your Jupyter Lab instance (for now, I have set this up so that users will find themselves in `${MYSCRATCH}/sandpit`).

### Start dask workers
Run `sbatch start_worker.sh`

This starts an instance of the contained running dask-worker, spec'd using the SLURM environment variables.

Once this job has left the queue, you should have access to these workers within your python environment.

### Instantiate a `dask-distributed` `Client`
To establish a `Client` for your scheduler within your python environment (on Jupyter Lab):
```
from dask.distributed import Client
client = Client(scheduler_file='$MYSCRATCH/scheduler.json')
```
(Note the `Client` widget did not work for me, but otherwise thing seem to be functioning well)


## Useful links
https://support.pawsey.org.au/documentation/display/US/Containers
https://docs.dask.org/en/latest/setup/hpc.html#using-a-shared-network-file-system-and-a-job-scheduler
https://github.com/pbranson/pangeo-hpc-shifter

