#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias sysinfo='sh /home/marko/.config/scripts/screenfetch'
PS1='[\u@\h \W]\$ '

export PATH=$PATH:~/programs/zig-0.15.0
