#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

doc: |
  Collect hybrid-selection (HS) metrics for a set of aligned files. 

requirements:
  ScatterFeatureRequirement: {}
  
inputs:
  alignments:
    doc: SAM or BAM format alignment files
    type: File[]
    format:
      - edam:format_2573  # SAM
      - edam:format_2572  # BAM
    
  baits:
    label: Bait Interval list
    type: File
    doc: An interval list file that contains the locations of the baits used in the capture.

  targets:
    label: Target Interval list
    type: File
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
    doc: |
      (Optional) The reference genome used to generate the aligned file and 
      interval lists. Without this file, the AT and GC dropout metrics cannot 
      be generated.

  near_distance:
    label: Near distance
    type: int?
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

outputs:
  log:
    type: File[]
    outputSource: hsmetrics/log
  metrics:
    type: File[]
    outputSource: hsmetrics/metrics

steps:
  hsmetrics:
    run: hsmetrics.cwl
    scatter: alignments
    in:
      alignments: alignments
      baits: baits
      targets: targets
      reference: reference
      near_distance: near_distance
      validation_stringency: validation_stringency
    out:
      - log
      - metrics

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.25.owl

