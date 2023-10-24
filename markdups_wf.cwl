#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

doc: |
  Removal of duplicates from aligned reads.

requirements:
  ScatterFeatureRequirement: {}
  
inputs:
  input_files:
    doc: SAM or BAM format alignment files
    type: File[]
    format: 
      - edam:format_2572
      - edam:format_2573

  remove_duplicates:
    label: Remove duplicates
    doc: Remove duplicates instead of writing them with appropriate flags set.
    type: boolean?

  remove_seq_duplicates:
    label: Remove sequencing duplicates?
    doc: |
      Remove duplicates that appear to have been caused by the sequencing process
      instead of library preparation, even if remove duplicates is false. 
    type: boolean?

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

  optical_duplicate_pixel_distance:
    label: Optical duplicate pixel distance
    type: int?
    default: 100
    doc: |
      Maximum offset between two duplicate clusters in order to 
      consider them optical duplicates. Default (100) is 
      appropriate for unpatterend Illumina flowcells. For 
      patterned flowcells, 2500 is more appropriate. 

  barcode_tag:
    label: Barcode tag
    type: string?
    doc: Molecular or Cell barcode SAM tag. For example, BC in 10X genomics data.

  read_name_regex:
    label: Readname regex
    doc: |
      Regex for identifying the tile/cluster positions in the readname, which 
      are used to distinguish sequencing vs. PCR duplicates, allowing for more 
      accurate estimation of library size.
    type: string?

  validation_stringency:
    label: Validation stringency
    type:
     - 'null'
     - type: enum
       symbols:
        - STRICT
        - LENIENT
        - SILENT

outputs:
  deduped_files:
    type: File[]
    outputSource: mdup/deduped_alignments
  log_files:
    type: File[]
    outputSource: mdup/log
  metrics_files:
    type: File[]
    outputSource: mdup/metrics

steps:
  mdup:
    run: markdups.cwl
    scatter: alignments
    in:
      alignments: input_files
      remove_duplicates: remove_duplicates
      remove_seq_duplicates: remove_seq_duplicates
      validation_stringency: validation_stringency
      duplicate_scoring_strategy: duplicate_scoring_strategy
      read_name_regex: read_name_regex
      optical_duplicate_pixel_distance: optical_duplicate_pixel_distance
      barcode_tag: barcode_tag
    out:
      - deduped_alignments
      - log
      - metrics

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.25.owl

