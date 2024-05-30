# Overview of planned functionality

## MVP Baseline (Must-Have)
- **Compare Configuration Against Existing Install:**
  - Ability to compare a given configuration (which may be in text form) against the existing install and list differences.
  - Return exit code 1 or 0 for automation.

- **Install Configuration:**
  - Ability to attempt to install "everything" in a given configuration file.
  - Configuration file can be a simple list of repositories (either links or local folder).

## Improvements (Features)
- **Mirror Repositories:**
  - If given the list of repositories, be able to mirror them into a local file folder.

- **Uninstall Unwanted Packages:**
  - Ability to uninstall unwanted packages.

- **Configuration Format:**
  - Support sensible formats for configuration files, such as JSON or YAML.

- **Environment Check:**
  - Check the environment for required dependencies of this tool.
  - Sanity check that includes version of jq and possibly a dry-run for s32ds.

- **Override Default Paths:**
  - Default values for paths can be overridden by arguments.

## Ideas (Future)
- **Automirror Installation:**
  - Automirror everything in a given installation and backup for cloning later.

- **Automated Studio Install:**
  - Automated install of the whole studio, not just the packages.

- **Docker Integration:**
  - Create a Docker image or package for Docker image that will run automated compilation.
  - Check the environment within Docker for building, including environment libraries check.
