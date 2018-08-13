set HOMEBREW_ROOT /home/linuxbrew/.linuxbrew
set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x MANPATH $MANPATH $XDG_DATA_HOME/man
set -x INFOPATH $INFOPATH $XDG_DATA_HOME/info
set -x CC clang
set -x CXX clang++
set -x PKG_CONFIG_PATH "$PKG_CONFIG_PATH:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig:$HOMEBREW_ROOT/lib/pkgconfig:$HOMEBREW_ROOT/share/pkgconfig"
set -x CFLAGS "$CFLAGS -I$HOMEBREW_ROOT/include"
set -x CPATH "$CPATH $HOMEBREW_ROOT/include"
set -x LDFLAGS "$LDFLAGS -L$HOMEBREW_ROOT/lib"
set -x LIBRARY_PATH "$LIBRARY_PATH $HOMEBREW_ROOT/lib"
set -x LD_LIBRARY_PATH "/usr/lib/x86_64-linux-gnu:/usr/local/lib:$HOMEBREW_ROOT/lib"
set -x HOMEBREW_VERBOSE 1
set -x GOPATH $HOME/.local
set -x GHQ_ROOT $GOPATH/src
set -x RBENV_ROOT $XDG_DATA_HOME/rbenv
set -x Z_DATA $XDG_DATA_HOME/z/history
set -x ANDROID_SDK_ROOT $XDG_DATA_HOME/android-sdk
set -x ANDROID_SDK_HOME $XDG_DATA_HOME/android-sdk
set -x ANDROID_HOME $XDG_DATA_HOME/android-sdk
set -x GRADLE_USER_HOME $XDG_DATA_HOME/gradle
set -x NODE_PATH $XDG_DATA_HOME/npm/lib/node_modules
set -x NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/npmrc
set -x JAVA_HOME $HOME/.local/opt/jdk-9.0.1
set -x RUSTUP_HOME $XDG_DATA_HOME/rustup
set -x CARGO_HOME $XDG_DATA_HOME/cargo
set -x MYPYPATH $XDG_DATA_HOME/mypy
set -x AWS_SHARED_CREDENTIALS_FILE $XDG_CONFIG_HOME/aws/credentials
set -x AWS_CONFIG_FILE $XDG_CONFIG_HOME/aws/config

function _add_path
    if test -d $argv
        set -x PATH $argv $PATH
    end
end

_add_path $HOME/.local/opt/android-studio/bin
_add_path $HOME/.local/bin
_add_path $HOMEBREW_ROOT/bin
_add_path $ANDROID_SDK_HOME/platform-tools
_add_path $XDG_DATA_HOME/linuxbrew/bin
_add_path $XDG_DATA_HOME/npm/bin
_add_path $JAVA_HOME/bin
_add_path $CARGO_HOME/bin
_add_path /usr/lib/google-cloud-sdk/platform/google_appengine
_add_path $HOME/.local/opt/Postman

rbenv init - | source

salias __init__ | source

function _is_git_repo
    git rev-parse --is-inside-work-tree >/dev/null ^/dev/null
end

function search
    if _is_git_repo
        git ls-files | xargs grep --color $argv
    else
        find . -type f | xargs grep --color $argv
    end
end

if not functions -q _orig_cd
    functions -c cd _orig_cd
end

function cd
    if count $argv >/dev/null
        if test -e $argv; or test $argv = -
            set dist $argv
        else
            z -l $argv | sed '$d' | awk '{ print $2 }' | fzf -1 | read -l p
            and set dist $p
        end
    else
        begin
            echo $HOME
            z -l | awk '{ print $2 }' | sed '$d'
        end | fzf | read -l p
        and set dist $p
    end
    and _orig_cd $dist
end

function fish_right_prompt
    function _is_git_repo
        git rev-parse --is-inside-work-tree >/dev/null ^/dev/null
    end

    function _is_git_dirty
        not git diff --exit-code --quiet
        or not git diff --staged --exit-code --quiet
    end

    function _git_branch_name
        git symbolic-ref --short HEAD ^/dev/null
    end

    if _is_git_repo
        _is_git_dirty
            and set color (set_color yellow)
            or set color (set_color brblue)

        set repo_info "$color"(_git_branch_name)
    end

    echo -n -s $repo_info ' ' (set_color cyan)(prompt_pwd)
end

function tmux
    command tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf $argv
end

function gcd
    find $GHQ_ROOT -regex $GHQ_ROOT'.*/\(\..*\|vendor\|node_modules\|.*test.*\)$' -prune -o -type d -path $GHQ_ROOT'/*/*/*' -printf '%P\n' | fzf | read -l p
    and cd (ghq root)/$p
end

function ctf
    chromix-too ls | fzf | awk '{print $0}' | xargs chromix-too focus
end

function nvo
    if test -d $argv
        read -P'It\'s directory. Sure? ' a
        and test "$a" = 'y'
        or return
    end

    nvc ex e (realpath $argv)
end

function nvcd
    realpath $argv |read p
    nvc ex cd $p
end

function to
    if test -z "$TMUX"
        nvim $argv
        return
    end

    if test -d $argv
        read -P'It\'s directory. Sure? ' a
        and test "$a" = 'y'
        or return
    end

    tmux list-panes -s -F'#{window_id} #{pane_id} #{pane_start_command}' | grep 'nvim '(realpath $argv) | read wid pid _
    and tmux copy-mode\; select-window -t"$wid"\; select-pane -t"$pid"
    or tmux copy-mode\; new-window nvim (realpath $argv)
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

function gdb
    command gdb -nh -x $XDG_CONFIG_HOME/gdb/init $argv
end

function fish_prompt
    set last_status $status

    test $last_status = 0
    and set_color cyan
    or set_color yellow

    echo -n -s ' ❯'(set_color cyan)'❯ '(set_color normal)
end

# Configurations for plugins

# async-prompt
set -g async_prompt_inherit_variables
set -g async_prompt_functions fish_right_prompt
