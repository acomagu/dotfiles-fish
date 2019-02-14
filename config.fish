function _add_path
    if test -d $argv
        set -x PATH $argv $PATH
    end
end

_add_path /home/linuxbrew/.linuxbrew/bin
if type -q brew
    set HOMEBREW_ROOT (brew --prefix)
    _add_path $HOMEBREW_ROOT/opt/coreutils/libexec/gnubin
    set -x HOMEBREW_VERBOSE 1
    set -x LD_LIBRARY_PATH "/usr/lib/x86_64-linux-gnu:/usr/local/lib:$HOMEBREW_ROOT/lib"
    set -x PKG_CONFIG_PATH "$PKG_CONFIG_PATH:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig:/usr/lib/pkgconfig:$HOMEBREW_ROOT/lib/pkgconfig:$HOMEBREW_ROOT/share/pkgconfig"
    set -x CFLAGS "$CFLAGS -I$HOMEBREW_ROOT/include"
    set -x CPATH "$CPATH $HOMEBREW_ROOT/include"
    set -x LDFLAGS "$LDFLAGS -L$HOMEBREW_ROOT/lib"
    set -x LIBRARY_PATH "$LIBRARY_PATH $HOMEBREW_ROOT/lib"
    set -x NVM_DIR (readlink -e $HOMEBREW_ROOT/opt/nvm)
end

set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_DESKTOP_DIR $HOME/desktop
set -x XDG_DOCUMENTS_DIR $HOME/desktop
set -x XDG_DOWNLOAD_DIR $HOME/desktop
set -x XDG_MUSIC_DIR $HOME/desktop
set -x XDG_PICTURES_DIR $HOME/desktop
set -x XDG_PUBLICSHARE_DIR $HOME/desktop
set -x XDG_TEMPLATES_DIR $HOME/desktop
set -x XDG_VIDEOS_DIR $HOME/desktop
set -x GOPATH $HOME/.local
set -x GHQ_ROOT $GOPATH/src
set -x RBENV_ROOT $XDG_DATA_HOME/rbenv
set -x Z_DATA $XDG_DATA_HOME/z/history
set -x ANDROID_SDK_ROOT $XDG_DATA_HOME/android-sdk
set -x ANDROID_SDK_HOME $XDG_DATA_HOME/android-sdk
set -x ANDROID_HOME $XDG_DATA_HOME/android-sdk
set -x GRADLE_USER_HOME $XDG_DATA_HOME/gradle
set -x NODE_PATH $XDG_DATA_HOME/npm/lib/node_modules
set -x NVM_PATH $XDG_DATA_HOME/nvm
set -x NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/npmrc
set -x RUSTUP_HOME $XDG_DATA_HOME/rustup
set -x CARGO_HOME $XDG_DATA_HOME/cargo
set -x MYPYPATH $XDG_DATA_HOME/mypy
set -x AWS_SHARED_CREDENTIALS_FILE $XDG_CONFIG_HOME/aws/credentials
set -x AWS_CONFIG_FILE $XDG_CONFIG_HOME/aws/config
set -x WINEPREFIX $XDG_DATA_HOME/wine
set -x VST_PATH $VST_PATH:$XDG_DATA_HOME/vst
set -x LESSHISTFILE $XDG_DATA_HOME/less/history
set -x LESSKEY $XDG_DATA_HOME/less/keys
set -x GNUPGHOME $XDG_DATA_HOME/gnupg
set -x MPLAYER_HOME $XDG_CONFIG_HOME/mplayer

_add_path $HOME/.local/bin
_add_path $ANDROID_SDK_HOME/platform-tools
_add_path $HOME/.local/opt/android-studio/bin
_add_path $XDG_DATA_HOME/npm/bin
_add_path $CARGO_HOME/bin
_add_path /usr/lib/google-cloud-sdk/platform/google_appengine

if type -q rbenv
    rbenv init - | source
end

if type -q salias
    salias __init__ | source
end

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
            echo $argv
        else
            z -l $argv 2>&1 | begin
                read -l line
                and if string match -q -r '^common:' "$line"
                    read -l line
                    and echo $line
                else
                    echo $line
                    cat
                end
            end | awk '{ print $2 }'
        end
    else
        echo $HOME
        z -l | awk '{ print $2 }'
    end | sed '/^$/d' | fzf -1 | read -l p
    and _orig_cd $p
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

function git
    if test -z "$argv"
        command git
        return
    end

    switch $argv[1]
        case push
            set -l head
            if not string join \n -- $argv | sed 1d | grep -E '^[^-]' >/dev/null
                and command git status -b --porcelain=v2 | grep -E 'upstream|head' | cut -d' ' -f3 | begin
                    read head
                    and not read -l upstream
                end
                and command git remote get-url origin >/dev/null
                and read -P"Set origin/$head as the upstream branch? [Y/n]: " -l ans
                and contains "$ans" y Y ''

                command git $argv -u origin $head
            else
                command git $argv
            end
        case '*'
            command git $argv
    end
end
