#!/bin/bash

sample_name() {
  # Remove the file extension. 'a.b.c.def' -> 'a.b.c'
  s=$(basename $f)
  echo "${s%%.*}"
}

warn() {
  echo $@ >&2
}

collate_duplicate_metrics() {
  local out="$1" dir="$2"
  local files=($(find "$dir" -name '*.mdup_metrics.txt' | sort))
  [[ ${#files[@]} -eq 0 ]] && return 1
  warn -e "$(DATE)\tCollating ${#files[@]} duplicate metrics files to ${OUT}"
  (
    echo -ne "SAMPLE\t"
    grep -A1 '## METRICS' "${files[0]}" | tail -n1
    local f
    for f in ${files[*]}
    do
      local sample=$(sample_name "$f")
      grep -A2 '## METRICS' "$f" | tail -n1 \
        | awk -v OFS='\t' -v SAMPLE=$sample '{print SAMPLE,$0}'
    done
  ) | awk -f $SCRIPTDIR/transpose.awk > "$out"
}

collate_hs_metrics() {
  local out="$1" dir="$2" scriptdir="$3"
  local files=($(find "$dir" -name '*.hs_metrics.txt' | sort))
  [[ ${#files[@]} -eq 0 ]] && return 1
  warn -e "$(DATE)\tCollating ${#files[@]} hs_metrics files to ${OUT}"
  (
    # echo -ne "SAMPLE\n"
    grep -A1 '## METRICS' "${files[0]}" | tail -n1 | cut -f 1-66 \
      | awk -v OFS='\t' '{print "SAMPLE",$0}'
    local f
    for f in ${files[*]}
    do
      local sample=$(sample_name "$f")
      grep -A2 '## METRICS' "$f" | tail -n1 | cut -f 1-66 \
        | awk -v OFS='\t' -v SAMPLE=$sample '{print SAMPLE,$0}'
    done
  ) | awk -f $SCRIPTDIR/transpose.awk > "$out"
}

PREFIX=$1 DIR=$2 TYPE=$3

SCRIPTDIR=$(dirname "$0")
echo $SCRIPTDIR

collate_duplicate_metrics ${PREFIX}.all_dup_metrics.txt "$DIR"
collate_hs_metrics ${PREFIX}.all_hs_metrics.txt "$DIR"
