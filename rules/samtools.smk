import glob
import os
from pathlib import Path


rule samtools:
    input:
        bam=lambda wc: expand("{DIR}/{{sample}}.filtered.bam", DIR = units.loc[wc.sample]['bam'])
    output:
        bam="{}/{{sample}}/lofreq/{{sample}}.filtered.sorted.bam".format(OUTDIR)
    conda:
        "../envs/samtools.yaml"
    threads: get_resource("samtools", "threads")
    resources:
        mem_mb=get_resource("samtools", "mem_mb"),
        walltime=get_resource("samtools", "walltime")
    log:
        err="{}/{{sample}}/samtools.err".format(LOGDIR),
        out="{}/{{sample}}/samtools.out".format(LOGDIR),
        time="{}/{{sample}}/samtools.time".format(LOGDIR)
    shell:
        """
        {DATETIME} > {log.time} &&
        samtools sort {input.bam} -o {output.bam}
        {DATETIME} >> {log.time} 
        """
