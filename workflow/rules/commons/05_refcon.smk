
import pandas

localrules: refcon_dump_manifest, refcon_cache_manifests


# Snakemake interacts with Singularity containers using "exec",
# which leads to a problem for the "refcon_run_get_file".
# Dynamically setting the Singularity container for the
# "singularity:" keyword results in a parsing error for
# unclear reasons. Hence, for now, force the use of
# "singularity run" to extract data from reference containers
# (i.e., treat them like a regular file)


def refcon_find_container(manifest_cache, ref_filename):

    if not pathlib.Path(manifest_cache).is_file():
        # could be a dry run
        return 'No-manifest-cache-available'

    manifests = pandas.read_csv(manifest_cache, sep="\t", header=0)

    refcon_names = sorted(manifests['refcon_name'].unique())

    matched_names = set(manifests.loc[manifests['name'] == ref_filename, 'refcon_name'])
    matched_alias1 = set(manifests.loc[manifests['alias1'] == ref_filename, 'refcon_name'])
    matched_alias2 = set(manifests.loc[manifests['alias2'] == ref_filename, 'refcon_name'])

    select_container = sorted(matched_names.union(matched_alias1, matched_alias2))
    if len(select_container) > 1:
        raise ValueError(
            f'The requested reference file name "{ref_filename}" exists in multiple containers: {select_container}'
        )
    elif len(select_container) == 0:
        raise ValueError(
            f'The requested reference file name "{ref_filename}" exists in none of these containers: {refcon_names}'
        )
    else:
        pass
    container_path = DIR_REFCON / pathlib.Path(select_container[0] + '.sif')
    return container_path


def load_reference_container_names():

    existing_container = [sif_file.stem for sif_file in DIR_REFCON.glob("*.sif")]
    requested_container = config.get("reference_container_names", [])
    if not requested_container:
        raise ValueError(
            "The config option 'use_reference_container' is set to True. "
            "Consequently, you need to specify a list of container names "
            "in the config with the option 'reference_container_names'."
        )
    missing_container = ""
    for req_con in requested_container:
        if req_con not in existing_container:
            missing_container += f"\nMissing reference container: {req_con}"
            missing_container += f"\nExpected container image location: {DIR_REFCON / pathlib.Path(req_con)}.sif\n"

    if missing_container:
        logerr(missing_container)
        raise ValueError(
            "At least one of the specified reference containers "
            "(option 'reference_container_names' in the config) "
            "does not exist in the reference container store."
        )
    return sorted(requested_container)


if USE_REFERENCE_CONTAINER:

    rule refcon_dump_manifest:
        input:
            sif = DIR_REFCON / pathlib.Path('{refcon_name}.sif')
        output:
            manifest = 'cache/refcon/{refcon_name}.manifest'
        envmodules:
            ENV_MODULE_SINGULARITY
        shell:
            '{input.sif} manifest > {output.manifest}'

    rule refcon_run_get_file:
        input:
            cache = 'cache/refcon/refcon_manifests.cache'
        output:
            'global_ref/{filename}'
        envmodules:
            ENV_MODULE_SINGULARITY
        params:
            refcon_path = lambda wildcards, input: refcon_find_container(input.cache, wildcards.filename)
        shell:
            '{params.refcon_path} get {wildcards.filename} {output}'


    rule refcon_cache_manifests:
        input:
            manifests = expand(
                'cache/refcon/{refcon_name}.manifest',
                refcon_name=load_reference_container_names()
            )
        output:
            cache = 'cache/refcon/refcon_manifests.cache'
        run:
            merged_manifests = []
            for manifest_file in input.manifests:
                container_name = pathlib.Path(manifest_file).stem
                manifest = pandas.read_csv(manifest_file, sep='\t', header=0)
                manifest['refcon_name'] = container_name
                merged_manifests.append(manifest)
            merged_manifests = pandas.concat(merged_manifests, axis=0, ignore_index=False)

            merged_manifests.to_csv(output.cache, header=True, index=False, sep='\t')
        # END OF RUN BLOCK
