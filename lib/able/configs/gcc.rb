module Able

  ##
  # Rule set for GNU GCC and Binutils
  #
  module GCC
   
    def depfile_name target
      target.chomp(@out_part) + '.d'
    end

    def more_deps infiles, outfile
      File.read(depfile_name outfile).scan(/^[[:print:]]*\:$/).map { |path| path.chop }
    rescue
    end

    def ar infiles, outfile
      arflags = '' + String(ENV['ARFLAGS']) + String(@arflags)
      ar = @ar || ENV['AR'] || 'ar'
      sh ar, arflags, 'cr', outfile, *infiles
    end

    def assemble infiles, outfile, more_flags = ''
      asflags = '' + String(ENV['ASFLAGS']) + Strinf(@asflags)
      as = @as || ENV['AS'] || 'gcc'
      sh as, asflags, *infiles, more_flags, '-o', outfile
    end
 
    def c_compile infiles, outfile, more_flags = ''
      depopts = "-MMD -MP -MF #{depfile_name outfile}"
      cflags = '' + String(ENV['CFLAGS']) + String(@cflags)
      cc = @cc || ENV['CC'] || 'gcc'
      sh cc, cflags, depopts, *infiles, more_flags, '-o', outfile
    end

    def cxx_compile infiles, outfile, more_flags = ''
      depopts = "-MMD -MP -MF #{depfile_name outfile}"
      cxxflags = '' + String(ENV['CXXFLAGS']) + String(@cxxflags)
      cxx = @cxx || ENV['CXX'] || 'g++'
      sh cxx, cxxflags, depopts, *infiles, more_flags, '-o', outfile
    end

    def link infiles, outfile, more_opts = ''
      ldflags = '' + String(ENV['LDFLAGS']) + String(@ldflags)
      ld = @ld || ENV['LD'] || 'g++'
      sh ld, ldflags, *infiles, more_opts, '-o', outfile
    end

    def link_so infiles, outfile
      link infiles, outfile, '-shared'
    end

  end

end
