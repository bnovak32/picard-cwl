#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: |
  Identify and mark or remove PCR and sequencing duplicates from SAM/BAM/CRAM files.

hints:
  ResourceRequirement:
    coresMin: 1
    ramMin: 3814
  DockerRequirement:
    dockerPull: bnovak32/picard:3.1.0
  
baseCommand: [ picard, MarkDuplicates ]

arguments:
  - prefix: --OUTPUT
    valueFrom: $(inputs.alignments.nameroot).mdup$(inputs.alignments.nameext)
  - prefix: --METRICS_FILE 
    valueFrom: $(inputs.alignments.nameroot).mdup_metrics.txt

inputs:
  alignments:
    label: Input file
    doc: SAM or BAM format alignment file
    format:
      - edam:format_2573  # SAM
      - edam:format_2572  # BAM
    type: File
    inputBinding:
      prefix: "--INPUT"

  remove_duplicates:
    label: Remove duplicates
    doc: Remove duplicates instead of writing them with appropriate flags set.
    type: boolean?
    inputBinding:
      prefix: "--REMOVE_DUPLICATES=true"

  remove_seq_duplicates:
    label: Remove sequencing duplicates?
    doc: |
      Remove duplicates that appear to have been caused by the sequencing process
      instead of library preparation, even if remove duplicates is false. 
    type: boolean?
    inputBinding:
      prefix: "--REMOVE_SEQUENCING_DUPLICATES=true"

  duplicate_scoring_strategy:
    label: Duplicate scoring strategy
    doc: scoring strategy for choosing the non-duplicate among candidates
    type:
      - 'null'
      - type: enum
        symbols:
          - SUM_OF_BASE_QUALITIES
          - TOTAL_MAPPED_REFERENCE_LENGTH
          - RANDOM
    inputBinding:
      prefix: --DUPLICATE_SCORING_STRATEGY

  optical_duplicate_pixel_distance:
    label: Optical duplicate pixel distance
    type: int?
    default: 100
    doc: |
      Maximum offset between two duplicate clusters in order to 
      consider them optical duplicates. Default (100) is 
      appropriate for unpatterend Illumina flowcells. For 
      patterned flowcells, 2500 is more appropriate. 
    inputBinding:
      prefix: --OPTICAL_DUPLICATE_PIXEL_DISTANCE

  barcode_tag:
    label: Barcode tag
    type: string?
    doc: Molecular or Cell barcode SAM tag. For example, BC in 10X genomics data.
    inputBinding:
      prefix: --BARCODE_TAG

  read_name_regex:
    label: Readname regex
    doc: |
      Regex for identifying the tile/cluster positions in the readname, which 
      are used to distinguish sequencing vs. PCR duplicates, allowing for more 
      accurate estimation of library size.
    type: string?
    inputBinding:
      prefix: --READ_NAME_REGEX

  validation_stringency:
    label: Validation stringency
    type:
     - 'null'
     - type: enum
       symbols:
        - STRICT
        - LENIENT
        - SILENT
    inputBinding:
      prefix: --VALIDATION_STRINGENCY

outputs:
  deduped_alignments:
    type: File
    format: $(inputs.alignments.format)
    outputBinding:
      glob: $(inputs.alignments.nameroot).mdup$(inputs.alignments.nameext)
  log:
    type: File
    streamable: true
    outputBinding:
      glob: $(inputs.alignments.nameroot).mdup.log
  metrics:
    type: File
    outputBinding:
      glob: $(inputs.alignments.nameroot).mdup_metrics.txt

stderr: $(inputs.alignments.nameroot).mdup.log

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - https://edamontology.org/EDAM_1.25.owl

