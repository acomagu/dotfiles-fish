function _add_path
    for path in $argv
        if test -d $path
            set -x PATH $path $PATH
        end
    end
end

_add_path /home/linuxbrew/.linuxbrew/bin
if type -q brew
    set HOMEBREW_ROOT (brew --prefix)
    _add_path $HOMEBREW_ROOT/opt/coreutils/libexec/gnubin
    _add_path $HOMEBREW_ROOT/opt/findutils/libexec/gnubin
    _add_path $HOMEBREW_ROOT/opt/gnu-sed/libexec/gnubin
    set -x HOMEBREW_VERBOSE 1
    set -x LD_LIBRARY_PATH "/usr/lib/x86_64-linux-gnu:/usr/local/lib:$HOMEBREW_ROOT/lib"
    set -x PKG_CONFIG_PATH "$PKG_CONFIG_PATH:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig:/usr/lib/pkgconfig:$HOMEBREW_ROOT/lib/pkgconfig:$HOMEBREW_ROOT/share/pkgconfig"
    set -x CFLAGS "$CFLAGS -I$HOMEBREW_ROOT/include"
    set -x CPATH "$CPATH $HOMEBREW_ROOT/include"
    set -x LDFLAGS "$LDFLAGS -L$HOMEBREW_ROOT/lib"
    set -x LIBRARY_PATH "$LIBRARY_PATH $HOMEBREW_ROOT/lib"
    set -x NVM_DIR (readlink -e $HOMEBREW_ROOT/opt/nvm)
end

set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_DESKTOP_DIR $HOME/desktop
set -x XDG_DOCUMENTS_DIR $HOME/desktop
set -x XDG_DOWNLOAD_DIR $HOME/desktop
set -x XDG_MUSIC_DIR $HOME/desktop
set -x XDG_PICTURES_DIR $HOME/desktop
set -x XDG_PUBLICSHARE_DIR $HOME/desktop
set -x XDG_TEMPLATES_DIR $HOME/desktop
set -x XDG_VIDEOS_DIR $HOME/desktop

set -x ANDROID_HOME $XDG_DATA_HOME/android-sdk
set -x ANDROID_SDK_HOME $XDG_DATA_HOME/android-sdk
set -x ANDROID_SDK_ROOT $XDG_DATA_HOME/android-sdk
set -x AWS_CONFIG_FILE $XDG_CONFIG_HOME/aws/config
set -x AWS_SHARED_CREDENTIALS_FILE $XDG_CONFIG_HOME/aws/credentials
set -x CARGO_HOME $XDG_DATA_HOME/cargo
set -x CDK_HOME $XDG_DATA_HOME/cdk
set -x GHQ_ROOT $HOME/.local/src
set -x GNUPGHOME $XDG_DATA_HOME/gnupg
set -x GOPATH $HOME/.local
set -x GOPROXY https://proxy.golang.org
set -x GRADLE_USER_HOME $XDG_DATA_HOME/gradle
set -x LESSHISTFILE $XDG_DATA_HOME/less/history
set -x LESSKEY $XDG_DATA_HOME/less/keys
set -x MAKEFLAGS -j (nproc)
set -x MKSHELL rc
set -x MOZ_USE_XINPUT2 1
set -x MPLAYER_HOME $XDG_CONFIG_HOME/mplayer
set -x MYPYPATH $XDG_DATA_HOME/mypy
set -x NODE_PATH $XDG_DATA_HOME/npm/lib/node_modules
set -x NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/npmrc
set -x NVM_PATH $XDG_DATA_HOME/nvm
set -x QT_LOGGING_RULES '*.debug=false;qt.qpa.*=false'
set -x RBENV_ROOT $XDG_DATA_HOME/rbenv
set -x RUSTUP_HOME $XDG_DATA_HOME/rustup
set -x STEAM_LIBRARY_PATH $XDG_DATA_HOME/Steam
set -x VST_PATH $VST_PATH:$XDG_DATA_HOME/vst
set -x WINEPREFIX $XDG_DATA_HOME/wine
set -x Z_DATA $XDG_DATA_HOME/z/history

set -l appengine_paths $HOME/.local/opt/google-cloud-sdk /usr/lib/google-cloud-sdk

_add_path $HOME/.local/bin
_add_path $ANDROID_SDK_HOME/platform-tools
_add_path $HOME/.local/opt/android-studio/bin
_add_path $XDG_DATA_HOME/npm/bin
_add_path $CARGO_HOME/bin
_add_path $appengine_paths/bin
_add_path $appengine_paths/platform/google_appengine

bind \cd delete-char

if type -q rbenv
    rbenv init - | source
end

if type -q salias
    salias __init__ | source
end

# Disable package suggestion.
function fish_command_not_found
    __fish_default_command_not_found_handler $argv
end

