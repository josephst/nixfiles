#!/usr/bin/env bash

# Brother's file action, with private intermediate files and completion-safe
# publication into the configured scan directory.
set -u

SCAN_DIR="${BRSCAN_SKEY_SCAN_DIR:-$HOME/brscan}"
STAGING_DIR="${BRSCAN_SKEY_STAGING_DIR:-$HOME/.brscan-skey-staging}"
SCANIMAGE="${BRSCAN_SKEY_SCANIMAGE:-/opt/brother/scanner/brscan-skey/skey-scanimage}"

log_message() {
  # The vendor daemon can detach stdout/stderr, so keep failures in journald.
  logger -t brscan-skey -- "$*" 2>/dev/null || :
  printf '%s\n' "$*" >&2
}

if ! mkdir -p "$SCAN_DIR" || ! (umask 077; mkdir -p "$STAGING_DIR") || ! chmod 0700 "$STAGING_DIR"; then
  log_message "cannot create scan or staging directory: scan=$SCAN_DIR staging=$STAGING_DIR"
  exit 1
fi

if [ -r "$HOME/.brscan-skey/scantofile.config" ]; then
  # shellcheck disable=SC1090,SC1091
  . "$HOME/.brscan-skey/scantofile.config"
elif [ -r /etc/opt/brother/scanner/brscan-skey/scantofile.config ]; then
  # shellcheck disable=SC1091
  . /etc/opt/brother/scanner/brscan-skey/scantofile.config
fi

DEVICE_NAME=${1-}
if [ -z "$DEVICE_NAME" ]; then
  log_message "scan failed: no device name supplied"
  exit 2
fi

JOB_DIR=$(mktemp -d "$STAGING_DIR/job.XXXXXX") || {
  log_message "scan failed: cannot create private staging directory under $STAGING_DIR"
  exit 1
}
OUTPUT="$SCAN_DIR/brscan_$(date +%Y-%m-%d-%H-%M-%S)_${JOB_DIR##*.}.pdf"
STAGING_OUTPUT="$JOB_DIR/scan.tif"
COMPRESSED_OUTPUT="$JOB_DIR/scan.lzw.tif"
STAGING_PDF="$JOB_DIR/scan.pdf"
pdf_complete=0
PUBLICATION_TEMP=""

# Invoked by the EXIT trap, including the explicit failure exits below.
# shellcheck disable=SC2329
cleanup() {
  local status=$?
  local temporary_files=("$STAGING_OUTPUT" "$COMPRESSED_OUTPUT")
  if [ -n "$PUBLICATION_TEMP" ]; then
    temporary_files+=("$PUBLICATION_TEMP")
  fi
  if [ "$pdf_complete" -eq 0 ]; then
    temporary_files+=("$STAGING_PDF")
  fi
  if ! rm -f -- "${temporary_files[@]}"; then
    log_message "could not remove temporary files from $JOB_DIR"
  fi
  if [ ! -e "$STAGING_PDF" ] && ! rmdir "$JOB_DIR"; then
    log_message "could not remove private job directory: $JOB_DIR"
  fi
  return "$status"
}
trap 'cleanup' EXIT

resolution=${resolution:-100}
size=${size:-Letter}
duplex=${duplex:-}

SCAN_ARGS=(--device-name "$DEVICE_NAME" --resolution "$resolution" --size "$size")
if [ "$duplex" = ON ]; then
  SCAN_ARGS+=(--duplex --source ADF_C)
else
  SCAN_ARGS+=(--source FB)
fi
SCAN_ARGS+=(--outputfile "$STAGING_OUTPUT")

if [[ "$DEVICE_NAME" == *net* ]]; then
  sleep 1
fi

scan_status=1
for attempt in 1 2; do
  rm -f -- "$STAGING_OUTPUT"
  if "$SCANIMAGE" "${SCAN_ARGS[@]}"; then
    scan_status=0
  else
    scan_status=$?
  fi
  if [ "$scan_status" -eq 0 ] && [ -s "$STAGING_OUTPUT" ]; then
    break
  fi
  log_message "scan attempt $attempt failed with exit code $scan_status; output=$STAGING_OUTPUT"
  if [ "$scan_status" -eq 0 ]; then
    scan_status=1
  fi
  [ "$attempt" -eq 2 ] || sleep 1
done

if [ "$scan_status" -ne 0 ] || [ ! -s "$STAGING_OUTPUT" ]; then
  log_message "scan failed with exit code $scan_status; private output=$STAGING_OUTPUT"
  exit "$scan_status"
fi

if tiffcp -c lzw "$STAGING_OUTPUT" "$COMPRESSED_OUTPUT"; then
  :
else
  conversion_status=$?
  log_message "compression failed with exit code $conversion_status; input=$STAGING_OUTPUT"
  exit "$conversion_status"
fi

if tiff2pdf "$COMPRESSED_OUTPUT" > "$STAGING_PDF"; then
  :
else
  conversion_status=$?
  log_message "PDF conversion failed with exit code $conversion_status; input=$COMPRESSED_OUTPUT"
  exit "$conversion_status"
fi

if [ ! -s "$STAGING_PDF" ]; then
  log_message "PDF conversion failed with exit code 0: output is empty; private output=$STAGING_PDF"
  exit 1
fi
pdf_complete=1

# Stage the completed PDF on the destination mount before the atomic rename.
# Paperless ignores dotfiles; the .tmp suffix also avoids advertising a PDF
# while copying. Keep the private original until publication succeeds.
publish_pdf() {
  PUBLICATION_TEMP=$(mktemp "$SCAN_DIR/.brscan.XXXXXX.tmp") || return $?
  cp -- "$STAGING_PDF" "$PUBLICATION_TEMP" || return $?
  chmod --reference="$STAGING_PDF" -- "$PUBLICATION_TEMP" || return $?
  mv --no-copy -T --update=none-fail -- "$PUBLICATION_TEMP" "$OUTPUT"
}

if publish_pdf; then
  pdf_complete=0
  printf '%s is created.\n' "$OUTPUT"
  exit 0
else
  publish_status=$?
  log_message "publication failed with exit code $publish_status; completed PDF retained at $STAGING_PDF; destination=$OUTPUT"
  exit "$publish_status"
fi
