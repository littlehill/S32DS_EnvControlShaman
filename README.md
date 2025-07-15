# S32DS_EnvControlShaman
Automate and standardize environment setup, management and controll for S32 Design Studio across multiple machines and developers.
**Ensures everything is where it should be, so you don't have to.**

## Overview

As many know, it’s hard enough to install the S32DS correctly once. Now imagine you have two machines, or even worse, two developers...

It’s my own nightmare to manage this manually rn, and therefore here we go.

### What S32DS EnvControlShaman Offers

shit empty repo atm, working on alpha [shrug]  
what is the plan ? [see the requirements-and-planning.md](requirements-and-planning.md)

#### Main Goal for alpha

A clean install on a new machine. Kick off the Shaman to use the p2 director of Eclipse to install whatever you need.

## Install steps
Info: This only works with Win10/11 at the moment.

1. If you do not have it, install Git Bash. You can find it here: [Git Bash Download](https://www.git-scm.com/download/win).

2. Checkout this repository into `/c/NXP/`. If `/c/NXP` does not exist, create it.

3. Install the S32DS.3.6.x from NXP : `S32DS_3.6.0_win32.x86_64` or `S32DS_3.6.2_RFP_win32.x86_64.exe`.

4. Open Git Bash and `cd` into the `/c/NXP/S32DS_EnvControlShaman` folder.
   
5. Set a ```SHAMAN_ECLIPSE_BIN_PATH``` variable to the path of S32DS eclipse executable.  
(expecting something like "/c/NXP/S32DS.3.6.0/eclipse/s32ds.exe" or "../S32DS.3.6.2/eclipse/s32ds.exe")

6. Run `./subtasks/bash_env_sanity_check.sh -v`.
    - Fix any errors before continuing.

7. Run one of the following commands:
    - `./subtasks/create_list_of_available_repos.sh -outfile generated_list_of_repos.tmp.txt -url <path to the repositories in S3 bucket or on NAS>`
    - `./subtasks/create_list_of_available_repos.sh -outfile generated_list_of_repos.tmp.txt -dir <the root folder of your local extracted repos>`

8. Run `./automated-s32ds-update_main.sh generated_list_of_repos.tmp.txt` and hope for the best.

