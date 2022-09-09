
localrules:
    dump_config,


rule dump_config:
    output:
        RUN_CONFIG_RELPATH,
    run:
        import yaml

        runinfo = {"_timestamp": get_timestamp(), "_username": get_username()}
        runinfo.update(config)
        with open(RUN_CONFIG_RELPATH, "w", encoding="ascii") as cfg_dump:
            yaml.dump(runinfo, cfg_dump, allow_unicode=False, encoding="ascii")
        # END OF RUN BLOCK
