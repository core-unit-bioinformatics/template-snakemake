"""
This module is designed to be included in other
workflows to locate and get reference data
from reference containers.
This module must never have any other dependencies!

Assumptions:
The config of the executing workflow must specify the
variables:
1) reference_container_folder: <path to folder>
2) reference_container_names: <list of container names to use>

"""

import pathlib
import pandas
import os

localrules: refcon_run_dump_manifest, refcon_cache_manifests

if 'use_reference_container' in config:
    USE_REFERENCE_CONTAINER = config['use_reference_container']
    if USE_REFERENCE_CONTAINER:
        if not pathlib.Path(config['reference_container_folder']).is_dir():
            err_msg = f"\n!!! USER ACTION REQUIRED !!!\n"
            err_msg += f"Please provide a config file with the following information:\n"
            err_msg += f"reference_container_folder: <path to folder>\n"
            err_msg += f"reference_container_names: <list of container names to use>\n\n"
            raise ValueError(err_msg)
        else:
            REFCON_DIR = DIR_REFCON

            # define reference_container_names list and test if selected container name(s) are available
            list_of_containers = []
            for container in [items for items in os.listdir(REFCON_DIR) if items.endswith('.sif')]:
                list_of_containers.append(container)
            container_names = set([names.replace('.sif', '') for names in list_of_containers])
            selected_containers = set(config['reference_container_names'])
            unknown_containers = list(sorted(selected_containers - container_names))

            if len(unknown_containers) < 1:
                REFCON_NAMES = config['reference_container_names']
            else:
                err_msg = f"\n!!! USER ACTION REQUIRED !!!\n"
                err_msg += f"This container name is unknown: {unknown_containers}\n"
                err_msg += f"Please provide a config file with the following information:\n"
                err_msg += f"reference_container_folder: <path to folder>\n"
                err_msg += f"reference_container_names: <list of container names to use>\n\n"
                err_msg += f"Make sure the provided reference_container_names exist in the reference_container_folder \n\n"
                raise ValueError(err_msg)
    else:
        REFCON_DIR = ""
        REFCON_NAMES = ""

else:
    err_msg = f"\n!!! USER ACTION REQUIRED !!!\n"
    err_msg += f"Please provide a config file with the following information:\n"
    err_msg += f"use_reference_container: <True or False>\n"
    err_msg += f"If a reference container should be used please also provide the following information:\n"
    err_msg += f"reference_container_folder: <path to folder>\n"
    err_msg += f"reference_container_names: <list of container names to use>\n\n"
    raise ValueError(err_msg)


# Snakemake interacts with Singularity containers using "exec",
# which leads to a problem for the "refcon_run_get_file".
# Dynamically setting the Singularity container for the
# "singularity:" keyword results in a parsing error for
# unclear reasons. Hence, for now, force the use of
# "singularity run" to extract data from reference containers
# (i.e., treat them like a regular file)

SINGULARITY_ENV_MODULE = config.get('singularity_env_module', 'Singularity')


def refcon_find_container(manifest_cache, ref_filename):

    if not pathlib.Path(manifest_cache).is_file():
        # could be a dry run
        return 'No-manifest-cache-available'

    manifests = pandas.read_hdf(manifest_cache, 'manifests')

    matched_names = set(manifests.loc[manifests['name'] == ref_filename, 'refcon_name'])
    matched_alias1 = set(manifests.loc[manifests['alias1'] == ref_filename, 'refcon_name'])
    matched_alias2 = set(manifests.loc[manifests['alias2'] == ref_filename, 'refcon_name'])

    select_container = sorted(matched_names.union(matched_alias1, matched_alias2))
    if len(select_container) > 1:
        raise ValueError(f'The requested reference file name "{ref_filename}" exists in multiple containers: {select_container}')
    elif len(select_container) == 0:
        raise ValueError(f'The requested reference file name "{ref_filename}" exists in none of these containers: {REFCON_NAMES}')
    else:
        pass
    container_path = REFCON_DIR / pathlib.Path(select_container[0] + '.sif')
    return container_path


rule refcon_run_dump_manifest:
    input:
        sif = REFCON_DIR / pathlib.Path('{refcon_name}.sif')
    output:
        manifest = 'cache/refcon/{refcon_name}.manifest'
    envmodules:
        SINGULARITY_ENV_MODULE
    shell:
            '{input.sif} manifest > {output.manifest}'

rule refcon_run_get_file:
    input:
        cache = 'cache/refcon/refcon_manifests.cache'
    output:
        'global_ref/{filename}'
    envmodules:
        SINGULARITY_ENV_MODULE
    params:
        refcon_path = lambda wildcards, input: refcon_find_container(input.cache, wildcards.filename)
    shell:
        '{params.refcon_path} get {wildcards.filename} {output}'


rule refcon_cache_manifests:
    input:
        manifests = expand('cache/refcon/{refcon_name}.manifest', refcon_name=REFCON_NAMES)
    output:
        cache = 'cache/refcon/refcon_manifests.cache'
    run:
        merged_manifests = []
        for manifest_file in input.manifests:
            container_name = pathlib.Path(manifest_file).name.rsplit('.', 1)[0]
            assert container_name in REFCON_NAMES
            manifest = pandas.read_csv(manifest_file, sep='\t', header=0)
            manifest['refcon_name'] = container_name
            merged_manifests.append(manifest)
        merged_manifests = pandas.concat(merged_manifests, axis=0, ignore_index=False)

        merged_manifests.to_hdf(output.cache, 'manifests', mode='w')


