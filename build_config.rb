MRuby::Build.new do |conf|
  # load specific toolchain settings

  # Gets set by the VS command prompts.
  toolchain :clang
  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  enable_debug

  # Use mrbgems
  # conf.gem 'examples/mrbgems/ruby_extension_example'
  # conf.gem 'examples/mrbgems/c_extension_example' do |g|
  #   g.cc.flags << '-g' # append cflags in this gem
  # end
  # conf.gem 'examples/mrbgems/c_and_ruby_extension_example'
  # conf.gem :core => 'mruby-eval'
  # conf.gem :mgem => 'mruby-io'
  # conf.gem :github => 'iij/mruby-io'
  # conf.gem :git => 'git@github.com:iij/mruby-io.git', :branch => 'master', :options => '-v'

  # include the default GEMs
  conf.gembox 'default'
  # C compiler settings
  # conf.cc do |cc|
  #   cc.command = ENV['CC'] || 'gcc'
  #   cc.flags = [ENV['CFLAGS'] || %w()]
  #   cc.include_paths = ["#{root}/include"]
  #   cc.defines = %w(DISABLE_GEMS)
  #   cc.option_include_path = '-I%s'
  #   cc.option_define = '-D%s'
  #   cc.compile_options = "%{flags} -MMD -o %{outfile} -c %{infile}"
  # end

  # mrbc settings
  # conf.mrbc do |mrbc|
  #   mrbc.compile_options = "-g -B%{funcname} -o-" # The -g option is required for line numbers
  # end

  # Linker settings
  # conf.linker do |linker|
  #   linker.command = ENV['LD'] || 'gcc'
  #   linker.flags = [ENV['LDFLAGS'] || []]
  #   linker.flags_before_libraries = []
  #   linker.libraries = %w()
  #   linker.flags_after_libraries = []
  #   linker.library_paths = []
  #   linker.option_library = '-l%s'
  #   linker.option_library_path = '-L%s'
  #   linker.link_options = "%{flags} -o %{outfile} %{objs} %{libs}"
  # end

  # Archiver settings
  # conf.archiver do |archiver|
  #   archiver.command = ENV['AR'] || 'ar'
  #   archiver.archive_options = 'rs %{outfile} %{objs}'
  # end

  # Parser generator settings
  # conf.yacc do |yacc|
  #   yacc.command = ENV['YACC'] || 'bison'
  #   yacc.compile_options = '-o %{outfile} %{infile}'
  # end

  # gperf settings
  # conf.gperf do |gperf|
  #   gperf.command = 'gperf'
  #   gperf.compile_options = '-L ANSI-C -C -p -j1 -i 1 -g -o -t -N mrb_reserved_word -k"1,3,$" %{infile} > %{outfile}'
  # end

  # file extensions
  # conf.exts do |exts|
  #   exts.object = '.o'
  #   exts.executable = '' # '.exe' if Windows
  #   exts.library = '.a'
  # end

  # file separetor
  # conf.file_separator = '/'

  # bintest
  # conf.enable_bintest
end

MRuby::Build.new('host-debug') do |conf|
  # load specific toolchain settings

  # Gets set by the VS command prompts.
  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  enable_debug

  # include the default GEMs
  conf.gembox 'default'

  # C compiler settings
  conf.cc.defines = %w(MRB_ENABLE_DEBUG_HOOK)

  # Generate mruby debugger command (require mruby-eval)
  conf.gem :core => "mruby-bin-debugger"

  # bintest
  # conf.enable_bintest
end

MRuby::Build.new('test') do |conf|
  # Gets set by the VS command prompts.
  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
    toolchain :visualcpp
  else
    toolchain :gcc
  end

  enable_debug
  conf.enable_bintest
  conf.enable_test

  conf.gembox 'default'
end

#MRuby::Build.new('bench') do |conf|
#  # Gets set by the VS command prompts.
#  if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR']
#    toolchain :visualcpp
#  else
#    toolchain :gcc
#    conf.cc.flags << '-O3'
#  end
#
#  conf.gembox 'default'
#end

# Define cross build settings
# MRuby::CrossBuild.new('32bit') do |conf|
#   toolchain :gcc
#
#   conf.cc.flags << "-m32"
#   conf.linker.flags << "-m32"
#
#   conf.build_mrbtest_lib_only
#
#   conf.gem 'examples/mrbgems/c_and_ruby_extension_example'
#
#   conf.test_runner.command = 'env'
# end

LIBTRANSISTOR_HOME = ENV["LIBTRANSISTOR_HOME"]
if LIBTRANSISTOR_HOME == nil then
  raise "set LIBTRANSISTOR_HOME in environment"
end

MRuby::CrossBuild.new("transistor") do |conf|
  toolchain :clang
  enable_debug

  conf.gembox "transistor"
  conf.gem "../mruby-transistor"
  conf.gem "../mruby-circuitbreaker"

  conf.cc do |cc|
    cc.command = "clang"
    cc.include_paths = ["#{LIBTRANSISTOR_HOME}/include/", "#{root}/include/"]
    cc.flags = "-g -fPIC -fexceptions -fuse-ld=lld -fstack-protector-strong -O3 -mtune=cortex-a53 -target aarch64-none-linux-gnu -nostdlib -nostdlibinc -D__SWITCH__=1 -Wno-unused-command-line-argument"
  end

  conf.cxx do |cxx|
    cxx.command = "clang++"
    cxx.include_paths = ["#{LIBTRANSISTOR_HOME}/include/", "#{root}/include/", "#{LIBTRANSISTOR_HOME}/include/c++/v1/"]
    cxx.flags = "-g -fPIC -fexceptions -fuse-ld=lld -fstack-protector-strong -O3 -mtune=cortex-a53 -target aarch64-none-linux-gnu -nostdlib -nostdlibinc -D__SWITCH__=1 -Wno-unused-command-line-argument -std=c++17 -stdlib=libc++ -nodefaultlibs -nostdinc++"
  end

  class << conf.cc
    def header_search_paths
      include_paths
    end
  end

  class << conf.cxx
    def header_search_paths
      include_paths
    end
  end

  conf.linker do |linker|
    linker.command = "ld.lld"
    linker.flags = "-Bsymbolic --shared --no-undefined --no-gc-sections --eh-frame-hdr -T #{LIBTRANSISTOR_HOME}/link.T -L #{LIBTRANSISTOR_HOME}/lib/"
    linker.flags_before_libraries = "--whole-archive -ltransistor.nro --no-whole-archive"
    linker.libraries = ["c", "m", "clang_rt.builtins-aarch64", "pthread", "lzma", "c++", "c++abi", "unwind"]
  end

  conf.exts do |exts|
    exts.executable = ".nro.so"
  end
end
