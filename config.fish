set -x XDG_CONFIG_HOME "$HOME/.config"
set -x PATH $PATH "$HOME/.linuxbrew/bin"
set -x MANPATH $MANPATH "$HOME/.linuxbrew/share/man"
set -x INFOPATH $INFOPATH "$HOME/.linuxbrew/share/info"
set -x GOPATH "$HOME/dev/go"
set -x PATH $PATH "$GOPATH/bin"
set -x PATH $PATH "$HOME/.arduino"
set -x PATH $PATH "$HOME/.config/composer/vendor/bin"

set -x PATH $HOME/.rbenv/bin $PATH
set -x PATH $HOME/.rbenv/shims $PATH
rbenv rehash >/dev/null ^&1

set -x NODE_PATH /home/yuki/.linuxbrew/lib/node_modules

source $HOME/.enhancd/fish/enhancd.fish
function cd
    cd::cd $argv
end

function nvcd
    nvr -c "cd "(realpath $argv)
end

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
