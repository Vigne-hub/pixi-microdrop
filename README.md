# Getting Started with Pixi for Microdrop

This guide provides instructions on how to set up and run the Microdrop project.

1. Navigating to the microdrop-py directory:

```shell
cd microdrop-py>
```


2. Initializing and Updating SubmodulesIf you cloned the repository without using the --recursive flag, or if you need to update any nested repositories, run the following command to initialize and update all submodules:

```shell
git submodule update --init --recursive`
```
  

3. To start the Microdrop application, use the pixi command with the following script:

```shell
pixi run python .\tools\run_device_viewer_pluggable.py
```

