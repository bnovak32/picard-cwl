#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: |
  Collect hybrid-selection (HS) metrics for an aligned file. 

hints:
  ResourceRequirement:
    coresMin: 1
    ramMin: 3814
  DockerRequirement:
    dockerPull: bnovak32/picard:3.1.0
  
baseCommand: [ picard, CollectSequencingArtifactMetrics ]

arguments:
  - prefix: --OUTPUT
    valueFrom: $(inputs.alignments.nameroot)
  - prefix: --FILE_EXTENSION
    valueFrom: ".txt"

inputs:
  alignments:
    doc: SAM or BAM format alignment file
    format:
      - edam:format_2573  # SAM
      - edam:format_2572  # BAM
    type: File
    inputBinding:
      prefix: "--INPUT"

  reference:
    label: Reference genome
    type: File
    secondaryFiles:
      - ^.dict?
      - .fai?
    inputBinding: 
      prefix: "--REFERENCE_SEQUENCE"
    doc: |
      The reference genome used to generate the aligned file and interval lists.

  intervals:
    label: Intervals file
    type: File?
    inputBinding:
      prefix: "--INTERVALS"
    doc: (Optional) Interval file to restrict analysis


  validation_stringency:
    label: Validation Stringency
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
  log:
    type: File
    streamable: true
    outputBinding:
      glob: $(inputs.alignments.nameroot).seqartifact_metrics.log
  pre_adapter_detail:
    type: File
    outputBinding:
      glob: $(inputs.alignments.nameroot).pre_adapter_detail_metrics.txt
  pre_adapter_summary_metrics:
    type: File
    outputBinding:
      glob: $(inputs.alignments.nameroot).pre_adapter_summary_metrics.txt
  bait_bias_detail_metrics:
    type: File
    outputBinding:
      glob: $(inputs.alignments.nameroot).bait_bias_detail_metrics.txt
  error_summary_metrics:
    type: File
    outputBinding:
      glob: $(inputs.alignments.nameroot).error_summary_metrics.txt

stderr: $(inputs.alignments.nameroot).seqartifact_metrics.log

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - https://edamontology.org/EDAM_1.25.owl

