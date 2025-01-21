#!/usr/bin/env sh
set -eu
main() {
  need_cmd uname
  need_cmd mktemp
  need_cmd chmod
  need_cmd mkdir
  need_cmd rm
  need_cmd rmdir
  need_cmd tar
  need_cmd zstd
  need_cmd hg
  need_cmd git
  # need_cmd clang
  need_cmd grep
  need_cmd awk
  need_cmd head
  need_cmd tail
  export INFRA_HOST_CONFIG=$(cat /proc/sys/kernel/hostname).sxp
  export INFRA_HOST_ENV=$(cat /proc/sys/kernel/hostname).env
  rm -f $INFRA_HOST_CONFIG
  rm -f $INFRA_HOST_ENV
  check_mem
  local _mem_total="$RETVAL"
  check_disk
  check_mod kvm
  check_mod btrfs
  get_architecture || return 1
  local _arch="$RETVAL"
  assert_nz "$_arch" "arch"
  _write ";;; $INFRA_HOST_CONFIG -*- mode:skel -*-"
  _write ":arch \"$_arch\""
  kernel_version
  local _kernel_version="$RETVAL"
  _write ":kernel \"$_kernel_version\""
  check_cpus
  local _num_cpus="$RETVAL"
  _write ":cpus $_num_cpus"
  _write ":mem $_mem_total"
  case "$_arch" in
    *windows*)
      _write ":ext \"exe\""
      ;;
    *)
      _write ":ext nil"
  esac
  write_env
  say $INFRA_HOST_ENV
  say $INFRA_HOST_CONFIG

}

say() {
  printf '%s\n' "$1"
}

_write_var() {
  say "$1=$(eval echo "\$$1" 2> /dev/null)" >> $INFRA_HOST_ENV
}

_write() {
  say "$1" >> $INFRA_HOST_CONFIG
}

err() {
  say "$1" >&2
  exit 1
}

assert_nz() {
  if [ -z "$1" ]; then err "assert_nz $2"; fi
}

check_cmd() {
  command -v "$1" > /dev/null 2>&1
}

need_cmd() {
  if ! check_cmd "$1"; then
    err "need '$1' (command not found)"
  fi
}

ensure() {
  if ! "$@"; then err "command failed: $*"; fi
}

check_proc() {
  # Check for /proc by looking for the /proc/self/exe link
  # This is only run on Linux
  if ! test -L /proc/self/exe ; then
    err "fatal: Unable to find /proc/self/exe.  Is /proc mounted?  Installation cannot proceed without /proc."
  fi
}

get_bitness() {
  # Architecture detection without dependencies beyond coreutils.
  # ELF files start out "\x7fELF", and the following byte is
  #   0x01 for 32-bit and
  #   0x02 for 64-bit.
  # The printf builtin on some shells like dash only supports octal
  # escape sequences, so we use those.
  local _current_exe_head
  _current_exe_head=$(head -c 5 /proc/self/exe )
  if [ "$_current_exe_head" = "$(printf '\177ELF\001')" ]; then
    echo 32
  elif [ "$_current_exe_head" = "$(printf '\177ELF\002')" ]; then
    echo 64
  else
    err "unknown platform bitness"
  fi
}

is_host_amd64_elf() {
  # ELF e_machine detection without dependencies beyond coreutils.
  # Two-byte field at offset 0x12 indicates the CPU,
  # but we're interested in it being 0x3E to indicate amd64, or not that.
  local _current_exe_machine
  _current_exe_machine=$(head -c 19 /proc/self/exe | tail -c 1)
  [ "$_current_exe_machine" = "$(printf '\076')" ]
}

get_endianness() {
  local cputype=$1
  local suffix_eb=$2
  local suffix_el=$3

  # detect endianness without od/hexdump, like get_bitness() does.
  local _current_exe_endianness
  _current_exe_endianness="$(head -c 6 /proc/self/exe | tail -c 1)"
  if [ "$_current_exe_endianness" = "$(printf '\001')" ]; then
    echo "${cputype}${suffix_el}"
  elif [ "$_current_exe_endianness" = "$(printf '\002')" ]; then
    echo "${cputype}${suffix_eb}"
  else
    err "unknown platform endianness"
  fi
}

