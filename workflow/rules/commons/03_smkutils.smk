
localrules:
    dump_config,
    create_manifest,


rule accounting_file_md5_size:
    """
    Compute MD5 checksum and file size
    for accounted files (inputs, references, results).
    For convenience, this rule also computes the file
    size to avoid this overhead at some other place
    of the pipeline.
    """
    input:
        source=load_file_by_path_id,
    output:
        md5=DIR_PROC.joinpath(
            ".accounting", "checksums", "{file_type}", "{file_name}.{path_id}.md5"
        ),
        file_size=DIR_PROC.joinpath(
            ".accounting", "file_sizes", "{file_type}", "{file_name}.{path_id}.bytes"
        ),
    benchmark:
        DIR_RSRC.joinpath(
            ".accounting", "checksums", "{file_type}", "{file_name}.{path_id}.md5.rsrc"
        )
    wildcard_constraints:
        file_type="(" + "|".join(sorted(ACCOUNTING_FILES.keys())) + ")",
    resources:
        time_hrs=lambda wildcards, attempt: 1 * attempt,
        mem_gb=lambda wildcards, attempt: 1 * attempt,
    shell:
        "md5sum {input.source} > {output.md5}"
        " && "
        "stat -c %s {input.source} > {output.file_size}"


rule accounting_file_sha256:
    """
    Compute SHA256 checksum (same as for MD5)
    """
    input:
        source=load_file_by_path_id,
    output:
        sha256=DIR_PROC.joinpath(
            ".accounting", "checksums", "{file_type}", "{file_name}.{path_id}.sha256"
        ),
    benchmark:
        DIR_RSRC.joinpath(
            ".accounting",
            "checksums",
            "{file_type}",
            "{file_name}.{path_id}.sha256.rsrc",
        )
    wildcard_constraints:
        file_type="(" + "|".join(sorted(ACCOUNTING_FILES.keys())) + ")",
    resources:
        time_hrs=lambda wildcards, attempt: 1 * attempt,
        mem_gb=lambda wildcards, attempt: 1 * attempt,
    shell:
        "sha256sum {input.source} > {output.sha256}"


rule dump_config:
    output:
        RUN_CONFIG_RELPATH,
    params:
        acc_in=lambda wildcards, output: register_input(output, allow_non_existing=True),
    run:
        import yaml

        runinfo = {"_timestamp": get_timestamp(), "_username": get_username()}
        git_labels = collect_git_labels()
        for label, value in git_labels:
            runinfo[f"_{label}"] = value
        # add complete Snakemake config
        runinfo.update(config)
        for special_key in ["devmode", "resetacc"]:
            try:
                del runinfo[special_key]
            except KeyError:
                pass

        with open(RUN_CONFIG_RELPATH, "w", encoding="ascii") as cfg_dump:
            yaml.dump(runinfo, cfg_dump, allow_unicode=False, encoding="ascii")
        # END OF RUN BLOCK



rule create_manifest:
    input:
        manifest_files=load_accounting_information,
    output:
        manifest=MANIFEST_RELPATH,
    run:
        import fileinput
        import collections
        import pandas

        records = collections.defaultdict(dict)
        for line in fileinput.input(ACCOUNTING_FILES.values(), mode="r"):
            path_id, path_record = process_accounting_record(line)
            records[path_id].update(path_record)

        df = pandas.DataFrame.from_records(list(records.values()))
        df.sort_values(["file_category", "file_name"], ascending=True)
        reordered_columns = [
            "file_name",
            "file_category",
            "file_size_bytes",
            "file_checksum_md5",
            "file_checksum_sha256",
            "file_path",
            "path_id",
        ]
        assert all(c in df.columns for c in reordered_columns)
        df = df[reordered_columns]
        df.to_csv(output.manifest, header=True, index=False, sep="\t")
        # END OF RUN BLOCK
