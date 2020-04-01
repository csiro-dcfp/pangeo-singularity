#!/bin/bash -l

#SBATCH --partition=workq
#SBATCH --ntasks=10
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=6G
#SBATCH --time=2:00:00
#SBATCH --account=pawsey0315
#SBATCH --export=NONE
#SBATCH -J dask_worker   # name
#SBATCH -o dask-worker-%J.out

module load singularity

# Group Singularity image repository -----
# Let's put shared Singularity images here
groupRepository=/group/$PAWSEY_PROJECT/singularity/groupRepository

# Set the image and tag we want to use ----
# For now, using Richard's mod of docker://pangeo-notebook-onbuild
# image="docker://pangeo-notebook-onbuild:mod1"
image="docker://matear/pangeo-mac:mod1"

# Get the image filename -----
imagename=${image##*/}
imagename=$groupRepository/${imagename/:/_}.sif

# Pull/build the container if it doesn't already exist in the groupRepository -----
# When building singularity images, many files and a copy of the images themselves are saved in the cache. 
# Singularity modules at Pawsey define the Singularity image cache at $MYGROUP/.singularity/cache, contrary 
# to the Singularity default that defines the cache in /home. This avoids problems with the restricted 
# quota of /home. On other systems, e.g. Pearcey, it may be necessary to symlink $HOME/.singularity to a 
# (non-NFS) location with more space, e.g. /scratch1 or /flush# on Pearcey.
# Once you have finished building/pulling containers, you can clean up the cache using:
#     singularity cache clean -a
if [ ! -f $imagename ]; then
    echo "Cannot find image in group repository. Run start_jupyter.sh using same image prior to running this script"
fi

# calculate task memory limit
memlim=$(echo $SLURM_CPUS_PER_TASK*$SLURM_MEM_PER_CPU*0.95 | bc)

echo "Starting $SLURM_NTASKS workers with $SLURM_CPUS_PER_TASK CPUs each (Memory limit is $memlim)..."
srun --export=ALL -n $SLURM_NTASKS -c $SLURM_CPUS_PER_TASK \
singularity exec -C -B ${userDirectory}:/home/joyvan -B ${userDirectory}:$HOME ${imagename} \
dask-worker --scheduler-file $MYSCRATCH/scheduler.json --nthreads $SLURM_CPUS_PER_TASK --memory-limit ${memlim}M