get_architecture() {
  local _ostype _cputype _bitness _arch _clibtype
  _ostype="$(uname -s)"
  _cputype="$(uname -m)"
  _clibtype="gnu"

  if [ "$_ostype" = Linux ]; then
    if [ "$(uname -o)" = Android ]; then
      _ostype=Android
    fi
    if ldd --version 2>&1 | grep -q 'musl'; then
      _clibtype="musl"
    fi
  fi

  if [ "$_ostype" = Darwin ] && [ "$_cputype" = i386 ]; then
    # Darwin `uname -m` lies
    if sysctl hw.optional.x86_64 | grep -q ': 1'; then
      _cputype=x86_64
    fi
  fi

  if [ "$_ostype" = SunOS ]; then
    # Both Solaris and illumos presently announce as "SunOS" in "uname -s"
    # so use "uname -o" to disambiguate.  We use the full path to the
    # system uname in case the user has coreutils uname first in PATH,
    # which has historically sometimes printed the wrong value here.
    if [ "$(/usr/bin/uname -o)" = illumos ]; then
      _ostype=illumos
    fi

    # illumos systems have multi-arch userlands, and "uname -m" reports the
    # machine hardware name; e.g., "i86pc" on both 32- and 64-bit x86
    # systems.  Check for the native (widest) instruction set on the
    # running kernel:
    if [ "$_cputype" = i86pc ]; then
      _cputype="$(isainfo -n)"
    fi
  fi

  case "$_ostype" in

    Android)
      _ostype=linux-android
      ;;

    Linux)
      check_proc
      _ostype=unknown-linux-$_clibtype
      _bitness=$(get_bitness)
      ;;

    FreeBSD)
      _ostype=unknown-freebsd
      ;;

    NetBSD)
      _ostype=unknown-netbsd
      ;;

    DragonFly)
      _ostype=unknown-dragonfly
      ;;

    Darwin)
      _ostype=apple-darwin
      ;;

    illumos)
      _ostype=unknown-illumos
      ;;

    MINGW* | MSYS* | CYGWIN* | Windows_NT)
      _ostype=pc-windows-gnu
      ;;

    *)
      err "unrecognized OS type: $_ostype"
      ;;

  esac

  case "$_cputype" in

    i386 | i486 | i686 | i786 | x86)
      _cputype=i686
      ;;

    xscale | arm)
      _cputype=arm
      if [ "$_ostype" = "linux-android" ]; then
        _ostype=linux-androideabi
      fi
      ;;

    armv6l)
      _cputype=arm
      if [ "$_ostype" = "linux-android" ]; then
        _ostype=linux-androideabi
      else
        _ostype="${_ostype}eabihf"
      fi
      ;;

    armv7l | armv8l)
      _cputype=armv7
      if [ "$_ostype" = "linux-android" ]; then
        _ostype=linux-androideabi
      else
        _ostype="${_ostype}eabihf"
      fi
      ;;

    aarch64 | arm64)
      _cputype=aarch64
      ;;

    x86_64 | x86-64 | x64 | amd64)
      _cputype=x86_64
      ;;

    mips)
      _cputype=$(get_endianness mips '' el)
      ;;

    mips64)
      if [ "$_bitness" -eq 64 ]; then
        # only n64 ABI is supported for now
        _ostype="${_ostype}abi64"
        _cputype=$(get_endianness mips64 '' el)
      fi
      ;;

    ppc)
      _cputype=powerpc
      ;;

    ppc64)
      _cputype=powerpc64
      ;;

    ppc64le)
      _cputype=powerpc64le
      ;;

    s390x)
      _cputype=s390x
      ;;
    riscv64)
      _cputype=riscv64gc
      ;;
    loongarch64)
      _cputype=loongarch64
      ;;
    *)
      err "unknown CPU type: $_cputype"

  esac

  # Detect 64-bit linux with 32-bit userland
  if [ "${_ostype}" = unknown-linux-gnu ] && [ "${_bitness}" -eq 32 ]; then
    case $_cputype in
      x86_64)
        if [ -n "${CPUTYPE:-}" ]; then
          _cputype="$CPUTYPE"
        else {
          # 32-bit executable for amd64 = x32
          if is_host_amd64_elf; then {
            echo "This host is running an x32 userland; as it stands, x32 support is poor," 1>&2
            echo "and there isn't a native toolchain -- you will have to install" 1>&2
            echo "multiarch compatibility with i686 and/or amd64, then select one" 1>&2
            echo "by re-running this script with the CPUTYPE environment variable" 1>&2
            echo "set to i686 or x86_64, respectively." 1>&2
            exit 1
          }; else
            _cputype=i686
          fi
        }; fi
        ;;
      mips64)
        _cputype=$(get_endianness mips '' el)
        ;;
      powerpc64)
        _cputype=powerpc
        ;;
      aarch64)
        _cputype=armv7
        if [ "$_ostype" = "linux-android" ]; then
          _ostype=linux-androideabi
        else
          _ostype="${_ostype}eabihf"
        fi
        ;;
      riscv64gc)
        err "riscv64 with 32-bit userland unsupported"
        ;;
    esac
  fi

  if [ "$_ostype" = "unknown-linux-gnueabihf" ] && [ "$_cputype" = armv7 ]; then
    if ensure grep '^Features' /proc/cpuinfo | grep -q -v neon; then
      # At least one processor does not have NEON.
      _cputype=arm
    fi
  fi

  _arch="${_cputype}-${_ostype}"

  RETVAL="$_arch"
}

