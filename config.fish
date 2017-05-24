set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_CONFIG_HOME $HOME/.config
set -x MANPATH $MANPATH $XDG_DATA_HOME/man
set -x INFOPATH $INFOPATH $XDG_DATA_HOME/info
set -x GOPATH $HOME/.local
set -x GHQ_ROOT $GOPATH/src
set -x GEM_HOME $XDG_DATA_HOME/gem
set -x RBENV_ROOT $XDG_DATA_HOME/rbenv
set -x Z_DATA $XDG_DATA_HOME/z/history
set -x NODE_PATH $HOME/.local/lib/node_modules
set -x PATH $PATH $HOME/.local/bin
set -x PATH $PATH $RBENV_ROOT/shims

rbenv rehash >/dev/null ^&1

function cd
    if count $argv > /dev/null
        builtin cd $argv
    else
        begin;
            echo $HOME
            z -l | awk '{ print $2 }'
        end | fzf | read -l p
        and builtin cd $p
    end
end

function gcd
  ghq list | fzf | read -l p
  and cd (ghq root)/$p
end

function nvcd
    nvr -c "cd "(realpath $argv)
end

eval (python3 -m virtualfish compat_aliases)

function fish_prompt
    function _is_git_repo
        type -q git; or return 1
        git status -s >/dev/null ^/dev/null
    end

    function _git_branch_name
        echo (git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
    end

    function _is_git_dirty
      echo (git status -s --ignore-submodules=dirty ^/dev/null)
    end

    if _is_git_repo
        if [ (_is_git_dirty) ]
            set color (set_color yellow)
        else
            set color (set_color brblue)
        end
        set repo_info ":$color"(_git_branch_name)
    end

    test $SSH_TTY; and printf (set_color red)(whoami)(set_color white)'@'(set_color yellow)(hostname)' '

    test $USER = 'root'; and echo (set_color red)"#"

    # Main
    echo -n -s (set_color cyan)(prompt_pwd) $repo_info ' ' (set_color red)'❯'(set_color yellow)'❯'(set_color green)'❯ '
end
