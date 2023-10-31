import glob
import os
from pathlib import Path

rule indel_qual:
    input:
       bam="{}/{{sample}}/lofreq/{{sample}}.filtered.sorted.bam".format(OUTDIR)
    output:
       bam="{}/{{sample}}/lofreq/{{sample}}.quality.bam".format(OUTDIR)
    params:
       reference=config['genome_reference']
    conda:
       "../envs/lofreq.yaml"
    threads: get_resource("lofreq", "threads")
    resources:
        mem_mb=get_resource("lofreq", "mem_mb"),
        walltime=get_resource("lofreq", "walltime")
    log:
        err="{}/{{sample}}/lofreq.quality.err".format(LOGDIR),
        out="{}/{{sample}}/lofreq.quality.out".format(LOGDIR)
    shell:
        """
        lofreq indelqual --verbose --dindel -f {params.reference} -o {output.bam} {input.bam}
        """

rule lofreq:
    input:
        bam="{}/{{sample}}/lofreq/{{sample}}.quality.bam".format(OUTDIR)
    output:
        finish="{}/{{sample}}/lofreq/{{sample}}.finish".format(OUTDIR),
        vcf="{}/{{sample}}/lofreq/{{sample}}.vcf".format(OUTDIR)
    params:    
        reference=config['genome_reference'],
        region=config['region_file'],
        dbsnp=config['dbsnp']
    conda:
        "../envs/lofreq.yaml"
    threads: get_resource("lofreq", "threads")
    resources:
        mem_mb=get_resource("lofreq", "mem_mb"),
        walltime=get_resource("lofreq", "walltime")
    log:
        err="{}/{{sample}}/lofreq.err".format(LOGDIR),
        out="{}/{{sample}}/lofreq.out".format(LOGDIR),
        time="{}/{{sample}}/lofreq.time".format(LOGDIR)
    shell:
        """
        {DATETIME} > {log.time} &&
        lofreq call -f {params.reference} -l {params.region} --call-indels -S {params.dbsnp} -s -o {output.vcf} {input.bam}        
        touch {output.finish}
        {DATETIME} >> {log.time} 
        """