function ngrok
    command ngrok $argv -config $XDG_CONFIG_HOME/ngrok2/ngrok.yml
end

function _is_git_repo
    git rev-parse --is-inside-work-tree >/dev/null ^/dev/null
end

function search
    if _is_git_repo
        git ls-files --exclude-standard -o -c | xargs ls -d ^/dev/null
    else
        find . -type f
    end | xargs grep --color $argv
end

if not functions -q _orig_cd
    functions -c cd _orig_cd
end

function cd
    if count $argv >/dev/null
        if test -e $argv || test $argv = -
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

function _is_git_repo
    git rev-parse --is-inside-work-tree >/dev/null ^/dev/null
end

function _is_git_dirty
    set -l stat (git status --porcelain=v2)
    test -n "$stat"
end

function _git_branch_name
    git symbolic-ref --short HEAD ^/dev/null
end

function _fish_right_prompt_branch_name
    if _is_git_repo
        _is_git_dirty
            and set color (set_color bryellow)
            or set color (set_color 88f)

        echo -n "$color"(_git_branch_name)
    end
end

function _fish_right_prompt_repo_info
    echo -n ' '(set_color cyan)(prompt_pwd)
end

function fish_right_prompt
    _fish_right_prompt_branch_name
    _fish_right_prompt_repo_info
end

function gcd
    ghq list | fzf | read -l p
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
set -g async_prompt_functions fish_right_prompt

function fish_right_prompt_loading_indicator -a last_prompt
    echo -n "$last_prompt" | sed -r 's/[[:cntrl:]]\[[0-9]{1,3}m//g' | read -zl uncolored_last_prompt
    echo -n (set_color brblack)"$uncolored_last_prompt"(set_color normal)
end

function _fish_right_prompt_repo_info_loading_indicator
    echo (set_color '#aaa')' … '(set_color normal)
end

function git
    if test -z "$argv"
        command git
        return
    end

    switch $argv[1]
        case push
            set -l ghuser acomagu
            if test -z (git remote)
                and git rev-parse --show-toplevel | sed 's|^'(ghq root)"/github.com/$ghuser/\(.*\)\$|\1|" | read -l dirname
                and read -P"Set git@github.com:$ghuser/$dirname as origin remote branch? [Y/n]: " -l ans
                and contains "$ans" y Y ''

                command git remote add origin git@github.com:$ghuser/$dirname
            end

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
        case add
            command git $argv
            and command git status
        case chb
            git branch --sort=-committerdate --color | fzf --reverse --ansi | awk '{ print $NF }' | xargs git checkout
        case '*'
            command git $argv
    end
end

function yay
    if test -z "$argv"
        command yay --sudoloop -Syu
    end
    command yay --sudoloop $argv
end

function genid
    echo 'abcdefghijklmnopqrstuvwxyz1234567890' | string split '' | shuf | head -n3 | string join ''
end

function hugo
    set -l cmd $argv[1]
    switch "$cmd"
        case new
            set -l cmd $argv[2]
            switch "$cmd"
                case image
                    set -l id $argv[3]
                    set -l path $argv[4]
                    set -l ext (echo $path | awk -F. '{ print $NF }')
                    set -l fname (genid).$ext
                    mkdir -p static/assets/$id
                    and cp $path static/assets/$id/$fname
                    and echo "![](/assets/$id/$fname)"
                    return
            end
    end

    command hugo $argv
end

function goinstall
    if test $GO111MODULE != on
        echo 'GO111MODULE is not on' >&2
        return 1
    end

    set -l mod
    if test (count $argv) -ge 1
        set mod $argv
    else
        set mod (pwd | sed -n 's|.*\(github.com/[^/]\+/[^/]\+\).*|\1|p')
    end
    if test (count $mod) -ne 1
        echo "Could not determine the module name: $mod" >&2
        return 1
    end

    set -l prodrt "$GHQ_ROOT/$mod"
    test -e $prodrt/go.mod || echo "module $mod" > $prodrt/go.mod
    echo "
        cd $prodrt
        go install
    " | fish
end

function goget
    ghq get -p --shallow https://$argv
    goinstall $argv
end

function encode-uri
    if test -z "$argv"
        cat
    else
        echo $argv
    end | perl -MURI::Escape -le '
        my $in = <STDIN>;
        chomp($in);
        print uri_escape($in);
    '
end

function youtube-dl
    command youtube-dl --no-mtime $argv
end

function diff
    git diff --no-index $argv
end

function sshfs
    command sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=1 $argv
end

function switch-insomnia-conf
    set -l confs $XDG_CONFIG_HOME/Insomnia-*
    string join \n $confs | fzf --height=10 | read -l selection
    test -z "$selection"
    and return 1

    rm -rf "$XDG_CONFIG_HOME/Insomnia"
    cp -r "$selection" "$XDG_CONFIG_HOME/Insomnia"
end
