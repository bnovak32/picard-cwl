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
  
baseCommand: [ picard, CollectHsMetrics ]

arguments:
  - prefix: --OUTPUT
    valueFrom: $(inputs.alignments.nameroot).hs_metrics.txt

inputs:
  alignments:
    doc: SAM or BAM format alignment file
    format:
      - edam:format_2573  # SAM
      - edam:format_2572  # BAM
    type: File
    inputBinding:
      prefix: "--INPUT"

  baits:
    label: Bait Interval list
    type: File
    inputBinding:
      prefix: "--BAIT_INTERVALS"
    doc: An interval list file that contains the locations of the baits used in the capture.

  targets:
    label: Target Interval list
    type: File
    inputBinding:
      prefix: "--TARGET_INTERVALS"
    doc: |
      An interval list file that contains the locations of the targets. This 
      corresponds to where the baits were designed to generate coverage. If 
      this file is not available, use the same file as used for bait intervals.

  reference:
    label: Reference genome
    type: File?
    secondaryFiles:
      - ^.dict?
      - .fai
    inputBinding: 
      prefix: "--REFERENCE_SEQUENCE"
    doc: |
      (Optional) The reference genome used to generate the aligned file and 
      interval lists. Without this file, the AT and GC dropout metrics cannot 
      be generated.

  near_distance:
    label: Near distance
    type: int?
    inputBinding: 
      prefix: "--NEAR_DISTANCE"
    doc: |
      (Optional) The maximum distance between a read and a nearest probe, 
      bait, or amplicon for the read to be considered 'near probe' and 
      included in percentage selected. Default value: 250

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
      glob: $(inputs.alignments.nameroot).hsmetrics.log
  metrics:
    type: File
    outputBinding:
      glob: $(inputs.alignments.nameroot).hsmetrics.txt

stderr: $(inputs.alignments.nameroot).hsmetrics.log


$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.25.owl

