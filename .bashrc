#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias sysinfo='sh /home/marko/.config/scripts/screenfetch'
PS1='[\u@\h \W]\$ '

export PATH=$PATH:/home/marko/programs/zig-0.15.2
export PATH=$PATH:/home/marko/programs/zls
export PATH=$PATH:/home/marko/programs/ccls/Release
export PATH=$PATH:/home/marko/programs/nnd
export PATH=$PATH:/home/marko/programs/blender5.0
export PATH=$PATH:/home/marko/programs/renderdoc_1.41/bin
export PATH=$PATH:/home/marko/programs/desmume

source /home/marko/programs/vulkan-sdk/1.4.328.1/setup-env.sh

