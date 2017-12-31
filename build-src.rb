#Settings
CurrentVersion = "3.0.2"

def cmd(x)
    puts x
    ret = system(x)
    if(!ret)
        puts "ERROR: '#{x}' failed"
        exit
    end
end

def stage(x)
    puts "# #{x}"
end

def chdir(x)
    puts "Changing directory to #{x}"
    Dir.chdir(x)
end

def clean()
    dir = "zyn-fusion-ui-src-#{CurrentVersion}"
    cmd "rm -rf #{dir}"
    cmd "rm -f #{dir}.tar"
    cmd "rm -f #{dir}.tar.bz2"
end

def get_zest()
    dir = "zyn-fusion-ui-src-#{CurrentVersion}"
    stage "Getting Zest"
    #Clone the unreleased UI submodules
    cmd   "git clone --depth=1 https://github.com/mruby-zest/mruby-zest-build #{dir}"
    chdir "#{dir}"
    cmd   "git submodule update --init"
    cmd   "git archive-all --prefix #{dir} ../#{dir}.tar"
    chdir ".."
    cmd   "bzip2 #{dir}.tar"
end

clean()
get_zest()
