set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_CONFIG_HOME $HOME/.config
set -x MANPATH $MANPATH $XDG_DATA_HOME/man
set -x INFOPATH $INFOPATH $XDG_DATA_HOME/info
set -x GOPATH $HOME/.local
set -x GHQ_ROOT $GOPATH/src
set -x RBENV_ROOT $XDG_DATA_HOME/rbenv
set -x Z_DATA $XDG_DATA_HOME/z/history
set -x ANDROID_SDK_ROOT $XDG_DATA_HOME/android-sdk
set -x ANDROID_SDK_HOME $XDG_DATA_HOME/android-sdk
set -x ANDROID_HOME $XDG_DATA_HOME/android-sdk
set -x GRADLE_USER_HOME $XDG_DATA_HOME/gradle
set -x NODE_PATH $HOME/.local/lib/node_modules
set -x RUSTUP_HOME $XDG_DATA_HOME/rustup
set -x CARGO_HOME $XDG_DATA_HOME/cargo
set -x MYPYPATH $XDG_DATA_HOME/mypy

function _add_path
    if test -d $argv
        set -x PATH $PATH $argv
    end
end

_add_path $HOME/.local/opt/android-studio/bin
_add_path $HOME/.local/bin
_add_path $RBENV_ROOT/shims
_add_path $ANDROID_SDK_HOME/platform-tools
_add_path $XDG_DATA_HOME/google-cloud-sdk/bin

rbenv init - | source
rbenv rehash >/dev/null ^&1

function _is_git_repo
    git rev-parse --is-inside-work-tree >/dev/null ^/dev/null
end

function _is_git_dirty
    not git diff-index --quiet HEAD
end

function search
    if _is_git_repo
        git ls-files | xargs grep --color $argv
    else
        find . -type f | xargs grep --color $argv
    end
end

function cd
    if count $argv > /dev/null
        if test -e $argv
            builtin cd $argv
        else
            z -l $argv | sed '$d' | awk '{ print $2 }' | fzf -1 | read -l p
            and builtin cd $p
        end
    else
        begin
            echo $HOME
            z -l | awk '{ print $2 }' | sed '$d'
        end | fzf | read -l p
        and builtin cd $p
    end
end

function gcd
    ghq list | fzf | read -l p
    and cd (ghq root)/$p
end

function ctf
    chromix-too ls | fzf | awk '{print $0}' | xargs chromix-too focus
end

function nvcd
    nvr -c "cd "(realpath $argv)
end

function pd
    z -l $argv | sed '$d' | awk '{ print $2 }' | fzf -1
end

function pf
    find ~ | fzf -q $argv -1
end

function gbf
    git branch | awk '{ print $NF }' | fzf
end

function memo
    twty -a privmagu $argv >/dev/null
end

function fish_right_prompt
    function _git_branch_name
        git symbolic-ref --short HEAD ^/dev/null
    end

    if _is_git_repo
        if _is_git_dirty
            set color (set_color yellow)
        else
            set color (set_color brblue)
        end
        set repo_info "$color"(_git_branch_name)
    end

    echo -n -s $repo_info ' ' (set_color cyan)(prompt_pwd)
end

function fish_prompt

    test $SSH_TTY; and printf (set_color red)(whoami)(set_color white)'@'(set_color yellow)(hostname)' '

    test $USER = 'root'; and echo (set_color red)"#"

    # Main
    echo -n -s  (set_color cyan)' ❯❯ '
end
