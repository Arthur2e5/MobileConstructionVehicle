#! /bin/bash
# common.sh - A simple bash library for MCV.
# ------------------------------------------
# Copyright 2015 Guanrenfu (GitHub)
# Copyright 2015 Mingye Wang <arthur200126@gmail.com>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
shopt -s extglob expand_aliases
# stdio redirection for logging
mcvstd(){ $mcvlog >> $mcvproc_out; }	# out
mcverr(){ $mcvlog >> $mcvproc_err; }	# error
mcverb(){ $mcvlog >> $mcvproc_erb; }	# verbose
# wraped logging
mcvlog(){
	[ "$2" ] || return 2
	local log_verbose=$1 prefix=$2
	shift 2
	echo "$@" | mcverr
	if ((mcv_verbose < log_verbose)); then
		echo -e "$prefix\t$@" | mcverb
	else
		echo -e "$prefix\t$@" | tee /dev/stderr | mcverr
	fi
}
# easy and quick aliases.
fatal(){ mcvlog 0 FF "$@"; }
error(){ mcvlog 1 EE "$@"; }
warn(){ mcvlog 2 WW "$@"; }
info(){ mcvlog 3 II "$@"; }
verbose(){ mcvlog 4 VV "$@"; }
debug(){ mcvlog 5 DD "$@"; }
die(){ fatal "$1"; exit ${2-1}; }
bye(){ echo "$@"; exit 0; }
mcv_lib(){	[ "$(basename "$0")" == "$1".sh ] && die $"请勿直接运行此文件。"; }
mcv_lib common

msg_blk(){
	echo
	for i; do echo "$i"; done
	echo
}
# ui.
yesno_query(){
	local PS3="${1:$PS3}" sentence bool
	shift
	for i; do echo -e "$sentence"; done
	select bool in Yes No; do if [ "$bool" == Yes ]; then return 0; else return 1; fi; done;
}
yesno_prepend(){
	yesno_query $"输入你的选择：" "$@"
}
# mcvfile
mcvsh_paragraph(){ echo -e "\n\n$@" >> mcv.sh; }
mcvdo(){ echo "$@" >> mcv.sh; }
# options parsing
mcv_verbose=3
if [ "$1" == --help ]; then
	echo -e $"$0, 一个自动配置程序。"
	echo
	echo -e $"用法："
	echo -e "-v\t"$"啰嗦一点。"
	echo -e "-q\t"$"安静一点。"
	for _help_opt in ${!mcvopts[@]}; do
		echo -e "-$_help_opt\t${mcvopts[_help_opt]}"
	done
	exit 0
fi
mcvopt="${!mcvopts[*]}" # 移除空格
while getopts "vq${mcvopt// }"; do
	case $opt in
		(v)	((mcv_verbose++));;
		(n) ((mcv_verbose--));;
		(*)	mcv_cmdline_$opt;;
	esac
done
unset mcvopt
reset
