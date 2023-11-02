import pandas as pd
import os

# -- Snakefile basic configuration -- #
report: "report/workflow.rst"
# Include rule files
include: "rules/common.smk"
# Variable declaration
OUTDIR = config["out"]
LOGDIR = config["log"]

# -- Read samples file -- #
try:
    samples = pd.read_csv(config["samples"], sep="\t", comment="#").set_index("sample", drop=False)
    validate(samples, schema="schemas/samples.schema.yaml")
except FileNotFoundError:
    warning(f"ERROR: the samples file ({config['samples']}) does not exist. Please see the README file for details. Quitting now.")
    sys.exit(1)

# -- Read units file -- #
try:
    units = pd.read_csv(config["units"], dtype=str, sep="\t", comment="#").set_index(["sample"], drop=False)
    validate(units, schema="schemas/units.schema.yaml")
except FileNotFoundError:
    warning(f"ERROR: the units file ({config['units']}) does not exist. Please see the README file for details. Quitting now.")
    sys.exit(1)    

# -- Auxiliary functions -- #
def get_resource(rule,resource):
    try:
        return config["resources"][rule][resource]
    except KeyError:
        return config["resources"]["default"][resource]

# Create a rule that decides whether an integrated or merged object could be
# the output. For instance: if harmony = TRUE and exists a merged.rds file;
# then the output is mergedintegration.rds

# -- Final output -- #
rule all:
    input:
        expand(["{OUTDIR}/{sample}/lofreq/{sample}.filtered.sorted.bai",
        "{OUTDIR}/{sample}/lofreq/{sample}.finish"], sample=samples['sample'], OUTDIR=OUTDIR)

# -- Rule files -- #
include: "rules/samtools.smk"
include: "rules/lofreq.smk"
