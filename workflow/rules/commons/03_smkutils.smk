
localrules:
    dump_config,


rule dump_config:
    output:
        RUN_CONFIG_RELPATH,
    run:
        import yaml

        runinfo = {"_timestamp": get_timestamp(), "_username": get_username()}
        git_labels = collect_git_labels()
        for label, value in git_labels:
            runinfo[f"_{label}"] = value
        # add complete Snakemake config
        runinfo.update(config)
        try:
            del runinfo["devmode"]
        except KeyError:
            pass

        with open(RUN_CONFIG_RELPATH, "w", encoding="ascii") as cfg_dump:
            yaml.dump(runinfo, cfg_dump, allow_unicode=False, encoding="ascii")
        # END OF RUN BLOCK