mem_total () {
  local _mem_total
  _mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
  RETVAL="$_mem_total"
}

check_mem () {
  mem_total
  local _mem_total="$RETVAL"
  local _mem_min=8388608 # 8Gb in kB
  if [ "$_mem_total" -lt "$_mem_min" ]; then
    err "not enough memory: $_mem_total < $_mem_min";
  fi
}

disk_free () {
  local _disk_free
  _disk_free=$(df . | tail -n1 | awk '{print $4}')
  RETVAL="${_disk_free}"
}

check_disk () {
  disk_free
  local _disk_free="$RETVAL"
  local _disk_min=33554432 # in bytes
  if [ "$_disk_free" -lt "$_disk_min" ]; then
    err "not enough disk space: $_disk_free < $_disk_min"
  fi
}

kernel_version () {
  local _kernel_version
  _kernel_version=$(uname -r)
  RETVAL="$_kernel_version"
}

check_mod () {
  if ! lsmod | grep -wq "$1"; then
    err "kernel module $1 isn't loaded"
  fi
}

num_cpus () {
  local _num_cpus
  _num_cpus=$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)
  RETVAL="$_num_cpus"
  # sysctl -n hw.ncpu # nproc --all
}

check_cpus () {
  num_cpus
  local _num_cpus="$RETVAL"
  local _min_cpus=8
  if [ "$_num_cpus" -lt "$_min_cpus" ]; then
    err "not enough cpu threads ($_num_cpus < $_min_cpus)"
  fi
}

write_env () {
  _write_var STASH
  _write_var STORE
  _write_var DIST
  _write_var PACKY_URL
  _write_var VC_URL
  _write_var INSTALL_PREFIX
  _write_var CC
  _write_var AR
  _write_var HG
  _write_var GIT
  _write_var LISP
  _write_var RUST
  _write_var LD
  _write_var SHELL
  _write_var DEV
  _write_var DEV_HOME
  _write_var ID
  _write_var CARGO_HOME
  _write_var RUSTUP_HOME
  _write_var LISP_HOME
}

main "$@" || exit 1
