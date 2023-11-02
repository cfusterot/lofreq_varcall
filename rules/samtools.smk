import glob
import os
from pathlib import Path


rule samtools_sort:
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
        err="{}/{{sample}}/samtools_sort.err".format(LOGDIR),
        out="{}/{{sample}}/samtools_sort.out".format(LOGDIR),
        time="{}/{{sample}}/samtools_sort.time".format(LOGDIR)
    shell:
        """
        {DATETIME} > {log.time} &&
        samtools sort {input.bam} -o {output.bam}
        {DATETIME} >> {log.time} 
        """

rule samtools_index:
     input:
         bam="{}/{{sample}}/lofreq/{{sample}}.filtered.sorted.bam".format(OUTDIR)
     output:
         bai="{}/{{sample}}/lofreq/{{sample}}.filtered.sorted.bai".format(OUTDIR)
     conda:
         "../envs/samtools.yaml"
     threads: get_resource("samtools", "threads")
     resources:
         mem_mb=get_resource("samtools", "mem_mb"),
     log:
         err="{}/{{sample}}/samtools_index.err".format(LOGDIR),
         out="{}/{{sample}}/samtools_index.out".format(LOGDIR)
     shell:
         """
         samtools index {input.bam} {output.bai}
         """
