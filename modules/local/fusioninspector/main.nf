process FUSIONINSPECTOR {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::dfam=3.3 bioconda::hmmer=3.3.2 bioconda::star-fusion=1.12.0 bioconda::samtools=1.9 bioconda::star=2.7.8a"
    container 'docker.io/trinityctat/starfusion:1.12.0'

    input:
    tuple val(meta), path(reads), path(fusion_list)
    path reference

    output:
    tuple val(meta), path("*FusionInspector.fusions.tsv")    , emit: tsv
    path "*"                                                 , emit: output
    path "versions.yml"                                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def fasta = meta.single_end ? "--left_fq ${reads[0]}" : "--left_fq ${reads[0]} --right_fq ${reads[1]}"
    def args = task.ext.args ?: ''
    """
    FusionInspector \\
        --fusions $fusion_list \\
        --genome_lib ${reference} \\
        $fasta \\
        --CPU ${task.cpus} \\
        -O . \\
        --out_prefix $prefix \\
        --vis $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        STAR-Fusion: \$(STAR-Fusion --version 2>&1 | grep -i 'version' | sed 's/STAR-Fusion version: //')
    END_VERSIONS
    """

    stub:
    """
    touch FusionInspector.log
    touch FusionInspector.fusions.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        STAR-Fusion: \$(STAR-Fusion --version 2>&1 | grep -i 'version' | sed 's/STAR-Fusion version: //')
    END_VERSIONS
    """
}
